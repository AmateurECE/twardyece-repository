---
title: "Windows Quick Reference"
---

# PowerShell One-liners

```ps1
# Creating an etags table
Get-ChildItem -Path "*.[ch]" -Recurse | Foreach-Object { etags.exe --append $_.FullName }

# Count the lines of output (for example, from git-log)
(git log --oneline abcdefgh..ijklmnop | Measure-Object -lines).Lines

# Filtering output from a command (e.g. Get-ChildItem) using regex.
Get-ChildItem -Recurse -Path . | Foreach-Object { if ($_.FullName -cmatch "Test") { Write-Host $_.FullName } }

# Creating a symlink
New-Item -Path C:\Path\to\link -ItemType SymbolicLink -Value C:\Path\to\target

# Downloading a file
Invoke-WebRequest https://example.com/releases/app.tar.gz -OutFile .\app.tar.gz

# Extracting a tar file (surprisingly, it's the same):
tar -xzvf .\app.tar.gz
```


# Installing Windows Terminal

Without access to the Windows Store, we need to jump through a couple of hoops.
An `.msixbundle` can be downloaded from the Releases section of the official
Microsoft GitHub account. We can then install this file in PowerShell:

```
PS> Add-AppxPackage .\Microsoft.WindowsTerminal.msixbundle
```

I experienced an error related to a missing framework: `Microsoft.UI.Xaml.2.8`.
I downloaded this package explicitly from [NuGet][1]. The downloaded file can
be opened with 7zip or similar, and contains an appx file in the path
`.\tools\AppX\x64\Release`. Extract this file to somewhere and install it using
`Add-AppxPackage`. Ideally, all dependencies are now resolved and we can repeat
the above to install Windows Terminal.


[1]: https://nuget.org/packages/Microsoft.UI.Xaml
