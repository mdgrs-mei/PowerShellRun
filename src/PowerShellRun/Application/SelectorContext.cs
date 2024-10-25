namespace PowerShellRun;
using System.Text;

public class SelectorContext
{
    public string Query { get; set; } = "";
    public int CursorIndex { get; set; } = 0;
    public int[]? MarkedEntryIndexes { get; set; } = null;

    public override string ToString()
    {
        var builder = new StringBuilder();
        builder.Append($"{Query}:{CursorIndex}");
        if (MarkedEntryIndexes is not null)
        {
            builder.Append(":{");
            for (var i = 0; i < MarkedEntryIndexes.Length; ++i)
            {
                if (i == MarkedEntryIndexes.Length - 1)
                {
                    builder.Append($"{i}");
                }
                else
                {
                    builder.Append($"{i}, ");
                }
            }
            builder.Append("}");
        }
        return builder.ToString();
    }
}
