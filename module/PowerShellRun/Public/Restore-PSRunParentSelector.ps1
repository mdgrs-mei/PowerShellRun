<#
.SYNOPSIS
Requests a restoration of the parent selector menu from a function or ScriptBlock entry.

.DESCRIPTION
Requests a restoration of the parent selector menu from a function or ScriptBlock entry.
If a function or ScriptBlock returns after calling this function, the parent selector menu opens again with the previous context. This is used to create nested menus.

.INPUTS
None.

.OUTPUTS
None.
#>
function Restore-PSRunParentSelector {
    [CmdletBinding()]
    param()

    $script:globalStore.RequestParentSelectorRestore()
}
