#Requires -Modules PSScriptAnalyzer

BeforeAll {
    $moduleDir = "$PSScriptRoot/../module/PowerShellRun/"
    # Define exclude rule types here since 'TypeNotFound' cannot be suppressed by settings or attributes.
    $excludeRules = @(
        'TypeNotFound'
        'PSUseBOMForUnicodeEncodedFile'
        'PSUseUsingScopeModifierInNewRunspaces'
    )
}

Describe 'PowerShellRun' {
    It 'shows no warnings and errors of PSScriptAnalyzer' {
        $result = Invoke-ScriptAnalyzer -Path $moduleDir -Recurse
        $result = $result | Where-Object {
            -not ($_.RuleName -in $excludeRules)
        }
        $result | Out-String | Write-Host
        $result.Count | Should -Be 0
    }
}
