namespace PowerShellRun;

using System.Collections.Generic;

public static class Selector
{
    public static SelectorResult Open(
        IReadOnlyList<SelectorEntry> entries,
        SelectorMode mode = SelectorMode.SingleSelection,
        SelectorOption? option = null,
        SelectorContext? context = null)
    {
        if (option is not null)
        {
            SelectorOptionHolder.GetInstance().Option = option;
        }
        option = SelectorOptionHolder.GetInstance().Option;
        var theme = option.Theme;

        var bgRunspace = BackgroundRunspace.GetInstance();
        if (!bgRunspace.IsInit)
        {
            bgRunspace.Init();
        }
        bgRunspace.Start();

        var keyInput = KeyInput.GetInstance();
        keyInput.Init();

        var canvas = Canvas.GetInstance();
        canvas.Init(theme.CanvasHeightPercentage);

        var searchBar = new SearchBar(
            promptString: option.Prompt,
            processQuitAcceptKeys: false);

        var resultWindow = new ResultWindow(mode, searchBar.RootLayout);
        var pacemaker = new Pacemaker(16);

        resultWindow.SetEntries(entries);

        var canvasLayout = resultWindow.RootLayout;
        canvasLayout.BorderFlags = theme.CanvasBorderFlags;
        canvasLayout.BorderSymbol = theme.CanvasBorderSymbol;
        canvasLayout.BorderForegroundColor = theme.CanvasBorderForegroundColor;
        canvasLayout.BorderBackgroundColor = theme.CanvasBorderBackgroundColor;

        if (context is not null)
        {
            searchBar.SetQuery(context.Query);
            resultWindow.SetContext(context);
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
            {
                // Contents dependent components have to be updated here.
                resultWindow.UpdateLayout();
            }
            canvasLayout.UpdateLayout(0, 0, canvas.Width, canvas.Height);

            searchBar.Update();
            if (searchBar.IsQuit)
            {
                lastKeyCombination = searchBar.LastKeyCombination;
                break;
            }

            if (searchBar.IsQueryUpdated)
            {
                resultWindow.SetQuery(searchBar.Query);
            }
            resultWindow.Update();

            if (resultWindow.IsQuit || resultWindow.IsActionAccepted)
            {
                lastKeyCombination = resultWindow.LastKeyCombination;
                break;
            }

            var cursorPosInCanvas = searchBar.GetCursorPositionInCanvas();
            canvas.SetCursorOffset(cursorPosInCanvas.X, cursorPosInCanvas.Y);
            if (searchBar.IsQueryUpdated || resultWindow.IsUpdated)
            {
                canvas.ClearCells();
                canvasLayout.Render();
            }
            if (searchBar.IsQueryUpdated || searchBar.IsCursorUpdated || resultWindow.IsUpdated)
            {
                canvas.Write();
            }
        }

        var result = resultWindow.GetResult();

        var selectorResult = new SelectorResult();
        selectorResult.FocusedEntry = result.FocusedEntry;
        selectorResult.MarkedEntries = result.MarkedEntries;
        selectorResult.KeyCombination = lastKeyCombination;

        selectorResult.Context.Query = searchBar.Query;
        selectorResult.Context.CursorIndex = result.CursorIndex;
        selectorResult.Context.MarkedEntryIndexes = result.MarkedEntryIndexes;

        canvas.Term();
        keyInput.Term();
        bgRunspace.Finish();

        KeyInput.DestroyInstance();
        Canvas.DestroyInstance();
        SelectorOptionHolder.DestroyInstance();

        return selectorResult;
    }
}
