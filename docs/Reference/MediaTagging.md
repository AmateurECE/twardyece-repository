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
$ num=$(id3v2 -l "$f" | awk '/TRCK/{print $NF}'); id3v2 -T "$num/$total" "$f"
```

# FLAC

Tags on FLAC files can be modified using the `metaflac` tool, which is
available as part of the `flac` package on Arch Linux.

## Adding Track Total

For FLAC files, the track total tag is `TOTALTRACKS`.
