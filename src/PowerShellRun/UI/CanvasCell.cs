using System;
using System.Drawing;
using System.Net.Http;
namespace PowerShellRun;

internal class CanvasCell
{
    [Flags]
    public enum Option
    {
        None = 0,
        ForceResetFont = 1 << 0,
        ForceResetFontNext = 1 << 1,
        EscapeSequenceLowPriority = 1 << 2,
        SecondCellOfWideCharacter = 1 << 3,
    }

    // base characters
    public char Character { get; set; }
    // surrogate pairs or combining character sequences
    public string? TextElement { get; set; }
    public string? EscapeSequence { get; set; }
    public FontColor? ForegroundColor { get; set; }
    public FontColor? BackgroundColor { get; set; }
    public FontStyle FontStyle { get; set; }
    public Option OptionFlags { get; set; }

    public CanvasCell()
    {
        Clear();
    }

    public void Clear()
    {
        Character = ' ';
        TextElement = null;
        EscapeSequence = null;
        ForegroundColor = null;
        BackgroundColor = null;
        FontStyle = FontStyle.Default;
        OptionFlags = Option.None;
    }

    public void CopyTo(CanvasCell cell)
    {
        cell.Character = Character;
        cell.TextElement = TextElement;
        cell.EscapeSequence = EscapeSequence;
        cell.ForegroundColor = ForegroundColor;
        cell.BackgroundColor = BackgroundColor;
        cell.FontStyle = FontStyle;
        cell.OptionFlags = OptionFlags;
    }

    public void SetCharacter(
        char character,
        FontColor? foregroundColor,
        FontColor? backgroundColor,
        FontStyle fontStyle,
        Option optionFlags)
    {
        Character = character;
        TextElement = null;
        ForegroundColor = foregroundColor;
        BackgroundColor = backgroundColor;
        FontStyle = fontStyle;
        OptionFlags = optionFlags;
    }

    public void SetTextElement(
        string textElement,
        FontColor? foregroundColor,
        FontColor? backgroundColor,
        FontStyle fontStyle,
        Option optionFlags)
    {
        Character = ' ';
        TextElement = textElement;
        ForegroundColor = foregroundColor;
        BackgroundColor = backgroundColor;
        FontStyle = fontStyle;
        OptionFlags = optionFlags;
    }
}
