function TabComplete() {
    $actionKeys = @(
        [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Insert')
    )

    $inputScript = $null
    $cursorPos = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$inputScript, [ref]$cursorPos)

    $commandCompletion = TabExpansion2 -inputScript $inputScript -cursorColumn $cursorPos
    if ($commandCompletion.CompletionMatches.Count -eq 0) {
        return
    }

    if ($commandCompletion.CompletionMatches.Count -eq 1) {
        $completion = $commandCompletion.CompletionMatches[0]
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($commandCompletion.ReplacementIndex, $commandCompletion.ReplacementLength, $completion.CompletionText)
        return
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()

    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $noMatchRegex = [Regex]::new('\0')
    foreach ($completion in $commandCompletion.CompletionMatches) {
        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.UserData = $completion
        $entry.Icon = GetTabCompletionIcon $completion
        $entry.Name = $completion.ListItemText
        $entry.Description = $completion.ResultType
        # Exclude Description from search.
        $entry.DescriptionSearchablePattern = $noMatchRegex
        $entry.PreviewAsyncScript, $entry.PreviewAsyncScriptArgumentList = GetTabCompletionPreviewScript $completion
        $entry.ActionKeys = $actionKeys
        $entries.Add($entry)
    }

    $originalCanvasTopMargin = $script:globalStore.psRunSelectorOption.Theme.CanvasTopMargin
    $script:globalStore.psRunSelectorOption.Theme.CanvasTopMargin += 1

    $result = Invoke-PSRunSelectorCustom -Entry $entries -Option $script:globalStore.psRunSelectorOption

    $script:globalStore.psRunSelectorOption.Theme.CanvasTopMargin = $originalCanvasTopMargin

    $completion = $result.FocusedEntry.UserData
    if (-not $completion) {
        # We have to call RevertLine twice to escape from PredictionViewStyle ListView.
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($inputScript)
        return
    }

    if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Replace($commandCompletion.ReplacementIndex, $commandCompletion.ReplacementLength, $completion.CompletionText)
    }
}

function GetTabCompletionIcon($CompletionResult) {
    $resultType = $CompletionResult.ResultType
    $icon = switch ($resultType) {
        ProviderContainer { '📁' }
        ProviderItem { '📄' }
        History { '📙' }
        Command { '🔧' }
        default { '📝' }
    }
    $icon
}

function GetTabCompletionPreviewScript($CompletionResult) {
    $previewDefault = {
        param ($completionResult)
        $completionResult.ToolTip
    }

    $previewFolder = {
        param ($completionResult)
        $path = $completionResult.ToolTip
        $childItems = Get-ChildItem $path
        $childItems | ForEach-Object {
            if ($_.PSIsContainer) {
                $icon = '📁'
            } else {
                $icon = '📄'
            }
            '{0} {1}' -f $icon, $_.Name
        }
    }

    $previewFile = {
        param ($completionResult)
        $path = $completionResult.ToolTip
        Get-Item $path | Out-String
    }

    $previewCommand = {
        param ($completionResult)
        $commandName = $completionResult.ListItemText
        $command = Get-Command -Name $commandName -ErrorAction Ignore
        if (-not $command) {
            return $completionResult.ToolTip
        }

        $preview = switch ($command.CommandType) {
            { $_ -in 'Alias', 'Cmdlet', 'Function', 'Filter' } { Get-Help $commandName | Out-String }
            default { $command | Out-String }
        }
        $preview
    }

    $resultType = $CompletionResult.ResultType
    $previewScript = switch ($resultType) {
        ProviderContainer { $previewFolder }
        ProviderItem { $previewFile }
        Command { $previewCommand }
        default { $previewDefault }
    }

    $previewScript, $CompletionResult
}
