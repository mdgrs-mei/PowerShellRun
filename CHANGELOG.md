# Changelog

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
