namespace PowerShellRun;

public class RemapKey : DeepCloneable
{
    public KeyCombination Source { get; set; } = new KeyCombination(KeyModifier.None, Key.None);
    public KeyCombination Destination { get; set; } = new KeyCombination(KeyModifier.None, Key.None);

    public RemapKey(KeyCombination source, KeyCombination destination)
    {
        Source = source;
        Destination = destination;
    }

    private RemapKey()
    {
    }

    protected override object EmptyNew()
    {
        return new RemapKey();
    }
}
