namespace PowerShellRun;

public class SelectorContext
{
    public string Query { get; set; } = "";
    public int CursorIndex { get; set; } = 0;
    public int[]? MarkedEntryIndexes { get; set; } = null;
}
