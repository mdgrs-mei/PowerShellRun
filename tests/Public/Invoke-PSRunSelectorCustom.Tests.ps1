Describe 'Invoke-PSRunSelectorCustom' {
    BeforeEach {
        Import-Module $PSScriptRoot/../../module/PowerShellRun -Force
        $option = [PowerShellRun.SelectorOption]::new()
        $context = [PowerShellRun.SelectorContext]::new()
        $option.AutoReturnBestMatch = $true
        $items = Get-ChildItem
    }

    It 'should return an input object' {
        $result = $items | ForEach-Object {
            $entry = [PowerShellRun.SelectorEntry]::new()
            $entry.UserData = $_
            $entry.Name = $_.Name
            $entry
        } | Invoke-PSRunSelectorCustom -Option $option
        $result.FocusedEntry.UserData | Should -Be $items[0]
    }

    It 'should return a context' {
        $query = 'abc'
        $context.Query = $query
        $result = $items | ForEach-Object {
            $entry = [PowerShellRun.SelectorEntry]::new()
            $entry.UserData = $_
            $entry.Name = $_.Name
            $entry
        } | Invoke-PSRunSelectorCustom -Option $option -Context $context
        $result.Context.Query | Should -Be $query
    }

    It 'should not throw an error with PreviewAsyncScript' {
        $result = $items | ForEach-Object {
            $entry = [PowerShellRun.SelectorEntry]::new()
            $entry.UserData = $_
            $entry.Name = $_.Name
            $entry.PreviewAsyncScript = {
                param($param)
                $param
            }
            $entry.PreviewAsyncScriptArgumentList = 'hello'
            $entry
        } | Invoke-PSRunSelectorCustom -Option $option
        $result.FocusedEntry.UserData | Should -Be $items[0]
    }

    AfterEach {
        Remove-Module PowerShellRun -Force
    }
}
