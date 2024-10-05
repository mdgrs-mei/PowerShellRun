<#
.SYNOPSIS
Adds a function as an entry.

.DESCRIPTION
Adds a function as an entry that can be invoked on selection. The entry belongs to the 'Function' category.
The function must be global and defined before calling this function.

.PARAMETER FunctionName
The function name you would like to add as an entry.

.PARAMETER Icon
The icon string.

.PARAMETER Name
The name of the entry. The function name is used by default.

.PARAMETER Description
The description string. The function name is used by default.

.PARAMETER Preview
The custom preview string.

.PARAMETER EntryGroup
The parent entry group object where this new entry is added.

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
function global:TestFunction { 'Hello' }
Add-PSRunFunction -FunctionName TestFunction

.EXAMPLE
function global:TestFunction { 'Hello' }
Add-PSRunFunction -FunctionName TestFunction -Icon '🍏' -Name 'Test Function' -Description 'This is a test function.'
#>
function Add-PSRunFunction {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [String]$FunctionName,

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
        $registry = $script:globalStore.GetRegistry('FunctionRegistry')
        $registry.AddFunction($FunctionName, $Icon, $Name, $Description, $Preview, $EntryGroup)
    }
}
