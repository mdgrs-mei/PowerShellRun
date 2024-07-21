<#
.SYNOPSIS
Adds a favorite folder as an entry that can be opened by the File Manager.

.DESCRIPTION
Adds a favorite folder as an entry that can be opened by the File Manager. The entry belongs to the 'Favorite' category.

.PARAMETER Path
The folder path.

.PARAMETER Icon
The icon string.

.PARAMETER Name
The name of the entry. The folder name is used by default.

.PARAMETER Description
The description string. The folder path is used by default.

.PARAMETER Preview
The custom preview string.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Add-PSRunFavoriteFolder -Path 'D:/PowerShellRun'

.EXAMPLE
Add-PSRunFavoriteFolder -Path 'D:/Download' -Icon '🌐'
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
        $fileSystemRegistry = $script:globalStore.GetRegistry('FileSystemRegistry')
        $fileSystemRegistry.AddFavoriteFolder($Path, $Icon, $Name, $Description, $Preview)
    }
}
