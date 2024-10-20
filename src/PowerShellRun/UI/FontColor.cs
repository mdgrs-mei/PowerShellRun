using System;
namespace PowerShellRun;

public class FontColor : DeepCloneable
{
    internal string? ForegroundEscapeCode = null;
    internal string? BackgroundEscapeCode = null;
    private PresetId? _presetId = null;
    private int? _rgb = null;

    private FontColor()
    {
    }
    private FontColor(PresetId presetId, string foregroundEscapeCode, string backgroundEscapeCode)
    {
        _presetId = presetId;
        ForegroundEscapeCode = foregroundEscapeCode;
        BackgroundEscapeCode = backgroundEscapeCode;
    }

    protected override object EmptyNew()
    {
        return new FontColor();
    }

    public override bool Equals(object? obj)
    {
        if (obj == null)
        {
            return false;
        }

        if (GetType() != obj.GetType())
        {
            return false;
        }

        FontColor other = (FontColor)obj;
        return _presetId == other._presetId && _rgb == other._rgb;
    }

    public override int GetHashCode()
    {
        return (_presetId, _rgb).GetHashCode();
    }

    public override string ToString()
    {
        if (_presetId is PresetId presetId)
        {
            return presetId.ToString();
        }
        else
        if (_rgb is int rgb)
        {
            int r = (rgb >> 24) & 0xff;
            int g = (rgb >> 16) & 0xff;
            int b = (rgb >> 8) & 0xff;
            return $"#{r:X2}{g:X2}{b:X2} (R={r}, G={g}, B={b})";
        }
        return "";
    }

    public static FontColor FromHex(string hexString)
    {
        int r = 0;
        int g = 0;
        int b = 0;

        if (!string.IsNullOrEmpty(hexString) && hexString.Length >= 6)
        {
            r = Convert.ToInt32(hexString.Substring(1, 2), 16);
            g = Convert.ToInt32(hexString.Substring(3, 2), 16);
            b = Convert.ToInt32(hexString.Substring(5, 2), 16);
        }

        var fontColor = new FontColor();
        fontColor._rgb = r << 24 | g << 16 | b << 8;
        fontColor.ForegroundEscapeCode = $"\x1b[38;2;{r};{g};{b}m";
        fontColor.BackgroundEscapeCode = $"\x1b[48;2;{r};{g};{b}m";

        return fontColor;
    }

    private enum PresetId
    {
        None,
        Black,
        Red,
        Green,
        Yellow,
        Blue,
        Magenta,
        Cyan,
        White,
        Default,
        BrightBlack,
        BrightRed,
        BrightGreen,
        BrightYellow,
        BrightBlue,
        BrightMagenta,
        BrightCyan,
        BrightWhite,
    }

    public static readonly FontColor Black = new FontColor(PresetId.Black, "\x1b[30m", "\x1b[40m");
    public static readonly FontColor Red = new FontColor(PresetId.Red, "\x1b[31m", "\x1b[41m");
    public static readonly FontColor Green = new FontColor(PresetId.Green, "\x1b[32m", "\x1b[42m");
    public static readonly FontColor Yellow = new FontColor(PresetId.Yellow, "\x1b[33m", "\x1b[43m");
    public static readonly FontColor Blue = new FontColor(PresetId.Blue, "\x1b[34m", "\x1b[44m");
    public static readonly FontColor Magenta = new FontColor(PresetId.Magenta, "\x1b[35m", "\x1b[45m");
    public static readonly FontColor Cyan = new FontColor(PresetId.Cyan, "\x1b[36m", "\x1b[46m");
    public static readonly FontColor White = new FontColor(PresetId.White, "\x1b[37m", "\x1b[47m");
    internal static readonly FontColor Default = new FontColor(PresetId.Default, "\x1b[39m", "\x1b[49m");
    public static readonly FontColor BrightBlack = new FontColor(PresetId.BrightBlack, "\x1b[90m", "\x1b[100m");
    public static readonly FontColor BrightRed = new FontColor(PresetId.BrightRed, "\x1b[91m", "\x1b[101m");
    public static readonly FontColor BrightGreen = new FontColor(PresetId.BrightGreen, "\x1b[92m", "\x1b[102m");
    public static readonly FontColor BrightYellow = new FontColor(PresetId.BrightYellow, "\x1b[93m", "\x1b[103m");
    public static readonly FontColor BrightBlue = new FontColor(PresetId.BrightBlue, "\x1b[94m", "\x1b[104m");
    public static readonly FontColor BrightMagenta = new FontColor(PresetId.BrightMagenta, "\x1b[95m", "\x1b[105m");
    public static readonly FontColor BrightCyan = new FontColor(PresetId.BrightCyan, "\x1b[96m", "\x1b[106m");
    public static readonly FontColor BrightWhite = new FontColor(PresetId.BrightWhite, "\x1b[97m", "\x1b[107m");
}
