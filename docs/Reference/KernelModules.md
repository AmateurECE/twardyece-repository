---
title: Loading and Configuration of Kernel Modules
---

Simply, if modules are not built statically into the kernel, they may be
loaded at boot time by init (differs for SysV vs. OpenRC/systemd) or by
udev. Modules may be loaded while executing from initrd/initramfs, so they
are already present at the time that the change root operation is completed
to switch to the newly mounted root filesystem.

The list of files that are significant here:

`/etc/modules`: (`modules(5)`) This file is used in old SysV init -based
systems, and is read by the `kmod` service.
`/etc/modules-load.d`: (`modules-load.d(5)`) Files in this directory are read
by OpenRC/systemd. They can be used to _load_ or _blacklist_ modules only--they
cannot be used to set module options, etc. For systemd, the
`systemd-modules-load.service(8)` reads these configuration files and loads
these modules automatically at runtime. In other words, use these files to
instruct systemd to load a module that would not otherwise be loaded by udev.
`/etc/modprobe.d`: Files in this directory have all the same functionality
as those in modules-load.d, and more. These files can be used to pass module
parameters, etc. These files configure `kmod`, so this configuration is used
whether the module is loaded by `systemd-modules-load.service`, `udevd`, etc.
