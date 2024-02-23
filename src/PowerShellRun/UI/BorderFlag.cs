namespace PowerShellRun;
using System;

[Flags]
public enum BorderFlag
{
    None = 0,
    Left = 1 << 0,
    Right = 1 << 1,
    Top = 1 << 2,
    Bottom = 1 << 3,
    All = Left | Right | Top | Bottom,
}
