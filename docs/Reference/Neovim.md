---
title: Neovim
---

# Restoring Plugin Versions from Lock File

Sometimes odd errors may appear in the output of noice (use command `:
NoiceErrors`) or messages (use command `: messages`). In many cases, this is
caused by breaking changes in plugin versions. To restore to a
version-controlled lock file, first ensure that the lock-file is up-to-date
with the version-control source (for me, this usually means `cd`-ing into my
`homeshick` castle and running `git checkout`).

To restore all plugin versions to those specified in the lock file, run the
command `:Lazy restore`. Conversely, to update plugin versions to the latest
version available, enter the package manager with the `: Mason` command and
type `U`. The Mason dialog contains instructions for displaying the help, which
provides greater information about key bindings.

# Quick Reference

```
# To set a line wrap limit to 79 characters. Vim will automatically wrap the
# line on whitespace when the cursor runs over this limit.
# To wrap existing text, mark a region in visual mode and type `gq`.
: set textwidth=79

# To wrap text in the buffer. This doesn't change the contents by inserting any
# newlines, it only wraps the lines on the screen.
: set wrap
# To undo:
: set nowrap
```
