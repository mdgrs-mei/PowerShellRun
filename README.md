<div align="center">

# PowerShellRun

App, Utility and Function Launcher for PowerShell.

![Demo](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/c0c9d820-da8f-4a0c-a9aa-62c45a3d62e4)

*PowerShellRun* is a PowerShell module that lets you fuzzy search applications, utilities and functions you define and launch them
 with ease. It is a customizable launcher app on the PowerShell terminal.
 
 </div>

## Installation

```powershell
Install-Module -Name PowerShellRun -Scope CurrentUser
```

## Requirements

- Windows or macOS
- PowerShell 7 or newer

## Quick Start

```powershell
Enable-PSRunEntry -Category All
Invoke-PSRun
```

This code enables entries of all categories and opens up this TUI:

![Invoke-PSRun](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/1e265819-d2f0-492a-978d-e16024e6a233)

Type characters to search entries and hit `Enter` to launch the selected item. There are some other actions that can be performed depending on the item. Hit `Ctrl+k` to open the Action Window and see what actions are available.

![ActionWindow](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/64d37afa-a6ec-4b5d-b739-f37decf9e442)

You can assign a shortcut key to quickly launch *PowerShellRun*.

```powershell
Set-PSRunPSReadLineKeyHandler -Chord 'Ctrl+j'
```

## Entry Categories

There are some entry categories that you can selectively enable by passing an array of the category names to `Enable-PSRunEntry`.

```powershell
Enable-PSRunEntry -Category Function, Favorite
```

### 🚀 Application

Installed applications are listed by the `Application` category. You can launch (or launch as admin on Windows) the application by pressing the action key.

### 🔧 Executable

Executable files under the PATH are listed by `Executable` category. You can invoke them on the same console where *PowerShellRun* is running.

### 🔎 Utility

Currently, we have only one utility entry defined by *PowerShellRun*.

`File Manager (PSRun)` navigates the folder hierarchy from the current directory using the PowerShellRun TUI.

![FiileManager](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/6a5f995a-36bc-4046-996e-141095f19004)

### 📁 Favorite

You can register folders or files that you frequently access. The available actions are the same as the ones in `File Manager (PSRun)`.

```powershell
Add-PSRunFavoriteFolder -Path 'D:/PowerShellRun'
Add-PSRunFavoriteFile -Path 'D:/PowerShellRun/README.md' -Icon '📖' -Preview @"
-------------------------------
💖 This is a custom preview 💖
-------------------------------
"@
```

![Favarites](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/bd80a193-37e3-49bc-805b-779cf0404d05)

### 📝 Function

The ability to call PowerShell functions is what makes *PowerShellRun* special. The functions defined between `Start-PSRunFunctionRegistration` and `Stop-PSRunFunctionRegistration` are registered as entries. The scope of the functions needs to be global so that *PowerShellRun* can call them.

```powershell
Start-PSRunFunctionRegistration

#.SYNOPSIS
# git pull with rebase option.
function global:GitPullRebase()
{
    git pull --rebase
}
# ... Define functions here as many as you want.

Stop-PSRunFunctionRegistration
```

![FunctionBasic](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/6e81aa7e-4aea-4c4f-9f4b-7853eae4d03a)

`SYNOPSIS` or `DESCRIPTION` in the comment based help is used as a description of the entry. You can also optionally specify parameters using the `COMPONENT`. It uses [ConvertFrom-StringData](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-stringdata?view=powershell-7.4) to extract the parameters.

```powershell
<#
.SYNOPSIS
git pull with rebase option.

.COMPONENT
PSRun(
    Icon = 🌿
    Preview = This is a custom preview.\nNew lines need to be written like this.)
#>
function global:GitPullRebase()
{
    git pull --rebase
}
```

![Function](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/4a08a1fd-896e-4961-bbc5-b3f885de1831)

## Options

You can customize *PowerShellRun*'s behavior and themes through options. Create a `SelectorOption` instance and pass it to `Set-PSRunDefaultSelectorOption`.

```powershell
$option = [PowerShellRun.SelectorOption]::new()
$option.Prompt = 'Type words👉 '
$option.QuitWithBackspaceOnEmptyQuery = $true
Set-PSRunDefaultSelectorOption $option
Invoke-PSRun
```

### Key Bindings

Key bindings are stored in `$option.KeyBinding`. You can set a string of `KeyModifier` and `Key` concatenated with `+` to the key.

```powershell
$keyBinding = $option.KeyBinding
$keyBinding.QuitKeys = @(
    'Escape'
    'Ctrl+j'
)
$keyBinding.MarkerKeys = 'Ctrl+f'
```

### Theme

The theme can be custmozied with `$option.Theme` property. We hope someone creates a cool theme library for *PowerShellRun*🙏.

