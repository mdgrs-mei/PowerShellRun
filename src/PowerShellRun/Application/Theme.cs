namespace PowerShellRun;

public class Theme
{
    public ConsoleCursorShape ConsoleCursorShape = ConsoleCursorShape.Default;
    public ConsoleCursorShape KeyRemapModeConsoleCursorShape = ConsoleCursorShape.SteadyBar;

    public int CanvasHeightPercentage { get; set; } = 60;
    public int PreviewSizePercentage { get; set; } = 60;
    public int NameWidthPercentage { get; set; } = 30;
    public PreviewPosition PreviewPosition { get; set; } = PreviewPosition.Bottom;

    public int CanvasTopMargin { get; set; } = 1;
    public BorderFlag CanvasBorderFlags { get; set; } = BorderFlag.None;
    public BorderSymbol CanvasBorderSymbol { get; set; } = new BorderSymbol();
    public FontColor? CanvasBorderForegroundColor { get; set; } = null;
    public FontColor? CanvasBorderBackgroundColor { get; set; } = null;

    public FontColor? DefaultForegroundColor { get; set; } = null;
    public FontColor? DefaultBackgroundColor { get; set; } = null;

    public bool CursorEnable { get; set; } = true;
    public string Cursor { get; set; } = "» ";

    public string Marker { get; set; } = "✓ ";

    public string PromptSymbol { get; set; } = "> ";
    public FontColor? PromptForegroundColor { get; set; } = FontColor.Magenta;
    public FontColor? PromptBackgroundColor { get; set; } = null;
    public FontColor? QueryForegroundColor { get; set; } = null;
    public FontColor? QueryBackgroundColor { get; set; } = null;
    public FontColor? QueryBoxBackgroundColor { get; set; } = null;
    public FontStyle QueryStyle { get; set; } = FontStyle.Default;

    public BorderFlag SearchBarBorderFlags { get; set; } = BorderFlag.Bottom;
    public BorderSymbol SearchBarBorderSymbol { get; set; } = new BorderSymbol();
    public FontColor? SearchBarBorderForegroundColor { get; set; } = FontColor.Magenta;
    public FontColor? SearchBarBorderBackgroundColor { get; set; } = null;

    public FontColor? CursorForegroundColor { get; set; } = FontColor.Magenta;
    public FontColor? CursorBackgroundColor { get; set; } = null;
    public FontColor? CursorBoxBackgroundColor { get; set; } = null;

    public FontColor? MarkerForegroundColor { get; set; } = FontColor.Yellow;
    public FontColor? MarkerBackgroundColor { get; set; } = null;
    public FontColor? MarkerBoxBackgroundColor { get; set; } = null;

    public bool IconEnable { get; set; } = true;
    public FontColor? IconForegroundColor { get; set; } = null;
    public FontColor? IconBackgroundColor { get; set; } = null;
    public FontColor? IconFocusForegroundColor { get; set; } = null;
    public FontColor? IconFocusBackgroundColor { get; set; } = null;

    public FontColor? NameForegroundColor { get; set; } = null;
    public FontColor? NameBackgroundColor { get; set; } = null;
    public FontStyle NameStyle { get; set; } = FontStyle.Default;
    public FontColor? NameHighlightForegroundColor { get; set; } = FontColor.Cyan;
    public FontColor? NameHighlightBackgroundColor { get; set; } = null;
    public FontStyle NameHighlightStyle { get; set; } = FontStyle.Default;
    public FontColor? NameFocusForegroundColor { get; set; } = null;
    public FontColor? NameFocusBackgroundColor { get; set; } = null;
    public FontStyle NameFocusStyle { get; set; } = FontStyle.Negative;
    public FontColor? NameFocusHighlightForegroundColor { get; set; } = null;
    public FontColor? NameFocusHighlightBackgroundColor { get; set; } = FontColor.Magenta;
    public FontStyle NameFocusHighlightStyle { get; set; } = FontStyle.Negative;
    public FontColor? NameBoxBackgroundColor { get; set; } = null;

