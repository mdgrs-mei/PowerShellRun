function Invoke-PSRunSelectorCustom
{
    [CmdletBinding()]
    [OutputType([PowerShellRun.SelectorResult])]
    param
    (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [PowerShellRun.SelectorEntry[]]$Entry,

        [Switch]$MultiSelection,

        [PowerShellRun.SelectorOption]$Option = $script:globalStore.defaultSelectorOption,

        [PowerShellRun.SelectorContext]$Context
    )

    begin
    {
        $isPipelineInput = $MyInvocation.ExpectingInput
        if ($isPipelineInput)
        {
            $entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
        }
    }
    process
    {
        if ($isPipelineInput)
        {
            $entries.Add($Entry[0])
        }
    }
    end
    {
        $mode = if ($MultiSelection) {[PowerShellRun.SelectorMode]::MultiSelection} else {[PowerShellRun.SelectorMode]::SingleSelection}
        if ($isPipelineInput)
        {
            $result = [PowerShellRun.Selector]::Open($entries, $mode, $Option, $Context)
        }
        else
        {
            $result = [PowerShellRun.Selector]::Open($Entry, $mode, $Option, $Context)
        }
        $result
    }
}