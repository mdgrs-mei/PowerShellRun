using module ./_EntryRegistry.psm1
class FunctionRegistry : EntryRegistry {
    $functionsAtRegisterStart = $null
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryUpdated = $false
    $isEnabled = $false
    $callback
    $actionKeys

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        if ($this.isEnabled -and ($categories -contains 'Function')) {
            return $this.entries
        }
        return $null
    }

    [void] InitializeEntries([String[]]$categories) {
        $enabled = $categories -contains 'Function'
        if ($this.isEnabled -ne $enabled) {
            $this.isEntryUpdated = $true
        }
        $this.isEnabled = $enabled
    }

    FunctionRegistry() {
        $this.actionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Invoke function')
            [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Get definition')
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
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $function = Get-Command $functionName
                $function.Definition | Set-Clipboard
            }
        }
    }

    [void] StartRegistration($errorAction) {
        if (-not ($null -eq $this.functionsAtRegisterStart)) {
            Write-Error -Message 'Function registration already started.' -Category InvalidOperation -ErrorAction $errorAction
            return
        }
        $this.functionsAtRegisterStart = (Get-Command -Type Function).Name
    }

    [void] StopRegistration($errorAction) {
        if ($null -eq $this.functionsAtRegisterStart) {
            Write-Error -Message 'Function registration has not started yet.' -Category InvalidOperation -ErrorAction $errorAction
            return
        }

        $functionsAtStop = Get-Command -Type Function
        foreach ($function in $functionsAtStop) {
            if ($function.Name -in $this.functionsAtRegisterStart) {
                continue
            }
            $this.isEntryUpdated = $true

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

            $this.entries.Add($entry)
        }

        $this.functionsAtRegisterStart = $null
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

