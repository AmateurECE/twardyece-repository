---
title: Tagging Media Files
---

# General

For the most part, edition of media files tags operates over a list of files.
So, for any command in this document to change/add/remove a tag, the formula
to do it for a whole directory of files is as follows:

```bash-session
$ IFS=$'\n'; for f in *.flac; do $(command); done
```

# MP3

Tags on MP3 files can be modified using the `id3v2` tool. On Arch Linux, this
is available via the package of the same name.

## Adding Track Total

For ID3 tags, the track number may optionally be stored as "num/total", where
"num" is the track number of this track, and "total" is the total number of
tracks.

The following command gets the track number from the current ID3 tags and
appends the tracktotal--it's assumed the track total is present in the shell
variable `$total`:

```bash-session
for f in *.mp3; do
    num=$(id3v2 -l "$f" | awk '/TRCK/{print $NF}')
    id3v2 -T "$num/$total" "$f"
done
```

## Removing a Tag

With `id3v2`, we can do this by specifying an empty value for an existing tag.
For example, to remove the disc number tag:

```bash-session
$ id3v2 --TPOS '' "$f"
```

# FLAC

Tags on FLAC files can be modified using the `metaflac` tool, which is
available as part of the `flac` package on Arch Linux.

## Adding Track Total

For FLAC files, the track total tag is `TOTALTRACKS`:

```bash-session
$ metaflac --set-tag=TOTALTRACKS=12 "$f"
```

## Importing Artwork

The following command will copy image data into a metadata frame in a flac
file. As always with cover art embedded in metadata flags, it's a good idea to
ensure the artwork is adequately compressed first.

```bash-session
$ metaflac --import-picture-from=<path> "$f"
```

# MP4/M4A

```
# List metadata
AtomicParsley file.m4a -t

# Update disk
IFS=$'\n'
for f in *.m4a; do
  AtomicParsley "$f" --disk "" --overWrite
done
```
