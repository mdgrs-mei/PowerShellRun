class WingetRegistry {
    $wingetEntry = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()

    $isWingetEnabled = $false
    $isEntryUpdated = $false

    [ScriptBlock]$defaultEditorScript
    $wingetArguments

    WingetRegistry() {
        $this.defaultEditorScript = {
            param ($item)
            Write-Host 'Not configured'
        }

        $this.wingetArguments = @{
            This = $this
            ActionKeys = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Install with winget')
                [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'View package details in browser')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy install command to Clipboard')
            )
            PreviewScript = {
                param ($item)
                if ($item -is [scriptblock]) {
                    'No preview available.' | Out-String
                } else {
                    # Can't find an equivalent in the powershell module to get the package details
                    $keys = @('Version', 'Publisher', 'Publisher Url', 'Author', 'Homepage', 'Description', 'License')
                    $maxKeyLength = ($keys | Measure-Object -Maximum -Property Length).Maximum
                    $output = @("$($PSStyle.Underline)$('Source'.PadRight($maxKeyLength, ' '))$($PSStyle.UnderlineOff) $($item.Source)")
                    $output += (winget show --exact --id $($item.Id) | Out-String).Split("`n") | ForEach-Object {
                        $parts = $_.Split(':')
                        $label = $parts[0].Trim()
                        $value = $parts[1..$parts.Length] -join ':'
                        if ($keys -contains $label) {
                            "$($PSStyle.Underline)$($label.PadRight($maxKeyLength, ' '))$($PSStyle.UnderlineOff)$value"
                        }
                    }
                    if ([string]::IsNullOrEmpty($output)) {
                        "No information available for $($item.Id)" | Out-String
                    } else {
                        $output -join "`n" | Out-String
                    }
                }
            }
        }
    }

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries() {
        $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
        if ($this.isWingetEnabled) {
            $entries.AddRange($this.wingetEntry)
        }
        return $entries
    }

    [void] EnableEntries([String[]]$categories) {
        $this.isEntryUpdated = $true

        $this.isWingetEnabled = $categories -contains 'Installer'
        $this.wingetEntry.Clear()
        if ($this.isWingetEnabled) {
            $this.RegisterWingetEntry()
        }
    }

    [void] RegisterWingetEntry() {
        $callback = {
            $result = $args[0].Result
            $arguments = $args[0].ArgumentList

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $arguments.This.wingetLoop $result $arguments
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                "winget install '$($result | ConvertTo-Json)'" | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '🔍'
        $entry.Name = 'Search Winget (PSRun)'
        $entry.Description = 'Search available winget packages and install them.'
        $entry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Explore winget packages')
        )

        # Could be named better, this entry is always shown with a score of one to ensure you can choose to use it to trigger an action on what's in the psrun prompt
        $entry.AlwaysAvailable = $true

        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this.wingetArguments
        }

        $this.wingetEntry.Add($entry)
    }

    $wingetLoop = {
        param($result, $arguments)

        $option = $script:globalStore.psRunSelectorOption.DeepClone()
        $option.QuitWithBackspaceOnEmptyQuery = $true

        $distance = 0
        while ($true) {
            # Strip winget from the query if it was used as a prefix to trigger the search
            $query = $result.Context.Query -replace '^\s*winget\s+(.+)', '$1'

            $option.Prompt = "https://winget.run/ results for packages matching '$query'> "

            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
            $addEntry = {
                param($item, $name, $icon)
                $entry = [PowerShellRun.SelectorEntry]::new()
                $entry.UserData = $item
                $entry.Name = $name
                $entry.Icon = '📦'
                $entry.PreviewAsyncScript = $arguments.PreviewScript
                $entry.ActionKeys = $arguments.ActionKeys
                $entry.PreviewAsyncScriptArgumentList = $item
                $entries.Add($entry)
            }

            if (Get-Module 'Microsoft.WinGet.Client' -ListAvailable -ErrorAction SilentlyContinue) {
                if (-not [string]::IsNullOrWhiteSpace($query)) {
                    Find-WinGetPackage -Query $query | ForEach-Object {
                        $addEntry.Invoke($_, $_.Name)
                    }
                }
            } else {
                $addEntry.Invoke({
                        Install-Module -Name Microsoft.WinGet.Client -Scope CurrentUser
                        Restore-PSRunFunctionParentSelector
                    }, 'Install the Microsoft.WinGet.Client PowerShell module to use winget search.', '📦')
            }

            if ($entries.Count -eq 0) {
                $addEntry.Invoke({ Restore-PSRunFunctionParentSelector }, 'No results found.', '🔙')
            }

            $result = Invoke-PSRunSelectorCustom -Entry $entries -Option $option

            if ($result.KeyCombination -eq 'Backspace') {
                if ($distance -eq 0) {
                    Restore-PSRunFunctionParentSelector
                    break
                } else {
                    $distance--
                    continue
                }
            }

            if (-not $result.FocusedEntry) {
                break
            }

            $item = $result.FocusedEntry.UserData

            # For special cases register a scriptblock as the item userdata
            if ($item -is [scriptblock]) {
                $item.Invoke()
                break
            }

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & winget install --exact --id $item.Id
                break
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                if ($item.Source -eq 'winget') {
                    try {
                        # This logic will work for 99% of the packages it's not worth overcomplicating it for the edge cases
                        $publisher = [System.Web.HttpUtility]::UrlEncode($item.Id.Split('.')[0])
                        $package = [System.Web.HttpUtility]::UrlEncode($item.Id.Split('.')[1])
                        $url = [uri]('https://github.com/microsoft/winget-pkgs/tree/master/manifests/' + $publisher[0].ToString().ToLower() + '/' + $publisher + '/' + $package)
                        Start-Process $url.ToString()
                    } catch {
                        Write-Error "Failed to open the package $($item.Id) in GitHub. $_"
                    }
                } elseif ($item.Source -eq 'msstore') {
                    try {
                        $url = [uri]"https://www.microsoft.com/store/productid/$($item.Id)"
                        Start-Process $url.ToString()
                    } catch {
                        Write-Error "Failed to open the package $($item.Id) in Microsoft Store. $_"
                    }
                } else {
                    Write-Error "Unknown source $($item.Source), cannot open $(item.Id) in browser."
                }
                break
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                "winget install --exact --id $($item.Id)" | Set-Clipboard
                break
            } else {
                break
            }
        }
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }
}

