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
