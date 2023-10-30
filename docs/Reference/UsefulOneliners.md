---
title: Useful One-liners
---

```
# Replace one or more empty lines in all files with a single empty line:
sed '/^$/N;/^\n$/D' inputFile

# Enable the double-glob operator in Bash, a.k.a the "globstar" or "**":
shopt -s globstar

# Multiline search and replace in mutliple files using Perl.
perl -i -pe 'BEGIN{undef $/;} s@mutiline\nregex@@' ./**/*/*.cpp

# List contents of directories in a tree-like format (installed by the
app-text/tree package on Gentoo)
tree some-subdirectory
```
