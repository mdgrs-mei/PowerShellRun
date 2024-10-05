Describe 'Add-PSRunFunction' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Enable-PSRunEntry -Category Function
        function global:Test {}
        Add-PSRunFunction -FunctionName Test -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FunctionRegistry')
            $registry.entries.Count | Should -Be 1
        }
        $function:Test = $null
    }

    It 'should add the entry under an entry group' {
        Enable-PSRunEntry -Category Function, EntryGroup
        $parentGroup = Add-PSRunEntryGroup -Name 'Parent Group' -PassThru
        function global:Test {}
        Add-PSRunFunction -FunctionName Test -EntryGroup $parentGroup

        $parentGroup.DirectChildEntries.Count | Should -Be 1
        $function:Test = $null
    }

    It 'should warn if the function is not found' {
        Enable-PSRunEntry -Category Function
        { Add-PSRunFunction -FunctionName Test -WarningAction Stop } | Should -Throw
    }

    It 'should not add an entry if category is disabled' {
        Enable-PSRunEntry -Category Script
        function global:Test {}
        { Add-PSRunFunction -FunctionName Test -WarningAction Stop } | Should -Throw
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
