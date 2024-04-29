Describe 'Set-PSRunPSReadLineKeyHandler' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should store key handler for InvokePSRun' {
        Set-PSRunPSReadLineKeyHandler -InvokePsRunChord 'Ctrl+j'

        InModuleScope 'PowerShellRun' {
            $script:globalStore.invokePsRunChord | Should -Be 'Ctrl+j'
        }
    }

    It 'should store key handler for PSReadLineHistory' {
        Set-PSRunPSReadLineKeyHandler -PSReadLineHistoryChord 'Ctrl+f'

        InModuleScope 'PowerShellRun' {
            $script:globalStore.psReadLineHistoryChord | Should -Be 'Ctrl+f'
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
