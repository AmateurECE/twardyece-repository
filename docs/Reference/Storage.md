---
title: Storage Devices
---

# Resizing Partitions

If reducing the size of a partition, be sure to reduce the size of the
filesystem it contains *first*. If extending the size of a partition, do this
*last*. Generally, the system can be recovered if done in the wrong order by
reverting to the original system state and then completing the actions in the
correct order.

# Filesystem Management Tools

## ext2, ext3, ext4

The `dumpe2fs` tool will dump information about the filesystem. It can be used,
e.g. to determine the current size of the filesystem. The `resize2fs` tool is
used to resize the filesystem, and `e2fsck` will repair a filesystem.

## ISO-9660

The `isoinfo` tool provides information about these filesystems.

## Btrfs

The package `btrfs-progs` contains useful utilities for working with these
filesystems.

# LVM2

LVM uses device-mapper to create various storage pools that expose a storage
layout to userspace that doesn't necessarily reflect the physical organization
of storage.

In LVM2, _volume groups_ may contain mutliple _physical volumes_ and multiple
_logical volumes_. A _logical volume_ is a block of storage that is presented
to userspace as a contiguous disk.

The tools `vgdisplay`, `lvdisplay` and `pvdisplay` can be used to show the
existing storage layout. The tools `lvreduce` and `lvextend` can be used to
change the size of a logical volume:

```bash
# Extend the size of the volume by 50GiB
lvextend -L +50G volume-group/my-volume
```

The volume argument to the above command correlates to the device-mapper device
exposed at `/dev/volume-group/my-volume`.

# Creating an NTFS partition on Linux

Using `fdisk`, first create a partition label (DOS/GPT/whatever), then a new
partition. Use the `t` command to change the partition type to 7--`NTFS/exFAT`.

Finally, use the `mkfs.ntfs` command to create an NTFS partition on the disk.
On Arch Linux, this tool is installed via the `ntfs-3g` package.
