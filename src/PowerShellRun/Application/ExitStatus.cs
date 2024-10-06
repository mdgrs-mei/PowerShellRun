namespace PowerShellRun;

// Stores the last exit status of the Selector or Prompt.
// User applications can get the status through this class even if they can't directly get the selector/prompt result.
// (e.g. the parent menu handling the restart key of the nested menus).
public static class ExitStatus
{
    public static ExitType Type { get; internal set; } = ExitType.None;
}

public enum ExitType
{
    None,
    Accept,
    Quit,
    QuitWithBackspaceOnEmptyQuery,
    Restart,
}
