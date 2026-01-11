Describe 'Add-PSRunFavoriteFolder' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Enable-PSRunEntry -Category Favorite
        Add-PSRunFavoriteFolder -Path 'C:/folder' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FileSystemRegistry')
            $registry.favoritesEntries.Count | Should -Be 1
        }
    }

    It 'should add the entry under an entry group' {
        Enable-PSRunEntry -Category Favorite, EntryGroup
        $parentGroup = Add-PSRunEntryGroup -Name 'Parent Group' -PassThru
        Add-PSRunFavoriteFolder -Path 'C:/folder' -EntryGroup $parentGroup

        $parentGroup.DirectChildEntries.Count | Should -Be 1
    }

    It 'should not add an entry if category is disabled' {
        Enable-PSRunEntry -Category Function
        { Add-PSRunFavoriteFolder -Path 'C:/folder' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview' -WarningAction Stop } | Should -Throw
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FileSystemRegistry')
            $registry.favoritesEntries.Count | Should -Be 0
        }
    }

    It 'should accept a pipeline input' {
        Enable-PSRunEntry -Category Favorite
        'C:/folder' | Add-PSRunFavoriteFolder
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FileSystemRegistry')
            $registry.favoritesEntries.Count | Should -Be 1
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
