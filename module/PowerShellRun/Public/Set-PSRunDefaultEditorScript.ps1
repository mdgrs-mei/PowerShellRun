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
        $fileSystemRegistry = $script:globalStore.GetRegistry('FileSystemRegistry')
        $fileSystemRegistry.SetDefaultEditorScript($ScriptBlock)
    }
}
