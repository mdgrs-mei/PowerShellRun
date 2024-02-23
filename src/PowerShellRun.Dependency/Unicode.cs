namespace PowerShellRun.Dependency;
using Wcwidth;

public class Unicode
{
    public static int GetDisplayWidth(char character)
    {
        return Wcwidth.UnicodeCalculator.GetWidth(character);
    }

    public static int GetDisplayWidth(string str)
    {
        int length = 0;
        foreach (var character in str)
        {
            length += Wcwidth.UnicodeCalculator.GetWidth(character);
        }
        return length;
    }
}
