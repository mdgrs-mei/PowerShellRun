namespace PowerShellRun;
using System.Runtime.InteropServices;

internal sealed class Platform : Singleton<Platform>
{
    public bool IsWindows { get; set; }
    public bool IsMacOs { get; set; }
    public bool IsLinux { get; set; }

    public Platform()
    {
        IsWindows = RuntimeInformation.IsOSPlatform(OSPlatform.Windows);
        IsMacOs = RuntimeInformation.IsOSPlatform(OSPlatform.OSX);
        IsLinux = RuntimeInformation.IsOSPlatform(OSPlatform.Linux);
    }
}
