using module ./_EntryRegistry.psm1
class ApplicationRegistry : EntryRegistry {
    $sync = [System.Collections.Hashtable]::Synchronized(@{})
    $registerEntryJob = $null

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
        if ($this.sync.applicationEntries -and ($categories -contains 'Application')) {
            $entries.AddRange($this.sync.applicationEntries)
        }
        if ($this.sync.executableEntries -and ($categories -contains 'Executable')) {
            $entries.AddRange($this.sync.executableEntries)
        }
        return $entries
    }

    [void] InitializeEntries([String[]]$categories) {
        if ($script:isWindows) {
            $this.StartRegisterEntriesWindows($categories)
        } elseif ($script:isMacOs) {
            $this.StartRegisterEntriesMacOs($categories)
        }
    }

    [void] StartRegisterEntriesWindows($categories) {
        $actionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Launch App')
            [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Launch App as Admin')
            [PowerShellRun.ActionKey]::new($script:globalStore.thirdActionKey, 'Launch App with arguments')
        )
        $callback = {
            $result = $args[0].Result
            $path, $name = $args[0].ArgumentList
            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $script:globalStore.invokeFile $path
            } elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                Start-Process $path -Verb runAs
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                $argumentList = $script:globalStore.GetArgumentListFor($name)
                if ($null -eq $argumentList) {
                    Restore-PSRunParentSelector
                } else {
                    & $script:globalStore.invokeFile $path $argumentList
                }
            }
        }

        $this.registerEntryJob = Start-ThreadJob {
            param ($categories, $actionKeys, $callback, $sync)

            $applicationEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
            $executableEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()

            if ($categories -contains 'Application') {
                # Start Menu shortcuts
                $startMenuFolders = @(
                    "$env:userprofile\AppData\Roaming\Microsoft\Windows\Start Menu\Programs",
                    'C:\ProgramData\Microsoft\Windows\Start Menu\Programs'
                )

                $shell = New-Object -ComObject WScript.Shell

                foreach ($folder in $startMenuFolders) {
                    $links = Get-ChildItem $folder -Filter '*.lnk' -Recurse
                    foreach ($link in $links) {
                        $shortcut = $shell.CreateShortcut($link.FullName)
                        $entry = [PowerShellRun.SelectorEntry]::new()
                        $entry.Icon = '🚀'
                        $entry.Name = $link.BaseName
                        $entry.Description = $shortcut.Description
                        $entry.Preview = $link.FullName
                        $entry.ActionKeys = $actionKeys

                        $entry.UserData = @{
                            ScriptBlock = $callback
                            ArgumentList = $link.FullName, $entry.Name
                        }

                        $applicationEntries.Add($entry)
                    }
                }

                # Store Apps
                $shell = New-Object -ComObject shell.application
                $appsFolder = $shell.NameSpace('shell:AppsFolder')
                foreach ($item in $appsFolder.Items()) {
                    if (-not $item.Path.Contains('!')) {
                        continue
                    }
                    $path = 'shell:AppsFolder\{0}' -f $item.Path
                    $entry = [PowerShellRun.SelectorEntry]::new()
                    $entry.Icon = '🪟'
                    $entry.Name = $item.Name
                    $entry.Preview = $path
                    # Store Apps don't run as admin
                    $entry.ActionKeys = $actionKeys[0], $actionKeys[2]

                    $entry.UserData = @{
                        ScriptBlock = $callback
                        ArgumentList = $path, $entry.Name
                    }

                    $applicationEntries.Add($entry)
                }
            }
            $sync.applicationEntries = $applicationEntries

            # Executables in Path
            if ($categories -contains 'Executable') {
                $apps = Get-Command -CommandType Application
                foreach ($app in $apps) {
                    $entry = [PowerShellRun.SelectorEntry]::new()
                    $entry.Icon = '🔧'
                    $entry.Name = $app.Name
                    $entry.Preview = $app | Select-Object -Property Version, Source | Out-String
                    $entry.ActionKeys = $actionKeys

                    $entry.UserData = @{
                        ScriptBlock = $callback
                        ArgumentList = $app.Source, $entry.Name
                    }

                    $executableEntries.Add($entry)
                }
            }
            $sync.executableEntries = $executableEntries

        } -ArgumentList $categories, $actionKeys, $callback, $this.sync
    }

    [void] StartRegisterEntriesMacOs($categories) {
        $actionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Launch App')
            [PowerShellRun.ActionKey]::new($script:globalStore.thirdActionKey, 'Launch App with arguments')
        )
        $callback = {
            $result = $args[0].Result
            $fullName, $name = $args[0].ArgumentList
            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $script:globalStore.invokeFile $fullName
            } elseif ($result.KeyCombination -eq $script:globalStore.thirdActionKey) {
                $argumentList = $script:globalStore.GetArgumentListFor($name)
                if ($null -eq $argumentList) {
                    Restore-PSRunParentSelector
                } else {
                    & $script:globalStore.invokeFile $fullName $argumentList
                }
            }
        }

        $this.registerEntryJob = Start-ThreadJob {
            param ($categories, $actionKeys, $callback, $sync)

            $applicationEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
            $executableEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()

            if ($categories -contains 'Application' ) {
                $folders = @(
                    '/Applications'
                    '/Applications/Utilities'
                    '/System/Applications'
                    '/System/Applications/Utilities'
                    '/System/Library/CoreServices/Applications'
                )

                foreach ($folder in $folders) {
                    $apps = Get-ChildItem $folder -Filter '*.app'
                    foreach ($app in $apps) {
                        $entry = [PowerShellRun.SelectorEntry]::new()
                        $entry.Icon = '🚀'
                        $entry.Name = [System.IO.Path]::GetFileNameWithoutExtension($app.BaseName)
                        $entry.Preview = $app.FullName
                        $entry.ActionKeys = $actionKeys

                        $entry.UserData = @{
                            ScriptBlock = $callback
                            ArgumentList = $app.FullName, $entry.Name
                        }

                        $applicationEntries.Add($entry)
                    }
                }
            }
            $sync.applicationEntries = $applicationEntries

            # Executables in Path
            if ($categories -contains 'Executable') {
                $apps = Get-Command -CommandType Application
                foreach ($app in $apps) {
                    $entry = [PowerShellRun.SelectorEntry]::new()
                    $entry.Icon = '🔧'
                    $entry.Name = $app.Name
                    $entry.Preview = $app | Select-Object -Property Version, Source | Out-String
                    $entry.ActionKeys = $actionKeys

                    $entry.UserData = @{
                        ScriptBlock = $callback
                        ArgumentList = $app.Source, $entry.Name
                    }

                    $executableEntries.Add($entry)
                }
            }
            $sync.executableEntries = $executableEntries

        } -ArgumentList $categories, $actionKeys, $callback, $this.sync
    }

    [bool] UpdateEntries() {
        if ($this.registerEntryJob) {
            Receive-Job $this.registerEntryJob -Wait | Out-Null
            $this.registerEntryJob | Remove-Job
            $this.registerEntryJob = $null
            return $true
        }
        return $false
    }
}

