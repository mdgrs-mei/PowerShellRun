function Restore-PSRunFunctionParentSelector {
    [CmdletBinding()]
    param()

    $script:globalStore.RequestParentSelectorRestore()
}