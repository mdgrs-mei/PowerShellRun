namespace PowerShellRun;
using System;
using System.Diagnostics;
using System.Text;
using PowerShellRun.Dependency;

internal class SearchBar
{
    private InputBuffer _inputBuffer = new InputBuffer();
    private bool _isFirstFrame = true;
    private bool _isProcessQuitAcceptKeys = false;
    private TextBox _prompt = new TextBox();
    private TextBox _textBox = new TextBox();

    public string Query { get; set; } = "";
    public LayoutItem RootLayout { get; } = new HorizontalLayout();
    public bool IsQuit { get; set; } = false;
    public bool IsAccepted { get; set; } = false;
    public KeyCombination? LastKeyCombination { get; private set; } = null;
    public bool IsQueryUpdated { get; private set; } = false;
    public bool IsCursorUpdated { get; private set; } = false;
    public string DebugPerfString = "";

    public SearchBar(string promptString, bool processQuitAcceptKeys)
    {
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;

        _isProcessQuitAcceptKeys = processQuitAcceptKeys;
        RootLayout.AddChild(_prompt);
        RootLayout.AddChild(_textBox);

        RootLayout.BorderFlags = theme.SearchBarBorderFlags;
        RootLayout.BorderSymbol = theme.SearchBarBorderSymbol;
        RootLayout.BorderForegroundColor = theme.SearchBarBorderForegroundColor;
        RootLayout.BorderBackgroundColor = theme.SearchBarBorderBackgroundColor;
        int borderHeight = theme.SearchBarBorderFlags.HasFlag(BorderFlag.Top) ? 1 : 0;
        borderHeight += theme.SearchBarBorderFlags.HasFlag(BorderFlag.Bottom) ? 1 : 0;
        RootLayout.LayoutSizeHeight.Set(LayoutSizeType.Absolute, 1 + borderHeight);

        string promptLine = theme.PromptSymbol;
        if (!string.IsNullOrEmpty(promptString))
        {
            promptLine = promptString + theme.PromptSymbol;
        }
        int promptLength = TextBox.GetDisplayWidth(promptLine);
        _prompt.OnlyStoreLinesInVisibleRange = false;
        _prompt.LayoutSizeWidth.Set(LayoutSizeType.Absolute, promptLength);
        _prompt.ClearAndSetFocusLine(0, 1);
        _prompt.AddWord(0, promptLine, theme.PromptForegroundColor, theme.PromptBackgroundColor);

        if (theme.QueryBoxBackgroundColor is not null)
        {
            _textBox.FillCells = true;
            _textBox.DefaultBackgroundColor = theme.QueryBoxBackgroundColor;
        }
    }

    public void SetQuery(string query)
    {
        _inputBuffer.ClearInput();
        _inputBuffer.Add(query);
    }

    public (int X, int Y) GetCursorPositionInCanvas()
    {
        int x = _textBox.X;
        int y = _textBox.Y;
        x += _inputBuffer.GetCursorOffsetInCanvas();
        return (x, y);
    }

    public void Update()
    {
        ReadKeys();
        IsQueryUpdated = _inputBuffer.IsQueryUpdated;
        IsCursorUpdated = _inputBuffer.IsCursorUpdated;
        if (_isFirstFrame)
        {
            _isFirstFrame = false;
            IsQueryUpdated = true;
        }
        if (!string.IsNullOrEmpty(DebugPerfString))
        {
            IsQueryUpdated = true;
        }
        _inputBuffer.ClearState();

        if (IsQuit)
            return;

        Query = _inputBuffer.GetString();
        if (IsQueryUpdated)
        {
            var theme = SelectorOptionHolder.GetInstance().Option.Theme;
            _textBox.ClearAndSetFocusLine(0, 1);
            _textBox.AddWord(0, Query, theme.QueryForegroundColor, theme.QueryBackgroundColor, theme.QueryStyle);

            if (!string.IsNullOrEmpty(DebugPerfString))
            {
                _textBox.AddWord(0, DebugPerfString);
            }
        }

        ProcessAutoReturn();
    }

    private void ReadKeys()
    {
        var isRemapMode = KeyInput.GetInstance().IsRemapMode;
        var inputKeys = KeyInput.GetInstance().GetFrameInputs();
        var option = SelectorOptionHolder.GetInstance().Option;
        var keyBinding = option.KeyBinding;

        foreach (var key in inputKeys)
        {
            if (_isProcessQuitAcceptKeys)
            {
                foreach (var quitKey in keyBinding.QuitKeys)
                {
                    if (key.KeyCombination.Equals(quitKey))
                    {
                        IsQuit = true;
                        LastKeyCombination = key.KeyCombination;
                        ExitStatus.Type = ExitType.Quit;
                        return;
                    }
                }
                foreach (var restartKey in keyBinding.RestartKeys)
                {
                    if (key.KeyCombination.Equals(restartKey))
                    {
                        IsQuit = true;
                        LastKeyCombination = key.KeyCombination;
                        ExitStatus.Type = ExitType.Restart;
                        return;
                    }
                }

                foreach (var acceptKey in keyBinding.PromptAcceptKeys)
                {
                    if (key.KeyCombination.Equals(acceptKey))
                    {
                        IsAccepted = true;
                        LastKeyCombination = key.KeyCombination;
                        ExitStatus.Type = ExitType.Accept;
                        return;
                    }
                }
            }

            if (key.KeyCombination.Modifier.HasFlag(KeyModifier.Ctrl))
                continue;
            if (key.KeyCombination.Modifier.HasFlag(KeyModifier.Alt))
                continue;

            if (key.KeyCombination.Key == Key.LeftArrow)
            {
                _inputBuffer.MoveCursorBackward();
                continue;
            }
            if (key.KeyCombination.Key == Key.RightArrow)
            {
                _inputBuffer.MoveCursorForward();
                continue;
            }
            if (key.KeyCombination.Key == Key.Home)
            {
                _inputBuffer.MoveCursorToBeginning();
                continue;
            }
            if (key.KeyCombination.Key == Key.End)
            {
                _inputBuffer.MoveCursorToEnd();
                continue;
            }

            if (key.KeyCombination.Key == Key.Backspace)
            {
                if (_inputBuffer.GetCursorCharIndex() > 0)
                {
                    _inputBuffer.Backspace();
                }
                else
                if (option.QuitWithBackspaceOnEmptyQuery && _inputBuffer.IsEmpty())
                {
                    IsQuit = true;
                    LastKeyCombination = key.KeyCombination;
                    ExitStatus.Type = ExitType.QuitWithBackspaceOnEmptyQuery;
                    return;
                }
                continue;
            }
            if (key.KeyCombination.Key == Key.Delete)
            {
                _inputBuffer.Delete();
                continue;
            }

            if (isRemapMode && !keyBinding.EnableTextInputInRemapMode)
                continue;

            // Skip text input since KeyChar cannot be reproduced if the key is remapped.
            if (key.IsRemapped)
                continue;

            if (key.ConsoleKeyInfo.KeyChar == '\0')
                continue;

            _inputBuffer.Add(key.ConsoleKeyInfo.KeyChar);
        }
    }

    private void ProcessAutoReturn()
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch && _isProcessQuitAcceptKeys)
        {
            IsAccepted = true;
            LastKeyCombination = null;
        }
    }
}
