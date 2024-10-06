using module ./_EntryRegistry.psm1
using module ./_EntryGroup.psm1

[NoRunspaceAffinity()]
class GlobalStore {
    $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $isEntryInitialized = $false
    $defaultSelectorOption = [PowerShellRun.SelectorOption]::new()
    $psRunSelectorOption = [PowerShellRun.SelectorOption]::new()

    # When you add a new category, you also need to add to the ValidateSet of Enable-PSRunEntry and Add-PSRunEntryGroup.
    $allCategoryNames = @(
        'Application'
        'Executable'
        'Function'
        'Utility'
        'Favorite'
        'Script'
        'EntryGroup'
    )
    $registryClassNames = @(
        'EntryGroupRegistry'
        'FunctionRegistry'
        'ScriptRegistry'
        'FileSystemRegistry'
        'WinGetRegistry'
        'ApplicationRegistry'
    )
    $registries = [System.Collections.Generic.List[EntryRegistry]]::new()
    $entryGroupRegistry = $null

    $originalPSConsoleHostReadLine = $null
    $isReadLineReplaced = $false
    $invokePsRunRequest = $false
    $invokePsRunRequestQuery = ''
    $invokePsRunChord = $null
    $psReadLineHistoryChord = $null

    $firstActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)
    $secondActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)
    $thirdActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)
    $copyActionKey = [PowerShellRun.KeyCombination]::new([PowerShellRun.KeyModifier]::None, [PowerShellRun.Key]::None)

    [ScriptBlock]$defaultEditorScript

    [void] Initialize() {
        $this.InitializeActionKeys()

        $this.defaultEditorScript = {
            param ($path)
            Invoke-Item $path
        }

        foreach ($className in $this.registryClassNames) {
            $registry = New-Object $className
            $this.registries.Add($registry)
        }
        $this.entryGroupRegistry = $this.GetRegistry('EntryGroupRegistry')
    }

    [void] Terminate() {
        # Wait for async entry initializations
        $this.UpdateEntries()

        $this.RemoveInvokePsRunChord()
        $this.RemovePSReadLineHistoryChord()
        $this.RestorePSConsoleHostReadLine()
    }

    [void] InitializeActionKeys() {
        $_firstActionKey = [PowerShellRun.KeyCombination]::new('Enter')
        if ($script:isMacOs) {
            $_secondActionKey = [PowerShellRun.KeyCombination]::new('Alt+Enter')
            $_thirdActionKey = [PowerShellRun.KeyCombination]::new('Alt+J')
            $_copyActionKey = [PowerShellRun.KeyCombination]::new('Ctrl+C')
        } else {
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

    [PowerShellRun.SelectorOption] GetPSRunSelectorOption() {
        return $this.psRunSelectorOption.DeepClone()
    }

    [EntryRegistry] GetRegistry($typeName) {
        foreach ($registry in $this.registries) {
            if ($registry.GetType().Name -eq $typeName) {
                return $registry
            }
        }
        return $null
    }

    [void] InitializeEntries([String[]]$entryCategories) {
        if ($this.isEntryInitialized) {
            return
        }
        foreach ($registry in $this.registries) {
            $registry.InitializeEntries($entryCategories)
        }
        $this.isEntryInitialized = $true
    }

    [bool] IsEntriesInitialized() {
        return $this.isEntryInitialized
    }

    [void] UpdateEntries() {
        $updated = $false
        foreach ($registry in $this.registries) {
            $updated = $registry.UpdateEntries() -or $updated
        }

        if ($updated) {
            $this.entries.Clear()
            $categoryGroups = $this.entryGroupRegistry.GetCategoryGroups()
            $ungroupedCategories = $this.allCategoryNames

            foreach ($categoryGroup in $categoryGroups) {
                $categoryGroup.ClearCategoryEntries()
                foreach ($registry in $this.registries) {
                    if ($_entries = $registry.GetEntries($categoryGroup.Categories)) {
                        $categoryGroup.AddCategoryEntries($_entries)
                    }

                    foreach ($groupCategory in $categoryGroup.Categories) {
                        $ungroupedCategories = $ungroupedCategories -ne $groupCategory
                    }
                }
                $categoryGroup.UpdateEntries()
            }

            foreach ($registry in $this.registries) {
                if ($_entries = $registry.GetEntries($ungroupedCategories)) {
                    $this.entries.AddRange($_entries)
                }
            }
        }
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
                return ('Invoke-PSRun -InitialQuery "{0}"' -f $this.invokePsRunRequestQuery)
            } else {
                return 'Invoke-PSRun'
            }
        } else {
            return $command
        }
    }

    [void] RequestInvokePsRun($query) {
        $this.invokePsRunRequest = $true
        $this.invokePsRunRequestQuery = $query
    }

    [void] SetInvokePsRunChord($chord) {
        $this.ReplacePSConsoleHostReadLine()
        $this.RemoveInvokePsRunChord()

        $this.invokePsRunChord = $chord
        Set-PSReadLineKeyHandler -Chord $chord -ScriptBlock {
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

            $script:globalStore.RequestInvokePsRun($line)
            [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        }
    }

    [void] RemoveInvokePsRunChord() {
        if ($this.invokePsRunChord) {
            Remove-PSReadLineKeyHandler -Chord $this.invokePsRunChord
            $this.invokePsRunChord = $null
        }
    }

    [void] SetPSReadLineHistoryChord($chord) {
        $this.RemovePSReadLineHistoryChord()

        $this.psReadLineHistoryChord = $chord
        Set-PSReadLineKeyHandler -Chord $chord -ScriptBlock {
            SearchPSReadLineHistory
        }
    }

    [void] RemovePSReadLineHistoryChord() {
        if ($this.psReadLineHistoryChord) {
            Remove-PSReadLineKeyHandler -Chord $this.psReadLineHistoryChord
            $this.psReadLineHistoryChord = $null
        }
    }

    [void] SetDefaultEditorScript([ScriptBlock]$scriptBlock) {
        $this.defaultEditorScript = $scriptBlock
    }

    [void] OpenContainingFolder($path) {
        if ($script:isWindows) {
            & explorer.exe (('/select,{0}' -f $path).Split())
        } else {
            $parentDir = ([System.IO.Directory]::GetParent($path)).FullName
            Invoke-Item $parentDir
        }
    }

    # Class methods cannot pass through the output of invoked command line apps in realtime so we use ScriptBlock.
    $invokeFile = {
        param($path, $argumentList)
        $command = Get-Command $path -ErrorAction SilentlyContinue
        if ($command -and ($command.CommandType -eq 'Application')) {
            # do not open new window when this is a command line app.
            & $path $argumentList
        } elseif ($path.Contains('shell:', 'OrdinalIgnoreCase')) {
            # On Windows, Invoke-Item cannot open special folders.
            Start-Process $path -ArgumentList $argumentList
        } else {
            # .ps1 files or .app files on macOS come here.
            Invoke-Item $path
        }
    }

    [Object[]] GetArgumentListFor([String]$name) {
        $option = $this.GetPSRunSelectorOption()
        $option.Prompt = 'Type arguments for {0}> ' -f $name
        $option.QuitWithBackspaceOnEmptyQuery = $true
        $promptResult = Invoke-PSRunPrompt -Option $option

        if ($null -eq $promptResult.Input) {
            return $null, $promptResult.KeyCombination
        } else {
            $literalQuoteRegex = "(?<=^(?:[^`"]*`"[^`"]*`")*[^`"]*`"[^`"]*)'"
            $literalDoubleQuoteRegex = "(?<=^(?:[^']*'[^']*')*[^']*'[^']*)`""
            $nonQuotedSpaceRegex = "(?<=^(?:[^`"]*`"[^`"]*`")*[^`"]*)(?<=^(?:[^']*'[^']*')*[^']*)\s+"

            # Replace quote enclosed by double quotes and double quote enclosed by quotes to simplify the splitting.
            $inputString = $promptResult.Input
            $inputString = $inputString -replace $literalQuoteRegex, "`u{0}"
            $inputString = $inputString -replace $literalDoubleQuoteRegex, "`u{1}"

            $argumentList = $inputString -split $nonQuotedSpaceRegex
            for ($i = 0; $i -lt $argumentList.Count; ++$i) {
                $argument = $argumentList[$i]
                $argument = $argument -replace "`u{0}", "'"
                $argument = $argument -replace "`u{1}", '"'

                # Remove enclosing quotes
                if ($argument.Length -ge 2) {
                    if ((($argument[0] -eq "'") -and ($argument[$argument.Length - 1] -eq "'")) -or
                        (($argument[0] -eq '"') -and ($argument[$argument.Length - 1] -eq '"'))) {
                        $argument = $argument.Substring(1, $argument.Length - 2)
                    }
                }

                $argumentList[$i] = $argument
            }

            return $argumentList, $promptResult.KeyCombination
        }
    }

    [Object] GetParameterList($astParameters) {
        if (-not $astParameters) {
            return @{}
        }

        $option = $this.GetPSRunSelectorOption()
        $option.QuitWithBackspaceOnEmptyQuery = $true

        $parameters = @{}
        $promptContexts = @{}
        for ($i = 0; $i -lt $astParameters.Count; ) {
            $parameterName = $astParameters[$i].Name.VariablePath.UserPath.Replace('$', '')
            $option.Prompt = '{0}> ' -f $parameterName
            $promptContext = $promptContexts[$parameterName]
            $promptResult = Invoke-PSRunPrompt -Option $option -Context $promptContext

            if ([PowerShellRun.ExitStatus]::Type -eq [PowerShellRun.ExitType]::QuitWithBackspaceOnEmptyQuery) {
                $promptContexts[$parameterName] = $null
                if ($i -eq 0) {
                    return $null
                } else {
                    --$i
                }
            } elseif ($null -eq $promptResult.Input) {
                return $null
            } else {
                $parameters[$parameterName] = $promptResult.Input
                $promptContexts[$parameterName] = $promptResult.Context
                ++$i
            }
        }
        return $parameters
    }
}
