using module ./_EntryGroup.psm1
using module ./_EntryRegistry.psm1

[NoRunspaceAffinity()]
class FileSystemRegistry : EntryRegistry {
    $favoritesEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    $fileManagerEntry = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()

    $isFavoritesEnabled = $false
    $isFileManagerEnabled = $false
    $isEntryUpdated = $false

    $fileManagerArguments

    FileSystemRegistry() {
        $this.fileManagerArguments = @{
            This = $this
            FolderActionKeys = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Go inside')
                [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Set-Location')
                [PowerShellRun.ActionKey]::new($script:globalStore.thirdActionKey, 'Open with default app')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy path to Clipboard')
            )
            FileActionKeys = @(
                [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Open with default app')
                [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Edit with default editor')
                [PowerShellRun.ActionKey]::new($script:globalStore.thirdActionKey, 'Open containing folder')
                [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy path to Clipboard')
            )
            PreviewScriptFolder = {
                param ($path)
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
            PreviewScriptFile = {
                param ($path)
                Get-Item $path | Out-String
            }
        }
    }

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
        if ($categories -contains 'Favorite') {
            $entries.AddRange($this.favoritesEntries)
        }
        if ($categories -contains 'Utility') {
            $entries.AddRange($this.fileManagerEntry)
        }
        return $entries
    }

    [void] InitializeEntries([String[]]$categories) {
        $this.isEntryUpdated = $true

        $this.isFavoritesEnabled = $categories -contains 'Favorite'

        $this.isFileManagerEnabled = $categories -contains 'Utility'
        $this.fileManagerEntry.Clear()
        if ($this.isFileManagerEnabled) {
            $this.RegisterFileManagerEntry()
        }
    }

    [void] RegisterFileManagerEntry() {
        $callback = {
            $result = $args[0].Result
            $arguments = $args[0].ArgumentList
            $rootDir = (Get-Location).Path

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $arguments.This.fileManagerLoop $rootDir $arguments
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $rootDir | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = '🔍'
        $entry.Name = 'File Manager (PSRun)'
        $entry.Description = 'Navigate file system with PowerShellRun based on the current directory'
        $entry.ActionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Explore current directory')
            [PowerShellRun.ActionKey]::new($script:globalStore.copyActionKey, 'Copy current directory path to Clipboard')
        )

        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this.fileManagerArguments
        }

        $this.fileManagerEntry.Add($entry)
    }

    [void] AddFavoriteFolder($folderPath, $icon, $name, $description, $preview, [EntryGroup]$entryGroup) {
        if (-not $this.isFavoritesEnabled) {
            Write-Warning -Message '"Favorite" category is disabled.'
            return
        }

        $callback = {
            $result = $args[0].Result
            $arguments, $path = $args[0].ArgumentList

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $arguments.This.fileManagerLoop $path $arguments
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                Set-Location $path
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                Invoke-Item $path
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $path | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($icon) { $icon } else { '📁' }
        $entry.Name = if ($name) { $name } else { Split-Path $folderPath -Leaf }
        $entry.Description = if ($description) { $description } else { $folderPath }
        if ($preview) {
            $entry.Preview = $preview
        } else {
            $entry.PreviewAsyncScript = $this.fileManagerArguments.PreviewScriptFolder
            $entry.PreviewAsyncScriptArgumentList = $folderPath
        }
        $entry.ActionKeys = $this.fileManagerArguments.FolderActionKeys

        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $this.fileManagerArguments, $folderPath
        }

        if ($entryGroup) {
            $entryGroup.AddEntry($entry)
        } else {
            $this.favoritesEntries.Add($entry)
            $this.isEntryUpdated = $true
        }
    }

    [void] AddFavoriteFile($filePath, $icon, $name, $description, $preview, [EntryGroup]$entryGroup) {
        if (-not $this.isFavoritesEnabled) {
            Write-Warning -Message '"Favorite" category is disabled.'
            return
        }

        $callback = {
            $result = $args[0].Result
            $path = $args[0].ArgumentList

            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $script:globalStore.invokeFile $path
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                & $script:globalStore.defaultEditorScript $path
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                $script:globalStore.OpenContainingFolder($path)
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $path | Set-Clipboard
            }
        }

        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.Icon = if ($icon) { $icon } else { '📄' }
        $entry.Name = if ($name) { $name } else { Split-Path $filePath -Leaf }
        $entry.Description = if ($description) { $description } else { $filePath }
        if ($preview) {
            $entry.Preview = $preview
        } else {
            $entry.PreviewAsyncScript = $this.fileManagerArguments.PreviewScriptFile
            $entry.PreviewAsyncScriptArgumentList = $filePath
        }
        $entry.ActionKeys = $this.fileManagerArguments.FileActionKeys

        $entry.UserData = @{
            ScriptBlock = $callback
            ArgumentList = $filePath
        }

        if ($entryGroup) {
            $entryGroup.AddEntry($entry)
        } else {
            $this.favoritesEntries.Add($entry)
            $this.isEntryUpdated = $true
        }
    }

    $fileManagerLoop = {
        param($rootDir, $arguments)

        $option = $script:globalStore.GetPSRunSelectorOption()
        $option.QuitWithBackspaceOnEmptyQuery = $true

        $distance = 0
        $currentDir = @{
            path = $rootDir
            prevDir = $null
        }
        while ($true) {
            $option.Prompt = "($distance) $($currentDir.path)> "

            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
            $addEntry = {
                param($arguments, $item, $name, $icon)
                $entry = [PowerShellRun.SelectorEntry]::new()
                $entry.UserData = $item
                $entry.Name = $name
                if ($item.PSIsContainer) {
                    $entry.Icon = if ($icon) { $icon } else { '📁' }
                    $entry.PreviewAsyncScript = $arguments.PreviewScriptFolder
                    $entry.ActionKeys = $arguments.FolderActionKeys
                } else {
                    $entry.Icon = if ($icon) { $icon } else { '📄' }
                    $entry.PreviewAsyncScript = $arguments.PreviewScriptFile
                    $entry.ActionKeys = $arguments.FileActionKeys
                }
                $entry.PreviewAsyncScriptArgumentList = $item.FullName
                $entries.Add($entry)
            }

            Get-ChildItem -Path $currentDir.path | ForEach-Object {
                $addEntry.Invoke($arguments, $_, $_.Name)
            }

            $parentItem = (Get-Item $currentDir.path).Parent
            if ($parentItem) {
                $addEntry.Invoke($arguments, (Get-Item $parentItem.FullName), '../', '🔼')
            }

            $result = Invoke-PSRunSelectorCustom -Entry $entries -Option $option

            if ($result.KeyCombination -eq 'Backspace') {
                if ($distance -eq 0) {
                    break
                } else {
                    $distance--
                    $currentDir.path = $currentDir.prevDir.path
                    $currentDir.prevDir = $currentDir.prevDir.prevDir
                    continue
                }
            }

            if (-not $result.FocusedEntry) {
                break
            }

            $item = $result.FocusedEntry.UserData
            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                if ($item.PSIsContainer) {
                    $distance++
                    $currentDir.prevDir = @{
                        path = $currentDir.path
                        prevDir = $currentDir.prevDir
                    }
                    $currentDir.path = $item.FullName
                } else {
                    & $script:globalStore.invokeFile $item.FullName
                    break
                }
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                if ($item.PSIsContainer) {
                    Set-Location $item.FullName
                } else {
                    & $script:globalStore.defaultEditorScript $item.FullName
                }
                break
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                if ($item.PSIsContainer) {
                    Invoke-Item $item.FullName
                } else {
                    $script:globalStore.OpenContainingFolder($item.FullName)
                }
                break
            } elseif ($result.KeyCombination -eq $script:globalStore.copyActionKey) {
                $item.FullName | Set-Clipboard
                break
            } else {
                break
            }
        }
    }

    [bool] UpdateEntries() {
        $updated = $this.isEntryUpdated
        $this.isEntryUpdated = $false
        return $updated
    }
}

