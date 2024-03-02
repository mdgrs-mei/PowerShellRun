# Changelog

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
