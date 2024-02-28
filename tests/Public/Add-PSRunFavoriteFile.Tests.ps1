Describe 'Add-PSRunFavoriteFile' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Add-PSRunFavoriteFile -Path 'C:/folder/test.txt' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $script:globalStore.fileSystemRegistry.favoritesEntries.Count | Should -Be 1
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
