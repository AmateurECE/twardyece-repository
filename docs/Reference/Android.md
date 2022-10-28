---
title: 'Android'
---

# Copying Photos

Moving photos and other files between a host PC and an Android phone is a real
pain. On Arch, the package `simple-mtpfs` is available in the AUR. Ensure the
phone screen is unlocked before attempting to mount the filesystem:

```bash-session
# simple-mtpfs /mnt/Mount
```

One must be root in order to read this mountpoint.
