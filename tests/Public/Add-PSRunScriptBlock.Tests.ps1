Describe 'Add-PSRunScriptBlock' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Add-PSRunScriptBlock -ScriptBlock { 'hello' } -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('ScriptRegistry')
            $registry.entries.Count | Should -Be 1
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
