function Set-PSRunPSReadLineKeyHandler {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Chord')]
        [String[]]$InvokePsRunChord,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]$PSReadLineHistoryChord
    )

    process {
        if ($InvokePsRunChord) {
            $script:globalStore.SetInvokePsRunChord($InvokePsRunChord)
        }

        if ($PSReadLineHistoryChord) {
            $script:globalStore.SetPSReadLineHistoryChord($PSReadLineHistoryChord)
        }
    }
}
