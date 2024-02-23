Describe 'Invoke-PSRunSelector' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
        $option = [PowerShellRun.SelectorOption]::new()
        $context = [PowerShellRun.SelectorContext]::new()
        $option.AutoReturnBestMatch = $true
    }

    It 'should return an entry in the input order' {
        $match = 'a', 'b' | Invoke-PSRunSelector -Option $option
        $match | Should -Be 'a'
    }

    It 'should return the best match' {
        $context.Query = 'b'
        $match = 'a', 'b' | Invoke-PSRunSelector -Option $option -Context $context
        $match | Should -Be 'b'
    }

    It 'should prioritize the exact match' {
        $context.Query = 'ab'
        $match = 'acb', 'cab' | Invoke-PSRunSelector -Option $option -Context $context
        $match | Should -Be 'cab'
    }

    It 'should return fuzzy match' {
        $context.Query = 'ab'
        $match = 'def', 'acb' | Invoke-PSRunSelector -Option $option -Context $context
        $match | Should -Be 'acb'
    }

    It 'should return case sensitive match' {
        $context.Query = 'A'
        $match = 'abc', 'Abc' | Invoke-PSRunSelector -Option $option -Context $context
        $match | Should -Be 'Abc'
    }

    It 'should not return any match if there is none' {
        $context.Query = 'abcd'
        $match = 'abc', 'bcd' | Invoke-PSRunSelector -Option $option -Context $context
        $match | Should -BeNullOrEmpty
    }

    It 'should prioritize shorter match' {
        $context.Query = 'ab'
        $match = 'accccb', 'acb' | Invoke-PSRunSelector -Option $option -Context $context
        $match | Should -Be 'acb'
    }

    It 'should prioritize the first character match' {
        $context.Query = 'ab'
        $match = 'cab', 'abc' | Invoke-PSRunSelector -Option $option -Context $context
        $match | Should -Be 'abc'
    }

    It 'should not throw an exception with multi selection' {
        $match = 'a' | Invoke-PSRunSelector -Option $option -MultiSelection
        $match | Should -Be 'a'
    }

    It 'should use Name attribute by default' {
        $context.Query = 'ab'
        $match = 'dd', 'ab' | ForEach-Object {
            @{
                Name = $_
            }
        } | Invoke-PSRunSelector -Option $option -Context $context
        $match.Name | Should -Be 'ab'
    }

    It 'should use specified Name property' {
        $context.Query = 'ab'
        $match = 'dd', 'ab' | ForEach-Object {
            @{
                AltName = $_
            }
        } | Invoke-PSRunSelector -NameProperty AltName -Option $option -Context $context
        $match.AltName | Should -Be 'ab'
    }

    It 'should process Expression' {
        $context.Query = 'ab'
        $match = 'dd', 'ab' | Invoke-PSRunSelector -Expression {
            @{
                Name = $_
            }
        } -Option $option -Context $context
        $match | Should -Be 'ab'
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
