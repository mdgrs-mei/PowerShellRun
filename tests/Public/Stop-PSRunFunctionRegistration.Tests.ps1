Describe 'Stop-PSRunFunctionRegistration' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should throw an error' {
        { Stop-PSRunFunctionRegistration -ErrorAction Stop } | Should -Throw
    }

    It 'should register a function' {
        Start-PSRunFunctionRegistration
        function global:Test {}
        Stop-PSRunFunctionRegistration

        InModuleScope 'PowerShellRun' {
            $functionRegistry = $script:globalStore.GetRegistry('FunctionRegistry')
            $functionRegistry.entries.Count | Should -Be 1
        }
        $function:Test = $null
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
