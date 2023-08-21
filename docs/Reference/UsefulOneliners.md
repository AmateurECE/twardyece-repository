---
title: Useful One-liners
---

```
# Replace one or more empty lines in all files with a single empty line:
sed '/^$/N;/^\n$/D' inputFile

# Enable the double-glob operator in Bash, a.k.a the "globstar" or "**":
shopt -s globstar
```
