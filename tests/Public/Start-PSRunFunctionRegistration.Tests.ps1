Describe 'Start-PSRunFunctionRegistration' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should not throw an error' {
        Start-PSRunFunctionRegistration
    }

    It 'should throw an error if called twice' {
        Start-PSRunFunctionRegistration
        { Start-PSRunFunctionRegistration -ErrorAction Stop } | Should -Throw
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
