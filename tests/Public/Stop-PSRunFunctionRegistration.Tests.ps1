Describe 'Stop-PSRunFunctionRegistration' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should throw an error' {
        { Stop-PSRunFunctionRegistration -ErrorAction Stop } | Should -Throw
    }

    It 'should register a function' {
        Enable-PSRunEntry -Category Function

        Start-PSRunFunctionRegistration
        function global:Test {}
        Stop-PSRunFunctionRegistration

        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FunctionRegistry')
            $registry.entries.Count | Should -Be 1
        }
        $function:Test = $null
    }

    It 'should not register a function if category is disabled' {
        Enable-PSRunEntry -Category Script

        Start-PSRunFunctionRegistration
        function global:Test {}
        Stop-PSRunFunctionRegistration

        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FunctionRegistry')
            $registry.entries.Count | Should -Be 0
        }
        $function:Test = $null
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
