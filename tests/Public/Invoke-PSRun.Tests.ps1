Describe 'Invoke-PSRun' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should throw with no entry' {
        {Invoke-PSRun -ErrorAction Stop} | Should -Throw
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
