<div align="center">

# Contribution Guidelines

Thank you for taking the time to contribute to this project👏

The followings are the types of contributions we expect and the guidelines to follow.

 </div>

## Reporting Bugs

- Make sure that you are using the latest version
- Go to [issues](https://github.com/mdgrs-mei/PowerShellRun/issues) page and confirm that there is not already an existing bug report.
- File an issue and follow the `Bug Report` issue form.

## Suggesting Enhancements

If you are thinking about requesting new features or minor improvements to existing functionality, please follow the steps below:

- Read the [documentation](https://github.com/mdgrs-mei/PowerShellRun/blob/main/README.md) carefully and confirm that the functionality is not covered already.
- Go to [issues](https://github.com/mdgrs-mei/PowerShellRun/issues) page and confirm that there is not already an existing enhancement request.
- File an issue and follow the `Feature Request` issue form.

## Making Pull Requests

- File an issue by following the above guidelines before making a PR
- In the issue, suggest that you are willing to make a PR
- Make the changes in your forked repository
- Create a PR

### Build and Test

Assuming the .NET SDK is installed, you can build the project by calling the build script.

```powershell
& .\Build.ps1
```

After the build, basic functionalities that are not dependent to the interactive part can be tested using Pester.

```powershell
& .\tests\RunPesterTests.ps1
```

For interactive testing on the console, we recommend that you install [RestartableSession](https://github.com/mdgrs-mei/RestartableSession) module. Once installed, you can set up a testing console by running this script:

```powershell
& .\tests\RestartableSession.ps1
```

This script builds the project, import the built module and call `Enable-PSRunEntry -Category All`. When you make a code modification, you can just call `restart` command to do the same process (build/import/setup).

### Coding

When you make a code modification, please follow the style of the existing code. For code formatting, we recommend that you use Visual Studio Code since the formatting settings are included in `.vscode` folder.
