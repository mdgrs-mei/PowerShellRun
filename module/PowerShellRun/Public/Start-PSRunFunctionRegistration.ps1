function Start-PSRunFunctionRegistration {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param()

    $script:globalStore.functionRegistry.StartRegistration()
}