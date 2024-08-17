<#
.SYNOPSIS
Initializes entries in the specified category.

.DESCRIPTION
Initializes entries in the specified category. You can specify one or more categories to enable.
By default, all categories are enabled.

.PARAMETER Category
Specifies a category or an array of categories to enable.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Enable-PSRunEntry -Category All

.EXAMPLE
Enable-PSRunEntry -Category Application, Function, Utility
#>
function Enable-PSRunEntry {
    [CmdletBinding()]
    param (
        [ValidateSet('All', 'Application', 'Executable', 'Function', 'Utility', 'Favorite', 'Script', 'EntryGroup')]
        [String[]]$Category = 'All'
    )

    if ($Category -contains 'All') {
        $Category = $script:globalStore.allCategoryNames
    }
    $script:globalStore.EnableEntries($Category)
}
