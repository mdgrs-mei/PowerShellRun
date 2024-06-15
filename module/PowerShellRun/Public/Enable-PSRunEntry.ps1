<#
.SYNOPSIS
Initializes PSRun entries.
#>
function Enable-PSRunEntry {
    [CmdletBinding()]
    param (
        [ValidateSet('All', 'Application', 'Executable', 'Function', 'Utility', 'Favorite', 'Script')]
        [String[]]$Category = 'All'
    )

    if ($Category -contains 'All') {
        $Category = 'Application', 'Executable', 'Function', 'Utility', 'Favorite', 'Script'
    }
    $script:globalStore.EnableEntries($Category)
}
