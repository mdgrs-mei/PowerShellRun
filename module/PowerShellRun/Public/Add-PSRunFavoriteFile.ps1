<#
.SYNOPSIS
Adds a favorite file.
#>
function Add-PSRunFavoriteFile {
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
        $fileSystemRegistry = $script:globalStore.GetRegistry('FileSystemRegistry')
        $fileSystemRegistry.AddFavoriteFile($Path, $Icon, $Name, $Description, $Preview)
    }
}
