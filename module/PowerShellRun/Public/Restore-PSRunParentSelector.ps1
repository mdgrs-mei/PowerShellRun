function Restore-PSRunParentSelector {
    [CmdletBinding()]
    [Alias('Restore-PSRunFunctionParentSelector')]
    param()

    $script:globalStore.RequestParentSelectorRestore()
}
