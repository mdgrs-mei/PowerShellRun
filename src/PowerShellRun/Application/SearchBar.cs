namespace PowerShellRun;
using System;
using System.Diagnostics;
using System.Text;

internal class SearchBar
{
    private StringBuilder _readKeysBuffer = new StringBuilder();
    private int _cursorX = 0;
    private bool _isFirstFrame = true;
    private bool _isQuerySetFromOutside = false;
    private TextBox _prompt = new TextBox();
    private TextBox _textBox = new TextBox();

    public string Query {get; set;} = "";
    public LayoutItem RootLayout {get;} = new HorizontalLayout();
    public bool IsQuit {get; set;} = false;
    public KeyCombination? LastKeyCombination {get; private set;} = null;
    public bool IsQueryUpdated {get; set;} = false;
    public bool IsCursorUpdated {get; set;} = false;
    public string DebugPerfString = "";

    public int CursorXInCanvas
    {
        get
        {
            return _cursorX + _textBox.X;
        }
    }
    public int CursorYInCanvas
    {
        get
        {
            return _textBox.Y;
        }
    }

    public SearchBar(string promptString)
    {
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;

        RootLayout.AddChild(_prompt);
        RootLayout.AddChild(_textBox);

        RootLayout.BorderFlags = theme.SearchBarBorderFlags;
        RootLayout.BorderSymbol = theme.SearchBarBorderSymbol;
        RootLayout.BorderForegroundColor = theme.SearchBarBorderForegroundColor;
        RootLayout.BorderBackgroundColor = theme.SearchBarBorderBackgroundColor;
        int borderHeight = theme.SearchBarBorderFlags.HasFlag(BorderFlag.Top) ? 1 : 0;
        borderHeight += theme.SearchBarBorderFlags.HasFlag(BorderFlag.Bottom) ? 1 : 0;
        RootLayout.LayoutSizeHeight.Set(LayoutSizeType.Absolute, 1 + borderHeight);

        int promptLength = TextBox.GetDisplayWidth(promptString);
        _prompt.OnlyStoreLinesInVisibleRange = false;
        _prompt.LayoutSizeWidth.Set(LayoutSizeType.Absolute, promptLength);
        _prompt.ClearAndSetFocusLine(0);
        _prompt.AddWord(0, promptString, theme.PromptForegroundColor, theme.PromptBackgroundColor);

        if (theme.QueryBoxBackgroundColor is not null)
        {
            _textBox.FillCells = true;
            _textBox.DefaultBackgroundColor = theme.QueryBoxBackgroundColor;
        }
    }

    public void SetQuery(string query)
    {
        _readKeysBuffer.Clear();
        _readKeysBuffer.Append(query);
        SetCursorX(query.Length);
        _isQuerySetFromOutside = true;
    }

    public void Update()
    {
        ReadKeys();
        if (IsQuit)
            return;

        Query = _readKeysBuffer.ToString();
        if (_isQuerySetFromOutside)
        {
            IsQueryUpdated = true;
            _isQuerySetFromOutside = false;
        }

        if (!string.IsNullOrEmpty(DebugPerfString))
        {
            IsQueryUpdated = true;
        }

        if (IsQueryUpdated)
        {
            var theme = SelectorOptionHolder.GetInstance().Option.Theme;
            _textBox.ClearAndSetFocusLine(0);
            _textBox.AddWord(0, Query, theme.QueryForegroundColor, theme.QueryBackgroundColor, theme.QueryStyle);

            if (!string.IsNullOrEmpty(DebugPerfString))
            {
                _textBox.AddWord(0, DebugPerfString);
            }
        }
    }

    private static Key[] _skipKeys =
    {
        Key.Enter,
        Key.Escape,
        Key.UpArrow,
        Key.DownArrow,
        Key.Tab,
    };
    private void ReadKeys()
    {
        IsQueryUpdated = false;
        IsCursorUpdated = false;
        var inputKeys = KeyInput.GetInstance().GetFrameInputs();
        var option = SelectorOptionHolder.GetInstance().Option;
        foreach (var key in inputKeys)
        {
            if (key.KeyCombination.Modifier.HasFlag(KeyModifier.Ctrl))
                continue;
            if (key.KeyCombination.Modifier.HasFlag(KeyModifier.Alt))
                continue;

            bool skip = false;
            foreach (var skipKey in _skipKeys)
            {
                if (skipKey == key.KeyCombination.Key)
                {
                    skip = true;
                    break;
                }
            }
            if (skip)
                continue;

            if (key.KeyCombination.Key == Key.LeftArrow)
            {
                SetCursorX(_cursorX - 1);
                continue;
            }
            if (key.KeyCombination.Key == Key.RightArrow)
            {
                SetCursorX(_cursorX + 1);
                continue;
            }
            if (key.KeyCombination.Key == Key.Home)
            {
                SetCursorX(0);
                continue;
            }
            if (key.KeyCombination.Key == Key.End)
            {
                SetCursorX(_readKeysBuffer.Length);
                continue;
            }

            if (key.KeyCombination.Key == Key.Backspace)
            {
                if (_readKeysBuffer.Length > 0 && _cursorX > 0)
                {
                    _readKeysBuffer.Remove(_cursorX - 1, 1);
                    SetCursorX(_cursorX - 1);
                    IsQueryUpdated = true;
                }
                else
                if (option.QuitWithBackspaceOnEmptyQuery && _readKeysBuffer.Length == 0)
                {
                    IsQuit = true;
                    LastKeyCombination = key.KeyCombination;
                    return;
                }
                continue;
            }
            if (key.KeyCombination.Key == Key.Delete)
            {
                if (_cursorX < _readKeysBuffer.Length)
                {
                    _readKeysBuffer.Remove(_cursorX, 1);
                    IsQueryUpdated = true;
                }
                continue;
            }
            // old method if !Char.IsAscii(key.ConsoleKeyInfo.KeyChar) does not allow for non-ascii characters.
            if (!Enum.IsDefined(typeof(Key), key.KeyCombination.Key) && (key.ConsoleKeyInfo.KeyChar < 0 || key.ConsoleKeyInfo.KeyChar > 127))
            {
                continue;
            }
            if (_readKeysBuffer.Length >= Constants.QueryCharacterMaxCount)
            {
                continue;
            }
            if (_cursorX == _readKeysBuffer.Length)
            {
                _readKeysBuffer.Append(key.ConsoleKeyInfo.KeyChar);
            }
            else
            {
                _readKeysBuffer.Insert(_cursorX, key.ConsoleKeyInfo.KeyChar);
            }
            SetCursorX(_cursorX + 1);
            IsQueryUpdated = true;
        }

        if (_isFirstFrame)
        {
            _isFirstFrame = false;
            IsQueryUpdated = true;
        }
    }

    private void SetCursorX(int x)
    {
        _cursorX = x;
        _cursorX = Math.Clamp(_cursorX, 0, _readKeysBuffer.Length);
        IsCursorUpdated = true;
    }
}
