---
title: 'Camera Filesystems'
---

# Camera Filesystems

My digital camera (a Canon EOS Rebel T3) is very ornary about the filesystems
that it accepts on SD cards. Through rigorous trial and error, I discovered
that the following configuration is valid:

```
Disk /dev/mmcblk0: 29.72 GiB, 31914983424 bytes, 62333952 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xac1dce70

Device         Boot Start      End  Sectors  Size Id Type
/dev/mmcblk0p1       2048 62333951 62331904 29.7G  7 HPFS/NTFS/exFAT
```

This creates a DOS partition table with a single slot for an exFAT filesystem.
Naturally, an exFAT filesystem is expected.
