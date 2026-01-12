using module ./_EntryGroup.psm1
using module ./_EntryRegistry.psm1

[NoRunspaceAffinity()]
class ScriptRegistry : EntryRegistry {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryUpdated = $false
    $isEnabled = $false

    $scriptBlockActionKeys
    $scriptBlockCallback
    $scriptFileActionKeys
    $scriptFileCallback
    $scriptFilePreviewScript

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        if ($categories -contains 'Script') {
            return $this.entries
        }
        return $null
    }

    [void] InitializeEntries([String[]]$categories) {
        $this.isEnabled = $categories -contains 'Script'
    }

    ScriptRegistry() {
        $this.scriptBlockActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Invoke script')
            [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Get definition')
            [PowerShellRun.ActionKey]::new($script:globalStore.thirdActionKey, 'Invoke with arguments')
            [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy definition to Clipboard')
        )

        $this.scriptBlockCallback = {
            $result = $args[0].Result
            $scriptBlock, $argumentList = $args[0].ArgumentList

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                if ($null -eq $argumentList) {
                    & $scriptBlock
                } else {
                    & $scriptBlock @argumentList
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                $scriptBlock.ToString()
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                $astParameters = $scriptBlock.Ast.ParamBlock.Parameters
                $parameters = $script:globalStore.GetParameterList($astParameters)
                if ($null -ne $parameters) {
                    & $scriptBlock @parameters
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $scriptBlock.ToString() | Set-Clipboard
            }
        }

        $this.scriptFileActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Invoke script')
            [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Edit with default editor')
            [PowerShellRun.ActionKey]::new($script:globalStore.thirdActionKey, 'Open containing folder')
            [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy path to Clipboard')
        )

        $this.scriptFileCallback = {
            $result = $args[0].Result
            $filePath, $argumentList = $args[0].ArgumentList

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                if ($null -eq $argumentList) {
                    & $filePath
                } else {
                    & $filePath @argumentList
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                & $script:globalStore.defaultEditorScript $filePath
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                $script:globalStore.OpenContainingFolder($filePath)
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $filePath | Set-Clipboard
            }
        }

        $this.scriptFilePreviewScript = {
            param ($path)
            Get-Content $path
        }
    }

    [void] AddScriptBlock($scriptBlock, $argumentList, $icon, $name, $description, $preview, [EntryGroup]$entryGroup) {
        if (-not $this.isEnabled) {
            Write-Warning -Message '"Script" category is disabled.'
            return
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($icon) { $icon } else { '{}' }
        $entry.Name = $name
        $entry.Description = $description
        if ($preview) {
            $entry.Preview = $preview
        } else {
            $entry.Preview = '{' + $scriptBlock.ToString() + '}'
        }
        $entry.ActionKeys = $this.scriptBlockActionKeys

        $entry.UserData = @{
            ScriptBlock = $this.scriptBlockCallback
            ArgumentList = $scriptBlock, $argumentList
        }

        if ($entryGroup) {
            $entryGroup.AddEntry($entry)
        } else {
            $this.entries.Add($entry)
            $this.isEntryUpdated = $true
        }
    }

    [void] AddScriptFile($filePath, $argumentList, $icon, $name, $description, $preview, [EntryGroup]$entryGroup) {
        if (-not $this.isEnabled) {
            Write-Warning -Message '"Script" category is disabled.'
            return
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($icon) { $icon } else { '📘' }
        $entry.Name = if ($name) { $name } else { Split-Path $filePath -Leaf }
        $entry.Description = if ($description) { $description } else { $filePath }
        if ($preview) {
            $entry.Preview = $preview
        } else {
            $entry.PreviewAsyncScript = $this.scriptFilePreviewScript
            $entry.PreviewAsyncScriptArgumentList = $filePath
        }
        $entry.ActionKeys = $this.scriptFileActionKeys

        $entry.UserData = @{
            ScriptBlock = $this.scriptFileCallback
            ArgumentList = $filePath, $argumentList
        }

        if ($entryGroup) {
            $entryGroup.AddEntry($entry)
        } else {
            $this.entries.Add($entry)
            $this.isEntryUpdated = $true
        }
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }
}

