<#
.SYNOPSIS
Starts function registration to PowerShellRun.

.DESCRIPTION
Starts function registration to PowerShellRun.
The global functions defined after calling Start-PSRunFunctionRegistration are registered as function entries. You need to call Stop-PSRunFunctionRegistration at the end of function definitions.

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
function Start-PSRunFunctionRegistration {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    $functionRegistry = $script:globalStore.GetRegistry('FunctionRegistry')
    $functionRegistry.StartRegistration()
}
