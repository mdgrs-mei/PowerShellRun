namespace PowerShellRun;
using PowerShellRun.Dependency;
using System;
using System.Collections.Generic;
using System.Management.Automation.Language;
using System.Text;

internal class TextBox : LayoutItem
{
    public class Word
    {
        public string String { get; set; } = "";
        public FontColor? ForegroundColor { get; set; } = null;
        public FontColor? BackgroundColor { get; set; } = null;
        public FontStyle FontStyle = FontStyle.Default;
        public bool[]? HighlightFlags { get; set; } = null;
        public FontColor? HighlightForegroundColor { get; set; } = null;
        public FontColor? HighlightBackgroundColor { get; set; } = null;
        public FontStyle HighlightFontStyle = FontStyle.Default;

        public Word(
            string str,
            FontColor? foregroundColor = null,
            FontColor? backgroundColor = null,
            FontStyle fontStyle = FontStyle.Default,
            bool[]? highlightFlags = null,
            FontColor? highlightForegroundColor = null,
            FontColor? highlightBackgroundColor = null,
            FontStyle highlightFontStyle = FontStyle.Default)
        {
            String = str;
            ForegroundColor = foregroundColor;
            BackgroundColor = backgroundColor;
            FontStyle = fontStyle;
            HighlightFlags = highlightFlags;
            HighlightForegroundColor = highlightForegroundColor;
            HighlightBackgroundColor = highlightBackgroundColor;
            HighlightFontStyle = highlightFontStyle;
        }
    }

    private class Line
    {
        public List<Word> Words { get; set; } = new List<Word>();
        public List<CanvasCell>? Cells { get; set; } = null;

        public void ClearCells()
        {
            Cells = null;
        }
        public void ConvertToCells(int maxWidth = Constants.TextBoxMaxWidth)
        {
            if (Cells is not null)
                return;

            Cells = new List<CanvasCell>();
            int tabSize = SelectorOptionHolder.GetInstance().Option.Theme.TabSize;
            int cellIndex = 0;
            StringBuilder? escapeSequenceBuilder = null;

            void AddEscapeSequence(char character)
            {
                if (escapeSequenceBuilder is null)
                {
                    escapeSequenceBuilder = new StringBuilder();
                }
                escapeSequenceBuilder.Append(character);
            }

            string? GetEscapeSequence()
            {
                if (escapeSequenceBuilder is not null && escapeSequenceBuilder.Length > 0)
                {
                    string escapeSequence = escapeSequenceBuilder.ToString();
                    escapeSequenceBuilder.Clear();
                    return escapeSequence;
                }
                return null;
            }

            void SetCell(Word word, int charIndex, char character)
            {
                FontColor? foregroundColor = word.ForegroundColor;
                FontColor? backgroundColor = word.BackgroundColor;
                FontStyle fontStyle = word.FontStyle;
                if (word.HighlightFlags is not null && charIndex < word.HighlightFlags.Length)
                {
                    if (word.HighlightFlags[charIndex])
                    {
                        foregroundColor = word.HighlightForegroundColor;
                        backgroundColor = word.HighlightBackgroundColor;
                        fontStyle = word.HighlightFontStyle;
                    }
                }

                string? escapeSequence = GetEscapeSequence();

                var cell = new CanvasCell();
                cell.SetCharacter(
                    character,
                    foregroundColor,
                    backgroundColor,
                    fontStyle,
                    CanvasCell.Option.None);

                cell.HeadEscapeSequence = escapeSequence;
                Cells.Add(cell);

                ++cellIndex;
            }

            foreach (var word in Words)
            {
                bool escaped = false;
                for (int i = 0; i < word.String.Length; ++i)
                {
                    if (cellIndex >= maxWidth)
                        break;

                    char character = word.String[i];
                    if (escaped)
                    {
                        if (character == 'm')
                        {
                            escaped = false;
                        }
                        AddEscapeSequence(character);
                    }
                    else
                    if (character == '\x1b')
                    {
                        escaped = true;
                        AddEscapeSequence(character);
                    }
                    else
                    if (character == '\t')
                    {
                        int spaces = tabSize - cellIndex % tabSize;
                        for (int s = 0; s < spaces; ++s)
                        {
                            SetCell(word, i, ' ');
                            if (cellIndex >= maxWidth)
                                break;
                        }
                    }
                    else
                    {
                        int displayWidth = Unicode.GetDisplayWidth(character);
                        if (displayWidth <= 0)
                            continue;

                        if (cellIndex + displayWidth > maxWidth)
                            continue;

                        SetCell(word, i, character);
                        if (displayWidth == 2)
                        {
                            SetCell(word, i, '\0');
                        }
                    }
                }

                if (cellIndex > 0)
                {
                    Cells[cellIndex - 1].TailEscapeSequence = GetEscapeSequence();
                }
            }
        }
    }

