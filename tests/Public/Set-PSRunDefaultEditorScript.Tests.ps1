﻿Describe 'Set-PSRunDefaultEditorScript' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should set the ScriptBlock' {
        $script = {
            param($path)
            & notepad.exe $path
        }

        Set-PSRunDefaultEditorScript $script

        InModuleScope 'PowerShellRun' -ArgumentList $script {
            param($script)
            $fileSystemRegistry = $script:globalStore.GetRegistry('FileSystemRegistry')
            $fileSystemRegistry.defaultEditorScript | Should -Be $script
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
