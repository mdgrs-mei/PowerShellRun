class GlobalStore {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $defaultSelectorOption = [PowerShellRun.SelectorOption]::new()
    $psRunSelectorOption = [PowerShellRun.SelectorOption]::new()

    $functionRegistry
    $applicationRegistry
    $fileSystemRegistry

    $parentSelectorRestoreRequest = $false
    $originalPSConsoleHostReadLine = $null
    $isReadLineReplaced = $false
    $invokePsRunRequest = $false
    $invokePsRunRequestQuery = ""
    $psReadLineChord = $null

    $firstActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)
    $secondActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)
    $thirdActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)
    $copyActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)

    [void] Initialize() {
        $this.InitializeActionKeys()

        $this.functionRegistry = New-Object FunctionRegistry
        $this.applicationRegistry = New-Object ApplicationRegistry
        $this.fileSystemRegistry = New-Object FileSystemRegistry
    }

    [void] Terminate() {
        # Wait for async entry initializations
        $this.UpdateEntries()

        $this.RemovePSReadLineKeyHandler()
        $this.RestorePSConsoleHostReadLine()
    }

    [void] InitializeActionKeys() {
        $_firstActionKey = [PowerShellRun.KeyCombination]::new('Enter')
        if ($script:isMacOs) {
            $_secondActionKey = [PowerShellRun.KeyCombination]::new('Alt+Enter')
            $_thirdActionKey = [PowerShellRun.KeyCombination]::new('Alt+J')
            $_copyActionKey = [PowerShellRun.KeyCombination]::new('Ctrl+C')
        }
        else {
            $_secondActionKey = [PowerShellRun.KeyCombination]::new('Shift+Enter')
            $_thirdActionKey = [PowerShellRun.KeyCombination]::new('Ctrl+Enter')
            $_copyActionKey = [PowerShellRun.KeyCombination]::new('Ctrl+C')
        }
        $this.SetActionKeys($_firstActionKey, $_secondActionKey, $_thirdActionKey, $_copyActionKey)
    }

    [void] SetActionKeys($firstActionKey, $secondActionKey, $thirdActionKey, $copyActionKey) {
        # Change the values instead of references so that entries that are already created can see the keys.
        $this.firstActionKey.Modifier = $firstActionKey.Modifier
        $this.firstActionKey.Key = $firstActionKey.Key

        $this.secondActionKey.Modifier = $secondActionKey.Modifier
        $this.secondActionKey.Key = $secondActionKey.Key

        $this.thirdActionKey.Modifier = $thirdActionKey.Modifier
        $this.thirdActionKey.Key = $thirdActionKey.Key

        $this.copyActionKey.Modifier = $copyActionKey.Modifier
        $this.copyActionKey.Key = $copyActionKey.Key
    }

    [void] SetDefaultSelectorOption([PowerShellRun.SelectorOption]$option) {
        $this.defaultSelectorOption = $option.DeepClone()
        $this.psRunSelectorOption = $option.DeepClone()

        $psRunKeyBinding = $this.psRunSelectorOption.KeyBinding
        $psRunKeyBinding.DefaultActionKeys[0].KeyCombination = $this.firstActionKey
        $psRunKeyBinding.DefaultActionKeys[0].Description = 'Quit'
    }

    [void] EnableEntries([String[]]$entryCategories) {
        $this.applicationRegistry.EnableEntries($entryCategories)
        $this.functionRegistry.EnableEntries($entryCategories)
        $this.fileSystemRegistry.EnableEntries($entryCategories)
    }

    [void] UpdateEntries() {
        $updated = $false
        $updated = $this.applicationRegistry.UpdateEntries() -or $updated
        $updated = $this.functionRegistry.UpdateEntries() -or $updated
        $updated = $this.fileSystemRegistry.UpdateEntries() -or $updated

        if ($updated) {
            $this.entries.Clear()
            if ($_entries = $this.functionRegistry.GetEntries()) {
                $this.entries.AddRange($_entries)
            }
            if ($_entries = $this.fileSystemRegistry.GetEntries()) {
                $this.entries.AddRange($_entries)
            }
            if ($_entries = $this.applicationRegistry.GetEntries()) {
                $this.entries.AddRange($_entries)
            }
        }
    }

    [void] RequestParentSelectorRestore() {
        $this.parentSelectorRestoreRequest = $true
    }

    [void] ClearParentSelectorRestoreRequest() {
        $this.parentSelectorRestoreRequest = $false
    }

    [bool] IsParentSelectorRestoreRequested() {
        return $this.parentSelectorRestoreRequest
    }

    [void] ReplacePSConsoleHostReadLine() {
        if ($this.isReadLineReplaced) {
            return
        }

        $this.isReadLineReplaced = $true
        $this.originalPSConsoleHostReadLine = $function:global:PSConsoleHostReadLine
        $function:global:PSConsoleHostReadLine = {
            $script:globalStore.InvokePSConsoleHostReadLine()
        }
    }

    [void] RestorePSConsoleHostReadLine() {
        if (-not $this.isReadLineReplaced) {
            return
        }

        $function:global:PSConsoleHostReadLine = $this.originalPSConsoleHostReadLine
        $this.isReadLineReplaced = $false
    }

    [Object] InvokePSConsoleHostReadLine() {
        $command = $this.originalPSConsoleHostReadLine.Invoke()
        if ($this.invokePsRunRequest) {
            $this.invokePsRunRequest = $false
            if ($this.invokePsRunRequestQuery) {
                return ('Invoke-PSRun -Query "{0}"' -f $this.invokePsRunRequestQuery)
            }
            else {
                return 'Invoke-PSRun'
            }
        }
        else {
            return $command
        }
    }

    [void] RequestInvokePsRun($query) {
        $this.invokePsRunRequest = $true
        $this.invokePsRunRequestQuery = $query
    }

    [void] SetPSReadLineKeyHandler($chord) {
        $this.RemovePSReadLineKeyHandler()

        $this.psReadLineChord = $chord
        Set-PSReadLineKeyHandler -Chord $chord -ScriptBlock {
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

            $script:globalStore.RequestInvokePsRun($line)
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        }
    }

    [void] RemovePSReadLineKeyHandler() {
        if ($this.psReadLineChord) {
            Remove-PSReadLineKeyHandler -Chord $this.psReadLineChord
            $this.psReadLineChord = $null
        }
    }

    # Class methods cannot pass through the output of invoked command line apps in realtime so we use ScriptBlock.
    $invokeFile = {
        param($path)
        $command = Get-Command $path -ErrorAction SilentlyContinue
        if ($command -and ($command.CommandType -eq 'Application')) {
            # do not open new window when this is a command line app.
            & $path
        }
        elseif ($path.Contains('shell:', 'OrdinalIgnoreCase')) {
            # On Windows, Invoke-Item cannot open special folders.
            Start-Process $path
        }
        else {
            # .ps1 files or .app files on macOS come here.
            Invoke-Item $path
        }
    }
}
