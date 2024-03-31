Describe 'Get-PSRunDefaultSelectorOption' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
        $optionSet = [PowerShellRun.SelectorOption]::new()
    }

    It 'should return the option you set' {
        $optionSet.AutoReturnBestMatch = $true
        Set-PSRunDefaultSelectorOption $optionSet

        $optionGot = Get-PSRunDefaultSelectorOption
        $optionGot.AutoReturnBestMatch | Should -Be $optionSet.AutoReturnBestMatch
    }

    It 'should deep clone the option every time you set' {
        $optionGot1 = Get-PSRunDefaultSelectorOption
        $optionGot1.KeyBinding.QuitKeys[0].Key = 'a'

        $optionGot2 = Get-PSRunDefaultSelectorOption
        $optionGot2.KeyBinding.QuitKeys[0].Key | Should -Not -Be $optionGot1.KeyBinding.QuitKeys[0].Key
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
