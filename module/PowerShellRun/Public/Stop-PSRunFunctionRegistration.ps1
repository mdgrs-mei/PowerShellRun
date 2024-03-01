function Stop-PSRunFunctionRegistration {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    $script:globalStore.functionRegistry.StopRegistration()
}
