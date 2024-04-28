function SearchPSReadLineHistory() {
    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()

    $cursorPos = $null
    $initialQuery = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$initialQuery, [ref]$cursorPos)

    $historyItems = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems()
    [Array]::Reverse($historyItems)

    $historySet = [System.Collections.Generic.Hashset[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($item in $historyItems) {
        $historySet.Add($item.CommandLine) | Out-Null
    }

    $context = [PowerShellRun.SelectorContext]::new()
    $context.Query = $initialQuery

    $actionKeys = @(
        [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Execute')
        [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Insert')
        [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy command to Clipboard')
    )

    $maxNameLength = 128
    $result = $historySet | ForEach-Object {
        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Name = if ($_.Length -gt $maxNameLength) {
            $_.Substring(0, $maxNameLength)
        } else {
            $_
        }
        $entry.Preview = $_
        $entry.ActionKeys = $actionKeys
        $entry
    } | Invoke-PSRunSelectorCustom -Context $context

    $command = $result.FocusedEntry.Name
    if (-not $command) {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursorPos)
        return
    }

    if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($command)
    } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        $command | Set-Clipboard
    }
}
