<#
.SYNOPSIS
Sets the default file editor script.

.DESCRIPTION
Sets the default file editor script that is used by file entries and script file entries.
The file entries have an 'Edit' action that invokes this ScriptBlock. The first argument is the path to the file, and you can specify the script that opens the file with your favorite editor.

.PARAMETER ScriptBlock
Specifies the ScriptBlock that opens the file. The first argument is the filepath.
The following script is used by default:
{
    param ($path)
    Invoke-Item $path
}

.INPUTS
None.

.OUTPUTS
None.

.EXAMPLE
Set-PSRunDefaultEditorScript -ScriptBlock {
    param ($path)
    nvim $path
}
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
