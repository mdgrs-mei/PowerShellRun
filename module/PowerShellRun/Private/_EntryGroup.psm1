class EntryGroup {
    [String]$Name
    [String[]]$Categories
    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]$ChildEntries = [System.Collections.Generic.List[PowerShellRun.SelectorEntry]]::new()

    EntryGroup([String]$name, [String[]]$categories) {
        $this.Name = $name
        $this.Categories = $categories
    }

    [void] AddEntry([PowerShellRun.SelectorEntry]$entry) {
        $this.ChildEntries.Add($entry)
    }

    [void] AddEntries([System.Collections.Generic.List[PowerShellRun.SelectorEntry]]$entries) {
        $this.ChildEntries.AddRange($entries)
    }

    [void] ClearEntries() {
        $this.ChildEntries.Clear()
    }
}
