function Start-PSRunFunctionRegistration {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    $functionRegistry = $script:globalStore.GetRegistry('FunctionRegistry')
    $functionRegistry.StartRegistration($ErrorActionPreference)
}
