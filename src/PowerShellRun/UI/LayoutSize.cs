using System;

namespace PowerShellRun;

internal enum LayoutSizeType
{
    Absolute,
    Percentage,
    Stretch,
    Content,
}

internal class LayoutSize
{
    public LayoutSizeType Type { get; private set; }
    public int Value { get; private set; }

    public LayoutSize(LayoutSizeType type = LayoutSizeType.Stretch, int value = 0)
    {
        Set(type, value);
    }

    public void Set(LayoutSizeType type, int value = 0)
    {
        if (type == LayoutSizeType.Percentage)
        {
            value = Math.Clamp(value, 0, 100);
        }
        Type = type;
        Value = value;
    }
}