```powershell
$default = [PowerShellRun.FontColor]::FromHex('#CBCCC6')
$gray = [PowerShellRun.FontColor]::FromHex('#707070')
$highlight = [PowerShellRun.FontColor]::FromHex('#61FFCA')
$focusHighlight = [PowerShellRun.FontColor]::FromHex('#4CBF99')
$roundBorder = [PowerShellRun.BorderSymbol]::new()
$roundBorder.TopLeft = '╭'
$roundBorder.TopRight = '╮'
$roundBorder.BottomLeft = '╰'
$roundBorder.BottomRight = '╯'

$option.Prompt = ' '
$theme = $option.Theme
$theme.CanvasHeightPercentage = 80
$theme.Cursor = '▸ '
$theme.IconEnable = $false
$theme.PreviewPosition = [PowerShellRun.PreviewPosition]::Right
$theme.CanvasBorderFlags = [PowerShellRun.BorderFlag]::All
$theme.SearchBarBorderFlags = [PowerShellRun.BorderFlag]::None
$theme.CanvasBorderSymbol = $roundBorder
$theme.PreviewBorderSymbol = $roundBorder
$theme.DefaultForegroundColor = $default
$theme.CanvasBorderForegroundColor = $gray
$theme.PromptForegroundColor = $gray
$theme.PreviewBorderForegroundColor = $gray
$theme.EntryScrollBarForegroundColor = $gray
$theme.PreviewScrollBarForegroundColor = $gray
$theme.CursorForegroundColor = $highlight
$theme.NameHighlightForegroundColor = $highlight
$theme.DescriptionHighlightForegroundColor = $highlight
$theme.NameFocusHighlightBackgroundColor = $focusHighlight
$theme.DescriptionFocusHighlightBackgroundColor = $focusHighlight
```

![Theme](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/9c6504b1-6369-49b9-af0d-93cd7164c7a9)

<div align="center">

# *PowerShellRun* as a Generic Selector

</div>

The underlying fuzzy selector in *PowerShellRun* is accesible with the following commands.

## Invoke-PSRunSelector

`Invoke-PSRunSelector` is designed to be used interactively on the terminal. It takes an array of **objects** and returns **objects**. It uses `Name`, `Description` and `Preview` properties of the object by default but you can change them with parameters like `-NameProperty`, `-DescriptionProperty` and `-PreviewProperty`.

```powershell
Get-ChildItem | Invoke-PSRunSelector -DescriptionProperty FullName -MultiSelection
```

![SelectorDemo](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/8b0ed6fc-ba69-4eaa-bb77-7c43f4699536)

`-Expression` parameter is useful if you need to build custom strings to be shown.

```powershell
Get-ChildItem | Invoke-PSRunSelector -Expression {@{
    Name = $_.Name
    Preview = Get-Item $_ | Out-String
}}
```

## Invoke-PSRunSelectorCustom

`Invoke-PSRunSelectorCustom` offers you a full access to the selector and is designed to create your own tool. It takes an array of `SelectorEntry` instances and returns a `SelectorResult` object. A `SelectorResult` object holds information such as the selected entry and the pressed key.

```powershell
PS> Get-ChildItem | ForEach-Object {
    $entry = [PowerShellRun.SelectorEntry]::new()
    $entry.UserData = $_
    $entry.Name = $_.Name
    $entry.Preview = $_.FullName
    $entry
} | Invoke-PSRunSelectorCustom

FocusedEntry                MarkedEntries KeyCombination Context
------------                ------------- -------------- -------
PowerShellRun.SelectorEntry               Enter          PowerShellRun.SelectorContext
```

By using `PreviewAsyncScript`, it's even possible to show information that takes some time to generate without blocking the UI. If you have [bat](https://github.com/sharkdp/bat) installed for syntax highlighting, you can build a Select-String viewer with this script:

```powershell
$word = 'Custom'
$option = [PowerShellRun.SelectorOption]::new()
$option.Prompt = "Searching for word '{0}'> " -f $word

$matches = Get-ChildItem *.cs -Recurse | Select-String $word
$result = $matches | ForEach-Object {
    $entry = [PowerShellRun.SelectorEntry]::new()
    $entry.UserData = $_
    $entry.Name = $_.Filename
    $entry.Description = $_.Path
    $entry.PreviewAsyncScript = {
        param($match)
        & bat --color=always --highlight-line $match.LineNumber $match.Path
    }
    $entry.PreviewAsyncScriptArgumentList = $_
    $entry.PreviewInitialVerticalScroll = $_.LineNumber
    $entry
} | Invoke-PSRunSelectorCustom -Option $option

if ($result.KeyCombination -eq 'Enter') {
    code $result.FocusedEntry.UserData.Path
}
```

![Invoke_PSRunSelectorCustom](https://github.com/mdgrs-mei/PowerShellRunPrivate/assets/81177095/abb0d171-e5c6-4bc6-8873-a2fbdbaf6707)


## Major Limitations

- No history support
- Some emojis break the rendering

<div align="center">

# Credits

</div>

*PowerShellRun* uses:

- Wcwidth  
https://github.com/spectreconsole/wcwidth

Inspired by these projects:
- fzf  
https://github.com/junegunn/fzf
- PowerToys Run  
https://github.com/microsoft/PowerToys

