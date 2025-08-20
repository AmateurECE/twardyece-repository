---
title: Useful One-liners
---

Replace one or more empty lines in all files with a single empty line:
```
sed '/^$/N;/^\n$/D' inputFile
```

Replace DOS-style (CR+LF, \r\n) line endings with Unix-style line endings
```
sed -i $'s/\r$//'
```

...the opposite
```
sed -i $'s/$/\r/'
```

Enable the double-glob operator in Bash, a.k.a the "globstar" or "**":
```
shopt -s globstar
```

Multiline search and replace in mutliple files using Perl.
```
perl -i -pe 'BEGIN{undef $/;} s@mutiline\nregex@@' ./**/*/*.cpp
```

List contents of directories in a tree-like format (installed by the
```
app-text/tree package on Gentoo)
tree some-subdirectory
```

Copy an image into a sparse file:
```
cp --sparse=always input.img output.img
```

Convert an image into a sparse file (in place). On Gentoo, this tool comes from
sys-apps/util-linux
```
fallocate -v --dig-holes file.img
```

Remove the first line from a stream:
```
echo -e "hey\nyou" | tail -n +2
```

Invert the colors of an image (using ImageMagick)
```
convert input.png -channel RGB -negate output.png
```

Extract the contents of a subdirectory in an archive into the current
directory, e.g., extracts the contents of linux-6.4.0/* into the current
directory
```
tar --strip-components=1 -xvf ../linux-6.4.0.tar.gz
```

Apply password-protection to a PDF file
```
pdftk source.pdf output destination.pdf user_pw PROMPT
```

Install an SSH public key on a remote server:
```
ssh-copy-id -i ~/.ssh/id_ed25519.pub <username>@<host>
```

Copy a partition over SSH:
```
ssh user@remote "dd if=/dev/sda | gzip -1 -" \
  | dd of=image.img.gz status=progress
```

Send a btrfs snapshot over SSH, where the SSH connection is established from
the receiver to the sender:
```
# Start the receiver
nc -l -p 9999 | btrfs receive /data/

# Send
ssh -R 9999:localhost:9999 ethantwardy@mail.ethantwardy.com \
  "btrfs send /data/snapshots/@etc | nc localhost 9999"
```

Use NTP to set the system clock time. It may take up to a minute for this
process to execute:
```
ntpd -g -q
hwclock --systohc
```
