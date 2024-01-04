---
title: Storage Devices
---

# Resizing Partitions

If reducing the size of a partition, be sure to reduce the size of the
filesystem it contains *first*. If extending the size of a partition, do this
*last*. Generally, the system can be recovered if done in the wrong order by
reverting to the original system state and then completing the actions in the
correct order.

# Resizing LVM2 Logical Volumes

!!! note
    The [Arch Linux wiki page on LVM2][1] is very helpful here

In this example, I'll be reducing the size of an LVM2 logical volume (LV) named
`home` to make space for a 30 GiB `btrfs` partition. Obviously, I checked to
make sure that the filesystem has the available space to support this
reduction.

I begin by booting into a Debian LiveCD, which I configure with an SSH server.
The credentials to log in are `user:live`, and no password is required for
`sudo` access.

I currently have the following layout:

```
root@debian:/home/user# lsblk
NAME       MAJ:MIN RM   SIZE RO TYPE   MOUNTPOINTS
sda          8:0    0 465.8G  0 disk
├─sda1       8:1    0   243M  0 part
├─sda2       8:2    0     1K  0 part
├─sda3       8:3    0   781M  0 part
└─sda5       8:5    0 464.8G  0 part
  ├─edtwardy--vg-root
  │        253:0    0  23.3G  0 lvm
  ├─edtwardy--vg-var
  │        253:1    0  76.4G  0 lvm
  ├─edtwardy--vg-swap_1
  │        253:2    0  13.9G  0 lvm
  ├─edtwardy--vg-tmp
  │        253:3    0   1.9G  0 lvm
  └─edtwardy--vg-home
           253:4    0 349.2G  0 lvm
root@debian:/home/user# lvs -v --segments
  LV     VG          Attr       Start   SSize    #Str Type   Stripe Chunk
  home   edtwardy-vg -wi-a-----      0  <349.24g    1 linear     0     0
  root   edtwardy-vg -wi-a-----      0    23.28g    1 linear     0     0
  swap_1 edtwardy-vg -wi-a-----      0   <13.93g    1 linear     0     0
  tmp    edtwardy-vg -wi-a-----      0    <1.86g    1 linear     0     0
  var    edtwardy-vg -wi-a-----      0     9.31g    1 linear     0     0
  var    edtwardy-vg -wi-a-----   9.31g  <16.38g    1 linear     0     0
  var    edtwardy-vg -wi-a----- <25.69g   50.76g    1 linear     0     0
root@debian:/home/user# pvs
  PV         VG          Fmt  Attr PSize    PFree
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g    0
```

I use resize2fs to reduce the size of the ext4 filesystem on the `home` LV.
Start by using `dumpe2fs` to calculate the new block size of the filesystem.
This allows us to remove any ambiguity caused by the interpretation of units
(m, M, g, G, etc.).

```
root@debian:/home/user# dumpe2fs -h /dev/edtwardy-vg/home
dumpe2fs 1.47.0 (5-Feb-2023)
...
Block count:              91550464
...
Block size:               4096
...
```

Calculate the new size with the formula:

> reduction = 30 \* 2\*\*30 (30 GiB)
>
> block_count - (reduction / block_size)

```
root@debian:/home/user# e2fsck -f /dev/edtwardy-vg/home
e2fsck 1.47.0 (5-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
/dev/edtwardy-vg/home: 3436910/22888448 files (0.5% non-contiguous), 44044815/91550464 blocks
root@debian:/home/user# resize2fs /dev/edtwardy-vg/home 83686144
resize2fs 1.47.0 (5-Feb-2023)
Resizing the filesystem on /dev/edtwardy-vg/home to 83686144 (4k) blocks.
The filesystem on /dev/edtwardy-vg/home is now 83686144 (4k) blocks long.
```

