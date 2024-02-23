#Requires -Modules @{ ModuleName='Pester'; ModuleVersion='5.0.0'}

$config = New-PesterConfiguration
$config.Run.PassThru = $true
$config.Run.Path = $PSScriptRoot

Invoke-Pester -Configuration $config