    public static int GetDisplayWidth(string str)
    {
        int tabSize = SelectorOptionHolder.GetInstance().Option.Theme.TabSize;
        int count = 0;
        bool escaped = false;
        for (int i = 0; i < str.Length; ++i)
        {
            char character = str[i];
            if (escaped)
            {
                if (character == 'm')
                {
                    escaped = false;
                }
            }
            else
            if (character == '\x1b')
            {
                escaped = true;
            }
            else
            if (character == '\t')
            {
                count += tabSize - count % tabSize;
            }
            else
            {
                int displayWidth = Unicode.GetDisplayWidth(character);
                if (displayWidth <= 0)
                    continue;
                count += displayWidth;
            }
        }
        return count;
    }

    private List<Line> _lines = new List<Line>();
    private int _topLineIndex = 0;
    private int _bottomLineIndex = 0;
    private int? _focusLineIndex = 0;
    private int _verticalScroll = 0;
    private int _lineCountForScrollBar = 0;

    public bool FillCells { get; set; } = false;
    public FontColor? DefaultBackgroundColor { get; set; } = null;
    public bool VerticalScrollBarEnable { get; set; } = false;
    public FontColor? ScrollBarForegroundColor { get; set; } = null;
    public FontColor? ScrollBarBackgroundColor { get; set; } = null;
    public bool OnlyStoreLinesInVisibleRange { get; set; } = true;

    public void ClearAndSetFocusLine(int focusLineIndex)
    {
        _focusLineIndex = focusLineIndex;
        _verticalScroll = 0;
        Clear();
    }

    public void ClearAndSetVerticalScroll(int scroll)
    {
        _focusLineIndex = null;
        _verticalScroll = Math.Max(scroll, 0);
        Clear();
    }

    private void Clear()
    {
        _lines.Clear();
        UpdateVisibleLineRange();

        if (OnlyStoreLinesInVisibleRange)
        {
            var visibleRange = GetVisibleLineRange();
            var lineCount = visibleRange.BottomLineIndex - visibleRange.TopLineIndex + 1;
            for (int i = 0; i < lineCount; ++i)
            {
                _lines.Add(new Line());
            }
        }
    }

    public void SetLineCountForScrollBar(int lineCount)
    {
        _lineCountForScrollBar = lineCount;
    }

    public void AddWord(
        int lineIndex,
        string word,
        FontColor? foregroundColor = null,
        FontColor? backgroundColor = null,
        FontStyle fontStyle = FontStyle.Default,
        bool[]? highlightFlags = null,
        FontColor? highlightForegroundColor = null,
        FontColor? highlightBackgroundColor = null,
        FontStyle highlightFontStyle = FontStyle.Default)
    {
        if (OnlyStoreLinesInVisibleRange)
        {
            lineIndex -= GetVisibleLineRange().TopLineIndex;
            if (lineIndex >= _lines.Count)
                return;
        }

        if (lineIndex < 0)
            return;

        if (!OnlyStoreLinesInVisibleRange)
        {
            while (_lines.Count <= lineIndex)
            {
                _lines.Add(new Line());
            }
        }

        if (backgroundColor is null)
        {
            backgroundColor = DefaultBackgroundColor;
        }
        if (highlightBackgroundColor is null)
        {
            highlightBackgroundColor = DefaultBackgroundColor;
        }

        var _word = new Word(
            word,
            foregroundColor,
            backgroundColor,
            fontStyle,
            highlightFlags,
            highlightForegroundColor,
            highlightBackgroundColor,
            highlightFontStyle);

        _lines[lineIndex].Words.Add(_word);
    }

