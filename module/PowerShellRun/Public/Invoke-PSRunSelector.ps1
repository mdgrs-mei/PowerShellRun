<#
.SYNOPSIS
Opens a PowerShellRun selector.

.DESCRIPTION
Opens a PowerShellRun selector that takes an array of objects and returns the selected object(s).

.PARAMETER InputObject
An array of objects to be filtered.

.PARAMETER NameProperty
Specifies the property name of the input object that is used as the entry name.

.PARAMETER DescriptionProperty
Specifies the property name of the input object that is used as the entry description.

.PARAMETER PreviewProperty
Specifies the property name of the input object that is used as the entry preview.

.PARAMETER Expression
Specifies the ScriptBlock that returns a hashtable. The hashtable needs to have Name, Description and Preview keys which are used as entry properties respectively.

.PARAMETER MultiSelection
Specifies if the selector accepts multiple selections.

.PARAMETER Option
Specifies an PowerShellRun.SelectorOption that is only effective for this invocation.
By default, the selector option that is set by Set-PSRunDefaultSelectorOption is used.

.PARAMETER Context
Specifies the initial state of the selector.

.INPUTS
An array of objects to be filtered.

.OUTPUTS
The selected object(s).

.EXAMPLE
Get-Process | Invoke-PSRunSelector

.EXAMPLE
Get-ChildItem | Invoke-PSRunSelector -DescriptionProperty FullName

.EXAMPLE
Get-ChildItem | Invoke-PSRunSelector -Expression {@{
    Name = $_.Name
    Description = '[{0}] {1}' -f $_.Mode, $_.LastAccessTime
    Preview = Get-Item $_ | Out-String
}}
#>
function Invoke-PSRunSelector {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        [String]$NameProperty = 'Name',

        [String]$DescriptionProperty = 'Description',

        [String]$PreviewProperty = 'Preview',

        [ScriptBlock]$Expression,

        [Switch]$MultiSelection,

        [PowerShellRun.SelectorOption]$Option = $script:globalStore.defaultSelectorOption,

        [PowerShellRun.SelectorContext]$Context
    )

    begin {
        $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    }
    process {
        foreach ($obj in $InputObject) {
            $entry = [PowerShellRun.SelectorEntry]::new()
            $entry.UserData = $obj
            if ($Expression) {
                $obj = $obj | ForEach-Object $Expression
            }
            if (($null -eq $obj.$NameProperty)) {
                if ($null -ne $obj) {
                    $entry.Name = $obj.ToString()
                }
            } else {
                $entry.Name = $obj.$NameProperty
            }
            $entry.Description = $obj.$DescriptionProperty
            $entry.Preview = $obj.$PreviewProperty
            $entries.Add($entry)
        }
    }
    end {
        $mode = if ($MultiSelection) { [PowerShellRun.SelectorMode]::MultiSelection } else { [PowerShellRun.SelectorMode]::SingleSelection }
        $result = [PowerShellRun.Selector]::Open($entries, $mode, $Option, $Context)

        if ($result.MarkedEntries) {
            $result.MarkedEntries.UserData
        } else {
            $result.FocusedEntry.UserData
        }
    }
}
