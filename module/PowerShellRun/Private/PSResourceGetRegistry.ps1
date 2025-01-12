using module ./_EntryRegistry.psm1

[NoRunspaceAffinity()]
class PSResourceGetRegistry : EntryRegistry {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $subMenuEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryUpdated = $false

    PSResourceGetRegistry() {
    }

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        if ($categories -contains 'Utility') {
            return $this.entries
        }
        return $null
    }

    [void] InitializeEntries([String[]]$categories) {
        $enabled = $categories -contains 'Utility'
        $enabled = $enabled -and $this.IsPSResourceGetInstalled()

        if ($enabled) {
            $this.RegisterEntries()
        }
    }

    [bool] IsPSResourceGetInstalled() {
        $module = Get-Module -Name Microsoft.PowerShell.PSResourceGet -ListAvailable
        if (-not $module) {
            return $false
        }
        return $true
    }

    [void] RegisterEntries() {
        $callback = {
            $thisClass = $args[0].ArgumentList

            $option = $script:globalStore.GetPSRunSelectorOption()
            $option.Prompt = 'PSResourceGet (PSRun)'
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
        $topEntry.Name = 'PSResourceGet (PSRun)'
        $topEntry.Description = 'Install and manage PowerShell modules using PSResourceGet'
        $topEntry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open PSResourceGet menu')
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

    [PowerShellRun.SelectorEntry] CreatePSResourceEntry($resource, $scope) {
        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($resource.Type -eq 'Module') {
            '📦'
        } elseif ($resource.Type -eq 'Script') {
            '📝'
        }
        $entry.Name = $resource.Name

        $repoString = "[$($resource.Repository)]".PadRight('[PSGallery]'.Length + 2)
        $versionString = "[$($resource.Version)]".PadRight('[10.10.100]'.Length)
        if ($scope) {
            $scopeString = "[$scope]".PadRight('[CurrentUser]'.Length)
            $entry.Description = '{0} {1} {2}' -f $scopeString, $repoString, $versionString
            $entry.UserData = [PSCustomObject]@{
                Resource = $resource
                Scope = $scope
            }
        } else {
            $entry.Description = '{0} {1}' -f $repoString, $versionString
            $entry.UserData = $resource
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
                $option.Prompt = 'Type module name to search'
                $promptResult = Invoke-PSRunPrompt -Option $option -Context $promptContext
                $promptContext = $promptResult.Context

                if ([string]::IsNullOrEmpty($promptResult.Input)) {
                    return
                }

                Write-Host ('Searching modules [{0}]...' -f $promptResult.Input)
                $searchWord = '*{0}*' -f $promptResult.Input
                $resources = Find-PSResource -Name $searchWord
                if (-not $resources) {
                    Write-Warning -Message ('[{0}] No available PSResource found.' -f $promptResult.Input)
                    return
                }

                $actionKeys = @(
                    [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Install for CurrentUser')
                    [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Install for AllUsers')
                    [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy install command to Clipboard')
                )

                $option.Prompt = $originalPrompt
                $result = $resources | ForEach-Object {
                    $entry = $thisClass.CreatePSResourceEntry($_, $null)
                    $entry.ActionKeys = $actionKeys
                    $entry.ActionKeysMultiSelection = $actionKeys
                    $entry.PreviewAsyncScript = {
                        param ($resource)
                        $resource | Format-List | Out-String
                    }
                    $entry.PreviewAsyncScriptArgumentList = $_
                    $entry
                } | Invoke-PSRunSelectorCustom -Option $option -MultiSelection

                if ([PowerShellRun.ExitStatus]::Type -eq [PowerShellRun.ExitType]::QuitWithBackspaceOnEmptyQuery) {
                    continue
                }

                if ($result.MarkedEntries) {
                    $installResources = $result.MarkedEntries.UserData
                } else {
                    $installResources = $result.FocusedEntry.UserData
                }

                if (-not $installResources) {
                    return
                }

                if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                    $installResources | ForEach-Object {
                        Write-Host "Installing [$($_.Name)]..."
                        Install-PSResource $_ -Scope CurrentUser -PassThru
                    }
                } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                    $installResources | ForEach-Object {
                        Write-Host "Installing [$($_.Name)]..."
                        Install-PSResource $_ -Scope AllUsers -PassThru
                    }
                } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                    $command = @()
                    $installResources | ForEach-Object {
                        $command += 'Install-PSResource -Name {0} -Version {1}' -f $_.Name, $_.Version
                    }
                    $command | Set-Clipboard
                }
                return
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '🔽'
        $entry.Name = 'Install'
        $entry.Description = 'Search PowerShell modules by name and install them'
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

            Write-Host 'Searching upgradable modules...'
            $upgradableResourcesAllUsers = $thisClass.GetUpgradableResources('AllUsers')
            $upgradableResourcesCurrentUser = $thisClass.GetUpgradableResources('CurrentUser')

            if (($upgradableResourcesAllUsers.Count -eq 0) -and ($upgradableResourcesCurrentUser.Count -eq 0)) {
                Write-Warning -Message 'No upgradable module found.'
                return
            }

            $actionKeys = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Upgrade')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy upgrade command to Clipboard')
            )

            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
            $upgradableResourcesAllUsers | ForEach-Object {
                $entry = $thisClass.CreatePSResourceEntry($_.Resource, 'AllUsers')
                $entry.Description = $entry.Description + ' ← [Installed: {0}]' -f $_.InstalledVersion
                $entry.ActionKeys = $actionKeys
                $entry.ActionKeysMultiSelection = $actionKeys
                $entry.Preview = $_.Resource | Format-List | Out-String
                $entries.Add($entry)
            }
            $upgradableResourcesCurrentUser | ForEach-Object {
                $entry = $thisClass.CreatePSResourceEntry($_.Resource, 'CurrentUser')
                $entry.Description = $entry.Description + ' ← [Installed: {0}]' -f $_.InstalledVersion
                $entry.ActionKeys = $actionKeys
                $entry.ActionKeysMultiSelection = $actionKeys
                $entry.Preview = $_.Resource | Format-List | Out-String
                $entries.Add($entry)
            }
            $result = Invoke-PSRunSelectorCustom -Entry $entries -Option $option -MultiSelection

            if ($result.MarkedEntries) {
                $upgradeResources = $result.MarkedEntries.UserData
            } else {
                $upgradeResources = $result.FocusedEntry.UserData
            }

            if (-not $upgradeResources) {
                return
            }

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                $upgradeResources | ForEach-Object {
                    Write-Host "Upgrading [$($_.Resource.Name)] to [$($_.Resource.Version)]..."
                    Update-PSResource -Name $_.Resource.Name -Scope $_.Scope -PassThru
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $command = @()
                $upgradeResources | ForEach-Object {
                    $command += 'Update-PSResource -Name {0} -Scope {1}' -f $_.Resource.Name, $_.Scope
                }
                $command | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '💫'
        $entry.Name = 'Upgrade'
        $entry.Description = 'List upgradable modules and upgrade selected ones'
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

            $resourcesAllUsers = Get-InstalledPSResource -Scope AllUsers
            $resourcesCurrentUser = Get-InstalledPSResource -Scope CurrentUser
            if ((-not $resourcesAllUsers) -and (-not $resourcesCurrentUser)) {
                Write-Warning -Message 'No module found.'
                return
            }

            $actionKeys = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Uninstall')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy uninstall command to Clipboard')
            )

            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
            $resourcesAllUsers | ForEach-Object {
                $entry = $thisClass.CreatePSResourceEntry($_, 'AllUsers')
                $entry.ActionKeys = $actionKeys
                $entry.ActionKeysMultiSelection = $actionKeys
                $entry.Preview = $_ | Format-List | Out-String
                $entries.Add($entry)
            }
            $resourcesCurrentUser | ForEach-Object {
                $entry = $thisClass.CreatePSResourceEntry($_, 'CurrentUser')
                $entry.ActionKeys = $actionKeys
                $entry.ActionKeysMultiSelection = $actionKeys
                $entry.Preview = $_ | Format-List | Out-String
                $entries.Add($entry)
            }
            $result = Invoke-PSRunSelectorCustom -Entry $entries -Option $option -MultiSelection

            if ($result.MarkedEntries) {
                $uninstallResources = $result.MarkedEntries.UserData
            } else {
                $uninstallResources = $result.FocusedEntry.UserData
            }

            if (-not $uninstallResources) {
                return
            }

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                $uninstallResources | ForEach-Object {
                    Write-Host "Uninstalling [$($_.Resource.Name)]..."
                    Uninstall-PSResource $_.Resource -Scope $_.Scope
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $command = @()
                $uninstallResources | ForEach-Object {
                    $command += 'Uninstall-PSResource -Name {0} -Scope {1}' -f $_.Resource.Name, $_.Scope
                }
                $command | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '⛔'
        $entry.Name = 'Uninstall'
        $entry.Description = 'List installed modules and uninstall selected ones'
        $entry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open Uninstall menu')
        )
        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this
        }

        return $entry
    }

    [Object[]] GetUpgradableResources($scope) {
        $installedResourceVersions = @{}
        Get-InstalledPSResource -Scope $scope | ForEach-Object {
            if ($installedResourceVersions.ContainsKey($_.Name)) {
                if ($_.Version -gt $installedResourceVersions[$_.Name]) {
                    $installedResourceVersions[$_.Name] = $_.Version
                }
            } else {
                $installedResourceVersions[$_.Name] = $_.Version
            }
        }

        $upgradableResources = @()
        foreach ($resourceName in $installedResourceVersions.Keys) {
            Find-PSResource -Name $resourceName | ForEach-Object {
                if ($_.Version -gt $installedResourceVersions[$resourceName]) {
                    $upgradableResources += [PSCustomObject]@{
                        Resource = $_
                        InstalledVersion = $installedResourceVersions[$resourceName]
                    }
                }
            }
        }
        return $upgradableResources
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }
}

