function Invoke-PSRunSelector {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Object[]]$InputObject,

        [String]$NameProperty = 'Name',

        [String]$DescriptionProperty = 'Description',

        [String]$PreviewProperty = 'Preview',

        [ScriptBlock]$Expression,

        [Switch]$MultiSelection,

        [PowerShellRun.SelectorOption]$Option = $script:globalStore.defaultSelectorOption,

        [PowerShellRun.SelectorContext]$Context
    )

    begin {
        $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    }
    process {
        foreach ($obj in $InputObject) {
            $entry = [PowerShellRun.SelectorEntry]::new()
            $entry.UserData = $obj
            if ($Expression) {
                $obj = $obj | ForEach-Object $Expression
            }
            if (($null -eq $obj.$NameProperty)) {
                if ($null -ne $obj) {
                    $entry.Name = $obj.ToString()
                }
            } else {
                $entry.Name = $obj.$NameProperty
            }
            $entry.Description = $obj.$DescriptionProperty
            $entry.Preview = $obj.$PreviewProperty
            $entries.Add($entry)
        }
    }
    end {
        $mode = if ($MultiSelection) { [PowerShellRun.SelectorMode]::MultiSelection } else { [PowerShellRun.SelectorMode]::SingleSelection }
        $result = [PowerShellRun.Selector]::Open($entries, $mode, $Option, $Context)

        if ($result.MarkedEntries) {
            $result.MarkedEntries.UserData
        } else {
            $result.FocusedEntry.UserData
        }
    }
}
