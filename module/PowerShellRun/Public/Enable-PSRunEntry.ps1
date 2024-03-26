<#
.SYNOPSIS
Initializes PSRun entries.
#>
function Enable-PSRunEntry {
    [CmdletBinding()]
    param (
        [ValidateSet('All', 'Application', 'Executable', 'Function', 'Utility', 'Favorite', 'Installer')]
        [String[]]$Category = 'All'
    )

    if ($Category -contains 'All') {
        $Category = 'Application', 'Executable', 'Function', 'Utility', 'Favorite', 'Installer'
    }
    $script:globalStore.EnableEntries($Category)
}
