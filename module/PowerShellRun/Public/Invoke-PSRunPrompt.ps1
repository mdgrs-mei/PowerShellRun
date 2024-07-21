<#
.SYNOPSIS
Opens a PowerShellRun style prompt.

.DESCRIPTION
Opens a PowerShellRun style prompt to receive an input from the user.
The prompt reflects the selector options but without any entries.

.PARAMETER Option
Specifies an PowerShellRun.SelectorOption that is only effective for this invocation.
By default, the selector option that is set by Set-PSRunDefaultSelectorOption is used.

.PARAMETER Context
Specifies the initial state of the prompt.

.INPUTS
None.

.OUTPUTS
PowerShellRun.PromptResult

.EXAMPLE
$result = Invoke-PSRunPrompt

.EXAMPLE
$option = Get-PSRunDefaultSelectorOption
$option.Prompt = 'Type your name: '
$result = Invoke-PSRunPrompt -Option $option
#>
function Invoke-PSRunPrompt {
    [CmdletBinding()]
    [OutputType([PowerShellRun.PromptResult])]
    param (
        [PowerShellRun.SelectorOption]$Option = $script:globalStore.defaultSelectorOption,

        [PowerShellRun.PromptContext]$Context
    )

    $result = [PowerShellRun.Prompt]::Open($Option, $Context)
    $result
}
