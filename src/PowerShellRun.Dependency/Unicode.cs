namespace PowerShellRun.Dependency;
using Wcwidth;

public class Unicode
{
    public static int GetDisplayWidth(char character)
    {
        return Wcwidth.UnicodeCalculator.GetWidth(character);
    }

    public static int GetDisplayWidth(int codePoint)
    {
        return Wcwidth.UnicodeCalculator.GetWidth(codePoint);
    }
}
