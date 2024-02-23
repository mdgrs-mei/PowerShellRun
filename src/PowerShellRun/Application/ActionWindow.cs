using System;
using System.Configuration;
using System.Drawing;

namespace PowerShellRun;

internal class ActionWindow
{
    public LayoutItem RootLayout {get;} = new HorizontalLayout();
    public bool IsUpdated {get; set;} = false;
    public bool IsQuit {get; private set;} = false;
    public bool IsActionAccepted {get; private set;} = false;
    public KeyCombination? LastKeyCombination {get; private set;} = null;

    private TextBox _cursorBox = new TextBox();
    private TextBox _keyBox = new TextBox();
    private TextBox _descBox = new TextBox();
    private InternalEntry? _entry = null;
    private bool _isAnyEntryMarked = false;
    private int _cursorIndex = 0;
    
    public ActionWindow()
    {
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;

        RootLayout.LayoutSizeWidth.Set(LayoutSizeType.Content);
        RootLayout.LayoutSizeHeight.Set(LayoutSizeType.Absolute, Constants.ActionWindowHeight);
        RootLayout.VerticalAlign = LayoutItem.Align.Bottom;
        RootLayout.HorizontalAlign = LayoutItem.Align.Right;
        RootLayout.Margin.Right = 2;
        RootLayout.Margin.Bottom = 1;
        if (theme.ActionWindowBorderEnable)
        {
            RootLayout.BorderFlags = BorderFlag.All;
            RootLayout.BorderSymbol = theme.ActionWindowBorderSymbol;
            RootLayout.BorderForegroundColor = theme.ActionWindowBorderForegroundColor;
            RootLayout.BorderBackgroundColor = theme.ActionWindowBorderBackgroundColor;
        }
        else
        {
            _cursorBox.Padding.Top = 1;
            _cursorBox.Padding.Bottom = 1;
            _keyBox.Padding.Top = 1;
            _keyBox.Padding.Bottom = 1;
            _descBox.Padding.Top = 1;
            _descBox.Padding.Bottom = 1;
        }

        RootLayout.AddChild(_cursorBox);
        RootLayout.AddChild(_keyBox);
        RootLayout.AddChild(_descBox);

        int cursorLength = TextBox.GetDisplayWidth(theme.Cursor);
        _cursorBox.LayoutSizeWidth.Set(LayoutSizeType.Absolute, cursorLength + 1);
        _cursorBox.Padding.Left = 1;
        _cursorBox.FillCells = true;
        _cursorBox.DefaultBackgroundColor = theme.ActionWindowCursorBoxBackgroundColor;
        _cursorBox.Active = theme.CursorEnable;
        if (!theme.CursorEnable)
        {
            _keyBox.Padding.Left = 1;
        }
        
        _keyBox.LayoutSizeWidth.Set(LayoutSizeType.Content);
        _keyBox.Padding.Right = 1;
        _keyBox.FillCells = true;
        _keyBox.DefaultBackgroundColor = theme.ActionWindowKeyBoxBackgroundColor;
        if (theme.ActionWindowBorderEnable)
        {
            _keyBox.BorderFlags = BorderFlag.Right;
            _keyBox.BorderForegroundColor = theme.ActionWindowBorderForegroundColor;
            _keyBox.BorderBackgroundColor = theme.ActionWindowBorderBackgroundColor;
        }

        _descBox.LayoutSizeWidth.Set(LayoutSizeType.Content);
        _descBox.MinWidth = Constants.ActionWindowDescriptionMinWidth;
        _descBox.Padding.Left = 1;
        _descBox.FillCells = true;
        _descBox.DefaultBackgroundColor = theme.ActionWindowDescriptionBoxBackgroundColor;
        _descBox.VerticalScrollBarEnable = true;
        _descBox.ScrollBarForegroundColor = theme.ActionWindowScrollBarForegroundColor;
        _descBox.ScrollBarBackgroundColor = theme.ActionWindowScrollBarBackgroundColor;

        SetVisible(false);
    }

    public void SetEntry(InternalEntry? entry, bool isAnyEntryMarked)
    {
        IsUpdated = false;
        if (_entry != entry)
        {
            SetVisible(false);
            SetCursorIndex(0);
        }
        _entry = entry;
        _isAnyEntryMarked = isAnyEntryMarked;
    }

    public void Update() 
    {
        ReadKeys();
        BuildUi();
    }

    public bool IsVisible()
    {
        return RootLayout.Visible;
    }

    private void SetVisible(bool isVisible)
    {
        if (RootLayout.Visible != isVisible)
        {
            IsUpdated = true;
        }
        RootLayout.Visible = isVisible;
    }

