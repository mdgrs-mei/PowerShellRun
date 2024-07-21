<#
.SYNOPSIS
Sets KeyCombinations for PowerShellRun's action keys.

.DESCRIPTION
Sets KeyCombinations for PowerShellRun's action keys.
The launcher entries have their own actions and a KeyCombination is assigned to each action. PowerShellRun uses consistent key bindings across different types of entries, and this function allows customization of those assignments.
Generic action keys are named FirstActionKey, SecondActionKey and ThirdActionKey, starting from the primary key.
CopyActionKey is used to copy relevant information to the clip board if the entry type supports it.

.PARAMETER FirstActionKey
Specifies the first action key.

.PARAMETER SecondActionKey
Specifies the second action key.

.PARAMETER ThirdActionKey
Specifies the third action key.

.PARAMETER CopyActionKey
Specifies the copy action key. The copy action copies relevant information to the clip board depending on the entry type.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Set-PSRunActionKeyBinding -CopyActionKey 'Ctrl+h'

.EXAMPLE
Set-PSRunActionKeyBinding -FirstActionKey 'Ctrl+s' -SecondActionKey 'Ctrl+d' -ThirdActionKey 'Ctrl+f'
#>
function Set-PSRunActionKeyBinding {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PowerShellRun.KeyCombination]$FirstActionKey = $script:globalStore.firstActionKey,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PowerShellRun.KeyCombination]$SecondActionKey = $script:globalStore.secondActionKey,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PowerShellRun.KeyCombination]$ThirdActionKey = $script:globalStore.thirdActionKey,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [PowerShellRun.KeyCombination]$CopyActionKey = $script:globalStore.copyActionKey
    )

    process {
        $script:globalStore.SetActionKeys(
            $FirstActionKey,
            $SecondActionKey,
            $ThirdActionKey,
            $CopyActionKey)
    }
}
