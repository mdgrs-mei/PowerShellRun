namespace PowerShellRun;

public class ActionKey : DeepCloneable
{
    public KeyCombination KeyCombination {get; set;} = new KeyCombination(KeyModifier.None, Key.None);
    public string Description {get; set;} = "";

    public ActionKey(KeyCombination keyCombination, string description)
    {
        KeyCombination = keyCombination;
        Description = description;
    }

    private ActionKey()
    {
    }

    protected override object EmptyNew()
    {
        return new ActionKey();
    }
}