    private void ReadKeys()
    {
        var keyInput = KeyInput.GetInstance();
        var inputKeys = keyInput.GetFrameInputs();
        var keyBinding = SelectorOptionHolder.GetInstance().Option.KeyBinding;

        foreach (var key in inputKeys)
        {
            foreach (var openKey in keyBinding.ActionWindowOpenKeys)
            {
                if (key.KeyCombination.Equals(openKey))
                {
                    SetVisible(!IsVisible());
                    keyInput.ClearFrameInputs();
                    return;
                }
            }
        }

        if (!IsVisible())
            return;

        keyInput.ClearFrameInputs();
        var actionKeys = GetActionKeys();

        foreach (var key in inputKeys)
        {
            if (key.KeyCombination.Key == Key.UpArrow)
            {
                SetCursorIndex(_cursorIndex - 1);
                continue;
            }
            if (key.KeyCombination.Key == Key.DownArrow)
            {
                SetCursorIndex(_cursorIndex + 1);
                continue;
            }

            foreach (var quitKey in keyBinding.QuitKeys)
            {
                if (key.KeyCombination.Equals(quitKey))
                {
                    IsQuit = true;
                    LastKeyCombination = key.KeyCombination;
                    return;
                }
            }

            foreach (var acceptKey in keyBinding.ActionWindowAcceptKeys)
            {
                if (key.KeyCombination.Equals(acceptKey))
                {
                    var actionKey = GetFocusedActionKey();
                    if (actionKey is not null)
                    {
                        IsActionAccepted = true;
                        LastKeyCombination = actionKey.KeyCombination;
                        return;
                    }
                }
            }

            foreach (var actionKey in actionKeys)
            {
                if (actionKey.KeyCombination.Equals(key.KeyCombination))
                {
                    IsActionAccepted = true;
                    LastKeyCombination = key.KeyCombination;
                    return;
                }
            }

            // Hide if any other keys are pressed.
            SetVisible(false);
            return;
        }
    }

    private void BuildUi()
    {
        if (!IsVisible())
            return;

        _cursorBox.ClearAndSetFocusLine(_cursorIndex);
        _keyBox.ClearAndSetFocusLine(_cursorIndex);
        _descBox.ClearAndSetFocusLine(_cursorIndex);

        var actionKeys = GetActionKeys();
        _descBox.SetLineCountForScrollBar(actionKeys.Length);
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;

        for (int i = 0; i < actionKeys.Length; ++i)
        {
            var actionKey = actionKeys[i];
            if (i == _cursorIndex)
            {
                if (theme.CursorEnable)
                {
                    _cursorBox.AddWord(
                        i,
                        theme.Cursor,
                        theme.ActionWindowCursorForegroundColor,
                        theme.ActionWindowCursorBackgroundColor);
                }

                _keyBox.AddWord(
                    i,
                    actionKey.KeyCombination.ToString(),
                    theme.ActionWindowKeyFocusForegroundColor,
                    theme.ActionWindowKeyFocusBackgroundColor,
                    theme.ActionWindowKeyFocusStyle);

                _descBox.AddWord(
                    i,
                    actionKey.Description,
                    theme.ActionWindowDescriptionFocusForegroundColor,
                    theme.ActionWindowDescriptionFocusBackgroundColor,
                    theme.ActionWindowDescriptionFocusStyle);
            }
            else
            {
                _keyBox.AddWord(
                    i,
                    actionKey.KeyCombination.ToString(),
                    theme.ActionWindowKeyForegroundColor,
                    theme.ActionWindowKeyBackgroundColor,
                    theme.ActionWindowKeyStyle);

                _descBox.AddWord(
                    i,
                    actionKey.Description,
                    theme.ActionWindowDescriptionForegroundColor,
                    theme.ActionWindowDescriptionBackgroundColor,
                    theme.ActionWindowDescriptionStyle);
            }
        }
    }

    private void SetCursorIndex(int index)
    {
        int actionKeyCount = GetActionKeys().Length;
        _cursorIndex = index;
        _cursorIndex = Math.Min(_cursorIndex, actionKeyCount - 1);
        _cursorIndex = Math.Max(_cursorIndex, 0);
        IsUpdated = true;
    }

    private ActionKey? GetFocusedActionKey()
    {
        var actionKeys = GetActionKeys();
        if (_cursorIndex >= actionKeys.Length)
            return null;

        return actionKeys[_cursorIndex];
    }

    private ActionKey[] GetActionKeys()
    {
        if (_entry is not null)
        {
            return _isAnyEntryMarked ? _entry.GetActionKeysMultiSelection() : _entry.GetActionKeys();
        }
        else
        {
            var keyBinding = SelectorOptionHolder.GetInstance().Option.KeyBinding;
            return _isAnyEntryMarked ? keyBinding.DefaultActionKeysMultiSelection : keyBinding.DefaultActionKeys;
        }
    }
}
