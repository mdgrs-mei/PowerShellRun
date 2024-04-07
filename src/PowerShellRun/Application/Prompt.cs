namespace PowerShellRun;

public static class Prompt
{
    public static PromptResult Open(
        SelectorOption? option = null,
        PromptContext? context = null)
    {
        if (option is not null)
        {
            SelectorOptionHolder.GetInstance().Option = option;
        }
        option = SelectorOptionHolder.GetInstance().Option;
        var theme = option.Theme;

        var keyInput = KeyInput.GetInstance();
        keyInput.Init();

        var canvas = Canvas.GetInstance();
        canvas.Init(theme.CanvasHeightPercentage);

        var searchBar = new SearchBar(
            promptString: option.Prompt,
            processQuitAcceptKeys: true);

        var pacemaker = new Pacemaker(16);
        var canvasLayout = new StackLayout();
        canvasLayout.AddChild(searchBar.RootLayout);

        if (context is not null)
        {
            searchBar.SetQuery(context.Input);
        }
        KeyCombination? lastKeyCombination = null;

        while (true)
        {
            pacemaker.Tick();
            if (option.DebugPerfEnable)
            {
                searchBar.DebugPerfString = pacemaker.GetDebugPerfString();
            }

            keyInput.Update();

            canvas.UpdateSize();
            canvasLayout.UpdateLayout(0, 0, canvas.Width, canvas.Height);

            searchBar.Update();
            if (searchBar.IsQuit || searchBar.IsAccepted)
            {
                lastKeyCombination = searchBar.LastKeyCombination;
                break;
            }

            var cursorPosInCanvas = searchBar.GetCursorPositionInCanvas();
            canvas.SetCursorOffset(cursorPosInCanvas.X, cursorPosInCanvas.Y);
            if (searchBar.IsQueryUpdated)
            {
                canvas.ClearCells();
                canvasLayout.Render();
            }
            if (searchBar.IsQueryUpdated || searchBar.IsCursorUpdated)
            {
                canvas.Write();
            }
        }

        var promptResult = new PromptResult();
        promptResult.Input = searchBar.IsAccepted ? searchBar.Query : null;
        promptResult.KeyCombination = lastKeyCombination;
        promptResult.Context.Input = searchBar.Query;

        canvas.Term();
        keyInput.Term();

        KeyInput.DestroyInstance();
        Canvas.DestroyInstance();
        SelectorOptionHolder.DestroyInstance();

        return promptResult;
    }
}
