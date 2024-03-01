namespace PowerShellRun;

internal sealed class SelectorOptionHolder : Singleton<SelectorOptionHolder>
{
    public SelectorOption Option { get; set; } = new SelectorOption();
}
