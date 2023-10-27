---
title: "PowerShell Reference"
---

# PowerShell

```ps1
# Creating an etags table
Get-ChildItem -Path "*.[ch]" -Recurse | Foreach-Object { etags.exe --append $_.FullName }

# Count the lines of output (for example, from git-log)
(git log --oneline abcdefgh..ijklmnop | Measure-Object -lines).Lines

# Filtering output from a command (e.g. Get-ChildItem) using regex.
Get-ChildItem -Recurse -Path . | Foreach-Object { if ($_.FullName -cmatch "Test") { Write-Host $_.FullName } }
```

