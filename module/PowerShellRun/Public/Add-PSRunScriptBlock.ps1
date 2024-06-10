<#
.SYNOPSIS
Adds a ScriptBlock as an entry.
#>
function Add-PSRunScriptBlock {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ScriptBlock]$ScriptBlock,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Icon,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$Name,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Description,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String[]]$Preview
    )

    process {
        $registry = $script:globalStore.GetRegistry('ScriptRegistry')
        $registry.AddScriptBlock($ScriptBlock, $Icon, $Name, $Description, $Preview)
    }
}
