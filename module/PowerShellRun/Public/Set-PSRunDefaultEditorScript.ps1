<#
.SYNOPSIS
Sets the default file editor script.
#>
function Set-PSRunDefaultEditorScript {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ScriptBlock]$ScriptBlock
    )

    process {
        $script:globalStore.SetDefaultEditorScript($ScriptBlock)
    }
}
