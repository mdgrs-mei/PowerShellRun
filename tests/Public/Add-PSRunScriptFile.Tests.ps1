﻿Describe 'Add-PSRunScriptFile' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should add an entry' {
        Enable-PSRunEntry -Category Script
        Add-PSRunScriptFile -Path 'D:/test.ps1' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('ScriptRegistry')
            $registry.entries.Count | Should -Be 1
        }
    }

    It 'should not add an entry if category is disabled' {
        Enable-PSRunEntry -Category Function
        Add-PSRunScriptFile -Path 'D:/test.ps1' -Icon '😆' -Name 'Custom Name' -Description 'Custom Desc' -Preview 'Custom Preview'
        InModuleScope 'PowerShellRun' {
            $registry = $script:globalStore.GetRegistry('ScriptRegistry')
            $registry.entries.Count | Should -Be 0
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
