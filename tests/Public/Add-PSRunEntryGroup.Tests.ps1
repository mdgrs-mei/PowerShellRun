Describe 'Add-PSRunEntryGroup' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add a normal entry group' {
        Enable-PSRunEntry -Category EntryGroup
        Add-PSRunEntryGroup -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('EntryGroupRegistry')
            $registry.entries.Count | Should -Be 1
        }
    }

    It 'should add a category entry group' {
        Enable-PSRunEntry -Category EntryGroup
        Add-PSRunEntryGroup -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview' -Category Function
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('EntryGroupRegistry')
            $registry.entries.Count | Should -Be 1
        }
    }

    It 'should add the entry under an entry group' {
        Enable-PSRunEntry -Category EntryGroup
        $parentGroup = Add-PSRunEntryGroup -Name 'Parent Group' -PassThru
        Add-PSRunEntryGroup -Name 'Custom Name' -EntryGroup $parentGroup

        $parentGroup.DirectChildEntries.Count | Should -Be 1
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('EntryGroupRegistry')
            $registry.entries.Count | Should -Be 1
        }
    }

    It 'should not add an entry if category is disabled' {
        Enable-PSRunEntry -Category Function
        { Add-PSRunEntryGroup -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview' -WarningAction Stop } | Should -Throw
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('EntryGroupRegistry')
            $registry.entries.Count | Should -Be 0
        }
    }

    It 'should return the entry group with PassThru' {
        Enable-PSRunEntry -Category EntryGroup
        $group = Add-PSRunEntryGroup -Name 'Custom Name' -PassThru
        $group | Should -Not -BeNullOrEmpty
    }

    It 'should accept a pipeline input' {
        Enable-PSRunEntry -Category EntryGroup
        'Custom Name' | Add-PSRunEntryGroup
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('EntryGroupRegistry')
            $registry.entries.Count | Should -Be 1
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
