﻿Describe 'Add-PSRunFavoriteFile' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Enable-PSRunEntry -Category Favorite
        Add-PSRunFavoriteFile -Path 'C:/folder/test.txt' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FileSystemRegistry')
            $registry.favoritesEntries.Count | Should -Be 1
        }
    }

    It 'should add the entry under an entry group' {
        Enable-PSRunEntry -Category Favorite, EntryGroup
        $parentGroup = Add-PSRunEntryGroup -Name 'Parent Group' -PassThru
        Add-PSRunFavoriteFile -Path 'C:/folder/test.txt' -EntryGroup $parentGroup

        $parentGroup.DirectChildEntries.Count | Should -Be 1
    }

    It 'should not add an entry if category is disabled' {
        Enable-PSRunEntry -Category Function
        { Add-PSRunFavoriteFile -Path 'C:/folder/test.txt' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview' -WarningAction Stop } | Should -Throw
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('FileSystemRegistry')
            $registry.favoritesEntries.Count | Should -Be 0
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
