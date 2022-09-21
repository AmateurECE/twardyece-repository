---
title: "PowerShell Reference"
---

# PowerShell

### Creating etags Table

```ps1con
PS project-root> Get-ChildItem -Path "*.[ch]" -Recurse | Foreach-Object { etags.exe --append $_.FullName }
```
