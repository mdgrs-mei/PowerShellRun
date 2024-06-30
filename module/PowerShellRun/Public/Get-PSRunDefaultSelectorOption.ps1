<#
.SYNOPSIS
Returns a deep clone of the default selector option.

.DESCRIPTION
Returns a deep clone of the default selector option. You can set the default selector option by Set-PSRunDefaultSelectorOption.

.INPUTS
None.

.OUTPUTS
PowerShellRun.SelectorOption

.EXAMPLE
$option = Get-PSRunDefaultSelectorOption
$option.QuitWithBackspaceOnEmptyQuery = $true
Set-PSRunDefaultSelectorOption $option
#>
function Get-PSRunDefaultSelectorOption {
    [CmdletBinding()]
    param ()

    $script:globalStore.defaultSelectorOption.DeepClone()
}
