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