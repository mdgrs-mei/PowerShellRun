function Get-PSRunDefaultSelectorOption {
    [CmdletBinding()]
    param ()

    $script:globalStore.defaultSelectorOption.DeepClone()
}
