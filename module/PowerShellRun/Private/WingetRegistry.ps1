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
                [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'View details in winget.run')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy install command to Clipboard')
            )
            PreviewScript = {
                param ($item)
                $preview = @(
                    "$($PSStyle.Underline)Install:$($PSStyle.UnderlineOff)     winget install --exact --id $($item.Id)"
                    "$($PSStyle.Underline)Name:$($PSStyle.UnderlineOff)        $($item.Latest.Name)"
                    "$($PSStyle.Underline)Publisher:$($PSStyle.UnderlineOff)   $($item.Latest.Publisher)"
                    "$($PSStyle.Underline)Homepage:$($PSStyle.UnderlineOff)    $($item.Latest.Homepage)"
                    "$($PSStyle.Underline)Description:$($PSStyle.UnderlineOff) $($item.Latest.Description -replace '\. ', ".`n             ")"
                )
                $preview -join "`n" | Out-String
            }
        }
    }

    static [System.Collections.Generic.List[object]] SearchWinget([string] $Query) {
        try {
            $result = Invoke-WebRequest -Method 'GET' -Uri 'https://api.winget.run/v2/packages' -Body @{
                ensureContains = 'true'
                partialMatch = 'true'
                take = '10'
                query = [System.Web.HttpUtility]::UrlEncode($Query)
                order = '1'
            }

            # Response is not valid json, rename some duplicate properties and convert to json
            $result = $result.Content -creplace 'createdAt', '_createdAt' -replace 'updatedAt', '_updatedAt'
            $result = $result | ConvertFrom-Json -ErrorAction SilentlyContinue

            return $result.Packages
        } catch {
            # Need a way to indicate the registry failed to respond
            return @()
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
            $option.Prompt = "https://winget.run/ results for packages matching '$($result.Context.Query)'> "

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

            [WingetRegistry]::SearchWinget($result.Context.Query) | ForEach-Object {
                $addEntry.Invoke($_, $_.Latest.Name)
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
            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & winget install --id "$($item.Id)"
                break
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                Start-Process "https://example.com/$($item.Id)"
                break
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $item.ToString() | Set-Clipboard
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

