<#
.SYNOPSIS
Opens a PowerShellRun selector with all available options.

.DESCRIPTION
Opens a PowerShellRun selector with all available options. It takes an array of PowerShellRun.SelectorEntry and returns a PowerShellRun.SelectorResult.

.PARAMETER Entry
An array of PowerShellRun.SelectorEntry. Each entry has properties for customizations.

Use this command to see what properties are available:
[PowerShellRun.SelectorEntry]::new() | Get-Member -MemberType Properties

.PARAMETER MultiSelection
Specifies if the selector accepts multiple selections.

.PARAMETER Option
Specifies an PowerShellRun.SelectorOption that is only effective for this invocation.
By default, the selector option that is set by Set-PSRunDefaultSelectorOption is used.

.PARAMETER Context
Specifies the initial state of the selector.

.INPUTS
An array of PowerShellRun.SelectorEntry.

.OUTPUTS
PowerShellRun.SelectorResult

.EXAMPLE
$result = Get-Process | ForEach-Object {
    $entry = [PowerShellRun.SelectorEntry]::new()
    $entry.UserData = $_
    $entry.Name = $_.Name
    $entry
} | Invoke-PSRunSelectorCustom

$result.KeyCombination
$result.FocusedEntry.UserData

.EXAMPLE
$actionKey = [PowerShellRun.ActionKey]::new('Ctrl+h', 'This is a custom action')
Get-ChildItem | ForEach-Object {
    $entry = [PowerShellRun.SelectorEntry]::new()
    $entry.UserData = $_
    $entry.Icon = if ($_.PSIsContainer) {'📁'} else {'📄'}
    $entry.Name = $_.Name
    $entry.Description = $_.FullName
    $entry.ActionKeys = $actionKey
    $entry
} | Invoke-PSRunSelectorCustom
#>
function Invoke-PSRunSelectorCustom {
    [CmdletBinding()]
    [OutputType([PowerShellRun.SelectorResult])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [PowerShellRun.SelectorEntry[]]$Entry,

        [Switch]$MultiSelection,

        [PowerShellRun.SelectorOption]$Option = $script:globalStore.defaultSelectorOption,

        [PowerShellRun.SelectorContext]$Context
    )

    begin {
        $isPipelineInput = $MyInvocation.ExpectingInput
        if ($isPipelineInput) {
            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
        }
    }
    process {
        if ($isPipelineInput) {
            $entries.Add($Entry[0])
        }
    }
    end {
        $mode = if ($MultiSelection) { [PowerShellRun.SelectorMode]::MultiSelection } else { [PowerShellRun.SelectorMode]::SingleSelection }
        if ($isPipelineInput) {
            $result = [PowerShellRun.Selector]::Open($entries, $mode, $Option, $Context)
        } else {
            $result = [PowerShellRun.Selector]::Open($Entry, $mode, $Option, $Context)
        }
        $result
    }
}
