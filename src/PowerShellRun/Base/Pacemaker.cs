namespace PowerShellRun;
using System.Diagnostics;
using System.Threading;

internal class Pacemaker
{
    private Stopwatch _stopwatch = new Stopwatch();
    private int _intervalMillisecond = 0;
    private int _elapsedMillisecond = 0;

    public Pacemaker(int intervalMillisecond)
    {
        _intervalMillisecond = intervalMillisecond;
    }

    public void Tick()
    {
        if (!_stopwatch.IsRunning)
        {
            _stopwatch.Start();
            return;
        }

        _stopwatch.Stop();
        _elapsedMillisecond = (int)_stopwatch.ElapsedMilliseconds;
        int waitMillisecond = _intervalMillisecond - _elapsedMillisecond;
        if (waitMillisecond > 0)
        {
            Thread.Sleep(waitMillisecond);
        }
        _stopwatch.Restart();
    }

    public string GetDebugPerfString()
    {
        return new string($" {_elapsedMillisecond} ms");
    }
}
