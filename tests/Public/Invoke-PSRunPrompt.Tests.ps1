Describe 'Invoke-PSRunPrompt' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
        $option = [PowerShellRun.SelectorOption]::new()
        $context = [PowerShellRun.PromptContext]::new()
        $option.AutoReturnBestMatch = $true
    }

    It 'should return input text' {
        $text = 'abc'
        $context.Input = $text
        $result = Invoke-PSRunPrompt -Option $option -Context $context
        $result.Input | Should -Be $text
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
