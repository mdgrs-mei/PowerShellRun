namespace PowerShellRun;

public class KeyBinding
{
    public KeyCombination[] QuitKeys { get; set; }
    public KeyCombination[] PageUpKeys { get; set; }
    public KeyCombination[] PageDownKeys { get; set; }
    public KeyCombination[] PreviewVerticalScrollUpKeys { get; set; }
    public KeyCombination[] PreviewVerticalScrollDownKeys { get; set; }
    public KeyCombination[] PreviewPageUpKeys { get; set; }
    public KeyCombination[] PreviewPageDownKeys { get; set; }
    public KeyCombination[] MarkerKeys { get; set; }
    public KeyCombination[] ToggleAllMarkerKeys { get; set; }
    public KeyCombination[] PromptAcceptKeys { get; set; }
    public ActionKey[] DefaultActionKeys { get; set; }
    public ActionKey[] DefaultActionKeysMultiSelection { get; set; }
    public KeyCombination[] ActionWindowOpenKeys { get; set; }
    public KeyCombination[] ActionWindowAcceptKeys { get; set; }

    public KeyBinding()
    {
        QuitKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.None, Key.Escape),
        };

        PageUpKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.None, Key.PageUp),
        };

        PageDownKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.None, Key.PageDown),
        };

        MarkerKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.None, Key.Tab),
        };

        ToggleAllMarkerKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.Shift, Key.Tab),
        };

        PromptAcceptKeys = new KeyCombination[]{
            new KeyCombination(KeyModifier.None, Key.Enter),
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
            PreviewPageUpKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Alt, Key.PageUp),
            };
            PreviewPageDownKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Alt, Key.PageDown),
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
            PreviewPageUpKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Shift, Key.PageUp),
            };
            PreviewPageDownKeys = new KeyCombination[]{
                new KeyCombination(KeyModifier.Shift, Key.PageDown),
            };
        }
    }

    public KeyBinding? DeepClone()
    {
        return (KeyBinding?)DeepCloneable.DeepClone(this);
    }
}
