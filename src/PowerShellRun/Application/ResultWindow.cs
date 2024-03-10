namespace PowerShellRun;

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Management.Automation.Host;

internal class ResultWindow
{
    public StackLayout RootLayout { get; } = new StackLayout();
    private LayoutItem _resultLayout;
    private VerticalLayout _searchLayout = new VerticalLayout();
    private HorizontalLayout _entryLayout = new HorizontalLayout();
    private TextBox _cursorBox = new TextBox();
    private TextBox _markerBox = new TextBox();
    private TextBox _nameBox = new TextBox();
    private TextBox _descriptionBox = new TextBox();
    private TextBox _previewBox = new TextBox();
    private ActionWindow _actionWindow = new ActionWindow();

    private Searcher _searcher = new Searcher();
    private IReadOnlyList<SelectorEntry>? _selectorEntries = null;
    private InternalEntry[]? _internalEntries = null;
    private string _query = "";
    private InternalEntry[] _searchResults = new InternalEntry[] { };
    private InternalEntry? _prevFocusedEntry = null;
    private SelectorMode _mode;
    private bool _isFocusedEntryContentUpdated = false;
    private bool _isQueryUpdated = false;
    private bool _isCursorUpdated = false;
    private bool _isPreviewScrollUpdated = false;
    private bool _isMarkerUpdated = false;
    private int? _cursorIndexRequest = null;
    private int _previewVerticalScroll = 0;

    public bool IsUpdated { get; private set; } = false;
    public bool IsQuit { get; private set; } = false;
    public bool IsActionAccepted { get; private set; } = false;
    public bool IsActionWindowOpen
    {
        get => _actionWindow.IsVisible();
    }
    public KeyCombination? LastKeyCombination { get; private set; } = null;

    public ResultWindow(SelectorMode mode, LayoutItem searchBarLayout)
    {
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;

        _mode = mode;
        if (theme.PreviewPosition == PreviewPosition.Bottom)
        {
            _resultLayout = new VerticalLayout();
        }
        else
        {
            _resultLayout = new HorizontalLayout();
        }

        RootLayout.AddChild(_resultLayout);
        RootLayout.AddChild(_actionWindow.RootLayout);

        _resultLayout.AddChild(_searchLayout);
        _resultLayout.AddChild(_previewBox);

        _searchLayout.AddChild(searchBarLayout);
        _searchLayout.AddChild(_entryLayout);

        _entryLayout.AddChild(_cursorBox);
        _entryLayout.AddChild(_markerBox);
        _entryLayout.AddChild(_nameBox);
        _entryLayout.AddChild(_descriptionBox);

        _entryLayout.BorderFlags = theme.EntryBorderFlags;
        _entryLayout.BorderSymbol = theme.EntryBorderSymbol;
        _entryLayout.BorderForegroundColor = theme.EntryBorderForegroundColor;
        _entryLayout.BorderBackgroundColor = theme.EntryBorderBackgroundColor;

        int cursorLength = TextBox.GetDisplayWidth(theme.Cursor);
        _cursorBox.LayoutSizeWidth.Set(LayoutSizeType.Absolute, cursorLength);
        if (theme.CursorBoxBackgroundColor is not null)
        {
            _cursorBox.FillCells = true;
            _cursorBox.DefaultBackgroundColor = theme.CursorBoxBackgroundColor;
        }
        _cursorBox.Active = theme.CursorEnable;

        int markerLength = TextBox.GetDisplayWidth(theme.Marker);
        _markerBox.LayoutSizeWidth.Set(LayoutSizeType.Absolute, markerLength);
        if (theme.MarkerBoxBackgroundColor is not null)
        {
            _markerBox.FillCells = true;
            _markerBox.DefaultBackgroundColor = theme.MarkerBoxBackgroundColor;
        }
        _markerBox.Active = (_mode == SelectorMode.MultiSelection);

        if (theme.NameBoxBackgroundColor is not null)
        {
            _nameBox.FillCells = true;
            _nameBox.DefaultBackgroundColor = theme.NameBoxBackgroundColor;
        }

        _descriptionBox.Margin.Left = 1;
        if (theme.DescriptionBoxBackgroundColor is not null)
        {
            _descriptionBox.FillCells = true;
            _descriptionBox.DefaultBackgroundColor = theme.DescriptionBoxBackgroundColor;
        }

        _previewBox.VerticalScrollBarEnable = true;
        _previewBox.BorderFlags = theme.PreviewBorderFlags;
        _previewBox.BorderSymbol = theme.PreviewBorderSymbol;
        _previewBox.BorderForegroundColor = theme.PreviewBorderForegroundColor;
        _previewBox.BorderBackgroundColor = theme.PreviewBorderBackgroundColor;
        if (!theme.PreviewBorderFlags.HasFlag(BorderFlag.Top))
        {
            _previewBox.Padding.Top = 1;
        }
        if (!theme.PreviewBorderFlags.HasFlag(BorderFlag.Bottom))
        {
            _previewBox.Padding.Bottom = 1;
        }

        _previewBox.ScrollBarForegroundColor = theme.PreviewScrollBarForegroundColor;
        _previewBox.ScrollBarBackgroundColor = theme.PreviewScrollBarBackgroundColor;
        _previewBox.Padding.Left = 1;
        if (theme.PreviewBoxBackgroundColor is not null)
        {
            _previewBox.FillCells = true;
            _previewBox.DefaultBackgroundColor = theme.PreviewBoxBackgroundColor;
        }
    }

