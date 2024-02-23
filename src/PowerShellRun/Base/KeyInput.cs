namespace PowerShellRun;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;

internal sealed class KeyInput : Singleton<KeyInput>
{
    public class KeyInfo
    {
        public KeyCombination KeyCombination {get; set;}
        public ConsoleKeyInfo ConsoleKeyInfo {get; set;}

        public KeyInfo(KeyCombination keyCombination, ConsoleKeyInfo consoleKeyInfo)
        {
            KeyCombination = keyCombination;
            ConsoleKeyInfo = consoleKeyInfo;
        }
    }

    private List<KeyInfo> _frameInputs = new List<KeyInfo>();
    private static KeyInfo[] _emptyInputs = new KeyInfo[0];
    private bool _isEmptied = false;
    private bool _originalControlCAsInput = false;

    public void Init()
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch)
            return;

        _originalControlCAsInput = Console.TreatControlCAsInput;
        Console.TreatControlCAsInput = true;
    }

    public void Term()
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch)
            return;

        Console.TreatControlCAsInput = _originalControlCAsInput;
    }

    public void Update()
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch)
            return;

        _isEmptied = false;
        _frameInputs.Clear();

        while (Console.KeyAvailable)
        {
            var keyInfo = Console.ReadKey(true);
            var keyCombination = ConvertToKeyCombination(keyInfo.Modifiers, keyInfo.Key);
            _frameInputs.Add(new KeyInfo(keyCombination, keyInfo));
        }
    }

    public ReadOnlyCollection<KeyInfo> GetFrameInputs()
    {
        if (_isEmptied)
        {
            return Array.AsReadOnly(_emptyInputs);
        }
        return _frameInputs.AsReadOnly();
    }

    public void ClearFrameInputs()
    {
        _isEmptied = true;
    }

    private KeyCombination ConvertToKeyCombination(ConsoleModifiers consoleModifiers, ConsoleKey consoleKey)
    {
        KeyModifier modifier = KeyModifier.None;
        if (consoleModifiers.HasFlag(ConsoleModifiers.Alt))
        {
            modifier |= KeyModifier.Alt;
        }
        if (consoleModifiers.HasFlag(ConsoleModifiers.Shift))
        {
            modifier |= KeyModifier.Shift;
        }
        if (consoleModifiers.HasFlag(ConsoleModifiers.Control))
        {
            modifier |= KeyModifier.Ctrl;
        }

        Key key = Key.None;
        foreach (var map in _keyConsoleKeyTable)
        {
            if (consoleKey == map.ConsoleKey)
            {
                key = map.Key;
                break;
            }
        }

        consoleModifiers.HasFlag(ConsoleModifiers.Control);
        return new KeyCombination(modifier, key);
    }

    private static (Key Key, ConsoleKey ConsoleKey)[] _keyConsoleKeyTable = 
    {
        (Key.Backspace, ConsoleKey.Backspace),
        (Key.Tab, ConsoleKey.Tab),
        (Key.Enter, ConsoleKey.Enter),
        (Key.Escape, ConsoleKey.Escape),
        (Key.Spacebar, ConsoleKey.Spacebar),
        (Key.PageUp, ConsoleKey.PageUp),
        (Key.PageDown, ConsoleKey.PageDown),
        (Key.End, ConsoleKey.End),
        (Key.Home, ConsoleKey.Home),
        (Key.LeftArrow, ConsoleKey.LeftArrow),
        (Key.UpArrow, ConsoleKey.UpArrow),
        (Key.RightArrow, ConsoleKey.RightArrow),
        (Key.DownArrow, ConsoleKey.DownArrow),
        (Key.Delete, ConsoleKey.Delete),

        (Key.D0, ConsoleKey.D0),
        (Key.D1, ConsoleKey.D1),
        (Key.D2, ConsoleKey.D2),
        (Key.D3, ConsoleKey.D3),
        (Key.D4, ConsoleKey.D4),
        (Key.D5, ConsoleKey.D5),
        (Key.D6, ConsoleKey.D6),
        (Key.D7, ConsoleKey.D7),
        (Key.D8, ConsoleKey.D8),
        (Key.D9, ConsoleKey.D9),

        (Key.A, ConsoleKey.A),
        (Key.B, ConsoleKey.B),
        (Key.C, ConsoleKey.C),
        (Key.D, ConsoleKey.D),
        (Key.E, ConsoleKey.E),
        (Key.F, ConsoleKey.F),
        (Key.G, ConsoleKey.G),
        (Key.H, ConsoleKey.H),
        (Key.I, ConsoleKey.I),
        (Key.J, ConsoleKey.J),
        (Key.K, ConsoleKey.K),
        (Key.L, ConsoleKey.L),
        (Key.M, ConsoleKey.M),
        (Key.N, ConsoleKey.N),
        (Key.O, ConsoleKey.O),
        (Key.P, ConsoleKey.P),
        (Key.Q, ConsoleKey.Q),
        (Key.R, ConsoleKey.R),
        (Key.S, ConsoleKey.S),
        (Key.T, ConsoleKey.T),
        (Key.U, ConsoleKey.U),
        (Key.V, ConsoleKey.V),
        (Key.W, ConsoleKey.W),
        (Key.X, ConsoleKey.X),
        (Key.Y, ConsoleKey.Y),
        (Key.Z, ConsoleKey.Z),

        (Key.F1, ConsoleKey.F1),
        (Key.F2, ConsoleKey.F2),
        (Key.F3, ConsoleKey.F3),
        (Key.F4, ConsoleKey.F4),
        (Key.F5, ConsoleKey.F5),
        (Key.F6, ConsoleKey.F6),
        (Key.F7, ConsoleKey.F7),
        (Key.F8, ConsoleKey.F8),
        (Key.F9, ConsoleKey.F9),
        (Key.F10, ConsoleKey.F10),
        (Key.F11, ConsoleKey.F11),
        (Key.F12, ConsoleKey.F12),
    };
}
