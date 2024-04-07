namespace PowerShellRun;

public class PromptResult
{
    public string? Input { get; set; } = null;
    public KeyCombination? KeyCombination { get; set; } = null;
    public PromptContext Context { get; set; } = new PromptContext();
}
