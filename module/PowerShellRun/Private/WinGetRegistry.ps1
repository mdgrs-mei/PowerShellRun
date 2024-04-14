using module ./_EntryRegistry.psm1
class WinGetRegistry : EntryRegistry {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $subMenuEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryUpdated = $false
    $isEnabled = $false
    $restoreParentMenu = $false

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
                    $entry.Name = $_.Name
                    $entry.Description = "[{0}]`t{1}" -f $_.Source, $_.Id
                    $entry.Preview = $_ | Format-List | Out-String
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

                $installPackages | ForEach-Object {
                    Install-WinGetPackage -Id $_.Id
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

