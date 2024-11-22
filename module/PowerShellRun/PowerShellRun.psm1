
$netVersion = 'net8.0'
$dll = "$PSScriptRoot/bin/$netVersion/PowerShellRun.dll"
Import-Module $dll

# To avoid global variable access from classes (PSAvoidGlobalVars)
$script:isWindows = $IsWindows
$script:isMacOs = $IsMacOS
$script:isLinux = $IsLinux

$privateScripts = @(Get-ChildItem $PSScriptRoot/Private/*.ps1 -Exclude _*)
$publicScripts = @(Get-ChildItem $PSScriptRoot/Public/*.ps1)
foreach ($private:script in ($privateScripts + $publicScripts)) {
    . $script.FullName
}

$script:globalStore = [GlobalStore]::new()
$script:globalStore.Initialize()

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { $script:globalStore.Terminate() }

Export-ModuleMember -Function $publicScripts.BaseName
