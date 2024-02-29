class ApplicationRegistry {
    $sync = [System.Collections.Hashtable]::Synchronized(@{})
    $registerEntryJob = $null

    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries() {
        return $this.sync.entries
    }

    [void] EnableEntries([String[]]$categories) {
        # Wait for the previous job if exists
        $this.UpdateEntries()

        if ($script:isWindows) {
            $this.StartRegisterEntriesWindows($categories)
        }
        elseif ($script:isMacOs) {
            $this.StartRegisterEntriesMacOs($categories)
        }
    }

    [void] StartRegisterEntriesWindows($categories) {
        $actionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Launch App')
            [PowerShellRun.ActionKey]::new($script:globalStore.secondActionKey, 'Launch App as Admin')
        )
        $callback = {
            $result = $args[0].Result
            $path = $args[0].ArgumentList
            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $script:globalStore.invokeFile $path
            }
            elseif ($result.KeyCombination -eq $script:globalStore.secondActionKey) {
                Start-Process $path -Verb runAs
            }
        }

        $this.registerEntryJob = Start-ThreadJob {
            param ($categories, $actionKeys, $callback, $sync)

            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()

            if ($categories -Contains 'Application') {
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
                            ScriptBlock  = $callback
                            ArgumentList = $link.FullName
                        }

                        $entries.Add($entry)
                    }
                }

                # Store Apps
                $shell = New-Object -ComObject shell.application
                $appsFolder = $shell.NameSpace("shell:AppsFolder")
                foreach ($item in $appsFolder.Items()) {
                    if (-not $item.Path.Contains('!')) {
                        continue
                    }
                    $path = "shell:AppsFolder\{0}" -f $item.Path
                    $entry = [PowerShellRun.SelectorEntry]::new()
                    $entry.Icon = '🪟'
                    $entry.Name = $item.Name
                    $entry.Preview = $path
                    # Store Apps don't run as admin
                    $entry.ActionKeys = $actionKeys[0]

                    $entry.UserData = @{
                        ScriptBlock  = $callback
                        ArgumentList = $path
                    }

                    $entries.Add($entry)
                }
            }

            # Executables in Path
            if ($categories -Contains 'Executable') {
                $apps = Get-Command -CommandType Application
                foreach ($app in $apps) {
                    $entry = [PowerShellRun.SelectorEntry]::new()
                    $entry.Icon = '🔧'
                    $entry.Name = $app.Name
                    $entry.Preview = $app | Select-Object -Property Version, Source | Out-String
                    $entry.ActionKeys = $actionKeys

                    $entry.UserData = @{
                        ScriptBlock  = $callback
                        ArgumentList = $app.Source
                    }

                    $entries.Add($entry)
                }
            }

            $sync.entries = $entries
        } -ArgumentList $categories, $actionKeys, $callback, $this.sync
    }

    [void] StartRegisterEntriesMacOs($categories) {
        $actionKeys = @(
            [PowerShellRun.ActionKey]::new($script:globalStore.firstActionKey, 'Launch App')
        )
        $callback = {
            $result = $args[0].Result
            $fullName = $args[0].ArgumentList
            if ($result.KeyCombination -eq $script:globalStore.firstActionKey) {
                & $script:globalStore.invokeFile $fullName
            }
        }

        $this.registerEntryJob = Start-ThreadJob {
            param ($categories, $actionKeys, $callback, $sync)

            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()

            if ($categories -Contains 'Application' ) {
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
                            ScriptBlock  = $callback
                            ArgumentList = $app.FullName
                        }

                        $entries.Add($entry)
                    }
                }
            }

            # Executables in Path
            if ($categories -Contains 'Executable') {
                $apps = Get-Command -CommandType Application
                foreach ($app in $apps) {
                    $entry = [PowerShellRun.SelectorEntry]::new()
                    $entry.Icon = '🔧'
                    $entry.Name = $app.Name
                    $entry.Preview = $app | Select-Object -Property Version, Source | Out-String
                    $entry.ActionKeys = $actionKeys

                    $entry.UserData = @{
                        ScriptBlock  = $callback
                        ArgumentList = $app.Source
                    }

                    $entries.Add($entry)
                }
            }

            $sync.entries = $entries
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

