#Requires -Modules RestartableSession

$root = Split-Path $PSScriptRoot -Parent
Enter-RSSession -OnStart {
    $root = $args[0]
    $netVersion = 'net6.0'
    $build = "$root/Build.ps1"

    & $build Debug
    Import-Module "$root/module/PowerShellRun"
    Enable-PSRunEntry -Category All
    Set-PSRunPSReadLineKeyHandler -InvokePSRunChord 'Ctrl+Spacebar' -PSReadLineHistoryChord 'Ctrl+r'

    function Restart {
        Restart-RSSession
    }
    function Pester {
        & "$root/tests/RunPesterTests.ps1"
    }
} -OnStartArgumentList $root -ShowProcessId