    public void SetEntries(IReadOnlyList<SelectorEntry> entries)
    {
        _selectorEntries = entries;
        _internalEntries = InternalEntry.ConvertFrom(entries);
        InitializeContentLayout();
    }

    public void SetContext(SelectorContext context)
    {
        RequestCursorIndex(context.CursorIndex);
        MarkEntries(context.MarkedEntryIndexes);
    }

    private void InitializeContentLayout()
    {
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;
        bool descExists = false;
        bool previewExists = false;
        if (_selectorEntries is not null)
        {
            foreach (var entry in _selectorEntries)
            {
                if (!string.IsNullOrEmpty(entry.Description))
                {
                    descExists = true;
                }
                if (entry.Preview is not null)
                {
                    previewExists = true;
                }
                if (entry.PreviewAsyncScript is not null)
                {
                    previewExists = true;
                }
            }
        }

        bool descEnable = descExists && theme.DescriptionEnable;
        if (descEnable)
        {
            _nameBox.LayoutSizeWidth.Set(LayoutSizeType.Percentage, theme.NameWidthPercentage);
            _descriptionBox.VerticalScrollBarEnable = true;
            _descriptionBox.ScrollBarForegroundColor = theme.EntryScrollBarForegroundColor;
            _descriptionBox.ScrollBarBackgroundColor = theme.EntryScrollBarBackgroundColor;
        }
        else
        {
            _nameBox.LayoutSizeWidth.Set(LayoutSizeType.Stretch);
            _nameBox.VerticalScrollBarEnable = true;
            _nameBox.ScrollBarForegroundColor = theme.EntryScrollBarForegroundColor;
            _nameBox.ScrollBarBackgroundColor = theme.EntryScrollBarBackgroundColor;
        }
        _descriptionBox.Active = descEnable;

        bool previewEnable = previewExists && theme.PreviewEnable;
        if (previewEnable)
        {
            if (theme.PreviewPosition == PreviewPosition.Bottom)
            {
                _searchLayout.LayoutSizeHeight.Set(LayoutSizeType.Percentage, 100 - theme.PreviewSizePercentage);
            }
            else
            {
                _searchLayout.LayoutSizeWidth.Set(LayoutSizeType.Percentage, 100 - theme.PreviewSizePercentage);
            }
        }
        _previewBox.Active = previewEnable;
    }

    public void UpdateLayout()
    {
        var focusedEntry = GetFocusedInternalEntry();
        var isAnyEntryMarked = IsAnyEntryMarked();
        _actionWindow.SetEntry(focusedEntry, isAnyEntryMarked);
        _actionWindow.Update();
    }

    public void SetQuery(string query)
    {
        _query = query;
        _isQueryUpdated = true;
    }

    public void Update()
    {
        GetActionWindowState();
        if (IsQuit || IsActionAccepted)
            return;

        Search();
        ProcessCursorIndexRequest();
        ReadKeys();
        ProcessAutoReturn();
        if (IsQuit || IsActionAccepted)
            return;

        UpdateFocusedEntry();
        BuildUi();

        _prevFocusedEntry = GetFocusedInternalEntry();
        _isQueryUpdated = false;
        _isCursorUpdated = false;
        _isPreviewScrollUpdated = false;
        _isMarkerUpdated = false;
    }

    private SelectorEntry? GetFocusedEntry()
    {
        int cursorIndex = _nameBox.GetFocusLineIndex();
        if (cursorIndex >= _searchResults.Length)
            return null;
        return _searchResults[cursorIndex].SelectorEntry;
    }

