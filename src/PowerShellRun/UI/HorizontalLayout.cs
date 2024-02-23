namespace PowerShellRun;
using System;
using System.Diagnostics;

internal class HorizontalLayout : LayoutItem
{
    public override (LayoutSize Width, LayoutSize Height) GetLayoutSize()
    {
        var layoutSize = base.GetLayoutSize();
        if (layoutSize.Width.Type == LayoutSizeType.Content)
        {
            int width = 0;
            foreach (var child in _children)
            {
                var sizeRequest = child.GetLayoutSize();
                Debug.Assert(sizeRequest.Width.Type == LayoutSizeType.Absolute);

                var margin = child.Margin;
                int marginWidth = margin.Left + margin.Right;
                width += sizeRequest.Width.Value + marginWidth;
            }

            if (BorderFlags.HasFlag(BorderFlag.Left))
            {
                ++width;
            }
            if (BorderFlags.HasFlag(BorderFlag.Right))
            {
                ++width;
            }

            layoutSize.Width = new LayoutSize(LayoutSizeType.Absolute, width);
        }

        if (layoutSize.Height.Type == LayoutSizeType.Content)
        {
            int height = 0;
            foreach (var child in _children)
            {
                var sizeRequest = child.GetLayoutSize();
                Debug.Assert(sizeRequest.Height.Type == LayoutSizeType.Absolute);

                var margin = child.Margin;
                int marginHeight = margin.Top + margin.Bottom;
                height = Math.Max(height, sizeRequest.Height.Value + marginHeight);
            }

            if (BorderFlags.HasFlag(BorderFlag.Top))
            {
                ++height;
            }
            if (BorderFlags.HasFlag(BorderFlag.Bottom))
            {
                ++height;
            }

            layoutSize.Height = new LayoutSize(LayoutSizeType.Absolute, height);
        }

        return layoutSize;
    }

    public override void UpdateLayout(int x, int y, int width, int height)
    {
        base.UpdateLayout(x, y, width, height);
        var innerLayout = GetInnerLayout();

        int parentX = innerLayout.X;
        int parentY = innerLayout.Y;
        int parentWidth = innerLayout.Width;
        int parentHeight = innerLayout.Height;
        int parentBottom = Math.Max(parentY + parentHeight - 1, parentY);
        int widthRemaining = parentWidth;
        int currentX = parentX;

        foreach (var child in _children)
        {
            if (!child.Active)
                continue;

            var sizeRequest = child.GetLayoutSize();
            var margin = child.Margin;
            int currentHeight = Math.Max(parentHeight - margin.Top - margin.Bottom, 0);
            int currentY = Math.Min(parentY + margin.Top, parentBottom);

            int marginWidth = margin.Left + margin.Right;
            widthRemaining -= marginWidth;
            widthRemaining = Math.Max(0, widthRemaining);

            int currentWidth = 0;
            if (sizeRequest.Width.Type == LayoutSizeType.Absolute)
            {
                currentWidth = Math.Min(sizeRequest.Width.Value, widthRemaining);
            }
            else
            if (sizeRequest.Width.Type == LayoutSizeType.Percentage)
            {
                currentWidth = Math.Min(parentWidth * sizeRequest.Width.Value / 100, widthRemaining);
            }
            else
            if (sizeRequest.Width.Type == LayoutSizeType.Stretch)
            {
                currentWidth = widthRemaining;
            }
            currentX = Math.Min(currentX + margin.Left, parentX + parentWidth - 1);

            child.UpdateLayout(currentX, currentY, currentWidth, currentHeight);

            widthRemaining -= currentWidth;
            widthRemaining = Math.Max(0, widthRemaining);
            currentX = parentX + parentWidth - widthRemaining;
        }
    }
}
