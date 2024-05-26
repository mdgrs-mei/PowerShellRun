using System;
namespace PowerShellRun;

[Flags]
public enum FontStyle
{
    Default = 0,
    Bold = 1 << 0,
    Underline = 1 << 1,

    // Swaps foreground and background colors.
    Negative = 1 << 2,
}

internal static class FontStyleTable
{
    private static string[] _escapeCodes;

    static FontStyleTable()
    {
        int count = 1 << (Enum.GetValues(typeof(FontStyle)).Length - 1);
        _escapeCodes = new string[count];

        _escapeCodes[(int)FontStyle.Default] = "\x1b[22m\x1b[24m\x1b[27m";
        _escapeCodes[(int)FontStyle.Bold] = "\x1b[1m";
        _escapeCodes[(int)FontStyle.Underline] = "\x1b[4m";
        _escapeCodes[(int)(FontStyle.Underline | FontStyle.Bold)] = "\x1b[4m\x1b[1m";
        _escapeCodes[(int)FontStyle.Negative] = "\x1b[7m";
        _escapeCodes[(int)(FontStyle.Negative | FontStyle.Bold)] = "\x1b[7m\x1b[1m";
        _escapeCodes[(int)(FontStyle.Negative | FontStyle.Underline)] = "\x1b[7m\x1b[4m";
        _escapeCodes[(int)(FontStyle.Negative | FontStyle.Underline | FontStyle.Bold)] = "\x1b[7m\x1b[4m\x1b[1m";
    }

    public static string GetEscapeCode(FontStyle style)
    {
        return _escapeCodes[(int)style];
    }
}
