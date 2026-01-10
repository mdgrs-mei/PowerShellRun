<#
.SYNOPSIS
Sets the default options for the PowerShellRun selectors.

.DESCRIPTION
Sets the default options for the PowerShellRun selectors. The option is used in all selector invocations such as Invoke-PSRun and Invoke-PSRunSelector.

.PARAMETER Option
Specifies PowerShellRun.SelectorOption that is used by default in all selector invocations.

Use this command to see what properties are available:
[PowerShellRun.SelectorOption]::new() | Get-Member -MemberType Properties

.INPUTS
The Option parameter.

.OUTPUTS
None.

.EXAMPLE
$option = Get-PSRunDefaultSelectorOption
$option.Theme.PreviewPosition = 'right'
Set-PSRunDefaultSelectorOption -Option $option
#>
function Set-PSRunDefaultSelectorOption {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [PowerShellRun.SelectorOption]$Option
    )

    process {
        $script:globalStore.SetDefaultSelectorOption($Option)
    }
}
