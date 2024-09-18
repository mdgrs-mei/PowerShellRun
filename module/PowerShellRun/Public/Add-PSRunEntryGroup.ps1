<#
.SYNOPSIS
Adds an entry group.
#>
function Add-PSRunEntryGroup {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Icon,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]$Preview,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('Application', 'Executable', 'Function', 'Utility', 'Favorite', 'Script')]
        [String[]]$Category,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Object]$EntryGroup,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Switch]$PassThru
    )

    process {
        $registry = $script:globalStore.GetRegistry('EntryGroupRegistry')
        $group = $registry.AddEntryGroup($Icon, $Name, $Description, $Preview, $Category, $EntryGroup)

        if ($PassThru) {
            $group
        }
    }
}
