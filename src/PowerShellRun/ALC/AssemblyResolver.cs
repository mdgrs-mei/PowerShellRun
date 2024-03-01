namespace PowerShellRun;
using System.IO;
using System.Reflection;
using System.Runtime.Loader;
using System.Management.Automation;

public class AssemblyResolver : IModuleAssemblyInitializer, IModuleAssemblyCleanup
{
    private static readonly string _dependencyDirPath;
    private static readonly CustomAssemblyLoadContext _alc;

    static AssemblyResolver()
    {
        string assemblyDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? "";

        _dependencyDirPath = Path.GetFullPath(
            Path.Combine(
                assemblyDir,
                "Dependencies"));

        _alc = new CustomAssemblyLoadContext(_dependencyDirPath);
    }

    public void OnImport()
    {
        AssemblyLoadContext.Default.Resolving += Resolve;
    }

    public void OnRemove(PSModuleInfo psModuleInfo)
    {
        AssemblyLoadContext.Default.Resolving -= Resolve;
    }

    private static Assembly? Resolve(AssemblyLoadContext defaultAlc, AssemblyName assemblyToResolve)
    {
        if (assemblyToResolve.Name is null)
        {
            return null;
        }
        if (!assemblyToResolve.Name.Equals("PowerShellRun.Dependency"))
        {
            return null;
        }
        return _alc.LoadFromAssemblyName(assemblyToResolve);
    }
}
