<#
.SYNOPSIS
Adds a script file as an entry.

.DESCRIPTION
Adds a script file as an entry that can be invoked on selection. The entry belongs to the 'Script' category.

.PARAMETER Path
The filepath of the script file.

.PARAMETER Icon
The icon string.

.PARAMETER Name
The name of the entry. The filename is used by default.

.PARAMETER Description
The description string. The filepath is used by default.

.PARAMETER Preview
The custom preview string. The content of the script file is used by default.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Add-PSRunScriptFile -Path D:\TestScriptFile.ps1

.EXAMPLE
Add-PSRunScriptFile -Path 'D:\PowerShellRun\Build.ps1' -Icon '🧪' -Name 'Build Script' -Description 'This script builds the project'
#>
function Add-PSRunScriptFile {
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
        $registry = $script:globalStore.GetRegistry('ScriptRegistry')
        $registry.AddScriptFile($Path, $Icon, $Name, $Description, $Preview)
    }
}
