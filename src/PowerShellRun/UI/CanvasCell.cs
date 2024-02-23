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
        ForceResetColor = 1 << 0,
    }

    public char Character {get; set;}
    public string? HeadEscapeSequence {get; set;}
    public string? TailEscapeSequence {get; set;}
    public FontColor? ForegroundColor {get; set;}
    public FontColor? BackgroundColor {get; set;}
    public FontStyle FontStyle {get; set;}
    public Option OptionFlags {get; set;}

    public CanvasCell()
    {
        Clear();
    }

    public void Clear()
    {
        Character = ' ';
        HeadEscapeSequence = null;
        TailEscapeSequence = null;
        ForegroundColor = null;
        BackgroundColor = null;
        FontStyle = FontStyle.Default;
        OptionFlags = Option.None;
    }

    public void CopyTo(CanvasCell cell)
    {
        cell.Character = Character;
        cell.HeadEscapeSequence = HeadEscapeSequence;
        cell.TailEscapeSequence = TailEscapeSequence;
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
        ForegroundColor = foregroundColor;
        BackgroundColor = backgroundColor;
        FontStyle = fontStyle;
        OptionFlags = optionFlags;
    }
}
