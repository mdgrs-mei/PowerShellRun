namespace PowerShellRun;
using System;
using System.Collections.Generic;

internal abstract class LayoutItem
{
    public class Rect
    {
        public int Left { get; set; } = 0;
        public int Right { get; set; } = 0;
        public int Top { get; set; } = 0;
        public int Bottom { get; set; } = 0;
    }

    public enum Align
    {
        Left,
        Right,
        Top,
        Bottom,
    }

    protected List<LayoutItem> _children = new List<LayoutItem>();

    public LayoutSize LayoutSizeWidth = new LayoutSize();
    public LayoutSize LayoutSizeHeight = new LayoutSize();
    public Align HorizontalAlign = Align.Left;
    public Align VerticalAlign = Align.Top;

    public int X { get; private set; } = 0;
    public int Y { get; private set; } = 0;
    public int Width { get; private set; } = 0;
    public int Height { get; private set; } = 0;
    public int? MinWidth { get; set; } = null;
    public int? MinHeight { get; set; } = null;
    public Rect Padding { get; set; } = new Rect();
    public Rect Margin { get; set; } = new Rect();
    public BorderFlag BorderFlags { get; set; } = BorderFlag.None;
    public BorderSymbol BorderSymbol { get; set; } = new BorderSymbol();
    public FontColor? BorderForegroundColor { get; set; } = null;
    public FontColor? BorderBackgroundColor { get; set; } = null;

    public bool Active { get; set; } = true;
    public bool Visible { get; set; } = true;

    public virtual (LayoutSize Width, LayoutSize Height) GetLayoutSize()
    {
        return (LayoutSizeWidth, LayoutSizeHeight);
    }

    public virtual void UpdateLayout(int x, int y, int width, int height)
    {
        X = x;
        Y = y;
        Width = width;
        Height = height;
    }

    public virtual (int X, int Y, int Width, int Height) GetInnerLayout()
    {
        int x = X;
        if (BorderFlags.HasFlag(BorderFlag.Left))
        {
            ++x;
        }
        x += Padding.Left;
        x = Math.Min(x, X + Width - 1);

        int y = Y;
        if (BorderFlags.HasFlag(BorderFlag.Top))
        {
            ++y;
        }
        y += Padding.Top;
        y = Math.Min(y, Y + Height - 1);

        int width = Width;
        if (BorderFlags.HasFlag(BorderFlag.Left))
        {
            --width;
        }
        if (BorderFlags.HasFlag(BorderFlag.Right))
        {
            --width;
        }
        width -= Padding.Left + Padding.Right;
        width = Math.Max(width, 0);

        int height = Height;
        if (BorderFlags.HasFlag(BorderFlag.Top))
        {
            --height;
        }
        if (BorderFlags.HasFlag(BorderFlag.Bottom))
        {
            --height;
        }
        height -= Padding.Top + Padding.Bottom;
        height = Math.Max(height, 0);

        return (x, y, width, height);
    }

    public virtual void Render()
    {
        if (!Active || !Visible)
            return;

        RenderBorders();

        foreach (var child in _children)
        {
            if (!child.Active || !child.Visible)
                continue;

            child.Render();
        }
    }

    protected void RenderBorders()
    {
        var canvas = Canvas.GetInstance();
        int rightEnd = Math.Max(X + Width - 1, X);
        int bottomEnd = Math.Max(Y + Height - 1, Y);

        if (BorderFlags.HasFlag(BorderFlag.Left))
        {
            for (int i = 0; i < Height; ++i)
            {
                char character = BorderSymbol.Vertical;
                if (i == 0 && BorderFlags.HasFlag(BorderFlag.Top))
                {
                    character = BorderSymbol.TopLeft;
                }
                else
                if (i == Height - 1 && BorderFlags.HasFlag(BorderFlag.Bottom))
                {
                    character = BorderSymbol.BottomLeft;
                }
                canvas.SetCell(X, Y + i, character, BorderForegroundColor, BorderBackgroundColor, FontStyle.Default, null, CanvasCell.Option.ForceResetColor);
            }
        }
        if (BorderFlags.HasFlag(BorderFlag.Right))
        {
            for (int i = 0; i < Height; ++i)
            {
                char character = BorderSymbol.Vertical;
                if (i == 0 && BorderFlags.HasFlag(BorderFlag.Top))
                {
                    character = BorderSymbol.TopRight;
                }
                else
                if (i == Height - 1 && BorderFlags.HasFlag(BorderFlag.Bottom))
                {
                    character = BorderSymbol.BottomRight;
                }
                canvas.SetCell(rightEnd, Y + i, character, BorderForegroundColor, BorderBackgroundColor, FontStyle.Default, null, CanvasCell.Option.ForceResetColor);
            }
        }
        if (BorderFlags.HasFlag(BorderFlag.Top))
        {
            for (int i = 0; i < Width; ++i)
            {
                var option = i == 0 ? CanvasCell.Option.ForceResetColor : CanvasCell.Option.None;
                if (i == 0 && BorderFlags.HasFlag(BorderFlag.Left))
                    continue;
                if (i == Width - 1 && BorderFlags.HasFlag(BorderFlag.Right))
                    continue;
                canvas.SetCell(X + i, Y, BorderSymbol.Horizontal, BorderForegroundColor, BorderBackgroundColor, FontStyle.Default, null, option);
            }
        }
        if (BorderFlags.HasFlag(BorderFlag.Bottom))
        {
            for (int i = 0; i < Width; ++i)
            {
                var option = i == 0 ? CanvasCell.Option.ForceResetColor : CanvasCell.Option.None;
                if (i == 0 && BorderFlags.HasFlag(BorderFlag.Left))
                    continue;
                if (i == Width - 1 && BorderFlags.HasFlag(BorderFlag.Right))
                    continue;
                canvas.SetCell(X + i, bottomEnd, BorderSymbol.Horizontal, BorderForegroundColor, BorderBackgroundColor, FontStyle.Default, null, option);
            }
        }
    }

    public void AddChild(LayoutItem child)
    {
        _children.Add(child);
    }
}
