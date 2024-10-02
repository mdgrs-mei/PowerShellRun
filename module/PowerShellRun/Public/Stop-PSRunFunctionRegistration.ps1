<#
.SYNOPSIS
Stops function registration to PowerShellRun.

.DESCRIPTION
Stops function registration to PowerShellRun.
The global functions defined after Start-PSRunFunctionRegistration and before Stop-PSRunFunctionRegistration are registered as function entries.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Start-PSRunFunctionRegistration

function global:GitPullRebase() {
    git pull --rebase
}

Stop-PSRunFunctionRegistration
#>
function Stop-PSRunFunctionRegistration {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    $functionRegistry = $script:globalStore.GetRegistry('FunctionRegistry')
    $functionRegistry.StopRegistration()
}
