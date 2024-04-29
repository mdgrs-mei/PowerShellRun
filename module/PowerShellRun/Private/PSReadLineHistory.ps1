function SearchPSReadLineHistory() {
    $actionKeys = @(
        [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Execute')
        [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Insert')
        [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy command to Clipboard')
    )

    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()

    $cursorPos = $null
    $initialQuery = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$initialQuery, [ref]$cursorPos)

    $historyItems = [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems()
    [Array]::Reverse($historyItems)

    $historySet = [System.Collections.Generic.Hashset[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $maxNameLength = 128
    foreach ($item in $historyItems) {
        $isAdded = $historySet.Add($item.CommandLine)
        if ($isAdded) {
            $entry = [PowerShellRun.SelectorEntry]::new()
            $entry.UserData = $item
            $entry.Name = if ($item.CommandLine.Length -gt $maxNameLength) {
                $item.CommandLine.Substring(0, $maxNameLength)
            } else {
                $item.CommandLine
            }

            $startTime = if ($item.StartTime -ne [DateTime]::MinValue) {
                '{0} {1}' -f $item.StartTime.ToShortDateString(), $item.StartTime.ToShortTimeString()
            } else {
                '-'
            }
            $elapsedTime = if ($item.ApproximateElapsedTime -ne [TimeSpan]::Zero) {
                $item.ApproximateElapsedTime.ToString()
            } else {
                '-'
            }

            $entry.Preview = "{0}📅 {1} ⌚ {2}{3}`n`n{4}" -f $PSStyle.Underline, $startTime, $elapsedTime, $PSStyle.UnderlineOff, $item.CommandLine
            $entry.ActionKeys = $actionKeys

            $entries.Add($entry)
        }
    }

    $context = [PowerShellRun.SelectorContext]::new()
    $context.Query = $initialQuery

    $result = Invoke-PSRunSelectorCustom -Entry $entries -Context $context

    $command = $result.FocusedEntry.UserData.CommandLine
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