Note that `lvreduce` does have a `--resizefs` switch that can be used to reduce
the underlying filesystem in one go, but I chose not to do that here to
underscore that this is a required step (however it's accomplished).

Use `lvreduce` to reduce the size of the LV. We can specify a relative change
in any units we want, but again, we're going to use PE's, to remove all
ambiguity. The PE size can be taken from the output of `pvdisplay`, and the
size of the LV in PE's is displayed by the field `Current LE` in the output of
`lvdisplay`.

```
root@debian:/home/user# pvdisplay
  --- Physical volume ---
...
  PE Size               4.00 MiB
...
root@debian:/home/user# lvreduce --extents -7680 /dev/edtwardy-vg/home 
  WARNING: Reducing active logical volume to <319.24 GiB.
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce edtwardy-vg/home? [y/n]: y
  Size of logical volume edtwardy-vg/home changed from <349.24 GiB (89405 extents) to <319.24 GiB (81725 extents).
  Logical volume edtwardy-vg/home successfully resized.
```

We've likely created some empty space in the middle of our PV, so we may need
to use `pvmove` to move the extents of a around to partition to consume the
newly freed space and arrange the free extents to live at the end of the volume
group. To test, check the output of `pvs`:

```
root@debian:/home/user# pvs -v --segments
  PV         VG          Fmt  Attr PSize    PFree  Start  SSize LV     Start Type   PE Ranges
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g      0  5960 root       0 linear /dev/sda5:0-5959
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   5960  2384 var        0 linear /dev/sda5:5960-8343
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   8344  3566 swap_1     0 linear /dev/sda5:8344-11909
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  11910   476 tmp        0 linear /dev/sda5:11910-12385
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  12386 81725 home       0 linear /dev/sda5:12386-94110
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  94111  7680            0 free
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 101791 12995 var     6576 linear /dev/sda5:101791-114785
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 114786  4192 var     2384 linear /dev/sda5:114786-118977
```

Since the free space is large enough to contain the entire last segment, we'll
need to do this in two steps:
```
root@debian:/home/user# pvmove --alloc anywhere /dev/sda5:114786-118977
  /dev/sda5: Moved: 0.19%
...
  /dev/sda5: Moved: 100.00%
```

Now the landlocked segment is smaller than the last segment, so we have to do
some math.
```
root@debian:/home/user# pvs -v --segments /dev/sda5
  PV         VG          Fmt  Attr PSize    PFree  Start  SSize LV     Start Type   PE Ranges              
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g      0  5960 root       0 linear /dev/sda5:0-5959       
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   5960  2384 var        0 linear /dev/sda5:5960-8343    
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   8344  3566 swap_1     0 linear /dev/sda5:8344-11909   
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  11910   476 tmp        0 linear /dev/sda5:11910-12385  
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  12386 81725 home       0 linear /dev/sda5:12386-94110  
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  94111  4192 var     2384 linear /dev/sda5:94111-98302  
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  98303  3488            0 free                          
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 101791 12995 var     6576 linear /dev/sda5:101791-114785
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 114786  4192            0 free
```

> 114785 (end of final segment) - 3488 (size of free space) = 111297

```
root@debian:/home/user# pvmove --alloc anywhere /dev/sda5:111297-114785
  /dev/sda5: Moved: 0.89%
...
  /dev/sda5: Moved: 99.80%
```

Whoops! Looks like that didn't work.
```
root@debian:/home/user# pvs -v --segments
  PV         VG          Fmt  Attr PSize    PFree  Start  SSize LV     Start Type   PE Ranges
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g      0  5960 root       0 linear /dev/sda5:0-5959
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   5960  2384 var        0 linear /dev/sda5:5960-8343
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   8344  3566 swap_1     0 linear /dev/sda5:8344-11909
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  11910   476 tmp        0 linear /dev/sda5:11910-12385
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  12386 81725 home       0 linear /dev/sda5:12386-94110
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  94111  4192 var     2384 linear /dev/sda5:94111-98302
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  98303  3488            0 free
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 101791  9506 var     6576 linear /dev/sda5:101791-111296
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 111297  3489            0 free
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 114786  3489 var    16082 linear /dev/sda5:114786-118274
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 118275   703            0 free

```

Let's try again:
```
root@debian:/home/user# pvmove --alloc anywhere /dev/sda5:114787-118274 /dev/sda5:983
03-101791
  /dev/sda5: Moved: 1.06%
...
  /dev/sda5: Moved: 100.00%
```

Almost, now!
```
root@debian:/home/user# pvs -v --segments
  PV         VG          Fmt  Attr PSize    PFree  Start  SSize LV     Start Type   PE Ranges
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g      0  5960 root       0 linear /dev/sda5:0-5959
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   5960  2384 var        0 linear /dev/sda5:5960-8343
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g   8344  3566 swap_1     0 linear /dev/sda5:8344-11909
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  11910   476 tmp        0 linear /dev/sda5:11910-12385
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  12386 81725 home       0 linear /dev/sda5:12386-94110
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  94111  4192 var     2384 linear /dev/sda5:94111-98302
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g  98303  3488 var    16083 linear /dev/sda5:98303-101790
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 101791  9506 var     6576 linear /dev/sda5:101791-111296
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 111297  3489            0 free
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 114786     1 var    16082 linear /dev/sda5:114786-114786
  /dev/sda5  edtwardy-vg lvm2 a--  <464.76g 30.00g 114787  4191            0 free
```

One final move, and it's perfect:
```
root@debian:/home/user# pvmove --alloc anywhere /dev/sda5:114787-114788 /dev/sda5:111297-111298
  /dev/sda5: Moved: 100.00%
```

Use `pvresize` to reduce the size of the physical volume. For no apparent rhyme
or reason, the size argument to `pvresize` defaults to units of MiB, so we need
to convert our new size from PE's to MiB.

```
root@debian:/home/user# pvdisplay
  --- Physical volume ---
  PV Name               /dev/sda5
  VG Name               edtwardy-vg
...
  PE Size               4.00 MiB
  Total PE              118978
  Free PE               7680
  Allocated PE          111298
...
```

I frequently get output like this, indicating the size I provided is too small:

```
root@debian:/home/user# pvresize --setphysicalvolumesize 445192 /dev/sda5 
/dev/sda5: Requested size <434.76 GiB is less than real size <464.76 GiB. Proceed?  [y/n]: y
  WARNING: /dev/sda5: Pretending size is 911753216 not 974669825 sectors.
  /dev/sda5: cannot resize to 111297 extents as 111298 are allocated.
  0 physical volume(s) resized or updated / 1 physical volume(s) not resized
```

Of course, this doesn't make sense, because 445192 MiB is exactly 111298 PE's.
So, we just need to increment the number of PE's in the calculation until
`pvresize` is happy.

```
root@debian:/home/user# pvresize --setphysicalvolumesize 445196 /dev/sda5 
/dev/sda5: Requested size 434.76 GiB is less than real size <464.76 GiB. Proceed?  [y/n]: y
  WARNING: /dev/sda5: Pretending size is 911761408 not 974669825 sectors.
  Physical volume "/dev/sda5" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
```

Use `fdisk` to delete the extended partition, and create a new extended
partition at the exact same start sector, and a new logical partition in the
exact same start sector, but with reduced size.

I'm gonna use some math to determine the new end sector of the extended
partition:

> previous_end = 975171584
>
> sector_size = 512
>
> previous_end - (30 * 2**30 / sector_size)

```
root@debian:/home/user# fdisk /dev/sda

Welcome to fdisk (util-linux 2.38.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

This disk is currently in use - repartitioning is probably a bad idea.
It's recommended to umount all file systems, and swapoff all swap
partitions on this disk.


Command (m for help): p

Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: WDC  WDS500G2B0A
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5124b043

Device     Boot     Start       End   Sectors   Size Id Type
/dev/sda1            2048    499711    497664   243M 83 Linux
/dev/sda2          501758 975171584 974669827 464.8G  5 Extended
/dev/sda3  *    975173632 976773167   1599536   781M 83 Linux
/dev/sda5          501760 975171584 974669825 464.8G 8e Linux LVM

Partition table entries are not in disk order.

Command (m for help): d
Partition number (1-3,5, default 5): 2

Partition 2 has been deleted.

Command (m for help): p
Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: WDC  WDS500G2B0A
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5124b043

Device     Boot     Start       End Sectors  Size Id Type
/dev/sda1            2048    499711  497664  243M 83 Linux
/dev/sda3  *    975173632 976773167 1599536  781M 83 Linux

Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p): e
Partition number (2,4, default 2): 
First sector (499712-975173631, default 499712): 501758
Last sector, +/-sectors or +/-size{K,M,G,T,P} (501758-975173631, default 975173631): 912257024

Created a new partition 2 of type 'Extended' and of size 434.8 GiB.

Command (m for help): n
Partition type
   p   primary (2 primary, 1 extended, 1 free)
   l   logical (numbered from 5)
Select (default p): l

Adding logical partition 5
First sector (503806-912257024, default 503808): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (503808-912257024, default 912257024): 
 
Created a new partition 5 of type 'Linux' and of size 434.8 GiB.
Partition #5 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: n

Command (m for help): x

Expert command (m for help): b
Partition number (1-3,5, default 5): 
New beginning of data (501759-912257024, default 503808): 501760

Expert command (m for help): r

Command (m for help): p

Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: WDC  WDS500G2B0A
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5124b043

Device     Boot     Start       End   Sectors   Size Id Type
/dev/sda1            2048    499711    497664   243M 83 Linux
/dev/sda2          501758 912257024 911755267 434.8G  5 Extended
/dev/sda3  *    975173632 976773167   1599536   781M 83 Linux
/dev/sda5          501760 912257024 911755265 434.8G 83 Linux

Partition table entries are not in disk order.
```

Now, I'm going to create a new partition that will contain our `btrfs`
filesystem.

```
Command (m for help): n
Partition type
   p   primary (2 primary, 1 extended, 1 free)
   l   logical (numbered from 5)
Select (default p): 

Using default response p.
Selected partition 4
First sector (912257025-975173631, default 912259072): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (912259072-975173631, default 975173631): 

Created a new partition 4 of type 'Linux' and of size 30 GiB.

Command (m for help): p
Disk /dev/sda: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: WDC  WDS500G2B0A
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x5124b043

Device     Boot     Start       End   Sectors   Size Id Type
/dev/sda1            2048    499711    497664   243M 83 Linux
/dev/sda2          501758 912257024 911755267 434.8G  5 Extended
/dev/sda3  *    975173632 976773167   1599536   781M 83 Linux
/dev/sda4       912259072 975173631  62914560    30G 83 Linux
/dev/sda5          501760 912257024 911755265 434.8G 83 Linux

Partition table entries are not in disk order.

Command (m for help): w
The partition table has been altered.
Failed to update system information about partition 2: Device or resource busy

The kernel still uses the old partitions. The new table will be used at the next reboot. 
Syncing disks.
```

The error at the end doesn't seem to ever have caused any trouble for me, so I
ignore it?

But we're not out of the woods yet. Running `pvs` gives a warning that the PV
is larger than the partition:

```
root@debian:/home/user# pvs -v --segments
  WARNING: Device /dev/sda5 has size of 911755265 sectors which is smaller than corresponding PV size of 911759360 sectors. Was device resized?
  WARNING: One or more devices used as PVs in VG edtwardy-vg have changed sizes.
...
```

I simply resize the PV to be the same size as the partition, and we're good to
go:

```
root@debian:/home/user# pvresize --setphysicalvolumesize 911759360s /dev/sda5
  WARNING: Device /dev/sda5 has size of 911755265 sectors which is smaller than corresponding PV size of 911759360 sectors. Was device resized?
  WARNING: One or more devices used as PVs in VG edtwardy-vg have changed sizes.
  WARNING: /dev/sda5: Overriding real size <434.76 GiB. You could lose data.
/dev/sda5: Requested size 434.76 GiB exceeds real size <434.76 GiB. Proceed?  [y/n]: y
  WARNING: /dev/sda5: Pretending size is 911759360 not 911755265 sectors.
  Physical volume "/dev/sda5" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
```

I'm not sure why this happens. My expectation is that if it were unsafe,
`pvresize` would complain, like it otherwise does if you try to reduce the PV
size to below the actual space used by the allocated LEs. It's scary, but I
haven't had a problem so far, and I've done this twice.

If this is done incorrectly, the kernel may fail to boot, and device-mapper
will put an error in the boot log. From this error, it should be easy to
determine what to do. Usually, this means extending the partition by some
number of sectors.

Don't forget to update `/etc/fstab` if the root or boot partitions were
changed.

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

[1]: https://wiki.archlinux.org/title/LVM
