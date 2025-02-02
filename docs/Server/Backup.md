# Backup Procedure

Each of the WD Passport drives has two btrfs partitions on it. The largest
partition is meant to be used for raid0, and mounted as a single combined
volume for backing up the data. The second partition is a raid1, and is for
backing up container data. Mounting one partition will automatically mount the
other.

```
[~]$ lsblk
NAME                    MAJ:MIN RM   SIZE RO TYPE   MOUNTPOINTS
sdf                       8:80   0 931.5G  0 disk
├─sdf1                    8:81   0    30G  0 part
└─sdf2                    8:82   0 901.5G  0 part
sdg                       8:96   0 931.5G  0 disk
├─sdg1                    8:97   0    30G  0 part
└─sdg2                    8:98   0 901.5G  0 part
[~]$ sudo mount /dev/sdf2 /mnt/Backup/
```

The `twardyece-services` repository contains a backup script for backing up the
media library:

```
[twardyece-services]$ ./backup.sh &
```

At this point, we can close the shell and monitor the backup my looking at
`/var/log/backup/backup-xxxxxx.log`.

The repository also contains a script for backing up the container data:

```
[twardyece-services]$ ./backup-data.sh
```
