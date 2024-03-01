<#
.SYNOPSIS
Adds a favorite folder.
#>
function Add-PSRunFavoriteFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Path,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Icon,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]$Preview
    )

    process {
        $script:globalStore.fileSystemRegistry.AddFavoriteFolder($Path, $Icon, $Name, $Description, $Preview)
    }
}
