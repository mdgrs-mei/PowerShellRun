using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;

namespace PowerShellRun;

internal sealed class Canvas : Singleton<Canvas>
{
    private CanvasCell[]? _cells = null;
    private StreamWriter? _streamWriter = null;

    private TextWriter? _originalConsoleOut;
    private System.Text.Encoding? _originalEncoding;
    private LayoutSize _height = new LayoutSize(LayoutSizeType.Percentage, 50);
    private int? _rootCursorY = null;
    private int _cursorOffsetX = 0;
    private int _cursorOffsetY = 0;
    private int _cursorOffsetYFromRoot = 0;
    FontColor _defaultForegroundColor = FontColor.Default;
    FontColor _defaultBackgroundColor = FontColor.Default;

    public int Width { get; private set; } = 0;
    public int Height { get; private set; } = 0;

    public void Init(LayoutSize height)
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch)
            return;

        _originalConsoleOut = Console.Out;
        _originalEncoding = Console.OutputEncoding;

        Console.OutputEncoding = System.Text.Encoding.UTF8;

        // Replace writer to disable auto flush.
        // The explicit encoding argument is needed to suppress "System.Text.EncoderFallbackException: Unable to translate Unicode character"
        // which happens when emoji surrogate pairs are partially cut by borders for example.
        _streamWriter = new StreamWriter(Console.OpenStandardOutput(), new UTF8Encoding(false));
        _streamWriter.AutoFlush = false;
        Console.SetOut(_streamWriter);

        Debug.Assert(height.Type == LayoutSizeType.Percentage || height.Type == LayoutSizeType.Absolute);
        _height = height;
        _cursorOffsetX = 0;
        _cursorOffsetY = 0;
        _cursorOffsetYFromRoot = 0;
        UpdateSize();

        var theme = SelectorOptionHolder.GetInstance().Option.Theme;
        if (theme.DefaultForegroundColor is not null)
        {
            _defaultForegroundColor = theme.DefaultForegroundColor;
        }
        if (theme.DefaultBackgroundColor is not null)
        {
            _defaultBackgroundColor = theme.DefaultBackgroundColor;
        }
    }

    public void Term()
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch)
            return;

        ClearCells();
        SetCursorOffset(0, -option.Theme.CanvasTopMargin);
        _defaultForegroundColor = FontColor.Default;
        _defaultBackgroundColor = FontColor.Default;
        Write();

        if (_originalConsoleOut is not null)
        {
            Console.SetOut(_originalConsoleOut);
        }
        if (_originalEncoding is not null)
        {
            Console.OutputEncoding = _originalEncoding;
        }
        if (_streamWriter is not null)
        {
            _streamWriter.Dispose();
            _streamWriter = null;
        }

        _cells = null;
    }

    public void UpdateSize()
    {
        var option = SelectorOptionHolder.GetInstance().Option;
        if (option.AutoReturnBestMatch)
            return;

        int windowWidth = Console.WindowWidth;
        int windowHeight = Console.WindowHeight;

        int newWidth = windowWidth;
        int newHeight = windowHeight;
        if (_height.Type == LayoutSizeType.Percentage)
        {
            newHeight = windowHeight * _height.Value / 100;
        }
        else
        if (_height.Type == LayoutSizeType.Absolute)
        {
            newHeight = _height.Value;
        }
        newHeight = Math.Clamp(newHeight, 0, Math.Max(windowHeight - option.Theme.CanvasTopMargin, 0));

        if (newWidth != Width ||
            newHeight != Height)
        {
            SetSize(newWidth, newHeight);
            ResetRootCursorPosition();
        }
    }

    private void SetSize(int width, int height)
    {
        Width = width;
        Height = height;
        _cells = new CanvasCell[width * height];
        for (int i = 0; i < width * height; ++i)
        {
            _cells[i] = new CanvasCell();
        }
    }

    public void ClearCells()
    {
        if (_cells is null)
            return;

        for (int i = 0; i < Width * Height; ++i)
        {
            _cells[i].Clear();
        }
    }

    public void SetCell(
        int x,
        int y,
        char character,
        FontColor? foregroundColor = null,
        FontColor? backgroundColor = null,
        FontStyle fontStyle = FontStyle.Default,
        string? escapeSequence = null,
        CanvasCell.Option optionFlags = CanvasCell.Option.None)
    {
        if (_cells is null)
            return;

        int index = Width * y + x;
        if (index < 0 || index >= _cells.Length)
            return;

        var cell = _cells[index];
        cell.SetCharacter(character, foregroundColor, backgroundColor, fontStyle, optionFlags);
        cell.EscapeSequence = escapeSequence;
    }

    public void SetCell(
        int x,
        int y,
        CanvasCell cell)
    {
        if (_cells is null)
            return;

        int index = Width * y + x;
        if (index < 0 || index >= _cells.Length)
            return;

        cell.CopyTo(_cells[index]);
    }

    public void SetCellOption(
        int x,
        int y,
        CanvasCell.Option optionFlags)
    {
        if (_cells is null)
            return;

        int index = Width * y + x;
        if (index < 0 || index >= _cells.Length)
            return;

        var cell = _cells[index];
        cell.OptionFlags = optionFlags;
    }

    public void Write()
    {
        if (_cells is null)
            return;

        var theme = SelectorOptionHolder.GetInstance().Option.Theme;
        Console.CursorVisible = false;
        SetCursorPositionToRoot();

        var builder = new StringBuilder(_cells.Length);
        FontColor? currentBackgroundColor = null;
        FontColor? currentForegroundColor = null;
        FontStyle currentFontStyle = FontStyle.Default;
        bool currentEscapeSequenceLowPriority = false;
        bool forceResetFontNext = false;
        string? escapeSequence = null;

        for (int i = 0; i < theme.CanvasTopMargin; ++i)
        {
            builder.Append('\n');
        }

        builder.Append(_defaultForegroundColor.ForegroundEscapeCode);
        builder.Append(_defaultBackgroundColor.BackgroundEscapeCode);

        for (int y = 0; y < Height; ++y)
        {
            for (int x = 0; x < Width; ++x)
            {
                int index = Width * y + x;
                var cell = _cells[index];
                if (cell.Character == '\0')
                    continue;

                bool shouldSetEscapeSequence = false;
                bool shouldSetForegroundColor = false;
                bool shouldSetBackgroundColor = false;
                bool shouldSetStyle = false;

                bool forceResetFont = cell.OptionFlags.HasFlag(CanvasCell.Option.ForceResetColor);
                forceResetFont = forceResetFont || forceResetFontNext;
                forceResetFontNext = cell.OptionFlags.HasFlag(CanvasCell.Option.ForceResetFontNext);
                bool escapeSequenceLowPriority = cell.OptionFlags.HasFlag(CanvasCell.Option.EscapeSequenceLowPriority);

                if (forceResetFont)
                {
                    escapeSequence = null;
                }
                if (cell.EscapeSequence is not null)
                {
                    escapeSequence = cell.EscapeSequence;
                    shouldSetEscapeSequence = true;
                    forceResetFont = true;
                }
                if (currentEscapeSequenceLowPriority != escapeSequenceLowPriority)
                {
                    currentEscapeSequenceLowPriority = escapeSequenceLowPriority;
                    shouldSetEscapeSequence = true;
                    forceResetFont = true;
                }

                if (forceResetFont ||
                    cell.ForegroundColor != currentForegroundColor)
                {
                    currentForegroundColor = cell.ForegroundColor;
                    shouldSetForegroundColor = true;
                    shouldSetEscapeSequence = true;
                }
                if (forceResetFont ||
                    cell.BackgroundColor != currentBackgroundColor)
                {
                    currentBackgroundColor = cell.BackgroundColor;
                    shouldSetBackgroundColor = true;
                    shouldSetEscapeSequence = true;
                }
                if (forceResetFont ||
                    cell.FontStyle != currentFontStyle)
                {
                    currentFontStyle = cell.FontStyle;
                    shouldSetStyle = true;
                    shouldSetEscapeSequence = true;
                }

                if (escapeSequence is not null && shouldSetEscapeSequence && escapeSequenceLowPriority)
                {
                    builder.Append(escapeSequence);
                }

                if (shouldSetForegroundColor)
                {
                    if (cell.ForegroundColor is null)
                    {
                        builder.Append(_defaultForegroundColor.ForegroundEscapeCode);
                    }
                    else
                    {
                        builder.Append(cell.ForegroundColor.ForegroundEscapeCode);
                    }
                }

                if (shouldSetBackgroundColor)
                {
                    if (cell.BackgroundColor is null)
                    {
                        builder.Append(_defaultBackgroundColor.BackgroundEscapeCode);
                    }
                    else
                    {
                        builder.Append(cell.BackgroundColor.BackgroundEscapeCode);
                    }
                }

                if (shouldSetStyle)
                {
                    builder.Append(FontStyleTable.GetEscapeCode(cell.FontStyle));
                }

                if (escapeSequence is not null && shouldSetEscapeSequence && !escapeSequenceLowPriority)
                {
                    builder.Append(escapeSequence);
                }

                builder.Append(cell.Character);
            }
            builder.Append('\n');
        }
        builder.Append("\x1b[0m");
        Console.Write(builder.ToString());
        if (_streamWriter is not null)
        {
            _streamWriter.Flush();
        }
        ResetCursorPosition();

        Console.CursorVisible = true;
    }

    public void SetCursorOffset(int x, int y)
    {
        _cursorOffsetX = x;
        _cursorOffsetY = y;
    }

    private void ResetRootCursorPosition()
    {
        _rootCursorY = null;
    }

    private void SetCursorPositionToRoot()
    {
        int cursorX = 0;
        int cursorY = _rootCursorY ?? (Console.CursorTop - _cursorOffsetYFromRoot);
        cursorX = Math.Clamp(cursorX, 0, Console.WindowWidth - 1);
        cursorY = Math.Clamp(cursorY, 0, Console.WindowHeight - 1);

        Console.SetCursorPosition(cursorX, cursorY);
    }

    private void ResetCursorPosition()
    {
        var theme = SelectorOptionHolder.GetInstance().Option.Theme;
        if (_rootCursorY is null)
        {
            _rootCursorY = Console.CursorTop - Height - theme.CanvasTopMargin;
        }

        _cursorOffsetYFromRoot = theme.CanvasTopMargin + _cursorOffsetY;

        int cursorX = _cursorOffsetX;
        int cursorY = _rootCursorY.Value + _cursorOffsetYFromRoot;
        cursorX = Math.Clamp(cursorX, 0, Console.WindowWidth - 1);
        cursorY = Math.Clamp(cursorY, 0, Console.WindowHeight - 1);

        Console.SetCursorPosition(cursorX, cursorY);
    }
}
