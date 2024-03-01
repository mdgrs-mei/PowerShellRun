namespace PowerShellRun;

public class SelectorResult
{
    public SelectorEntry? FocusedEntry { get; set; } = null;
    public SelectorEntry[]? MarkedEntries { get; set; } = null;
    public KeyCombination? KeyCombination { get; set; } = null;
    public SelectorContext Context { get; set; } = new SelectorContext();
}
