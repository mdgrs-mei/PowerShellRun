<#
.SYNOPSIS
Configures hotkeys for PowerShellRun features using PSReadLineKeyHandler.

.DESCRIPTION
Configures hotkeys for PowerShellRun features using PSReadLineKeyHandler.
The chord can be a string or an array of strings. The format of the chord follows the spec of Set-PSReadLineKeyHandler.

.PARAMETER InvokePsRunChord
The key to call Invoke-PSRun.

.PARAMETER PSReadLineHistoryChord
The key to open PSReadLineHistory viewer.

.PARAMETER TabCompletionChord
The key to open tab completion menu.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Set-PSRunPSReadLineKeyHandler -InvokePsRunChord 'Ctrl+Spacebar' -PSReadLineHistoryChord 'Ctrl+r'

.LINK
https://learn.microsoft.com/en-us/powershell/module/psreadline/set-psreadlinekeyhandler?view=powershell-7.4
#>
function Set-PSRunPSReadLineKeyHandler {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Alias('Chord')]
        [String[]]$InvokePsRunChord,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$InvokePsRunDescription = 'Call Invoke-PSRun (PowerShellRun)',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]$PSReadLineHistoryChord,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$PSReadLineHistoryDescription = 'Search PSReadLine history (PowerShellRun)',

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]$TabCompletionChord,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$TabCompletionDescription = 'Open Tab completion menu (PowerShellRun)'
    )

    process {
        if ($InvokePsRunChord) {
            $script:globalStore.SetInvokePsRunChord($InvokePsRunChord, $InvokePsRunDescription)
        }

        if ($PSReadLineHistoryChord) {
            $script:globalStore.SetPSReadLineHistoryChord($PSReadLineHistoryChord, $PSReadLineHistoryDescription)
        }

        if ($TabCompletionChord) {
            $script:globalStore.SetTabCompletionChord($TabCompletionChord, $TabCompletionDescription)
        }
    }
}
