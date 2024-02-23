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

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
