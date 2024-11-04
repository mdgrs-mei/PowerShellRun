namespace PowerShellRun;

public class ActionKey : DeepCloneable
{
    public KeyCombination KeyCombination { get; set; } = new KeyCombination(KeyModifier.None, Key.None);
    public string Description { get; set; } = "";

    public ActionKey(KeyCombination keyCombination, string description)
    {
        KeyCombination = keyCombination;
        Description = description;
    }

    public ActionKey(string str)
    {
        var keyAndDescription = str.Split(':');
        var key = keyAndDescription[0];
        KeyCombination = new KeyCombination(key);
        if (keyAndDescription.Length > 1)
        {
            Description = keyAndDescription[1];
        }
    }

    private ActionKey()
    {
    }

    protected override object EmptyNew()
    {
        return new ActionKey();
    }

    public override string ToString()
    {
        return $"{KeyCombination.ToString()}:{Description}";
    }
}
