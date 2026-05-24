# Backup Procedure

As of 2026, I have a dedicated backup server that performs a daily backup using
`btrbk`. Backups of the PostgreSQL dataset are taken weekly on Sunday. It's
currently necessary to manually scrub the database on the application server
once a month:

```
sudo nohup btrfs scrub start -Bd /mnt/library 2>&1 | mailx -s 'btrfs-scrub' et@ethantwardy.com &
```

## Old Backup Procedure

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

# Restoring From a Backup

Assuming the snapshots are in good condition, we can restore by sending the
snapshot back to the server and then creating a read/write snapshot from it:

```
sudo btrfs subvolume snapshot snapshots/@dataset.20251201 @dataset
```

# Investigating `csum` errors in scrub

https://serverfault.com/a/1112005

What I've done:

```
# I ran a scrub. This produces a bunch of messages in dmesg with details about
# the errors.

# Extract all of the btrfs messages from dmesg
sudo dmesg | grep -i btrfs > btrfs-errors.txt

# Delete all of the subvolumes that point to corrupted blocks. It seems like
# some snapshots don't actually point to blocks with checksum errors, because
# some snapshots for all affected volumes remain.
grep -o 'root [[:digit:]]*' btrfs-errors.txt \
  | awk '{print $2}' \
  | sort | uniq \
  | xargs -I{} sudo btrfs inspect-internal subvolid-resolve {} /dataset 2>/dev/null \
  | sort | uniq \
  | xargs -I{} sudo btrfs subvolume delete /dataset/{}
```
