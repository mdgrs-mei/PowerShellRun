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
        [String]$InitialQuery
    )

    $script:globalStore.UpdateEntries()
    if ($script:globalStore.entries.Count -eq 0) {
        Write-Error -Message 'There is no entry.' -Category InvalidOperation
        return
    }

    if ($InitialQuery) {
        $prevContext = [PowerShellRun.SelectorContext]::new()
        $prevContext.Query = $InitialQuery
    } else {
        $prevContext = $null
    }

    while ($true) {
        $mode = [PowerShellRun.SelectorMode]::SingleSelection
        $result = [PowerShellRun.Selector]::Open($script:globalStore.entries, $mode, $script:globalStore.psRunSelectorOption, $prevContext)
        $prevContext = $result.Context

        if ($result.FocusedEntry) {
            $callback = $result.FocusedEntry.UserData.ScriptBlock
            $argumentList = @{
                Result = $result
                ArgumentList = $result.FocusedEntry.UserData.ArgumentList
            }
            & $callback $argumentList

            if ([PowerShellRun.ExitStatus]::Type -eq [PowerShellRun.ExitType]::QuitWithBackspaceOnEmptyQuery) {
                continue
            }
        }

        if ([PowerShellRun.ExitStatus]::Type -eq [PowerShellRun.ExitType]::Restart) {
            $prevContext = $null
            continue
        }
        break
    }
}
