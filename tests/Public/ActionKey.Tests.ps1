Describe 'ActionKey' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'is set by a string' {
        [PowerShellRun.ActionKey]$actionKey = 'A:Hello'
        $actionKey.ToString() | Should -Be ([PowerShellRun.ActionKey]::new('A', 'Hello').ToString())
    }

    It 'should throw with an invalid string' {
        { [PowerShellRun.ActionKey]$actionKey = 'Hello' } | Should -Throw
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
