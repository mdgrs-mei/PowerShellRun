<#
.SYNOPSIS
Initializes entries in the specified category.

.DESCRIPTION
Initializes entries in the specified category. You can specify one or more categories to enable.
By default, all categories are enabled.

.PARAMETER Category
Specifies a category or an array of categories to enable.

.INPUTS
The Category parameter.

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
        [Parameter(ValueFromPipeline = $true)]
        [ValidateSet('All', 'Application', 'Executable', 'Function', 'Utility', 'Favorite', 'Script', 'EntryGroup')]
        [String[]]$Category = 'All'
    )

    begin {
        if ($script:globalStore.IsEntriesInitialized()) {
            Write-Error -Message 'Entries already initialized. This function must be called only once.' -Category InvalidOperation
            return
        }

        $categories = [System.Collections.Generic.List[String]]::new()
    }
    process {
        if ($script:globalStore.IsEntriesInitialized()) {
            return
        }

        foreach ($c in $Category) {
            $categories.Add($c)
        }
    }
    end {
        if ($script:globalStore.IsEntriesInitialized()) {
            return
        }

        if ($categories -contains 'All') {
            $categories = $script:globalStore.allCategoryNames
        }
        $script:globalStore.InitializeEntries($categories)
    }
}
