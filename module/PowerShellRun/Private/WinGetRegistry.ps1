using module ./_EntryRegistry.psm1

[NoRunspaceAffinity()]
class WinGetRegistry : EntryRegistry {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $subMenuEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryUpdated = $false

    WinGetRegistry() {
    }

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        if ($categories -contains 'Utility') {
            return $this.entries
        }
        return $null
    }

    [void] InitializeEntries([String[]]$categories) {
        $enabled = $categories -contains 'Utility'
        $enabled = $enabled -and $this.IsWinGetInstalled()

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

            $option = $script:globalStore.GetPSRunSelectorOption()
            $option.Prompt = 'WinGet (PSRun)'
            $option.QuitWithBackspaceOnEmptyQuery = $true

            $context = $null
            while ($true) {
                $result = Invoke-PSRunSelectorCustom -Entry $thisClass.subMenuEntries -Option $option -Context $context
                $context = $result.Context

                $entry = $result.FocusedEntry
                if (-not $entry) {
                    return
                }

                if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                    & $entry.UserData.ScriptBlock $entry.UserData.ArgumentList
                }

                if ([PowerShellRun.ExitStatus]::Type -ne [PowerShellRun.ExitType]::QuitWithBackspaceOnEmptyQuery) {
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

        $this.subMenuEntries.Add($this.CreateInstallEntry())
        $this.subMenuEntries.Add($this.CreateUpgradeEntry())
        $this.subMenuEntries.Add($this.CreateUninstallEntry())

        $this.isEntryUpdated = $true
    }

    [PowerShellRun.SelectorEntry] CreatePackageEntry($package) {
        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.UserData = $package
        $entry.Icon = if ($package.Source -eq 'winget') {
            '📦'
        } elseif ($package.Source -eq 'msstore') {
            '🛒'
        } else {
            '🔧'
        }
        $entry.Name = $package.Name
        $entry.Description = if ($package.Source) {
            '[{0}] {1}' -f $package.Source, $package.Id
        } else {
            $package.Id
        }
        return $entry
    }

    [PowerShellRun.SelectorEntry] CreateInstallEntry() {

        $callback = {
            param ($thisClass)

            $option = $script:globalStore.GetPSRunSelectorOption()
            $option.QuitWithBackspaceOnEmptyQuery = $true
            $promptContext = $null
            $originalPrompt = $option.Prompt

            while ($true) {
                $option.Prompt = 'Type application name to search'
                $promptResult = Invoke-PSRunPrompt -Option $option -Context $promptContext
                $promptContext = $promptResult.Context

                if ([string]::IsNullOrEmpty($promptResult.Input)) {
                    return
                }

                Write-Host ('Searching packages [{0}]...' -f $promptResult.Input)
                $packages = Find-WinGetPackage -Query $promptResult.Input
                if (-not $packages) {
                    Write-Warning -Message ('[{0}] No available application found.' -f $promptResult.Input)
                    return
                }

                $actionKeys = @(
                    [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Install with winget')
                    [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Show information on the source')
                    [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy install command to Clipboard')
                )

                $option.Prompt = $originalPrompt
                $result = $packages | ForEach-Object {
                    $entry = $thisClass.CreatePackageEntry($_)
                    $entry.ActionKeys = $actionKeys
                    $entry.ActionKeysMultiSelection = $actionKeys
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

                if ([PowerShellRun.ExitStatus]::Type -eq [PowerShellRun.ExitType]::QuitWithBackspaceOnEmptyQuery) {
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
                } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                    $installPackages | ForEach-Object {
                        & winget show --id $_.Id
                    }
                } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                    $command = @()
                    $installPackages | ForEach-Object {
                        $command += 'winget install --id {0}' -f $_.Id
                    }
                    $command | Set-Clipboard
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

    [PowerShellRun.SelectorEntry] CreateUpgradeEntry() {

        $callback = {
            param ($thisClass)

            $option = $script:globalStore.GetPSRunSelectorOption()
            $option.QuitWithBackspaceOnEmptyQuery = $true

            Write-Host 'Searching upgradable packages...'
            $packages = Get-WinGetPackage | Where-Object { $_.IsUpdateAvailable }
            if (-not $packages) {
                Write-Warning -Message 'No upgradable application found.'
                return
            }

            $actionKeys = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Upgrade with winget')
                [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Show information on the source')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy upgrade command to Clipboard')
            )

            $result = $packages | ForEach-Object {
                $entry = $thisClass.CreatePackageEntry($_)
                $entry.ActionKeys = $actionKeys
                $entry.ActionKeysMultiSelection = $actionKeys
                $entry.Preview = $_ | Format-List | Out-String
                $entry
            } | Invoke-PSRunSelectorCustom -Option $option -MultiSelection

            if ($result.MarkedEntries) {
                $upgradePackages = $result.MarkedEntries.UserData
            } else {
                $upgradePackages = $result.FocusedEntry.UserData
            }

            if (-not $upgradePackages) {
                return
            }

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                $upgradePackages | ForEach-Object {
                    Update-WinGetPackage -Id $_.Id
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                $upgradePackages | ForEach-Object {
                    & winget show --id $_.Id
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $command = @()
                $upgradePackages | ForEach-Object {
                    $command += 'winget upgrade --id {0}' -f $_.Id
                }
                $command | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '💫'
        $entry.Name = 'Upgrade'
        $entry.Description = 'Open Upgrade menu'
        $entry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open Upgrade menu')
        )
        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this
        }

        return $entry
    }

    [PowerShellRun.SelectorEntry] CreateUninstallEntry() {

        $callback = {
            param ($thisClass)

            $option = $script:globalStore.GetPSRunSelectorOption()
            $option.QuitWithBackspaceOnEmptyQuery = $true

            Write-Host 'Searching installed packages...'
            $packages = Get-WinGetPackage
            if (-not $packages) {
                Write-Warning -Message 'No application found.'
                return
            }

            $actionKeysNoSource = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Uninstall with winget')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy uninstall command to Clipboard')
            )

            $actionKeysWithSource = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Uninstall with winget')
                [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Show information on the source')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy uninstall command to Clipboard')
            )

            $result = $packages | ForEach-Object {
                $entry = $thisClass.CreatePackageEntry($_)
                $entry.ActionKeys = if ($_.Source) {
                    $actionKeysWithSource
                } else {
                    $actionKeysNoSource
                }
                $entry.ActionKeysMultiSelection = $actionKeys
                $entry.Preview = $_ | Format-List | Out-String
                $entry
            } | Invoke-PSRunSelectorCustom -Option $option -MultiSelection

            if ($result.MarkedEntries) {
                $uninstallPackages = $result.MarkedEntries.UserData
            } else {
                $uninstallPackages = $result.FocusedEntry.UserData
            }

            if (-not $uninstallPackages) {
                return
            }

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                $uninstallPackages | ForEach-Object {
                    if ($thisClass.IsUninstallableWithVersion($_)) {
                        Uninstall-WinGetPackage -Id $_.Id -Version $_.InstalledVersion -Confirm
                    } else {
                        Uninstall-WinGetPackage -Id $_.Id -Confirm
                    }
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                $uninstallPackages | ForEach-Object {
                    & winget show --id $_.Id
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $command = @()
                $uninstallPackages | ForEach-Object {
                    if ($thisClass.IsUninstallableWithVersion($_)) {
                        $command += 'winget uninstall --id {0} --version {1}' -f $_.Id, $_.InstalledVersion
                    } else {
                        $command += 'winget uninstall --id {0}' -f $_.Id
                    }
                }
                $command | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '⛔'
        $entry.Name = 'Uninstall'
        $entry.Description = 'Open Uninstall menu'
        $entry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open Uninstall menu')
        )
        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this
        }

        return $entry
    }

    [bool] IsUninstallableWithVersion($package) {
        # side by side is still in preview as of winget v1.7.10861.
        return $false
        <#
        if (-not $package.InstalledVersion) {
            return $false
        }
        return $package.Source -eq 'winget'
        #>
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }
}

