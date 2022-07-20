---
title: tmux Tips and Tricks
---
# Tmux

In the context of this file, the key combo `Prefix` will be used to denote the
combination configured as the bind key in the tmux configuration. By default,
this is `^B Shift+:`.

## Copying Text from Buffer to File

Where lines is the number of lines to save in the buffer, and file-path is
an absolute file path or a relative path (in which case it will be assumed
relative to the working directory of the tmux server).

```
Prefix capture-pane -S -<lines>
Prefix save-buffer <file-path>
```
