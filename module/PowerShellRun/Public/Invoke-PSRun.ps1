<#
.SYNOPSIS
Opens a launcher.

.DESCRIPTION
Opens a launcher that has entries enabled by Enable-PSRunEntry.

.PARAMETER InitialQuery
The initial query string inputted to the search bar.

.INPUTS
None.

.OUTPUTS
Returns the result of the selected entry.

.EXAMPLE
Invoke-PSRun
#>
function Invoke-PSRun {
    [CmdletBinding()]
    param (
        [PowerShellRun.SelectorOption]$Option = $script:globalStore.psRunSelectorOption,

        [String]$InitialQuery
    )

    $script:globalStore.UpdateEntries()
    if ($script:globalStore.entries.Count -eq 0) {
        Write-Error -Message 'There is no entry.' -Category InvalidOperation
        return
    }

    if ($Option -ne $script:globalStore.psRunSelectorOption) {
        Write-Warning -Message '"-Option" parameter of Invoke-PSRun is deprecated. Use Set-PSRunDefaultSelectorOption instead.'
    }

    if ($InitialQuery) {
        $prevContext = [PowerShellRun.SelectorContext]::new()
        $prevContext.Query = $InitialQuery
    } else {
        $prevContext = $null
    }

    while ($true) {
        $script:globalStore.ClearParentSelectorRestoreRequest()

        $mode = [PowerShellRun.SelectorMode]::SingleSelection
        $result = [PowerShellRun.Selector]::Open($script:globalStore.entries, $mode, $Option, $prevContext)
        $prevContext = $result.Context

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
