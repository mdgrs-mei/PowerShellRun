<#
.SYNOPSIS
Adds an entry group as an entry.

.DESCRIPTION
Adds an entry group as an entry that can hold other entries as its children. The entry groups belong to the 'EntryGroup' category.

.PARAMETER Icon
The icon string.

.PARAMETER Name
The name of the entry.

.PARAMETER Description
The description string.

.PARAMETER Preview
The custom preview string. Child entries are listed by default.

.PARAMETER Category
Specifies a category or an array of categories that the entry group holds.
If specified, the entries that belong to the category are all added to the entry group instead of being listed in the top menu.

.PARAMETER EntryGroup
The parent entry group object where this new entry group is added.

.PARAMETER PassThru
Returns the added entry group if specified.

.INPUTS
The Name parameter.

.OUTPUTS
An object that represents an entry group if PassThru is specified. None otherwise.

.EXAMPLE
$group = Add-PSRunEntryGroup -Name 'ProjectA' -PassThru
Add-PSRunScriptBlock -Name 'Hello' -ScriptBlock { 'Hello' } -EntryGroup $group

.EXAMPLE
Add-PSRunEntryGroup -Name 'Apps' -Category Application
#>
function Add-PSRunEntryGroup {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [String]$Icon,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
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
