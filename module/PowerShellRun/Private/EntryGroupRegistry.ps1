using module ./_EntryGroup.psm1
using module ./_EntryRegistry.psm1

[NoRunspaceAffinity()]
class EntryGroupRegistry : EntryRegistry {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $normalGroups = [System.Collections.Generic.List[EntryGroup]]::new()
    $categoryGroups = [System.Collections.Generic.List[EntryGroup]]::new()
    $isEntryUpdated = $false
    $isEnabled = $false

    $actionKeys
    $callback
    $previewScript

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        if ($categories -contains 'EntryGroup') {
            return $this.entries
        }
        return $null
    }

    [void] InitializeEntries([String[]]$categories) {
        $this.isEnabled = $categories -contains 'EntryGroup'
    }

    [void] SetEntriesDirty() {
        $this.isEntryUpdated = $true
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        if ($updated) {
            #category groups are always updated by GlobalStore so only update normal groups here.
            foreach ($group in $this.normalGroups) {
                $group.UpdateEntries()
            }
        }

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

            if (-not $group.Entries.Count) {
                Write-Error -Message 'There is no entry.' -Category InvalidOperation
                return
            }

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                $option = $script:globalStore.GetPSRunSelectorOption()
                $option.QuitWithBackspaceOnEmptyQuery = $true
                $option.Prompt = "$($group.Name)"
                $prevContext = $null

                while ($true) {
                    $result = Invoke-PSRunSelectorCustom -Entry $group.Entries -Option $option -Context $prevContext
                    $prevContext = $result.Context

                    if ($result.FocusedEntry) {
                        $callback = $result.FocusedEntry.UserData.ScriptBlock
                        $argumentList = @{
                            Result = $result
                            ArgumentList = $result.FocusedEntry.UserData.ArgumentList
                        }
                        & $callback $argumentList

                        if ([PowerShellRun.ExitStatus]::Type -ne [PowerShellRun.ExitType]::QuitWithBackspaceOnEmptyQuery) {
                            break
                        }
                    } else {
                        break
                    }
                }
            }
        }

        $this.previewScript = {
            param($group)
            $group.Entries | ForEach-Object {
                $_.Icon + ' ' + $_.Name
            }
        }
    }

    [EntryGroup] AddEntryGroup($icon, $name, $description, $preview, [String[]]$categories, [EntryGroup]$parentGroup) {
        if (-not $this.isEnabled) {
            Write-Warning -Message '"EntryGroup" category is disabled.'
            return $null
        }

        $group = [EntryGroup]::new($this, $name, $categories)

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($icon) { $icon } else { '📂' }
        $entry.Name = $name
        $entry.Description = $description
        if ($preview) {
            $entry.Preview = $preview
        } else {
            $entry.PreviewAsyncScript = $this.previewScript
            $entry.PreviewAsyncScriptArgumentList = $group
        }
        $entry.ActionKeys = $this.actionKeys

        $entry.UserData = @{
            ScriptBlock = $this.callback
            ArgumentList = $group
        }

        if ($parentGroup) {
            $parentGroup.AddEntry($entry)
        } else {
            $this.entries.Add($entry)
            $this.SetEntriesDirty()
        }

        if ($categories) {
            $this.categoryGroups.Add($group)
        } else {
            $this.normalGroups.Add($group)
        }

        return $group
    }

    [System.Collections.Generic.List[EntryGroup]] GetCategoryGroups() {
        return $this.categoryGroups
    }
}

