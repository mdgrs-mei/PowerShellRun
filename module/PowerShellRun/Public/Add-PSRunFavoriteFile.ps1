<#
.SYNOPSIS
Adds a favorite file as an entry that can be opened by the File Manager.

.DESCRIPTION
Adds a favorite file as an entry that can be opened by the File Manager. The entry belongs to the 'Favorite' category.

.PARAMETER Path
The filepath.

.PARAMETER Icon
The icon string.

.PARAMETER Name
The name of the entry. The filename is used by default.

.PARAMETER Description
The description string. The filepath is used by default.

.PARAMETER Preview
The custom preview string.

.PARAMETER EntryGroup
The parent entry group object where this new entry is added.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Add-PSRunFavoriteFile -Path 'D:\test.bat'

.EXAMPLE
Add-PSRunFavoriteFile -Path 'D:\PowerShellRun\Build.ps1' -Icon '🧪' -Name 'Build Script' -Description 'This script builds the project'
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
        [String[]]$Preview,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Object]$EntryGroup
    )

    process {
        $fileSystemRegistry = $script:globalStore.GetRegistry('FileSystemRegistry')
        $fileSystemRegistry.AddFavoriteFile($Path, $Icon, $Name, $Description, $Preview, $EntryGroup)
    }
}
