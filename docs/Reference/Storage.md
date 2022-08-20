---
title: Storage Devices
---

# Creating an NTFS partition on Linux

Using `fdisk`, first create a partition label (DOS/GPT/whatever), then a new
partition. Use the `t` command to change the partition type to 7--`NTFS/exFAT`.

Finally, use the `mkfs.ntfs` command to create an NTFS partition on the disk.
On Arch Linux, this tool is installed via the `ntfs-3g` package.
