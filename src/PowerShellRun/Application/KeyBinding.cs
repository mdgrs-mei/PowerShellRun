namespace PowerShellRun;

public class KeyBinding
{
    public KeyCombination[] QuitKeys { get; set; }
    public KeyCombination[] PreviewVerticalScrollUpKeys { get; set; }
    public KeyCombination[] PreviewVerticalScrollDownKeys { get; set; }
    public KeyCombination[] MarkerKeys { get; set; }
    public KeyCombination[] ToggleAllMarkerKeys { get; set; }
    public ActionKey[] DefaultActionKeys { get; set; }
    public ActionKey[] DefaultActionKeysMultiSelection { get; set; }
    public KeyCombination[] ActionWindowOpenKeys { get; set; }
    public KeyCombination[] ActionWindowAcceptKeys { get; set; }

    public KeyBinding()
    {
        QuitKeys = new KeyCombination[]{
            KeyCombination.Escape,
        };

        MarkerKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.None, Key.Tab),
        };

        ToggleAllMarkerKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.Shift, Key.Tab),
        };

        DefaultActionKeys = new ActionKey[]{
            new ActionKey(new KeyCombination(KeyModifier.None, Key.Enter), "Return focused entry"),
        };

        DefaultActionKeysMultiSelection = new ActionKey[]{
            new ActionKey(new KeyCombination(KeyModifier.None, Key.Enter), "Return marked entries"),
        };

        ActionWindowOpenKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.Ctrl, Key.K),
        };

        ActionWindowAcceptKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.None, Key.Enter),
        };

        if (Platform.GetInstance().IsMacOs)
        {
            PreviewVerticalScrollUpKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Alt, Key.UpArrow),
            };
            PreviewVerticalScrollDownKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Alt, Key.DownArrow),
            };
        }
        else
        {
            PreviewVerticalScrollUpKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Shift, Key.UpArrow),
            };
            PreviewVerticalScrollDownKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Shift, Key.DownArrow),
            };
        }
    }

    public KeyBinding? DeepClone()
    {
        return (KeyBinding?)DeepCloneable.DeepClone(this);
    }
}
