Describe 'Set-PSRunPSReadLineKeyHandler' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
        $chord = 'Ctrl+j'
        $desc = 'InvokePSRun'
    }

    It 'should store key handler for InvokePSRun' {
        Remove-PSReadLineKeyHandler -Chord $chord
        Set-PSRunPSReadLineKeyHandler -InvokePsRunChord $chord -InvokePsRunDescription $desc

        $handler = Get-PSReadLineKeyHandler -Chord $chord
        $handler.Key | Should -Be $chord
        $handler.Description | Should -Be $desc
    }

    It 'should store key handler for PSReadLineHistory' {
        Remove-PSReadLineKeyHandler -Chord $chord
        Set-PSRunPSReadLineKeyHandler -PSReadLineHistoryChord $chord -PSReadLineHistoryDescription $desc

        $handler = Get-PSReadLineKeyHandler -Chord $chord
        $handler.Key | Should -Be $chord
        $handler.Description | Should -Be $desc
    }

    It 'should store key handler for TabCompletion' {
        Remove-PSReadLineKeyHandler -Chord $chord
        Set-PSRunPSReadLineKeyHandler -TabCompletionChord $chord -TabCompletionDescription $desc

        $handler = Get-PSReadLineKeyHandler -Chord $chord
        $handler.Key | Should -Be $chord
        $handler.Description | Should -Be $desc
    }

    It 'should remove key handlers by unloading module' {
        Set-PSRunPSReadLineKeyHandler -InvokePsRunChord $chord -InvokePsRunDescription $desc
        Remove-Module PowerShellRun -Force
        Get-PSReadLineKeyHandler -Chord $chord | Should -Be $null
    }

    AfterEach {
        if (Get-Module PowerShellRun) {
            Remove-Module PowerShellRun -Force
        }
    }
}
