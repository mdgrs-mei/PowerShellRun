using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace PowerShellRun;

internal class InternalEntry
{
    public SelectorEntry SelectorEntry { get; set; }
    public string Name { get; set; } = "";
    public string SearchName { get; private set; } = "";
    public string SearchNameLowerCase { get; private set; } = "";
    public string Description { get; set; } = "";
    public string SearchDescription { get; set; } = "";
    public string SearchDescriptionLowerCase { get; private set; } = "";

    public bool[] NameMatches { get; set; }
    public bool[] DescriptionMatches { get; set; }
    public int Score { get; set; } = 0;

    public bool IsMarked { get; set; } = false;
    public bool IsUpdated { get; private set; } = false;

    public BackgroundRunspace.Task? PreviewTask { get; set; } = null;
    private int _previewTaskExecutionCount = 0;
    private string[]? _previewLines = null;
    private readonly object? _previewLinesLock = null;
    private bool _previewLinesUpdatedByTask = false;

    public InternalEntry(SelectorEntry selectorEntry)
    {
        SelectorEntry = selectorEntry;
        Name = FormatWord(selectorEntry.Name);
        SearchName = GenerateSearchWord(Name, SelectorEntry.NameSearchablePattern);
        NameMatches = new bool[Name.Length];
        if (selectorEntry.Description is not null)
        {
            Description = FormatWord(selectorEntry.Description);
            SearchDescription = GenerateSearchWord(Description, SelectorEntry.DescriptionSearchablePattern);
            DescriptionMatches = new bool[Description.Length];
        }
        else
        {
            DescriptionMatches = new bool[0];
        }
        Array.Fill(NameMatches, false);
        Array.Fill(DescriptionMatches, false);

        SearchNameLowerCase = SearchName.ToLower();
        SearchDescriptionLowerCase = SearchDescription.ToLower();

        if (selectorEntry.Preview is not null)
        {
            _previewLines = FormatLines(selectorEntry.Preview);
        }

        if (selectorEntry.PreviewAsyncScript is not null)
        {
            _previewLinesLock = new object();
        }
    }

    public ActionKey[] GetActionKeys()
    {
        var keyBinding = SelectorOptionHolder.GetInstance().Option.KeyBinding;
        return SelectorEntry.ActionKeys ?? keyBinding.DefaultActionKeys;
    }

    public ActionKey[] GetActionKeysMultiSelection()
    {
        var keyBinding = SelectorOptionHolder.GetInstance().Option.KeyBinding;
        return SelectorEntry.ActionKeysMultiSelection ?? keyBinding.DefaultActionKeysMultiSelection;
    }

    public void CompletePreviewTask(System.Collections.ObjectModel.Collection<PSObject> taskResult)
    {
        if (_previewLinesLock is null)
            return;

        lock (_previewLinesLock)
        {
            if (taskResult.Count > 0 && taskResult[0] is not null)
            {
                _previewLines = FormatLines(taskResult);
            }
            PreviewTask = null;
            ++_previewTaskExecutionCount;
            _previewLinesUpdatedByTask = true;
        }
    }

    public string[]? GetPreviewLines()
    {
        if (_previewLinesLock is null)
            return _previewLines;

        lock (_previewLinesLock)
        {
            return _previewLines;
        }
    }

    public void UpdatePreviewTask()
    {
        IsUpdated = false;
        if (_previewLinesLock is null)
            return;

        lock (_previewLinesLock)
        {
            if (PreviewTask is null && _previewTaskExecutionCount == 0)
            {
                ScriptBlock scriptBlock = SelectorEntry.PreviewAsyncScript!;
                object[]? argumentList = SelectorEntry.PreviewAsyncScriptArgumentList;
                var task = new BackgroundRunspace.Task(scriptBlock, argumentList, this);
                PreviewTask = task;
                BackgroundRunspace.GetInstance().AddTask(task);
                return;
            }

            IsUpdated = _previewLinesUpdatedByTask;
            _previewLinesUpdatedByTask = false;
        }
    }

    private static string FormatWord(string word)
    {
        word = word.Replace("\r", "");
        word = word.Replace("\n", "");
        return word;
    }

    private static string GenerateSearchWord(string word, Regex? searchablePattern)
    {
        bool containsEscapeSequence = word.Contains('\x1b', StringComparison.Ordinal);
        if (!containsEscapeSequence && searchablePattern is null)
            return word;

        // Enable all characters.
        var characters = word.ToCharArray();

        // Only enable parts that are matched by regex if provided.
        if (searchablePattern is not null)
        {
            Array.Fill(characters, '\0');
            var matches = searchablePattern.Matches(word);
            foreach (Match match in matches)
            {
                for (int i = 0; i < match.Length; ++i)
                {
                    int charIndex = match.Index + i;
                    characters[charIndex] = word[charIndex];
                }
            }
        }

        // Disable escape seqnece characters.
        if (containsEscapeSequence)
        {
            bool escaped = false;
            for (int i = 0; i < characters.Length; ++i)
            {
                char character = characters[i];
                if (escaped)
                {
                    if (character == 'm')
                    {
                        escaped = false;
                    }
                    characters[i] = '\0';
                }
                else
                if (character == '\x1b')
                {
                    escaped = true;
                    characters[i] = '\0';
                }
            }
        }

        return new string(characters);
    }

    private static string[] FormatLines(IEnumerable objs)
    {
        var newLines = new List<string>();
        foreach (var obj in objs)
        {
            if (obj is null)
                continue;

            var line = obj.ToString();
            if (line is null)
                continue;

            line = line.Replace("\r", "");
            newLines.AddRange(line.Split("\n"));
        }
        return newLines.ToArray();
    }

    public static InternalEntry[] ConvertFrom(IReadOnlyList<SelectorEntry> selectorEntries)
    {
        var entries = new InternalEntry[selectorEntries.Count];
        for (int i = 0; i < selectorEntries.Count; ++i)
        {
            entries[i] = new InternalEntry(selectorEntries[i]);
        }
        return entries;
    }

    public static void ResetMatchesAndScore(InternalEntry[] entries)
    {
        foreach (var entry in entries)
        {
            Array.Fill(entry.NameMatches, false);
            Array.Fill(entry.DescriptionMatches, false);
            entry.Score = 0;
        }
    }
}
