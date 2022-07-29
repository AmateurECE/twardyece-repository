---
title: Building the kernel under CGroupsV2
---

# `kernel-sandbox` Package

Install kernel-sandbox package from my pacman repo to get the
`kernel-sandbox.slice`.

# Execute a Shell in the New Slice

```shell-session
$ systemd-run --user --slice=kernel-sandbox.slice --shell
```
