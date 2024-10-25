namespace PowerShellRun;

public class PromptContext
{
    public string Input { get; set; } = "";

    public override string ToString()
    {
        return Input;
    }
}
