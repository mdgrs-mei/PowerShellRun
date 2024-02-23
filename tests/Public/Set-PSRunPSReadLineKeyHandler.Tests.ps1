Describe 'Set-PSRunPSReadLineKeyHandler' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should set the option as default' {
        Set-PSRunPSReadLineKeyHandler -Chord 'Ctrl+j'

        InModuleScope 'PowerShellRun' {
            $script:globalStore.psReadLineChord | Should -Be 'Ctrl+j'
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
