using module ./_EntryGroup.psm1
using module ./_EntryRegistry.psm1

class EntryGroupRegistry : EntryRegistry {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $categoryGroups = [System.Collections.Generic.List[EntryGroup]]::new()
    $isEntryUpdated = $false
    $isEnabled = $false

    $actionKeys
    $callback

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        if ($this.isEnabled -and ($categories -contains 'EntryGroup')) {
            return $this.entries
        }
        return $null
    }

    [void] EnableEntries([String[]]$categories) {
        $enabled = $categories -contains 'EntryGroup'
        if ($this.isEnabled -ne $enabled) {
            $this.isEntryUpdated = $true
        }
        $this.isEnabled = $enabled
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }

    EntryGroupRegistry() {
        $this.actionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open group')
        )

        $this.callback = {
            $result = $args[0].Result
            $group = $args[0].ArgumentList

            if (-not $group.ChildEntries.Count) {
                Write-Error -Message 'There is no entry.' -Category InvalidOperation
                return
            }

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                $option = $script:globalStore.psRunSelectorOption.DeepClone()
                $option.QuitWithBackspaceOnEmptyQuery = $true
                $option.Prompt = "$($group.Name)> "
                $prevContext = $null

                while ($true) {
                    $script:globalStore.ClearParentSelectorRestoreRequest()

                    $result = Invoke-PSRunSelectorCustom -Entry $group.ChildEntries -Option $option -Context $prevContext
                    $prevContext = $result.Context

                    if ($result.KeyCombination -eq 'Backspace') {
                        Restore-PSRunParentSelector
                        return
                    }

                    if ($result.FocusedEntry) {
                        $callback = $result.FocusedEntry.UserData.ScriptBlock
                        $argumentList = @{
                            Result = $result
                            ArgumentList = $result.FocusedEntry.UserData.ArgumentList
                        }
                        & $callback $argumentList
                    }

                    if (-not $script:globalStore.IsParentSelectorRestoreRequested()) {
                        break
                    }
                }
            }
        }
    }

    [EntryGroup] AddEntryGroup($icon, $name, $description, $preview, [String[]]$categories) {
        $group = [EntryGroup]::new($name, $categories)

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($icon) { $icon } else { '📂' }
        $entry.Name = $name
        $entry.Description = $description
        if ($preview) {
            $entry.Preview = $preview
        }
        $entry.ActionKeys = $this.actionKeys

        $entry.UserData = @{
            ScriptBlock = $this.callback
            ArgumentList = $group
        }

        $this.entries.Add($entry)
        $this.isEntryUpdated = $true

        if ($categories) {
            $this.categoryGroups.Add($group)
        }

        return $group
    }

    [System.Collections.Generic.List[EntryGroup]] GetCategoryGroups() {
        if ($this.isEnabled) {
            return $this.categoryGroups
        } else {
            return $null
        }
    }
}

