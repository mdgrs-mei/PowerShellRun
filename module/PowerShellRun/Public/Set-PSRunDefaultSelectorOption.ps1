function Set-PSRunDefaultSelectorOption {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [PowerShellRun.SelectorOption]$Option
    )

    process {
        $script:globalStore.SetDefaultSelectorOption($Option)
    }
}
