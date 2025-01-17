<div align="center">

# PowerShellRun

[![GitHub license](https://img.shields.io/github/license/mdgrs-mei/PowerShellRun)](https://github.com/mdgrs-mei/PowerShellRun/blob/main/LICENSE)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/p/PowerShellRun)](https://www.powershellgallery.com/packages/PowerShellRun)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/dt/PowerShellRun)](https://www.powershellgallery.com/packages/PowerShellRun)

[![Pester Test](https://github.com/mdgrs-mei/PowerShellRun/actions/workflows/pester-test.yml/badge.svg)](https://github.com/mdgrs-mei/PowerShellRun/actions/workflows/pester-test.yml)

[![Hashnode](https://img.shields.io/badge/Hashnode-2962FF?style=for-the-badge&logo=hashnode&logoColor=white)](https://mdgrs.hashnode.dev/streamlining-your-workflow-around-the-powershell-terminal)

Terminal Based Launcher and Fuzzy Finder for PowerShell.

![Demo](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/d133be41-be9b-4045-8fa0-5194220a56fe)

*PowerShellRun* is a PowerShell module that lets you fuzzy search applications, utilities and functions you define and launch them
 with ease. It is a customizable launcher app on the PowerShell terminal.

 </div>

## Installation

```powershell
Install-PSResource -Name PowerShellRun
```

## Requirements

- Windows or macOS
- PowerShell 7.4 or newer

## Quick Start

First, call `Enable-PSRunEntry` to set up entries. You can control which entries are shown by passing the `-Category` parameter. Let's enable all for now:

```powershell
Enable-PSRunEntry -Category All
```

`Invoke-PSRun` function opens up the launcher TUI:

```powershell
Invoke-PSRun
```

![Invoke-PSRun](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/f923bc43-c76b-433a-ada1-c2f49fdaba4e)

Type characters to search entries and hit `Enter` to launch the selected item. There are some other actions that can be performed depending on the item. Hit `Ctrl+k` to open the Action Window and see what actions are available.

![ActionWindow](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/7abc7a2b-7252-4fc7-9753-796186fcb2ec)

Instead of typing `Invoke-PSRun` every time, you can assign a shortcut key to quickly launch *PowerShellRun*:

```powershell
Set-PSRunPSReadLineKeyHandler -InvokePsRunChord 'Ctrl+j'
```

## Controls

This is the default key bindings for the major controls. You can customize the bindings through [options](#key-bindings).

| Key | Action |
| ---- | ---- |
| `↑`, `↓` | Move cursor. |
| `PgUp`, `PgDn` | Move cursor up/down one page. |
| `Enter` | Execute the primary action of the selected entry. |
| `Tab` | Mark an entry in MultiSelection mode. |
| `Shift+Tab` | Toggle markers for all entries in MultiSelection mode. |
| `Backspace` on empty query | Go back to the parent menu. |
| `Ctrl+R` | Restart the menu. |
| `Ctrl+K` | Open the Action window. |
| `Escape` | Quit. |

## PowerShell Profile

The configurations of *PowerShellRun* are only persistent in a session so you need to add them to your [profile](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles) script to make them set up automatically in every PowerShell session. The typical profile script will look like this:

```powershell
# profile.ps1

# Set up entries.
Enable-PSRunEntry -Category All

# Set options.
Set-PSRunPSReadLineKeyHandler -InvokePsRunChord 'Ctrl+j'
Set-PSRunDefaultEditorScript -ScriptBlock {
    param($path)
    & code $path
}
$option = [PowerSHellRun.SelectorOption]::new()
$option.KeyBinding.QuitKeys = @(
    'Escape'
    'Ctrl+j'
)
Set-PSRunDefaultSelectorOption $option

# Add custom entries.
Add-PSRunFavoriteFolder -Path 'D:/PowerShellRun' -Icon '✨'
Add-PSRunScriptBlock -Name 'GitPullRebase' -ScriptBlock {
    git pull --rebase --prune
}
```

## Entry Categories

The entries listed in the launcher menu are grouped by `Category` internally. By passing an array of the category names to `Enable-PSRunEntry`, you can control which entries to show:

```powershell
Enable-PSRunEntry -Category Function, Favorite
```

In the following sections, we'll see what categories are available.

### ・🚀 Application

Installed applications are listed by the `Application` category. You can launch (or launch as admin on Windows) the application by pressing the action key.

### ・🔧 Executable

Executable files under the PATH are listed by `Executable` category. You can invoke them on the same console where *PowerShellRun* is running.

### ・🔎 Utility

PowerShellRun's built in utilities are listed by `Utility` category.

#### File Manager (PSRun)

`File Manager (PSRun)` navigates the folder hierarchy from the current directory using the PowerShellRun TUI.

![FiileManager](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/536b0853-0dd2-4c03-b429-c4ec95240cdf)

On the file entries, there is an action described as `"Edit with Default Editor"`. You can customize the script for this action like below:

```powershell
Set-PSRunDefaultEditorScript -ScriptBlock {
    param ($path)
    & code $path
}
```

#### WinGet (PSRun)

`WinGet (PSRun)` helps you install, upgrade and uninstall applications using winget. You need [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) and [Microsoft.WinGet.Client](https://github.com/microsoft/winget-cli) module installed to use this utility entry.

![image](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/225a5e71-cdd7-48ca-ba65-ee0af0dc0dba)

#### PSResourceGet (PSRun)

`PSResourceGet (PSRun)` allows you to install, upgrade and uninstall PowerShell modules. To use this utility, you need [PSResourceGet](https://github.com/PowerShell/PSResourceGet) module which should be pre-installed on PowerShell 7.4.

![image](https://github.com/user-attachments/assets/612af364-5fbe-41a1-b3c3-6250c5853473)

### ・📁 Favorite

You can register folders or files that you frequently access. The available actions are the same as the ones in `File Manager (PSRun)`.

```powershell
Add-PSRunFavoriteFolder -Path 'D:/PowerShellRun'
Add-PSRunFavoriteFile -Path 'D:/PowerShellRun/README.md' -Icon '📖' -Preview @"
-------------------------------
💖 This is a custom preview 💖
-------------------------------
"@
```

![Favarites](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/d174b169-3c3b-49f3-8d11-1997350c85fc)

### ・📝 Function

The ability to call PowerShell functions is what makes *PowerShellRun* special. The functions defined between `Start-PSRunFunctionRegistration` and `Stop-PSRunFunctionRegistration` are registered as entries. The scope of the functions needs to be global so that *PowerShellRun* can call them.

```powershell
Start-PSRunFunctionRegistration

#.SYNOPSIS
# git pull with rebase option.
function global:GitPullRebase() {
    git pull --rebase
}
# ... Define functions here as many as you want.

Stop-PSRunFunctionRegistration
```

![FunctionBasic](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/a70e8a1f-5e08-4dd1-861e-8cd74d23c1d2)

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
function global:GitPullRebase() {
    git pull --rebase
}
```

![Function](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/162b90dd-b51a-4b92-ab75-c8c29b3a385d)

If you cannot add `Start/Stop-PSRunFunctionRegistration` before and after the functions you would like to register, you can use `Add-PSRunFunction` instead to manually add functions one by one. The parameter extraction from the comment based help still works but the parameters passed to `Add-PSRunFunction` take priority. The registered functions must be defined globally before calling `Add-PSRunFunction`.

```powershell
Add-PSRunFunction -FunctionName GitPullRebase -Description 'Manually added function'
```

Inside a registered function entry, it's even possible to open *PowerShellRun*'s TUI using the commands described in the following [section](#powershellrun-as-a-generic-selector). To create a pseudo nested menu, we recommend that you enable the `QuitWithBackspaceOnEmptyQuery` flag in the [options](#options) to restore the parent menu with `Backspace` key. `File Manager (PSRun)` is a good example of the nested menu.

```powershell
function global:OpenNestedMenu() {
    $option = Get-PSRunDefaultSelectorOption
    $option.QuitWithBackspaceOnEmptyQuery = $true

    $result = Get-ChildItem | ForEach-Object {
        $entry = [PowerShellRun.SelectorEntry]::new()
        $entry.UserData = $_
        $entry.Name = $_.Name
        $entry
    } | Invoke-PSRunSelectorCustom -Option $option

    if ($null -eq $result.FocusedEntry) {
        return
    }
    # ... Key handlings here
}
```

### ・📘 Script

If you don't want to use the global scope to define function entries, you can use script entries. `Add-PSRunScriptBlock` adds a ScriptBlock and `Add-PSRunScriptFile` adds a `.ps1` file as an entry. They are invoked by pressing `Enter`.

```powershell
Add-PSRunScriptBlock -Name 'Test ScriptBlock' -ScriptBlock {
    'This is a test ScriptBlock'
}

Add-PSRunScriptFile -Path 'D:\PowerShellRun\tests\TestScriptFile.ps1' -Icon '💎'
```

![image](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/1fbeb3ee-1bf9-45f2-8729-8ebaa9d18e88)

### ・📂 EntryGroup

EntryGroups can have other entries as their children. You can use them to organize the launcher menu. EntryGroups are created by `Add-PSRunEntryGroup` function, and `Add-PSRun*` functions take `-EntryGroup` parameter to specify the parent group. The following example creates an EntryGroup for `ProjectA` and adds scripts for the project under that group:

```powershell
$projectA = Add-PSRunEntryGroup -Name 'ProjectA' -Icon '🍎' -PassThru
Add-PSRunScriptFile -EntryGroup $projectA -Path 'D:\PowerShellRun\Build.ps1' -Icon '🔁'
Add-PSRunScriptBlock -EntryGroup $projectA -Name 'Hello' -Icon '👋' -ScriptBlock {
    'Hello from ProjectA'
}
```

If you add `-Category` parameter to `Add-PSRunEntryGroup`, all the entries that belong to the specified categories are added as children of the group instead of being listed in the top menu.

```powershell
Add-PSRunEntryGroup -Name 'Functions' -Category Script, Function
```

`EntryGroup` forms a nested menu and you can go back to the parent menu by pressing `Backspace` key when the query is empty.

![EntryGroup](https://github.com/user-attachments/assets/14685437-18f1-4363-b3b0-c5061dcc7fed)

## History Search

History search functionality is provided outside the *PowerShellRun* menu using PSReadLineKeyHandler. It searches PSReadLine history. Multi-line entries are also supported. You can enable it with the following command:

```powershell
Set-PSRunPSReadLineKeyHandler -PSReadLineHistoryChord 'Ctrl+r'
```

![image](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/350afb04-4862-408b-b6b5-3e3c86d90264)

## Options

You can customize *PowerShellRun*'s behavior and themes through options. Create a `SelectorOption` instance and pass it to `Set-PSRunDefaultSelectorOption`.

```powershell
$option = [PowerShellRun.SelectorOption]::new()
$option.Theme.PromptSymbol = '👉 '
$option.ActionWindowCycleScrollEnable = $true
Set-PSRunDefaultSelectorOption $option
Invoke-PSRun
```

The option you set as default can be returned by `Get-PSRunDefaultSelectorOption`. Note that the returned option is always deep cloned. It is useful when you create a nested menu.

```powershell
$option = Get-PSRunDefaultSelectorOption
$option.Prompt = 'Nested menu prompt'
$option.QuitWithBackspaceOnEmptyQuery = $true
'a', 'b' | Invoke-PSRunSelector -Option $option
```

### ・Key Bindings

Key bindings are stored in `$option.KeyBinding`. You can set a string of `KeyModifier` and `Key` concatenated with `+` to the key.

```powershell
$keyBinding = $option.KeyBinding
$keyBinding.QuitKeys = @(
    'Escape'
    'Ctrl+j'
)
$keyBinding.MarkerKeys = 'Ctrl+f'
```

#### Key Remap Mode

There are two key binding modes, `Normal Mode` and `Key Remap Mode`. You can toggle the remap mode by pressing `RemapModeEnterKeys` and `RemapModeExitKeys`. In Key Remap mode, the keys you specify are remapped to other keys. This is useful if you'd like to achieve something like Vim Normal mode and Insert mode. Vim style `hjkl` navigation is set up like this:

```powershell
$theme.KeyRemapModeConsoleCursorShape = 'BlinkingBlock'
$keyBinding.InitialRemapMode = $true
$keyBinding.EnableTextInputInRemapMode = $false
$keyBinding.RemapModeEnterKeys = 'Escape'
$keyBinding.RemapModeExitKeys = 'i'
$keyBinding.RemapKeys = @(
    [PowerShellRun.RemapKey]::new('h', 'LeftArrow')
    [PowerShellRun.RemapKey]::new('j', 'DownArrow')
    [PowerShellRun.RemapKey]::new('k', 'UpArrow')
    [PowerShellRun.RemapKey]::new('l', 'RightArrow')
    [PowerShellRun.RemapKey]::new('Shift+j', 'Shift+DownArrow')
    [PowerShellRun.RemapKey]::new('Shift+k', 'Shift+UpArrow')
)
```

It starts in Key Remap mode, and `hjkl` keys are remapped to arrow keys. `i` key enables typing, and you can go back to the `hjkl` navigation by `Escape` key.

### ・Theme

The theme can be customized with `$option.Theme` property. We hope someone creates a cool theme library for *PowerShellRun*🙏.

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

$theme = $option.Theme
$theme.CanvasHeightPercentage = 80
$theme.Cursor = '▸ '
$theme.PromptSymbol = ' '
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

![Theme](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/3b91109f-2d7e-4985-a85f-67df6e402779)

<br>

<div align="center">

# *PowerShellRun* as a Generic Selector

</div>

The underlying fuzzy selector in *PowerShellRun* is accessible with the following commands.

## Invoke-PSRunSelector

`Invoke-PSRunSelector` is designed to be used interactively on the terminal. It takes an array of **objects** and returns **objects**. It uses `Name`, `Description` and `Preview` properties of the object by default but you can change them with parameters like `-NameProperty`, `-DescriptionProperty` and `-PreviewProperty`.

```powershell
Get-ChildItem | Invoke-PSRunSelector -DescriptionProperty FullName -MultiSelection
```

![SelectorDemo](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/799397eb-7a31-4349-a4b1-a0e671a4674c)

`-Expression` parameter is useful if you need to build custom strings.

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

### ・PreviewAsyncScript

By using `PreviewAsyncScript`, it's even possible to show information that takes some time to generate without blocking the UI. If you have [bat](https://github.com/sharkdp/bat) installed for syntax highlighting, you can build a Select-String viewer with this script:

```powershell
$word = Read-Host 'Type word to search for'
$filter = Read-Host 'Type path filter (e.g. "*.cs")'

$option = [PowerShellRun.SelectorOption]::new()
$option.Prompt = "Searching for word '{0}'" -f $word

$matchLines = Get-ChildItem $filter -Recurse | Select-String $word
$result = $matchLines | ForEach-Object {
    $entry = [PowerShellRun.SelectorEntry]::new()
    $entry.UserData = $_
    $entry.Name = '{0}:{1}' -f $_.Filename, $_.LineNumber
    $entry.Description = $_.Path
    $entry.PreviewAsyncScript = {
        param($match)
        & bat --color=always --highlight-line $match.LineNumber $match.Path
    }
    $entry.PreviewAsyncScriptArgumentList = $_
    $entry.PreviewInitialVerticalScroll = $_.LineNumber
    $entry
} | Invoke-PSRunSelectorCustom -Option $option

$match = $result.FocusedEntry.UserData
if ($match -and ($result.KeyCombination -eq 'Enter')) {
    $argument = '{0}:{1}' -f $match.Path, $match.LineNumber
    code --goto $argument
}
```

![Invoke-PSRunSelectorCustom](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/c963be6f-88cb-457b-a966-a94def3f057a)

### ・SearchablePattern

You can set Regex pattern to `NameSearchablePattern` and `DescriptionSearchablePattern` properties to define which parts of a string are hit by query.

#### Example1: The second word split by space is searchable

```powershell
# 'bbb' and 'eee' are searchable.
$pattern = [Regex]::new('(?<=^\S*\s).*?(?=\s|$)')
'aaa bbb ccc', 'ddd eee fff' | ForEach-Object {
    $entry = [PowerShellRun.SelectorEntry]::new()
    $entry.Name = $_
    $entry.NameSearchablePattern = $pattern
    $entry
} | Invoke-PSRunSelectorCustom
```

#### Example2: All words inside [] are searchable

```powershell
# 'bbb', 'ccc' and 'ddd' are searchable.
$pattern = [Regex]::new('(?<=\[).*?(?=\])')
'aaa [bbb] [ccc]', '[ddd] eee fff' | ForEach-Object {
    $entry = [PowerShellRun.SelectorEntry]::new()
    $entry.Name = $_
    $entry.NameSearchablePattern = $pattern
    $entry
} | Invoke-PSRunSelectorCustom
```

## Invoke-PSRunPrompt

`Invoke-PSRunPrompt` can be used to get user input in the same style as `Invoke-PSRunSelectorCustom` but without any entries. It reflects `SelectorOption` and returns the input, `KeyCombination` and the context. `WinGet (PSRun)` is a practical example.

```powershell
Invoke-PSRunPrompt
```

![image](https://github.com/mdgrs-mei/PowerShellRun/assets/81177095/90a9537f-afbd-4256-8ebb-af3d8e940d76)

```powershell
Input KeyCombination Context
----- -------------- -------
hello Enter          hello
```

## Major Limitations

- No history support
- Some emojis break the rendering

## Changelog

Changelog is available [here](https://github.com/mdgrs-mei/PowerShellRun/blob/main/CHANGELOG.md).

<br>

<div align="center">

# Contributing

</div>

## Code of Conduct

Please read our [Code of Conduct](https://github.com/mdgrs-mei/PowerShellRun/blob/main/CODE_OF_CONDUCT.md) to foster a welcoming environment. By participating in this project, you are expected to uphold this code.

## Have a question or want to showcase something?

Please come to our [Discussions](https://github.com/mdgrs-mei/PowerShellRun/discussions) page and avoid filing an issue to ask a question.

## Want to file an issue or make a PR?

Please see our [Contribution Guidelines](https://github.com/mdgrs-mei/PowerShellRun/blob/main/CONTRIBUTING.md).

<br>

<div align="center">

# Credits

</div>

*PowerShellRun* uses:

- Wcwidth<br>https://github.com/spectreconsole/wcwidth

Heavily inspired by:
- fzf<br>https://github.com/junegunn/fzf
- PowerToys Run<br>https://github.com/microsoft/PowerToys
