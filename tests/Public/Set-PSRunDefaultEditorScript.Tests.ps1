Describe 'Set-PSRunDefaultEditorScript' {
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
            $script:globalStore.defaultEditorScript | Should -Be $script
        }
    }

    It 'should accept a pipeline input' {
        $script = {
            param($path)
            & notepad.exe $path
        }

        $script | Set-PSRunDefaultEditorScript

        InModuleScope 'PowerShellRun' -ArgumentList $script {
            param($script)
            $script:globalStore.defaultEditorScript | Should -Be $script
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
