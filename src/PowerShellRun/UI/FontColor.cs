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
    private FontColor(PresetId presetId)
    {
        SetPresetId(presetId);
    }
    public FontColor(string str)
    {
        try
        {
            var presetId = Enum.Parse<PresetId>(str, true);
            SetPresetId(presetId);
        }
        catch
        {
            bool success = SetHex(str);
            if (!success)
            {
                throw new ArgumentException("Invalid string format. The string must be a preset name or a hex string.");
            }
        }
    }

    private void SetPresetId(PresetId presetId)
    {
        _presetId = presetId;
        ForegroundEscapeCode = _presetEscapeSequenceTable[(int)presetId].ForegroundEscapeCode;
        BackgroundEscapeCode = _presetEscapeSequenceTable[(int)presetId].BackgroundEscapeCode;
    }

    private bool SetHex(string hexString)
    {
        int r = 0;
        int g = 0;
        int b = 0;

        if (!string.IsNullOrEmpty(hexString) && hexString.Length >= 6)
        {
            try
            {
                r = Convert.ToInt32(hexString.Substring(1, 2), 16);
                g = Convert.ToInt32(hexString.Substring(3, 2), 16);
                b = Convert.ToInt32(hexString.Substring(5, 2), 16);
            }
            catch
            {
                return false;
            }
        }
        else
        {
            return false;
        }

        _rgb = r << 24 | g << 16 | b << 8;
        ForegroundEscapeCode = $"\x1b[38;2;{r};{g};{b}m";
        BackgroundEscapeCode = $"\x1b[48;2;{r};{g};{b}m";
        return true;
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
        var fontColor = new FontColor();
        bool success = fontColor.SetHex(hexString);
        if (!success)
        {
            throw new ArgumentException("Invalid hex string format. The format must be like '#61FFCA'.", nameof(hexString));
        }
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

    private static readonly (string ForegroundEscapeCode, string BackgroundEscapeCode)[] _presetEscapeSequenceTable = new[]
    {
        ("", ""), // None
        ("\x1b[30m", "\x1b[40m"), // Black
        ("\x1b[31m", "\x1b[41m"), // Red
        ("\x1b[32m", "\x1b[42m"), // Green
        ("\x1b[33m", "\x1b[43m"), // Yellow
        ("\x1b[34m", "\x1b[44m"), // Blue
        ("\x1b[35m", "\x1b[45m"), // Magenta
        ("\x1b[36m", "\x1b[46m"), // Cyan
        ("\x1b[37m", "\x1b[47m"), // White
        ("\x1b[39m", "\x1b[49m"), // Default
        ("\x1b[90m", "\x1b[100m"), // BrightBlack
        ("\x1b[91m", "\x1b[101m"), // BrightRed
        ("\x1b[92m", "\x1b[102m"), // BrightGreen
        ("\x1b[93m", "\x1b[103m"), // BrightYellow
        ("\x1b[94m", "\x1b[104m"), // BrightBlue
        ("\x1b[95m", "\x1b[105m"), // BrightMagenta
        ("\x1b[96m", "\x1b[106m"), // BrightCyan
        ("\x1b[97m", "\x1b[107m"), // BrightWhite
    };

    public static readonly FontColor Black = new FontColor(PresetId.Black);
    public static readonly FontColor Red = new FontColor(PresetId.Red);
    public static readonly FontColor Green = new FontColor(PresetId.Green);
    public static readonly FontColor Yellow = new FontColor(PresetId.Yellow);
    public static readonly FontColor Blue = new FontColor(PresetId.Blue);
    public static readonly FontColor Magenta = new FontColor(PresetId.Magenta);
    public static readonly FontColor Cyan = new FontColor(PresetId.Cyan);
    public static readonly FontColor White = new FontColor(PresetId.White);
    internal static readonly FontColor Default = new FontColor(PresetId.Default);
    public static readonly FontColor BrightBlack = new FontColor(PresetId.BrightBlack);
    public static readonly FontColor BrightRed = new FontColor(PresetId.BrightRed);
    public static readonly FontColor BrightGreen = new FontColor(PresetId.BrightGreen);
    public static readonly FontColor BrightYellow = new FontColor(PresetId.BrightYellow);
    public static readonly FontColor BrightBlue = new FontColor(PresetId.BrightBlue);
    public static readonly FontColor BrightMagenta = new FontColor(PresetId.BrightMagenta);
    public static readonly FontColor BrightCyan = new FontColor(PresetId.BrightCyan);
    public static readonly FontColor BrightWhite = new FontColor(PresetId.BrightWhite);
}
