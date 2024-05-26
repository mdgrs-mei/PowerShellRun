namespace PowerShellRun;
using System;
using System.Text;

public class KeyCombination : DeepCloneable
{
    public KeyModifier Modifier
    {
        get => _modifier;
        set
        {
            _modifier = value;
            SetString();
        }
    }
    public Key Key
    {
        get => _key;
        set
        {
            _key = value;
            SetString();
        }
    }

    private KeyModifier _modifier = KeyModifier.None;
    private Key _key = Key.None;
    private string _string = "";

    public KeyCombination(KeyModifier modifier, Key key)
    {
        _modifier = modifier;
        _key = key;
        SetString();
    }

    public KeyCombination(string str)
    {
        SetFromString(str);
    }

    private KeyCombination()
    { }

    protected override object EmptyNew()
    {
        return new KeyCombination();
    }

    public override bool Equals(object? obj)
    {
        if (obj == null)
        {
            return false;
        }

        if (obj is string)
        {
            obj = new KeyCombination((string)obj);
        }
        else
        if (GetType() != obj.GetType())
        {
            return false;
        }

        KeyCombination other = (KeyCombination)obj;
        return Modifier == other.Modifier && Key == other.Key;
    }

    public override int GetHashCode()
    {
        return (Modifier, Key).GetHashCode();
    }

    public override string ToString()
    {
        return _string;
    }

    private void SetString()
    {
        var builder = new StringBuilder();
        foreach (KeyModifier modifier in Enum.GetValues(typeof(KeyModifier)))
        {
            if (modifier == KeyModifier.None)
                continue;

            if (Modifier.HasFlag(modifier))
            {
                if (builder.Length > 0)
                {
                    builder.Append('+');
                }
                builder.Append(modifier.ToString());
            }
        }

        if (Key != Key.None)
        {
            if (builder.Length > 0)
            {
                builder.Append('+');
            }
            builder.Append(Key.ToString());
        }

        _string = builder.ToString();
    }

    private void SetFromString(string str)
    {
        _modifier = KeyModifier.None;
        _key = Key.None;

        if (string.IsNullOrEmpty(str))
        {
            SetString();
            return;
        }

        var keys = str.Split('+');
        foreach (KeyModifier enumModifier in Enum.GetValues(typeof(KeyModifier)))
        {
            if (enumModifier == KeyModifier.None)
                continue;

            foreach (var key in keys)
            {
                if (string.Equals(key, enumModifier.ToString(), StringComparison.OrdinalIgnoreCase))
                {
                    _modifier |= enumModifier;
                }
            }
        }

        foreach (Key enumKey in Enum.GetValues(typeof(Key)))
        {
            foreach (var key in keys)
            {
                if (string.Equals(key, enumKey.ToString(), StringComparison.OrdinalIgnoreCase))
                {
                    _key = enumKey;
                    break;
                }
            }
        }

        SetString();
    }

    internal static KeyCombination LeftArrow { get; } = new KeyCombination(KeyModifier.None, Key.LeftArrow);
    internal static KeyCombination UpArrow { get; } = new KeyCombination(KeyModifier.None, Key.UpArrow);
    internal static KeyCombination RightArrow { get; } = new KeyCombination(KeyModifier.None, Key.RightArrow);
    internal static KeyCombination DownArrow { get; } = new KeyCombination(KeyModifier.None, Key.DownArrow);
    internal static KeyCombination Enter { get; } = new KeyCombination(KeyModifier.None, Key.Enter);
    internal static KeyCombination CtrlEnter { get; } = new KeyCombination(KeyModifier.Ctrl, Key.Enter);
    internal static KeyCombination ShiftEnter { get; } = new KeyCombination(KeyModifier.Shift, Key.Enter);
    internal static KeyCombination Backspace { get; } = new KeyCombination(KeyModifier.None, Key.Backspace);
    internal static KeyCombination Escape { get; } = new KeyCombination(KeyModifier.None, Key.Escape);
}

[Flags]
public enum KeyModifier
{
    None = 0,
    Alt = 1 << 0,
    Shift = 1 << 1,
    Ctrl = 1 << 2,
}

public enum Key
{
    None = 0,
    Backspace,
    Tab,
    Enter,
    Escape,
    Spacebar,
    PageUp,
    PageDown,
    End,
    Home,
    LeftArrow,
    UpArrow,
    RightArrow,
    DownArrow,
    Delete,

    D0,
    D1,
    D2,
    D3,
    D4,
    D5,
    D6,
    D7,
    D8,
    D9,

    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    I,
    J,
    K,
    L,
    M,
    N,
    O,
    P,
    Q,
    R,
    S,
    T,
    U,
    V,
    W,
    X,
    Y,
    Z,

    Subtract,
    Divide,

    F1,
    F2,
    F3,
    F4,
    F5,
    F6,
    F7,
    F8,
    F9,
    F10,
    F11,
    F12,
}
