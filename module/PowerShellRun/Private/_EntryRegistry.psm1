[NoRunspaceAffinity()]
class EntryRegistry {
    [System.Collections.Generic.List[PowerShellRun.SelectorEntry]] GetEntries([String[]]$categories) {
        Write-Error -Message 'This method needs to be overridden.' -Category NotImplemented
        return $null
    }

    [void] InitializeEntries([String[]]$categories) {
        Write-Error -Message 'This method needs to be overridden.' -Category NotImplemented
    }

    [bool] UpdateEntries() {
        Write-Error -Message 'This method needs to be overridden.' -Category NotImplemented
        return $false
    }
}