    public bool DescriptionEnable { get; set; } = true;
    public FontColor? DescriptionForegroundColor { get; set; } = FontColor.BrightBlue;
    public FontColor? DescriptionBackgroundColor { get; set; } = null;
    public FontStyle DescriptionStyle { get; set; } = FontStyle.Default;
    public FontColor? DescriptionHighlightForegroundColor { get; set; } = FontColor.Cyan;
    public FontColor? DescriptionHighlightBackgroundColor { get; set; } = null;
    public FontStyle DescriptionHighlightStyle { get; set; } = FontStyle.Default;
    public FontColor? DescriptionFocusForegroundColor { get; set; } = null;
    public FontColor? DescriptionFocusBackgroundColor { get; set; } = null;
    public FontStyle DescriptionFocusStyle { get; set; } = FontStyle.Negative;
    public FontColor? DescriptionFocusHighlightForegroundColor { get; set; } = null;
    public FontColor? DescriptionFocusHighlightBackgroundColor { get; set; } = FontColor.Magenta;
    public FontStyle DescriptionFocusHighlightStyle { get; set; } = FontStyle.Negative;
    public FontColor? DescriptionBoxBackgroundColor { get; set; } = null;

    public BorderFlag EntryBorderFlags { get; set; } = BorderFlag.None;
    public BorderSymbol EntryBorderSymbol { get; set; } = new BorderSymbol();
    public FontColor? EntryBorderForegroundColor { get; set; } = null;
    public FontColor? EntryBorderBackgroundColor { get; set; } = null;
    public FontColor? EntryScrollBarForegroundColor { get; set; } = null;
    public FontColor? EntryScrollBarBackgroundColor { get; set; } = null;

    public bool PreviewEnable { get; set; } = true;
    public TextWrapMode PreviewTextWrapMode { get; set; } = TextWrapMode.None;
    public FontColor? PreviewForegroundColor { get; set; } = null;
    public FontColor? PreviewBackgroundColor { get; set; } = null;
    public FontStyle PreviewStyle { get; set; } = FontStyle.Default;
    public FontColor? PreviewBoxBackgroundColor { get; set; } = null;
    public BorderFlag PreviewBorderFlags { get; set; } = BorderFlag.All;
    public BorderSymbol PreviewBorderSymbol { get; set; } = new BorderSymbol();
    public FontColor? PreviewBorderForegroundColor { get; set; } = null;
    public FontColor? PreviewBorderBackgroundColor { get; set; } = null;
    public FontColor? PreviewScrollBarForegroundColor { get; set; } = null;
    public FontColor? PreviewScrollBarBackgroundColor { get; set; } = null;

    public FontColor? ActionWindowCursorForegroundColor { get; set; } = FontColor.Magenta;
    public FontColor? ActionWindowCursorBackgroundColor { get; set; } = null;
    public FontColor? ActionWindowCursorBoxBackgroundColor { get; set; } = null;

    public FontColor? ActionWindowKeyForegroundColor { get; set; } = null;
    public FontColor? ActionWindowKeyBackgroundColor { get; set; } = null;
    public FontStyle ActionWindowKeyStyle { get; set; } = FontStyle.Default;
    public FontColor? ActionWindowKeyFocusForegroundColor { get; set; } = null;
    public FontColor? ActionWindowKeyFocusBackgroundColor { get; set; } = null;
    public FontStyle ActionWindowKeyFocusStyle { get; set; } = FontStyle.Negative;
    public FontColor? ActionWindowKeyBoxBackgroundColor { get; set; } = null;

    public FontColor? ActionWindowDescriptionForegroundColor { get; set; } = FontColor.BrightBlue;
    public FontColor? ActionWindowDescriptionBackgroundColor { get; set; } = null;
    public FontStyle ActionWindowDescriptionStyle { get; set; } = FontStyle.Default;
    public FontColor? ActionWindowDescriptionFocusForegroundColor { get; set; } = null;
    public FontColor? ActionWindowDescriptionFocusBackgroundColor { get; set; } = null;
    public FontStyle ActionWindowDescriptionFocusStyle { get; set; } = FontStyle.Negative;
    public FontColor? ActionWindowDescriptionBoxBackgroundColor { get; set; } = null;

    public bool ActionWindowBorderEnable { get; set; } = true;
    public BorderSymbol ActionWindowBorderSymbol { get; set; } = new BorderSymbol();
    public FontColor? ActionWindowBorderForegroundColor { get; set; } = FontColor.Magenta;
    public FontColor? ActionWindowBorderBackgroundColor { get; set; } = null;
    public FontColor? ActionWindowScrollBarForegroundColor { get; set; } = FontColor.Magenta;
    public FontColor? ActionWindowScrollBarBackgroundColor { get; set; } = null;

    public int TabSize { get; set; } = 8;

    public Theme? DeepClone()
    {
        return (Theme?)DeepCloneable.DeepClone(this);
    }
}

public enum PreviewPosition
{
    Right,
    Bottom,
}
