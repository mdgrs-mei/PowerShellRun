namespace PowerShellRun;
using System;
using System.Linq;

internal class Searcher
{
    private enum ScoreOperation
    {
        Or,
        And,
    }

    public InternalEntry[] Search(InternalEntry[] entries, string query)
    {
        InternalEntry.ResetMatchesAndScore(entries);

        if (string.IsNullOrEmpty(query))
        {
            return entries;
        }

        CalculateScores(entries, query);
        var sortedEntries = (InternalEntry[])entries.Clone();
        Array.Sort(sortedEntries, (x, y) => -x.Score.CompareTo(y.Score));

        int nonZeroCount = 0;
        foreach (var entry in sortedEntries)
        {
            if (entry.Score == 0)
                break;
            ++nonZeroCount;
        }

        return sortedEntries.Take(nonZeroCount).ToArray();
    }

    private void CalculateScores(InternalEntry[] entries, string query)
    {
        // query as 1 word including spaces.
        AddScores(entries, query, ScoreOperation.Or);

        string[] delimitedQueries = query.Split(' ', System.StringSplitOptions.RemoveEmptyEntries);
        bool hasDelimiters = (delimitedQueries.Length > 0) && (delimitedQueries[0].Length != query.Length);
        if (hasDelimiters)
        {
            // 'And' search for delimited words.
            for (int i = 0; i < delimitedQueries.Length; ++i)
            {
                var operation = (i == 0) ? ScoreOperation.Or : ScoreOperation.And;
                var delimitedQuery = delimitedQueries[i];
                AddScores(entries, delimitedQuery, operation);
            }
        }
    }

    private void AddScores(InternalEntry[] entries, string query, ScoreOperation operation)
    {
        bool useLowerCase = false;
        if (!query.Any(x => Char.IsUpper(x)))
        {
            useLowerCase = true;
        }

        foreach (var entry in entries)
        {
            if (operation == ScoreOperation.And && entry.Score == 0)
                continue;

            string nameEntry = useLowerCase ? entry.NameLowerCase : entry.Name;
            string descriptionEntry = useLowerCase ? entry.DescriptionLowerCase : entry.Description;

            int nameScore = CalculateScore(nameEntry, entry.NameMatches, query);
            int descriptionScore = CalculateScore(descriptionEntry, entry.DescriptionMatches, query);
            int alwaysScore = entry.AlwaysAvailable ? 1 : 0;

            int score = Math.Max(Math.Max(nameScore, descriptionScore), alwaysScore);
            if (operation == ScoreOperation.And && score == 0)
            {
                entry.Score = 0;
            }
            else
            {
                entry.Score += score;
            }
        }
    }

    private int CalculateScore(string searchEntry, bool[] matches, string query)
    {
        int score = 0;
        if (string.IsNullOrEmpty(searchEntry) || string.IsNullOrEmpty(query))
            return score;

        var matchIndexes = GetExactMatch(searchEntry, matches, query);
        bool isExactMath = matchIndexes.MatchStartIndex is not null;
        if (isExactMath)
        {
            score += 100;
        }
        else
        {
            matchIndexes = GetFirstMatch(searchEntry, matches, query);
            if ((matchIndexes.MatchStartIndex is int matchStartIndex) && (matchIndexes.MatchEndIndex is int matchEndIndex))
            {
                int matchWordDistance = matchEndIndex - matchStartIndex;
                score += Math.Max(50 - matchWordDistance, 1);
            }
        }

        if (score > 0)
        {
            // Short name entires get higher score
            score += Math.Max(50 - searchEntry.Length, 1);
        }

        {
            if (matchIndexes.MatchStartIndex is int matchStartIndex)
            {
                // First character match gets higher score
                if (matchStartIndex == 0)
                {
                    score += 10;
                }
            }
        }

        return score;
    }

    private (int? MatchStartIndex, int? MatchEndIndex) GetExactMatch(string searchEntry, bool[] matches, string query)
    {
        int matchStartIndex = searchEntry.IndexOf(query, StringComparison.Ordinal);
        bool isExactMath = matchStartIndex >= 0;
        if (!isExactMath)
            return (null, null);

        for (int i = 0; i < query.Length; ++i)
        {
            matches[matchStartIndex + i] = true;
        }
        return (matchStartIndex, matchStartIndex + query.Length - 1);
    }

    private (int? MatchStartIndex, int? MatchEndIndex) GetFirstMatch(string searchEntry, bool[] matches, string query)
    {
        if (query.Length > searchEntry.Length)
            return (null, null);

        // search forward until the last character is found
        int lastCharacterMatchIndex = 0;
        int queryIndex = 0;
        bool matchFound = false;
        for (int i = 0; i < searchEntry.Length; ++i)
        {
            if (searchEntry[i] == query[queryIndex])
            {
                ++queryIndex;
                if (queryIndex >= query.Length)
                {
                    matchFound = true;
                    lastCharacterMatchIndex = i;
                    break;
                }
            }
        }

        if (!matchFound)
            return (null, null);

        // search backward from the last character match
        int? firstCharacterMatchIndex = null;
        queryIndex = query.Length - 1;
        for (int i = lastCharacterMatchIndex; i >= 0; --i)
        {
            if (searchEntry[i] == query[queryIndex])
            {
                matches[i] = true;
                --queryIndex;
                if (queryIndex < 0)
                {
                    firstCharacterMatchIndex = i;
                    break;
                }
            }
        }

        return (firstCharacterMatchIndex, lastCharacterMatchIndex);
    }
}
