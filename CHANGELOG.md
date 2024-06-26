# Changelog

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
