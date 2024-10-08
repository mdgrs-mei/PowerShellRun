using module ./_EntryGroup.psm1
using module ./_EntryRegistry.psm1

[NoRunspaceAffinity()]
class FunctionRegistry : EntryRegistry {
    $functionsAtRegisterStart = $null
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryUpdated = $false
    $isEnabled = $false
    $callback
    $actionKeys

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        if ($categories -contains 'Function') {
            return $this.entries
        }
        return $null
    }

    [void] InitializeEntries([String[]]$categories) {
        $this.isEnabled = $categories -contains 'Function'
    }

    FunctionRegistry() {
        $this.actionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Invoke function')
            [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Get definition')
            [PowerShellRun.ActionKey]::new($script:globalStore.thirdActionKey, 'Invoke with arguments')
            [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy definition to Clipboard')
        )

        $this.callback = {
            $result = $args[0].Result
            $functionName = $args[0].ArgumentList

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $functionName
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                $function = Get-Command $functionName
                $function.Definition
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                $function = Get-Command $functionName
                $astParameters = if ($function.ScriptBlock.Ast.Parameters) {
                    $function.ScriptBlock.Ast.Parameters
                } else {
                    $function.ScriptBlock.Ast.Body.ParamBlock.Parameters
                }

                $parameters = $script:globalStore.GetParameterList($astParameters)
                if ($null -ne $parameters) {
                    & $functionName @parameters
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $function = Get-Command $functionName
                $function.Definition | Set-Clipboard
            }
        }
    }

    [void] StartRegistration() {
        if (-not ($null -eq $this.functionsAtRegisterStart)) {
            Write-Error -Message 'Function registration already started.' -Category InvalidOperation
            return
        }

        $this.functionsAtRegisterStart = @{}
        $functions = Get-Command -Type Function -ListImported
        $functions | ForEach-Object {
            $this.functionsAtRegisterStart[$_.Name] = $_.ScriptBlock
        }
    }

    [void] StopRegistration() {
        if ($null -eq $this.functionsAtRegisterStart) {
            Write-Error -Message 'Function registration has not started yet.' -Category InvalidOperation
            return
        }
        if (-not $this.isEnabled) {
            Write-Warning -Message '"Function" category is disabled.'
            $this.functionsAtRegisterStart = $null
            return
        }

        $functionsAtStop = Get-Command -Type Function -ListImported
        foreach ($function in $functionsAtStop) {
            $functionAtStart = $this.functionsAtRegisterStart[$function.Name]
            if ($functionAtStart -eq $function.ScriptBlock) {
                continue
            }
            $entry = $this.CreateFunctionEntry($function)
            $this.entries.Add($entry)
            $this.isEntryUpdated = $true
        }

        $this.functionsAtRegisterStart = $null
    }

    [void] AddFunction($functionName, $icon, $name, $description, $preview, [EntryGroup]$entryGroup) {
        if (-not $this.isEnabled) {
            Write-Warning -Message '"Function" category is disabled.'
            return
        }

        $function = Get-Command -Type Function -ListImported -Name $functionName -ErrorAction Ignore
        if (-not $function) {
            Write-Warning -Message "Function [$functionName] not found."
            return
        }

        $entry = $this.CreateFunctionEntry($function)
        if ($icon) { $entry.Icon = $icon }
        if ($name) { $entry.Name = $name }
        if ($description) { $entry.Description = $description }
        if ($preview) { $entry.Preview = $preview }

        if ($entryGroup) {
            $entryGroup.AddEntry($entry)
        } else {
            $this.entries.Add($entry)
            $this.isEntryUpdated = $true
        }
    }

    [PowerShellRun.SelectorEntry] CreateFunctionEntry($function) {
        $help = Get-Help $function.Name
        $customAttributes = $this.GetFunctionCustomAttributes($help)

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($customAttributes.Icon) { $customAttributes.Icon } else { '📝' }
        $entry.Name = if ($customAttributes.Name) { $customAttributes.Name } else { $function.Name }
        $entry.Preview = if ($customAttributes.Preview) { $customAttributes.Preview } else { '{' + $function.Definition + '}' }

        if ($customAttributes.Description) {
            $entry.Description = $customAttributes.Description
        } elseif ($help.Description) {
            $entry.Description = $help.Description.Text
        } elseif ($help.Synopsis) {
            $entry.Description = $help.Synopsis
        }

        $entry.ActionKeys = $this.actionKeys

        $entry.UserData = @{
            ScriptBlock = $this.callback
            ArgumentList = $function.Name
        }
        return $entry
    }

    [object] GetFunctionCustomAttributes($help) {
        $hasAttributes = $help.Component -match 'PSRun\(([\s\S]*)\)'
        if ($hasAttributes) {
            return ConvertFrom-StringData $Matches.1
        }
        return $null
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }
}

