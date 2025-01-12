# Changelog

## [0.12.0] - 2025-01-12

### Added

- Added `PSResourceGet (PSRun)` utility entry

### Changed

- Changed .NET version from 6.0 to 8.0
- `WinGet (PSRun)` now shows progress when searching packages

## [0.11.0] - 2024-11-16

### Added

- Added string constructor to `FontColor`
- Added string constructor to `ActionKey`
- Added string constructor to `RemapKey`

### Changed

- Added `OutputType` attribute to `Get-PSRunDefaultSelectorOption`

### Fixed

- Fixed character width calculation for grapheme clusters
- Fixed broken rendering when wide characters are partially hidden by the Action Window

## [0.10.0] - 2024-10-31

### Added

- Added custom `ToString` methods to `FontColor`, `BorderSymbol`, `ActionKey`, `RemapKey`, `PromptContext`, `SelectorContext` and `SelectorEntry`
- Added `SelectorOption.Theme.PromptSymbol`

### Changed

- Removed `Option` parameter of `Invoke-PSRun`
  - Use `Set-PSRunDefaultSelectorOption` instead
- Removed `Restore-PSRunParentSelector`
  - The parent selector is now automatically restored when returning with backspace on empty query
- Moved the default prompt symbol `>` from `SelectorOption.Prompt` to `SelectorOption.Theme.PromptSymbol`

### Fixed

- Fixed incorrect `CanvasTopMargin` for PSReadLineHistory view

## [0.9.0] - 2024-10-08

### Added

- Added `Add-PSRunFunction`
- Added `RestartKeys` to `KeyBinding`
- Added `PowerShellRun.ExitStatus` class

### Changed

- Minimum PowerShell version is changed to 7.4 because of `NoRunspaceAffinity`
- Warnings are shown when you add an entry to a disabled category

### Fixed

- Fixed an issue where functions redefined between `Start/Stop-PSRunFunctionRegistration` are not registered
- Fixed an issue where the module refers the old globalStore when it's reloaded by `Import-Module -Force`
- Fixed an issue where the built-in nested menus used a wrong `DefaultActionKeys`

### Deprecated

- `Option` parameter of `Invoke-PSRun` will be removed in the next release
- `Restore-PSRunParentSelector` will be removed in the next release

## [0.8.0] - 2024-09-23

### Added

- Added comment based help to all public functions
- Added `Add-PSRunEntryGroup`
- Added `EntryGroup` parameter to `Add-*` functions
- Added `Launch/Invoke with arguments` actions to Application, Executable, ScriptBlock and Function entries

### Changed

- Enable-PSRunEntry must be called only once at the beginning of the module usage
- `Restore-PSRunFunctionParentSelector` alias has been removed

## [0.7.0] - 2024-06-15

### Added

- Added `Add-PSRunScriptBlock`
- Added `Add-PSRunScriptFile`

### Changed

- Renamed `Restore-PSRunFunctionParentSelector` `Restore-PSRunParentSelector`
- `Restore-PSRunFunctionParentSelector` is now an alias to `Restore-PSRunParentSelector`

### Deprecated

- `Restore-PSRunFunctionParentSelector` alias will be removed in the next release

## [0.6.0] - 2024-05-26

### Added

- Added support for CanvasBorder settings in `Invoke-PSRunPrompt`
- Added `NameSearchablePattern` and `DescriptionSearchablePattern` properties to `SelectorEntry`
- Added `InitialRemapMode` property to `KeyBinding`
- Added `EnableTextInputInRemapMode` property to `KeyBinding`
- Added `RemapModeEnterKeys` and `RemapModeExitKeys` properties to `KeyBinding`
- Added `RemapKeys` property to `KeyBinding`
- Added `ConsoleCursorShape` and `KeyRemapModeConsoleCursorShape` properties to `Theme`
- Added `Subtract` and `Divide` to `Key`

### Changed

- The reset escape sequence `\x1b[0m` resets the color and style to PowerShellRun's settings, not terminal's default
- The color and style of match highlights have higher priority than the ones set by escape sequences

### Fixed

- Escape sequence characters are now excluded from search

## [0.5.0] - 2024-04-30

### Added

- Added `PSReadLineHistoryChord` parameter to `Set-PSRunPSReadLineKeyHandler`

### Changed

- `Chord` parameter of `Set-PSRunPSReadLineKeyHandler` is now an alias to `InvokePsRunChord` parameter

### Fixed

- Fixed wrong match highlights when the line has new line characters

## [0.4.0] - 2024-04-22

### Added

- Added `Invoke-PSRunPrompt`
- Added `WinGet (PSRun)` utility entry

## [0.3.0] - 2024-04-01

### Added

- Added `Get-PSRunDefaultSelectorOption`

### Fixed

- Fixed an issue where you cannot use cli editors in Default Editor Script

## [0.2.0] - 2024-03-18

### Added

- Added `EntryCycleScrollEnable` property to `SelectorOption`
- Added `PreviewCycleScrollEnable` property to `SelectorOption`
- Added `ActionWindowCycleScrollEnable` property to `SelectorOption`
- Added `PageUpKeys` property to `KeyBinding`
- Added `PageDownKeys` property to `KeyBinding`
- Added `PreviewPageUpKeys` property to `KeyBinding`
- Added `PreviewPageDownKeys` property to `KeyBinding`
- Added parent folder entries to `File Manager (PSRun)`
- Added an indicator that shows distance from the root folder in `File Manager (PSRun)`

### Changed

- Changed `SelectorEntry.PreviewAsyncScriptArgumentList` to `object[]` to support named parameters in `PreviewAsyncScript`

### Fixed

- Fixed an error that occurs when some characters are typed before invoking PowerShellRun with a PSReadLine chord

## [0.1.0] - 2024-03-02

### Added

- Added non-ascii character support for query

### Changed

- File entries are now executed on the same window if they are command line applications
- Changed `Category` parameter of `Enable-PSRunEntry` to be case insensitive

### Fixed

- Fixed an issue where favorite entries added after `Invoke-PSRun` are not updated

## [0.0.1] - 2024-02-23

### Added

- Added `Add-PSRunFavoriteFile`
- Added `Add-PSRunFavoriteFolder`
- Added `Enable-PSRunEntry`
- Added `Invoke-PSRun`
- Added `Invoke-PSRunSelector`
- Added `Invoke-PSRunSelectorCustom`
- Added `Restore-PSRunFunctionParentSelector`
- Added `Set-PSRunActionKeyBinding`
- Added `Set-PSRunDefaultEditorScript`
- Added `Set-PSRunDefaultSelectorOption`
- Added `Set-PSRunPSReadLineKeyHandler`
- Added `Start-PSRunFunctionRegistration`
- Added `Stop-PSRunFunctionRegistration`
