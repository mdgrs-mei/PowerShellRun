Describe 'RemapKey' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'is set by a string' {
        [PowerShellRun.RemapKey]$remapKey = 'A:B'
        $remapKey.ToString() | Should -Be ([PowerShellRun.RemapKey]::new('A', 'B').ToString())
    }

    It 'should throw with an invalid string' {
        { [PowerShellRun.RemapKey]$remapKey = 'A:hello' } | Should -Throw
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
