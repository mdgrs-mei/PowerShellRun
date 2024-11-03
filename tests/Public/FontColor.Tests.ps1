Describe 'FontColor' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
    }

    It 'should be able to be set by a preset name' {
        $option = Get-PSRunDefaultSelectorOption
        $theme = $option.Theme
        $theme.DefaultForegroundColor = 'Black'
        $theme.DefaultForegroundColor -eq [PowerShellRun.FontColor]::Black | Should -BeTrue
    }

    It 'should be able to be set by a hex string' {
        $hex = '#20F230'
        $option = Get-PSRunDefaultSelectorOption
        $theme = $option.Theme
        $theme.DefaultForegroundColor = $hex
        $theme.DefaultForegroundColor -eq [PowerShellRun.FontColor]::FromHex($hex) | Should -BeTrue
    }

    It 'should throw with an invalid string' {
        $option = Get-PSRunDefaultSelectorOption
        $theme = $option.Theme
        { $theme.DefaultForegroundColor = 'abcdef' } | Should -Throw
    }

    It 'should throw with an invalid hex string' {
        { [PowerShellRun.FontColor]::FromHex('abcdef') } | Should -Throw
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
