---
title: Neovim
---

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
