namespace PowerShellRun;
using System;

internal class StackLayout : LayoutItem
{
    public override void UpdateLayout(int x, int y, int width, int height)
    {
        base.UpdateLayout(x, y, width, height);
        var innerLayout = GetInnerLayout();

        int parentX = innerLayout.X;
        int parentY = innerLayout.Y;
        int parentWidth = innerLayout.Width;
        int parentHeight = innerLayout.Height;
        int parentRightEnd = Math.Max(parentX + parentWidth - 1, parentX);
        int parentBottom = Math.Max(parentY + parentHeight - 1, parentY);

        foreach (var child in _children)
        {
            if (!child.Active)
                continue;

            var sizeRequest = child.GetLayoutSize();
            var xAlign = child.HorizontalAlign;
            var yAlign = child.VerticalAlign;
            var margin = child.Margin;

            int currentWidth = 0;
            int marginWidth = margin.Left + margin.Right;
            int widthRemaining = Math.Max(parentWidth - marginWidth, 0);
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
            int currentX = (xAlign == Align.Left) ? parentX + margin.Left : parentRightEnd - margin.Right - currentWidth + 1;
            currentX = Math.Clamp(currentX, parentX, parentRightEnd);

            int currentHeight = 0;
            int marginHeight = margin.Top + margin.Bottom;
            int heightRemaining = Math.Max(parentHeight - marginHeight, 0);
            if (sizeRequest.Height.Type == LayoutSizeType.Absolute)
            {
                currentHeight = Math.Min(sizeRequest.Height.Value, heightRemaining);
            }
            else
            if (sizeRequest.Height.Type == LayoutSizeType.Percentage)
            {
                currentHeight = Math.Min(parentHeight * sizeRequest.Height.Value / 100, heightRemaining);
            }
            else
            if (sizeRequest.Height.Type == LayoutSizeType.Stretch)
            {
                currentHeight = heightRemaining;
            }
            int currentY = (yAlign == Align.Top) ? parentY + margin.Top : parentBottom - margin.Bottom - currentHeight + 1;
            currentY = Math.Clamp(currentY, parentY, parentBottom);

            child.UpdateLayout(currentX, currentY, currentWidth, currentHeight);
        }
    }
}
