namespace PowerShellRun;

internal class Singleton<T> where T : class, new()
{
    private static T? _instance = null;
    public static T GetInstance()
    {
        CreateInstance();
        return _instance!;
    }

    public static void CreateInstance()
    {
        if (_instance is null)
        {
            _instance = new T();
        }
    }

    public static void DestroyInstance()
    {
        _instance = null;
    }
}