    private InternalEntry? GetFocusedInternalEntry()
    {
        int cursorIndex = _nameBox.GetFocusLineIndex();
        if (cursorIndex >= _searchResults.Length)
            return null;
        return _searchResults[cursorIndex];
    }

    private bool IsFocusedEntryUpdated()
    {
        return _prevFocusedEntry != GetFocusedInternalEntry();
    }

    public (SelectorEntry? FocusedEntry, int CursorIndex,
            SelectorEntry[]? MarkedEntries, int[]? MarkedEntryIndexes) GetResult()
    {
        int cursorIndex = _nameBox.GetFocusLineIndex();
        var marked = GetMarkedEntries();
        if (IsActionAccepted)
        {
            return (GetFocusedEntry(), cursorIndex, marked.Entries, marked.Indexes);
        }
        return (null, cursorIndex, null, marked.Indexes);
    }

    private void GetActionWindowState()
    {
        if (_actionWindow.IsQuit)
        {
            IsQuit = true;
            LastKeyCombination = _actionWindow.LastKeyCombination;
            return;
        }

        if (_actionWindow.IsActionAccepted)
        {
            IsActionAccepted = true;
            LastKeyCombination = _actionWindow.LastKeyCombination;
            return;
        }
    }

    private void ProcessAutoReturn()
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch)
        {
            SetCursorIndex(0);
            IsActionAccepted = true;
            LastKeyCombination = null;
        }
    }

    private void Search()
    {
        if (!_isQueryUpdated)
            return;

        SetCursorIndex(0);

        if (_internalEntries is null)
            return;

        _searchResults = _searcher.Search(_internalEntries, _query);
    }

    private void RequestCursorIndex(int index)
    {
        _cursorIndexRequest = index;
    }

    private void ProcessCursorIndexRequest()
    {
        if (_cursorIndexRequest is int index)
        {
            SetCursorIndex(index);
            _cursorIndexRequest = null;
        }
    }

    private void ReadKeys()
    {
        if (_actionWindow.IsVisible())
            return;

        var internalEntry = GetFocusedInternalEntry();
        var inputKeys = KeyInput.GetInstance().GetFrameInputs();
        var keyBinding = SelectorOptionHolder.GetInstance().Option.KeyBinding;
        bool isAnyEntryMarked = IsAnyEntryMarked();

        ActionKey[] actionKeys = isAnyEntryMarked ?
            keyBinding.DefaultActionKeysMultiSelection :
            keyBinding.DefaultActionKeys;

        if (internalEntry is not null)
        {
            actionKeys = isAnyEntryMarked ? internalEntry.GetActionKeysMultiSelection() : internalEntry.GetActionKeys();
        }

        foreach (var key in inputKeys)
        {
            foreach (var quitKey in keyBinding.QuitKeys)
            {
                if (key.KeyCombination.Equals(quitKey))
                {
                    IsQuit = true;
                    LastKeyCombination = key.KeyCombination;
                    return;
                }
            }

            if (actionKeys is not null)
            {
                foreach (var actionKey in actionKeys)
                {
                    if (actionKey.KeyCombination.Equals(key.KeyCombination))
                    {
                        IsActionAccepted = true;
                        LastKeyCombination = key.KeyCombination;
                        return;
                    }
                }
            }

            ReadKeysContinue(key, keyBinding);
        }
    }

    private void ReadKeysContinue(KeyInput.KeyInfo key, KeyBinding keyBinding)
    {
        if (key.KeyCombination.Equals(KeyCombination.UpArrow))
        {
            DecrementCursorIndex();
            return;
        }
        if (key.KeyCombination.Equals(KeyCombination.DownArrow))
        {
            IncrementCursorIndex();
            return;
        }

        foreach (var upKey in keyBinding.PreviewVerticalScrollUpKeys)
        {
            if (key.KeyCombination.Equals(upKey))
            {
                DecrementPreviewVerticalScroll();
                return;
            }
        }

        foreach (var downKey in keyBinding.PreviewVerticalScrollDownKeys)
        {
            if (key.KeyCombination.Equals(downKey))
            {
                IncrementPreviewVerticalScroll();
                return;
            }
        }

        foreach (var markerKey in keyBinding.MarkerKeys)
        {
            if (key.KeyCombination.Equals(markerKey))
            {
                ToggleMarker();
                return;
            }
        }

        foreach (var toggleKey in keyBinding.ToggleAllMarkerKeys)
        {
            if (key.KeyCombination.Equals(toggleKey))
            {
                ToggleAllMarkers();
                return;
            }
        }
    }

    private void UpdateFocusedEntry()
    {
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;

        _isFocusedEntryContentUpdated = false;
        var focusedEntry = GetFocusedInternalEntry();
        if (focusedEntry is not null)
        {
            if (theme.PreviewEnable)
            {
                focusedEntry.UpdatePreviewTask();
            }
            _isFocusedEntryContentUpdated = focusedEntry.IsUpdated;
        }
    }

    private void BuildUi()
    {
        IsUpdated = false;
        if (!_isFocusedEntryContentUpdated &&
            !_isQueryUpdated &&
            !_isCursorUpdated &&
            !_isPreviewScrollUpdated &&
            !_isMarkerUpdated &&
            !_actionWindow.IsUpdated)
        {
            return;
        }
        IsUpdated = true;

        var theme = SelectorOptionHolder.GetInstance().Option.Theme;
        bool isMarkerEnabled = (_mode == SelectorMode.MultiSelection);
        int lineCount = _searchResults.Length;

        _cursorBox.Clear(lineCount);
        _markerBox.Clear(lineCount);
        _nameBox.Clear(lineCount);
        _descriptionBox.Clear(lineCount);

        if (_searchResults.Length == 0)
        {
            _previewBox.ClearAndSetVerticalScroll(0, 0);
        }

        var visibleLineRange = _nameBox.GetVisibleLineRange();
        for (int i = visibleLineRange.TopLineIndex; i <= visibleLineRange.BottomLineIndex; ++i)
        {
            if (i >= _searchResults.Length)
                break;

            var internalEntry = _searchResults[i];
            var selectorEntry = internalEntry.SelectorEntry;

            string? icon = null;
            if (!string.IsNullOrEmpty(selectorEntry.Icon) && theme.IconEnable)
            {
                icon = selectorEntry.Icon + ' ';
            }

            if (i == _nameBox.GetFocusLineIndex())
            {
                if (theme.PreviewEnable)
                {
                    var previewLines = internalEntry.GetPreviewLines();
                    int previewLineCount = (previewLines is not null) ? previewLines.Length : 0;

                    if (IsFocusedEntryUpdated() || _isFocusedEntryContentUpdated)
                    {
                        _previewBox.ClearAndSetVerticalScroll(
                            selectorEntry.PreviewInitialVerticalScroll,
                            previewLineCount);
                    }
                    else
                    {
                        _previewBox.Clear(previewLineCount);
                    }

                    if (previewLines is not null)
                    {
                        for (int previewLineIndex = 0; previewLineIndex < previewLineCount; ++previewLineIndex)
                        {
                            _previewBox.AddWord(
                                previewLineIndex,
                                previewLines[previewLineIndex],
                                theme.PreviewForegroundColor,
                                theme.PreviewBackgroundColor,
                                theme.PreviewStyle);
                        }
                    }
                }

                if (theme.CursorEnable)
                {
                    _cursorBox.AddWord(
                        i,
                        theme.Cursor,
                        theme.CursorForegroundColor,
                        theme.CursorBackgroundColor);
                }

                if (isMarkerEnabled && internalEntry.IsMarked)
                {
                    _markerBox.AddWord(
                        i,
                        theme.Marker,
                        theme.MarkerForegroundColor,
                        theme.MarkerBackgroundColor);
                }

                if (icon is not null)
                {
                    _nameBox.AddWord(i, icon, theme.IconFocusForegroundColor, theme.IconFocusBackgroundColor);
                }

                _nameBox.AddWord(
                    i,
                    selectorEntry.Name,
                    theme.NameFocusForegroundColor,
                    theme.NameFocusBackgroundColor,
                    theme.NameFocusStyle,
                    internalEntry.NameMatches,
                    theme.NameFocusHighlightForegroundColor,
                    theme.NameFocusHighlightBackgroundColor,
                    theme.NameFocusHighlightStyle);

                if (selectorEntry.Description is not null)
                {
                    _descriptionBox.AddWord(
                        i,
                        selectorEntry.Description,
                        theme.DescriptionFocusForegroundColor,
                        theme.DescriptionFocusBackgroundColor,
                        theme.DescriptionFocusStyle,
                        internalEntry.DescriptionMatches,
                        theme.DescriptionFocusHighlightForegroundColor,
                        theme.DescriptionFocusHighlightBackgroundColor,
                        theme.DescriptionFocusHighlightStyle);
                }
            }
            else
            {
                if (isMarkerEnabled && internalEntry.IsMarked)
                {
                    _markerBox.AddWord(
                        i,
                        theme.Marker,
                        theme.MarkerForegroundColor,
                        theme.MarkerBackgroundColor);
                }

                if (icon is not null)
                {
                    _nameBox.AddWord(i, icon, theme.IconForegroundColor, theme.IconBackgroundColor);
                }

                _nameBox.AddWord(
                    i,
                    selectorEntry.Name,
                    theme.NameForegroundColor,
                    theme.NameBackgroundColor,
                    theme.NameStyle,
                    internalEntry.NameMatches,
                    theme.NameHighlightForegroundColor,
                    theme.NameHighlightBackgroundColor,
                    theme.NameHighlightStyle);

                if (selectorEntry.Description is not null && theme.DescriptionEnable)
                {
                    _descriptionBox.AddWord(
                        i,
                        selectorEntry.Description,
                        theme.DescriptionForegroundColor,
                        theme.DescriptionBackgroundColor,
                        theme.DescriptionStyle,
                        internalEntry.DescriptionMatches,
                        theme.DescriptionHighlightForegroundColor,
                        theme.DescriptionHighlightBackgroundColor,
                        theme.DescriptionHighlightStyle);
                }
            }
        }
    }

    private void SetCursorIndex(int index)
    {
        int lineCount = _searchResults.Length;

        _cursorBox.ClearAndSetFocusLine(index, lineCount);
        _markerBox.ClearAndSetFocusLine(index, lineCount);
        _nameBox.ClearAndSetFocusLine(index, lineCount);
        _descriptionBox.ClearAndSetFocusLine(index, lineCount);

        _isCursorUpdated = true;
    }

    private void IncrementCursorIndex()
    {
        _cursorBox.IncrementFocusLine();
        _markerBox.IncrementFocusLine();
        _nameBox.IncrementFocusLine();
        _descriptionBox.IncrementFocusLine();

        _isCursorUpdated = true;
    }

    private void DecrementCursorIndex()
    {
        _cursorBox.DecrementFocusLine();
        _markerBox.DecrementFocusLine();
        _nameBox.DecrementFocusLine();
        _descriptionBox.DecrementFocusLine();

        _isCursorUpdated = true;
    }

    private void IncrementPreviewVerticalScroll()
    {
        _previewBox.IncrementVerticalScroll();
        _isPreviewScrollUpdated = true;
    }

    private void DecrementPreviewVerticalScroll()
    {
        _previewBox.DecrementVerticalScroll();
        _isPreviewScrollUpdated = true;
    }

    private bool IsAnyEntryMarked()
    {
        if (_mode == SelectorMode.SingleSelection)
            return false;

        foreach (var entry in _searchResults)
        {
            if (entry.IsMarked)
            {
                return true;
            }
        }
        return false;
    }

    private bool IsAllEntryMarked()
    {
        if (_mode == SelectorMode.SingleSelection)
            return false;

        foreach (var entry in _searchResults)
        {
            if (!entry.IsMarked)
            {
                return false;
            }
        }
        return true;
    }

    private void ToggleMarker()
    {
        var internalEntry = GetFocusedInternalEntry();
        if (internalEntry is not null)
        {
            internalEntry.IsMarked = !internalEntry.IsMarked;
            _isMarkerUpdated = true;
        }
    }

    private void ToggleAllMarkers()
    {
        bool mark = !IsAllEntryMarked();
        foreach (var entry in _searchResults)
        {
            entry.IsMarked = mark;
        }
        _isMarkerUpdated = true;
    }

    private void MarkEntries(int[]? indexes)
    {
        if (indexes is null || _internalEntries is null)
            return;

        foreach (var index in indexes)
        {
            if (index < _internalEntries.Length)
            {
                _internalEntries[index].IsMarked = true;
            }
        }
    }

    private (SelectorEntry[]? Entries, int[]? Indexes) GetMarkedEntries()
    {
        if (_mode == SelectorMode.SingleSelection || _internalEntries is null)
            return (null, null);

        var markedEntries = new List<SelectorEntry>();
        var markedIndexes = new List<int>();
        for (int i = 0; i < _internalEntries.Length; ++i)
        {
            var entry = _internalEntries[i];
            if (entry.IsMarked)
            {
                markedEntries.Add(entry.SelectorEntry);
                markedIndexes.Add(i);
            }
        }

        if (markedEntries.Count == 0)
        {
            return (null, null);
        }
        else
        {
            return (markedEntries.ToArray(), markedIndexes.ToArray());
        }
    }
}
