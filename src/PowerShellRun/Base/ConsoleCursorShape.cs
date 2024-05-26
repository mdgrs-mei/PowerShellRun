using System;
namespace PowerShellRun;

public enum ConsoleCursorShape
{
    Default,
    BlinkingBlock,
    SteadyBlock,
    BlinkingUnderline,
    SteadyUnderline,
    BlinkingBar,
    SteadyBar,
}

internal static class ConsoleCursorShapeTable
{
    private static string[] _escapeCodes;

    static ConsoleCursorShapeTable()
    {
        int count = Enum.GetValues(typeof(ConsoleCursorShape)).Length;
        _escapeCodes = new string[count];

        _escapeCodes[(int)ConsoleCursorShape.Default] = "\x1b[0 q";
        _escapeCodes[(int)ConsoleCursorShape.BlinkingBlock] = "\x1b[1 q";
        _escapeCodes[(int)ConsoleCursorShape.SteadyBlock] = "\x1b[2 q";
        _escapeCodes[(int)ConsoleCursorShape.BlinkingUnderline] = "\x1b[3 q";
        _escapeCodes[(int)ConsoleCursorShape.SteadyUnderline] = "\x1b[4 q";
        _escapeCodes[(int)ConsoleCursorShape.BlinkingBar] = "\x1b[5 q";
        _escapeCodes[(int)ConsoleCursorShape.SteadyBar] = "\x1b[6 q";
    }

    public static string GetEscapeCode(ConsoleCursorShape style)
    {
        return _escapeCodes[(int)style];
    }
}
