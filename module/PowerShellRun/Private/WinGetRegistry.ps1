using module ./_EntryRegistry.psm1
class WinGetRegistry : EntryRegistry {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $subMenuEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryUpdated = $false
    $isEnabled = $false
    $restoreParentMenu = $false
    $installActionKeys

    WinGetRegistry() {
    }

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries() {
        if ($this.isEnabled) {
            return $this.entries
        }
        return $null
    }

    [void] EnableEntries([String[]]$categories) {
        $enabled = $categories -contains 'Utility'
        $enabled = $enabled -and $this.IsWinGetInstalled()

        if ($this.isEnabled -ne $enabled) {
            $this.isEntryUpdated = $true
        }
        $this.isEnabled = $enabled

        $this.entries.Clear()
        if ($enabled) {
            $this.RegisterEntries()
        }
    }

    [bool] IsWinGetInstalled() {
        $winGet = Get-Command -Name winget -Type Application -ErrorAction SilentlyContinue
        if (-not $winGet) {
            return $false
        }

        $winGetModule = Get-Module -Name Microsoft.WinGet.Client -ListAvailable
        if (-not $winGetModule) {
            return $false
        }
        return $true
    }

    [void] RegisterEntries() {
        $callback = {
            $thisClass = $args[0].ArgumentList

            $option = Get-PSRunDefaultSelectorOption
            $option.Prompt = 'WinGet (PSRun) > '
            $option.QuitWithBackspaceOnEmptyQuery = $true

            $context = $null
            while ($true) {
                $result = Invoke-PSRunSelectorCustom -Entry $thisClass.subMenuEntries -Option $option -Context $context
                $context = $result.Context

                if ($result.KeyCombination -eq 'Backspace') {
                    Restore-PSRunFunctionParentSelector
                    return
                }

                $entry = $result.FocusedEntry
                if (-not $entry) {
                    return
                }

                $thisClass.restoreParentMenu = $false
                if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                    & $entry.UserData.ScriptBlock $entry.UserData.ArgumentList
                }

                if (-not $thisClass.restoreParentMenu) {
                    return
                }
            }
        }

        $topEntry = [PowerShellRun.SelectorEntry]::new()
        $topEntry.Icon = '📦'
        $topEntry.Name = 'WinGet (PSRun)'
        $topEntry.Description = 'Install and manage applications using winget'
        $topEntry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open WinGet menu')
        )
        $topEntry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this
        }

        $this.entries.Add($topEntry)

        $this.subMenuEntries.Clear()
        $this.subMenuEntries.Add($this.CreateInstallEntry())
    }

    [PowerShellRun.SelectorEntry] CreateInstallEntry() {
        $this.installActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Install with winget')
            [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy install command to Clipboard')
        )

        $callback = {
            param ($thisClass)

            $option = Get-PSRunDefaultSelectorOption
            $option.QuitWithBackspaceOnEmptyQuery = $true
            $promptContext = $null

            while ($true) {
                $option.Prompt = 'Type application name to search > '
                $promptResult = Invoke-PSRunPrompt -Option $option -Context $promptContext
                $promptContext = $promptResult.Context

                if ($promptResult.KeyCombination -eq 'Backspace') {
                    $thisClass.restoreParentMenu = $true
                    return
                }
                if (-not $promptResult.Input) {
                    return
                }

                $option.Prompt = '> '
                $packages = Find-WinGetPackage -Query $promptResult.Input
                if (-not $packages) {
                    Write-Warning -Message ('[{0}] No available application found.' -f $promptResult.Input)
                    return
                }

                $result = $packages | ForEach-Object {
                    $entry = [PowerShellRun.SelectorEntry]::new()
                    $entry.UserData = $_
                    $entry.Icon = if ($_.Source -eq 'winget') {
                        '📦'
                    } elseif ($_.Source -eq 'msstore') {
                        '🛒'
                    } else {
                        '🔧'
                    }
                    $entry.Name = $_.Name
                    $entry.Description = '[{0}] {1}' -f $_.Source, $_.Id
                    $entry.ActionKeys = $thisClass.installActionKeys
                    $entry.ActionKeysMultiSelection = $thisClass.installActionKeys
                    $entry.Preview = 'Loading...'
                    $entry.PreviewAsyncScript = {
                        param ($package)
                        $lines = & winget show --id $package.Id
                        $lines | Where-Object {
                            # winget produces empty lines and lines that only have '-' at the beginning. Remove them.
                            $trimmedLine = $_.Trim()
                            ($trimmedLine.Length -ne 0) -and ($trimmedLine[0] -ne '-')
                        }
                    }
                    $entry.PreviewAsyncScriptArgumentList = $_
                    $entry
                } | Invoke-PSRunSelectorCustom -Option $option -MultiSelection

                if ($result.KeyCombination -eq 'Backspace') {
                    continue
                }

                if ($result.MarkedEntries) {
                    $installPackages = $result.MarkedEntries.UserData
                } else {
                    $installPackages = $result.FocusedEntry.UserData
                }

                if (-not $installPackages) {
                    return
                }

                if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                    $installPackages | ForEach-Object {
                        Install-WinGetPackage -Id $_.Id
                    }
                } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                    $installCommand = @()
                    $installPackages | ForEach-Object {
                        $installCommand += 'winget install --id {0}' -f $_.Id
                    }
                    $installCommand | Set-Clipboard
                }
                return
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '🔽'
        $entry.Name = 'Install'
        $entry.Description = 'Open Install menu'
        $entry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open Install menu')
        )
        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this
        }

        return $entry
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }
}

