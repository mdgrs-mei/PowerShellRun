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

    public RemapKey(string str)
    {
        var sourceAndDestination = str.Split(':');
        var source = sourceAndDestination[0];
        Source = new KeyCombination(source);
        if (sourceAndDestination.Length > 1)
        {
            Destination = new KeyCombination(sourceAndDestination[1]);
        }
    }

    private RemapKey()
    {
    }

    protected override object EmptyNew()
    {
        return new RemapKey();
    }

    public override string ToString()
    {
        return $"{Source.ToString()}:{Destination.ToString()}";
    }
}
