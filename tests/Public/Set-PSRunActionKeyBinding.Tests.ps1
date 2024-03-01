Describe 'Set-PSRunActionKeyBinding' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should set the keys' {
        $params = @{
            FirstActionKey = 'Ctrl+a'
            SecondActionKey = 'Ctrl+b'
            ThirdActionKey = 'Ctrl+c'
            CopyActionKey = 'Ctrl+d'
        }
        Set-PSRunActionKeyBinding @params

        InModuleScope 'PowerShellRun' -ArgumentList $params {
            param ($params)
            $script:globalStore.firstActionKey | Should -Be $params.FirstActionKey
            $script:globalStore.secondActionKey | Should -Be $params.SecondActionKey
            $script:globalStore.thirdActionKey | Should -Be $params.ThirdActionKey
            $script:globalStore.copyActionKey | Should -Be $params.CopyActionKey
        }
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