    public void SetLineColor(
        int lineIndex,
        FontColor? foregroundColor = null,
        FontColor? backgroundColor = null,
        FontColor? highlightForegroundColor = null,
        FontColor? highlightBackgroundColor = null)
    {
        if (OnlyStoreLinesInVisibleRange)
        {
            lineIndex -= GetVisibleLineRange().TopLineIndex;
        }

        if (lineIndex < 0 || lineIndex >= _lines.Count)
            return;

        var line = _lines[lineIndex];
        foreach (var word in line.Words)
        {
            word.ForegroundColor = foregroundColor;
            word.BackgroundColor = backgroundColor;
            word.HighlightForegroundColor = highlightForegroundColor;
            word.HighlightBackgroundColor = highlightBackgroundColor;
        }
        line.ClearCells();
    }

    public (int TopLineIndex, int BottomLineIndex) GetVisibleLineRange()
    {
        return (_topLineIndex, _bottomLineIndex);
    }

    public override (LayoutSize Width, LayoutSize Height) GetLayoutSize()
    {
        var layoutSize = base.GetLayoutSize();

        if (layoutSize.Width.Type == LayoutSizeType.Content)
        {
            int maxLineLength = 0;
            foreach (var line in _lines)
            {
                line.ConvertToCells();
                if (line.Cells is not null)
                {
                    maxLineLength = Math.Max(maxLineLength, line.Cells.Count);
                }
            }

            int width = maxLineLength;
            if (BorderFlags.HasFlag(BorderFlag.Left))
            {
                ++width;
            }
            if (BorderFlags.HasFlag(BorderFlag.Right))
            {
                ++width;
            }
            width += Padding.Left + Padding.Right;
            if (VerticalScrollBarEnable)
            {
                ++width;
            }

            if (MinWidth is int minWidth)
            {
                width = Math.Max(width, minWidth);
            }

            layoutSize.Width = new LayoutSize(LayoutSizeType.Absolute, width);
        }

        return layoutSize;
    }

    public override void UpdateLayout(int x, int y, int width, int height)
    {
        base.UpdateLayout(x, y, width, height);
        UpdateVisibleLineRange();
    }

    private void UpdateVisibleLineRange()
    {
        int innerLayoutHeight = GetInnerLayout().Height;

        if (_focusLineIndex is int focusLineIndex)
        {
            if (focusLineIndex < _topLineIndex)
            {
                _topLineIndex = focusLineIndex;
            }
            else
            if (_focusLineIndex >= _topLineIndex + innerLayoutHeight)
            {
                _topLineIndex = focusLineIndex - innerLayoutHeight + 1;
            }
        }
        else
        {
            _topLineIndex = _verticalScroll;
        }

        _bottomLineIndex = _topLineIndex + innerLayoutHeight - 1;
        _bottomLineIndex = Math.Max(_topLineIndex, _bottomLineIndex);
    }

    public override (int X, int Y, int Width, int Height) GetInnerLayout()
    {
        var layout = base.GetInnerLayout();
        if (VerticalScrollBarEnable)
        {
            layout.Width -= 1;
            layout.Width = Math.Max(layout.Width, 0);
        }
        return layout;
    }

    public override void Render()
    {
        if (!Active)
            return;

        RenderLines();
        RenderScrollBars();
        base.Render();
    }

