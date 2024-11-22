param (
    [ValidateSet('Debug', 'Release')]
    [String]$Configuration = 'Debug'
)

$netVersion = 'net8.0'
$copyExtensions = @('.dll', '.pdb')
$src = "$PSScriptRoot/src"
$coreSrc = "$src/PowerShellRun"
$depSrc = "$src/PowerShellRun.Dependency"
$outDir = "$PSScriptRoot/module/PowerShellRun/bin/$netVersion"
$outDeps = "$outDir/Dependencies"

Push-Location $depSrc
dotnet publish -c $Configuration
Pop-Location

Push-Location $coreSrc
dotnet publish -c $Configuration
Pop-Location

Remove-Item -Path $outDir -Recurse -ErrorAction Ignore
New-Item -Path $outDir -ItemType Directory
New-Item -Path $outDeps -ItemType Directory

$deps = [System.Collections.Generic.List[string]]::new()
Get-ChildItem -Path "$depSrc/bin/$Configuration/$netVersion/publish/" |
    Where-Object { $_.Extension -in $copyExtensions } |
    ForEach-Object { [void]$deps.Add($_.Name); Copy-Item -Path $_.FullName -Destination $outDeps }

Get-ChildItem -Path "$coreSrc/bin/$Configuration/$netVersion/publish/" |
    Where-Object { -not ($deps -contains $_.Name) -and $_.Extension -in $copyExtensions } |
    ForEach-Object { Copy-Item -Path $_.FullName -Destination $outDir }
