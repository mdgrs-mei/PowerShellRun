<#
.SYNOPSIS
Adds a ScriptBlock as an entry.

.DESCRIPTION
Adds a ScriptBlock as an entry that can be invoked on selection. The entry belongs to the 'Script' category.

.PARAMETER ScriptBlock
The ScriptBlock that is invoked on selection.

.PARAMETER Icon
The icon string.

.PARAMETER Name
The name of the entry.

.PARAMETER Description
The description string.

.PARAMETER Preview
The custom preview string. The definition of the ScriptBlock is used by default.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Add-PSRunScriptBlock -Name 'Hello ScriptBlock' -ScriptBlock { 'Hello' }

.EXAMPLE
Add-PSRunScriptBlock -Icon '🥏' -Name 'GitPullRebase' -Description 'git pull with rebase option' -ScriptBlock {
    git pull --rebase --prune
}
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
        [String[]]$Preview,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [Object]$EntryGroup
    )

    process {
        $registry = $script:globalStore.GetRegistry('ScriptRegistry')
        $registry.AddScriptBlock($ScriptBlock, $Icon, $Name, $Description, $Preview, $EntryGroup)
    }
}
