#Requires -Modules RestartableSession

$root = Split-Path $PSScriptRoot -Parent
Enter-RSSession -OnStart {
    $root = $args[0]
    $netVersion = 'net6.0'
    $build = "$root/Build.ps1"

    & $build Debug
    Import-Module "$root/module/PowerShellRun"

    function Pester
    {
        & "$root/tests/RunPesterTests.ps1"
    }
} -OnStartArgumentList $root -ShowProcessId