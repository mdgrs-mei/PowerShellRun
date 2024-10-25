using System;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace PowerShellRun;

public class SelectorEntry
{
    public object? UserData { get; set; } = null;
    public string? Icon { get; set; } = null;
    public string Name { get; set; } = "";
    public Regex? NameSearchablePattern { get; set; } = null;
    public string? Description { get; set; } = null;
    public Regex? DescriptionSearchablePattern { get; set; } = null;
    public string[]? Preview { get; set; } = null;
    public ScriptBlock? PreviewAsyncScript { get; set; } = null;
    public object[]? PreviewAsyncScriptArgumentList { get; set; } = null;
    public int PreviewInitialVerticalScroll { get; set; } = 0;
    public ActionKey[]? ActionKeys = null;
    public ActionKey[]? ActionKeysMultiSelection = null;

    public override string ToString()
    {
        return Name;
    }
}
