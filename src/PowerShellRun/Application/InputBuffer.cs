namespace PowerShellRun;

using System;
using System.Globalization;
using System.Text;
using PowerShellRun.Dependency;

internal class InputBuffer
{
    private StringBuilder _buffer = new StringBuilder();
    private int[] _textElementCharIndexes = new int[0];
    private int _cursorCharIndex = 0;
    public bool IsQueryUpdated { get; private set; } = false;
    public bool IsCursorUpdated { get; private set; } = false;

    public string GetString()
    {
        return _buffer.ToString();
    }

    public bool IsEmpty()
    {
        return _buffer.Length == 0;
    }

    public void ClearInput()
    {
        _buffer.Clear();
        UpdateTextElement();
    }

    public void ClearState()
    {
        IsQueryUpdated = false;
        IsCursorUpdated = false;
    }

    private void UpdateTextElement()
    {
        _textElementCharIndexes = StringInfo.ParseCombiningCharacters(GetString());
        IsQueryUpdated = true;
    }

    private int GetCharCount()
    {
        return _buffer.Length;
    }

    private int GetTextElementCount()
    {
        return _textElementCharIndexes.Length;
    }

    public void Add(char character)
    {
        if (_buffer.Length >= Constants.QueryCharacterMaxCount)
            return;

        if (Unicode.GetDisplayWidth(character) < 0)
            return;

        int cursorCharIndex = GetCursorCharIndex();
        if (cursorCharIndex == _buffer.Length)
        {
            _buffer.Append(character);
        }
        else
        {
            _buffer.Insert(cursorCharIndex, character);
        }

        UpdateTextElement();
        SetCursorCharIndex(cursorCharIndex + 1);
    }

    public void Add(string str)
    {
        foreach (char character in str)
        {
            Add(character);
        }
    }

    public void Backspace()
    {
        if (_cursorCharIndex == 0)
            return;

        int deleteFrom = GetCharIndexFromTextElementIndex(GetCursorTextElementIndex() - 1);
        int deleteTo = GetCursorCharIndex();
        _buffer.Remove(deleteFrom, deleteTo - deleteFrom);

        UpdateTextElement();
        SetCursorCharIndex(deleteFrom);
    }

    public void Delete()
    {
        if (_cursorCharIndex == GetCharCount())
            return;

        int deleteFrom = GetCursorCharIndex();
        int deleteTo = GetCharIndexFromTextElementIndex(GetCursorTextElementIndex() + 1);
        _buffer.Remove(deleteFrom, deleteTo - deleteFrom);

        UpdateTextElement();
    }

    public void MoveCursorForward()
    {
        int cursor = GetCharIndexFromTextElementIndex(GetCursorTextElementIndex() + 1);
        SetCursorCharIndex(cursor);
    }

    public void MoveCursorBackward()
    {
        int cursor = GetCharIndexFromTextElementIndex(GetCursorTextElementIndex() - 1);
        SetCursorCharIndex(cursor);
    }

    public void MoveCursorToBeginning()
    {
        SetCursorCharIndex(0);
    }

    public void MoveCursorToEnd()
    {
        SetCursorCharIndex(GetCharCount());
    }

    public int GetCursorOffsetInCanvas()
    {
        var str = GetString().Substring(0, GetCursorCharIndex());
        return TextBox.GetDisplayWidth(str);
    }

    private int GetCursorTextElementIndex()
    {
        return GetTextElementIndexFromCharIndex(GetCursorCharIndex());
    }

    public int GetCursorCharIndex()
    {
        return _cursorCharIndex;
    }

    private void SetCursorCharIndex(int index)
    {
        _cursorCharIndex = index;
        _cursorCharIndex = Math.Clamp(_cursorCharIndex, 0, GetCharCount());
        IsCursorUpdated = true;
    }

    private int GetTextElementIndexFromCharIndex(int charIndex)
    {
        int elementIndex = GetTextElementCount();
        if (charIndex < _buffer.Length)
        {
            for (var index = _textElementCharIndexes.Length - 1; index >= 0; index--)
            {
                if (_textElementCharIndexes[index] <= charIndex)
                {
                    elementIndex = index;
                    break;
                }
            }
        }
        return elementIndex;
    }

    private int GetCharIndexFromTextElementIndex(int textElementIndex)
    {
        if (textElementIndex < 0)
            return 0;

        if (textElementIndex >= _textElementCharIndexes.Length)
            return _buffer.Length;

        return _textElementCharIndexes[textElementIndex];
    }


}
