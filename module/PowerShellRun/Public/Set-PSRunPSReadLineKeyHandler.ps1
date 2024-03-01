function Set-PSRunPSReadLineKeyHandler {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String[]]$Chord
    )

    process {
        $script:globalStore.ReplacePSConsoleHostReadLine()
        $script:globalStore.SetPSReadLineKeyHandler($Chord)
    }
}