Describe 'Enable-PSRunEntry' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should not throw an error with All initialization' {
        Enable-PSRunEntry All
    }

    It 'should not throw an error with array initialization' {
        Enable-PSRunEntry Function, Utility, Favorite
    }

    It 'should accept pipeline inputs' {
        'function', 'Utility', 'Favorite' | Enable-PSRunEntry
    }

    It 'should throw if called twice' {
        Enable-PSRunEntry
        { Enable-PSRunEntry -ErrorAction Stop } | Should -Throw
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
