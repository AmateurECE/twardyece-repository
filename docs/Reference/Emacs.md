---
title: Emacs
---

# Things I Always Forget How To Do in Emacs

## Navigating Source Easily

This can be done using eTags. To start, create a TAGS table:

```bash-session
$ find . -type f -name '\.[ch]' | xargs etags --append
```

Once in Emacs, run the command `visit-tags-table`. To look around, point the
cursor at an interesting symbol and press `M-.` to jump to its definition.
Press `M-,` to jump back.
