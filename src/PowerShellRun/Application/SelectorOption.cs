namespace PowerShellRun;

public class SelectorOption
{
    public KeyBinding KeyBinding { get; set; } = new KeyBinding();
    public Theme Theme { get; set; } = new Theme();
    public string Prompt { get; set; } = "> ";
    public bool EntryCycleScrollEnable { get; set; } = true;
    public bool PreviewCycleScrollEnable { get; set; } = false;
    public bool ActionWindowCycleScrollEnable { get; set; } = false;
    public bool QuitWithBackspaceOnEmptyQuery { get; set; } = false;
    public bool AutoReturnBestMatch { get; set; } = false;
    public bool DebugPerfEnable { get; set; } = false;

    public SelectorOption? DeepClone()
    {
        return (SelectorOption?)DeepCloneable.DeepClone(this);
    }
}
