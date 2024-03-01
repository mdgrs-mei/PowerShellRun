Describe 'Restore-PSRunFunctionParentSelector' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should set the restore flag' {
        InModuleScope 'PowerShellRun' {
            $script:globalStore.IsParentSelectorRestoreRequested() | Should -Be $false
        }

        Restore-PSRunFunctionParentSelector

        InModuleScope 'PowerShellRun' {
            $script:globalStore.IsParentSelectorRestoreRequested() | Should -Be $true
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
