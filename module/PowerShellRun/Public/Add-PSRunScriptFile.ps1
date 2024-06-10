<#
.SYNOPSIS
Adds a script file as an entry.
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
