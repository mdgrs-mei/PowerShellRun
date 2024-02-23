Describe 'Set-PSRunDefaultSelectorOption' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
        $option = [PowerShellRun.SelectorOption]::new()
    }

    It 'should set the option as default' {
        $option.AutoReturnBestMatch = $true
        Set-PSRunDefaultSelectorOption $option
        $match = 'a', 'b' | Invoke-PSRunSelector
        $match | Should -Be 'a'
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
