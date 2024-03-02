#Requires -Modules RestartableSession

$root = Split-Path $PSScriptRoot -Parent
Enter-RSSession -OnStart {
    $root = $args[0]
    $netVersion = 'net6.0'
    $build = "$root/Build.ps1"

    & $build Debug
    Import-Module "$root/module/PowerShellRun"
    Enable-PSRunEntry -Category All

    function Restart {
        Restart-RSSession
    }
    function Pester {
        & "$root/tests/RunPesterTests.ps1"
    }
} -OnStartArgumentList $root -ShowProcessId