    private void RenderLines()
    {
        var innerLayout = GetInnerLayout();
        var canvas = Canvas.GetInstance();
        int lineIndexStart = 0;
        int lineIndexEnd = _lines.Count - 1;

        if (!OnlyStoreLinesInVisibleRange)
        {
            var visibleRange = GetVisibleLineRange();
            lineIndexStart = visibleRange.TopLineIndex;
            lineIndexEnd = visibleRange.BottomLineIndex;
        }

        int innerLayoutX = innerLayout.X;
        int innerLayoutY = innerLayout.Y;
        var leftEnd = X;
        var rightEnd = X + Width - 1;

        int y = innerLayoutY;
        for (int i = lineIndexStart; i <= lineIndexEnd; ++i)
        {
            int x = innerLayoutX;
            if (i < _lines.Count)
            {
                var line = _lines[i];
                line.ConvertToCells(innerLayout.Width);
                if (line.Cells is not null)
                {
                    foreach (var cell in line.Cells)
                    {
                        canvas.SetCell(x, y, cell);
                        ++x;
                    }
                }
            }

            // Fill left and right padding area.
            if (FillCells)
            {
                while (x <= rightEnd)
                {
                    canvas.SetCell(
                        x,
                        y,
                        ' ',
                        null,
                        DefaultBackgroundColor);
                    ++x;
                }

                for (x = innerLayoutX - 1; x >= leftEnd; --x)
                {
                    canvas.SetCell(
                        x,
                        y,
                        ' ',
                        null,
                        DefaultBackgroundColor);
                }
            }
            ++y;
        }

        // Fill top and bottom padding area.
        if (FillCells)
        {
            var topEnd = Y;
            var bottomEnd = Y + Height - 1;

            for (y = innerLayoutY - 1; y >= topEnd; --y)
            {
                for (int x = leftEnd; x <= rightEnd; ++x)
                {
                    canvas.SetCell(
                        x,
                        y,
                        ' ',
                        null,
                        DefaultBackgroundColor);
                }
            }

            for (y = innerLayoutY + innerLayout.Height - 1; y <= bottomEnd; ++y)
            {
                for (int x = leftEnd; x <= rightEnd; ++x)
                {
                    canvas.SetCell(
                        x,
                        y,
                        ' ',
                        null,
                        DefaultBackgroundColor);
                }
            }
        }

        if (!BorderFlags.HasFlag(BorderFlag.Left))
        {
            y = innerLayout.Y;
            for (int i = lineIndexStart; i <= lineIndexEnd; ++i)
            {
                canvas.SetCellOption(
                    leftEnd,
                    y,
                    CanvasCell.Option.ForceResetColor);
                ++y;
            }
        }
    }

    private void RenderScrollBars()
    {
        if (!VerticalScrollBarEnable)
            return;

        var canvas = Canvas.GetInstance();
        var innerLayout = base.GetInnerLayout();
        var innerWidth = Math.Max(innerLayout.Width, 1);
        var innerHeight = Math.Max(innerLayout.Height, 1);
        var visibleRange = GetVisibleLineRange();

        for (int i = 0; i < innerHeight; ++i)
        {
            canvas.SetCell(
                innerLayout.X + innerWidth - 1,
                innerLayout.Y + i,
                ' ',
                null,
                ScrollBarBackgroundColor);
        }

        if (_lineCountForScrollBar > 0)
        {
            int scrollBarHeight = Math.Clamp(innerHeight * innerHeight / _lineCountForScrollBar, 1, innerHeight);

            int scrollBarBottomLineIndex = (int)((innerHeight - 1) * ((double)(visibleRange.BottomLineIndex) / (_lineCountForScrollBar - 1)));
            scrollBarBottomLineIndex = Math.Clamp(scrollBarBottomLineIndex, 0, innerHeight - 1);

            int scrollBarTopLineIndex = Math.Clamp(scrollBarBottomLineIndex - scrollBarHeight + 1, 0, innerHeight - 1);

            if (visibleRange.TopLineIndex == 0)
            {
                scrollBarTopLineIndex = 0;
                scrollBarBottomLineIndex = Math.Clamp(scrollBarTopLineIndex + scrollBarHeight - 1, 0, innerHeight - 1);
            }

            // Render scrollbar only when less than 100%.
            if (scrollBarHeight < innerHeight)
            {
                for (int i = scrollBarTopLineIndex; i <= scrollBarBottomLineIndex; ++i)
                {
                    canvas.SetCell(
                        innerLayout.X + innerWidth - 1,
                        innerLayout.Y + i,
                        '│',
                        ScrollBarForegroundColor,
                        ScrollBarBackgroundColor,
                        FontStyle.Default,
                        null,
                        CanvasCell.Option.ForceResetColor);
                }
            }
        }
    }
}
