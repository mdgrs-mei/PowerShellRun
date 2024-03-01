namespace PowerShellRun;
using System;

internal class VerticalLayout : LayoutItem
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
        int heightRemaining = parentHeight;
        int currentY = parentY;

        foreach (var child in _children)
        {
            if (!child.Active)
                continue;

            var sizeRequest = child.GetLayoutSize();
            var margin = child.Margin;

            int currentWidth = Math.Max(parentWidth - margin.Left - margin.Right, 0);
            int currentX = Math.Min(parentX + margin.Left, parentRightEnd);

            int marginHeight = margin.Top + margin.Bottom;
            heightRemaining -= marginHeight;
            heightRemaining = Math.Max(0, heightRemaining);

            int currentHeight = 0;
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
            currentY = Math.Min(currentY + margin.Top, parentY + parentHeight - 1);

            child.UpdateLayout(currentX, currentY, currentWidth, currentHeight);

            heightRemaining -= currentHeight;
            heightRemaining = Math.Max(0, heightRemaining);
            currentY = parentY + parentHeight - heightRemaining;
        }
    }
}
