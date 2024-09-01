class EntryGroup {
    [Object]$Registry
    [String]$Name
    [String[]]$Categories
    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]$CategoryEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]$DirectChildEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]$Entries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()
    [bool]$IsEntryUpdated = $false

    EntryGroup([Object]$registry, [String]$name, [String[]]$categories) {
        $this.Registry = $registry
        $this.Name = $name
        $this.Categories = $categories
    }

    [void] AddEntry([PowerShellRun.SelectorEntry]$entry) {
        $this.DirectChildEntries.Add($entry)
        $this.IsEntryUpdated = $true
        $this.registry.SetEntriesDirty()
    }

    [void] AddCategoryEntries([System.Collections.Generic.List[PowerShellRun.SelectorEntry]]$entries) {
        $this.CategoryEntries.AddRange($entries)
        $this.IsEntryUpdated = $true
    }

    [void] ClearCategoryEntries() {
        $this.CategoryEntries.Clear()
        $this.IsEntryUpdated = $true
    }

    [void] UpdateEntries() {
        if (-not $this.IsEntryUpdated) {
            return
        }

        $this.Entries.Clear()
        $this.Entries.AddRange($this.CategoryEntries)
        $this.Entries.AddRange($this.DirectChildEntries)
        $this.IsEntryUpdated = $false
    }
}
