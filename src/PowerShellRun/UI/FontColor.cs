using System;
namespace PowerShellRun;

public class FontColor : DeepCloneable
{
    internal string? ForegroundEscapeCode = null;
    internal string? BackgroundEscapeCode = null;
    private int? _paletteId = null;
    private int? _rgb = null;

    private FontColor()
    {
    }
    private FontColor(int paletteId, string foregroundEscapeCode, string backgroundEscapeCode)
    {
        _paletteId = paletteId;
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
        return _paletteId == other._paletteId && _rgb == other._rgb;
    }
    
    public override int GetHashCode()
    {
        return (_paletteId, _rgb).GetHashCode();
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

    public static readonly FontColor Black = new FontColor(0, "\x1b[30m", "\x1b[40m");
    public static readonly FontColor Red = new FontColor(1, "\x1b[31m", "\x1b[41m");
    public static readonly FontColor Green = new FontColor(2, "\x1b[32m", "\x1b[42m");
    public static readonly FontColor Yellow = new FontColor(3, "\x1b[33m", "\x1b[43m");
    public static readonly FontColor Blue = new FontColor(4, "\x1b[34m", "\x1b[44m");
    public static readonly FontColor Magenta = new FontColor(5, "\x1b[35m", "\x1b[45m");
    public static readonly FontColor Cyan = new FontColor(6, "\x1b[36m", "\x1b[46m");
    public static readonly FontColor White = new FontColor(7, "\x1b[37m", "\x1b[47m");
    internal static readonly FontColor Default = new FontColor(9, "\x1b[39m", "\x1b[49m");
    public static readonly FontColor BrightBlack = new FontColor(10, "\x1b[90m", "\x1b[100m");
    public static readonly FontColor BrightRed = new FontColor(11, "\x1b[91m", "\x1b[101m");
    public static readonly FontColor BrightGreen = new FontColor(12, "\x1b[92m", "\x1b[102m");
    public static readonly FontColor BrightYellow = new FontColor(13, "\x1b[93m", "\x1b[103m");
    public static readonly FontColor BrightBlue = new FontColor(14, "\x1b[94m", "\x1b[104m");
    public static readonly FontColor BrightMagenta = new FontColor(15, "\x1b[95m", "\x1b[105m");
    public static readonly FontColor BrightCyan = new FontColor(16, "\x1b[96m", "\x1b[106m");
    public static readonly FontColor BrightWhite = new FontColor(17, "\x1b[97m", "\x1b[107m");
}
