Describe 'Add-PSRunScriptBlock' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Enable-PSRunEntry -Category Script
        Add-PSRunScriptBlock -ScriptBlock { 'hello' } -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('ScriptRegistry')
            $registry.entries.Count | Should -Be 1
        }
    }

    It 'should add the entry under an entry group' {
        Enable-PSRunEntry -Category Script, EntryGroup
        $parentGroup = Add-PSRunEntryGroup -Name 'Parent Group' -PassThru
        Add-PSRunScriptBlock -ScriptBlock { 'hello' } -Name 'Custom Name' -EntryGroup $parentGroup

        $parentGroup.DirectChildEntries.Count | Should -Be 1
    }

    It 'should not add an entry if category is disabled' {
        Enable-PSRunEntry -Category Function
        Add-PSRunScriptBlock -ScriptBlock { 'hello' } -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('ScriptRegistry')
            $registry.entries.Count | Should -Be 0
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
