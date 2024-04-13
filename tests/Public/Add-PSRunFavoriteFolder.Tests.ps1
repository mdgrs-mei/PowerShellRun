Describe 'Add-PSRunFavoriteFolder' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Add-PSRunFavoriteFolder -Path 'C:/folder' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $fileSystemRegistry = $script:globalStore.GetRegistry('FileSystemRegistry')
            $fileSystemRegistry.favoritesEntries.Count | Should -Be 1
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
