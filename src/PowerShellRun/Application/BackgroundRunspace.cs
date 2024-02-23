using System.Collections.Generic;
using System.Threading;
using System.Management.Automation;
using System.Management.Automation.Runspaces;

namespace PowerShellRun;

internal sealed class BackgroundRunspace : Singleton<BackgroundRunspace>
{
    public class Task
    {
        public ScriptBlock ScriptBlock {get;}
        public object? ArgumentList {get;} = null;

        private InternalEntry _outputEntry;

        public Task(ScriptBlock scriptBlock, object? argumentList, InternalEntry outputEntry)
        {
            ScriptBlock = scriptBlock;
            ArgumentList = argumentList;
            _outputEntry = outputEntry;
        }

        public void SetResult(System.Collections.ObjectModel.Collection<PSObject> result)
        {
            _outputEntry.CompletePreviewTask(result);
        }
    }

    public bool IsInit {get; private set;} = false;
    private Thread? _thread = null;

    private Stack<Task> _tasks = new Stack<Task>();
    private Runspace? _runspace = null;
    private PowerShell? _powershell = null;
    private int _createRunspaceRequest = 0;
    private int _destroyRunspaceRequest = 0;

    public void Init()
    {
        if (IsInit)
            return;

        // The thread stays alive once it's initialized.
        _thread = new Thread(new ThreadStart(ThreadEntry));
        _thread.IsBackground = true;
        _thread.Start();

        IsInit = true;
    }

    public void Start()
    {
        Interlocked.Exchange(ref _createRunspaceRequest, 1);

        lock (_tasks)
        {
            _tasks.Clear();
            Monitor.Pulse(_tasks);
        }
    }

    public void Finish()
    {
        Interlocked.Exchange(ref _destroyRunspaceRequest, 1);
        lock (_tasks)
        {
            _tasks.Clear();
            Monitor.Pulse(_tasks);
        }
    }

    public void AddTask(Task task)
    {
        lock (_tasks)
        {
            _tasks.Push(task);
            Monitor.Pulse(_tasks);
        }
    }

    private void ThreadEntry()
    {
        while (true)
        {
            ProcessRequests();

            Task? task = null;
            lock (_tasks)
            {
                while (_tasks.Count == 0 || _powershell is null)
                {
                    Monitor.Wait(_tasks);
                    ProcessRequests();
                }

                task = _tasks.Pop();
            }

            ProcessTask(task);
        }
    }

    private void ProcessRequests()
    {
        if (Interlocked.Exchange(ref _destroyRunspaceRequest, 0) == 1)
        {
            if (_powershell is not null)
            {
                _powershell.Dispose();
                _powershell = null;
            }

            if (_runspace is not null)
            {
                _runspace.Dispose();
                _runspace = null;
            }
        }

        if (Interlocked.Exchange(ref _createRunspaceRequest, 0) == 1)
        {
            if (_powershell is null) 
            {
                _runspace = RunspaceFactory.CreateRunspace();
                _runspace.Open();

                _powershell = PowerShell.Create();
                _powershell.Runspace = _runspace;
            }
        }
    }

    private void ProcessTask(Task task)
    {
        if (_powershell is null)
            return;
            
        _powershell.Commands.Clear();
        _powershell.AddScript(task.ScriptBlock.ToString());
        if (task.ArgumentList is not null)
        {
            _powershell.AddArgument(task.ArgumentList);
        }
        System.Collections.ObjectModel.Collection<PSObject> result = _powershell.Invoke();
        task.SetResult(result);
    }
}
