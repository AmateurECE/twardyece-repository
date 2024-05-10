# Using the Portage Python API

The Python API is installed with Portage itself. There is very little
documentation on its interface, but an introduction can be found
[here][1], and an extended (and terse) reference can be found [here][2].

Here's a brief example of its use:

```python
import portage

# Use portage.db[portage.root] to access the database. "vartree" contains the
# list of installed packages and "porttree" contains every ebuild.
# See: https://www.funtoo.org/Portage_API
installed_packages = portage.db[portage.root]["vartree"].dbapi

# List all "catpkg-version" or "category/package-version" atoms in the tree.
print("\n".join(installed_packages.cpv_all()))
```

This can be used for performing various queries on the database. While this is
very cool, I generally prefer to use `equery`, simply because its options are
well documented.

# Querying the Database for Package Metadata

When I took my machine from testing to stable, I needed to generate a list of
all packages currently in testing so that I could add them to
`package.accept_keywords`. I stole this query from [this blogpost][3].

```
equery list --installed -F '<=$cpv $mask2' '*' | \
     grep \~ | sudo tee /etc/portage/package.keywords/testing
```

I test to make sure that this has produced no changes by checking emerge:

```
$ emerge --ask --update --newuse --deep --pretend --with-bdeps=y @world

These are the packages that would be merged, in order:

Calculating dependencies... done!
Dependency resolution took 8.12 s (backtrack: 0/20).

```

# Cleaning `/etc/portage/package.*` From Unused Keywords

Over time, these directories gather keywords that no longer serve a function.
Use `eix-test-obsolete` to look for all kinds of obsoletion. Since this
command produces a lot of output, I've attempted to document the sections it
produces below:

## Non-matching Entries

```
Non-matching entries in /etc/portage/package.{accept_keywords,use}:
=dev-libs/hyprland-protocols-0.2 **
```

These packages cannot be found in the tree, either in portage or in any
enabled overlays. These may also show up under `Installed packages with a
version not in the database (or masked)` if there are other versions in the
tree. Resolving these requires more than just changing files in
`/etc/portage`, since it may also require updating packages to new versions or
removing packages entirely.

## Redundant Entries

```
Redundant in /etc/portage/package.{,accept_}keywords:

... considered as REDUNDANT_IF_DOUBLE
[I] sys-devel/clang (17.0.6(17/17)@12/09/23 18.1.5(18/18.1)@05/05/24): C language family frontend for LLVM
```

These entires are redundant because one or more overlapping entries specify
the same behavior for portage. In this case, I have two versions of clang
installed, and two entries in `/etc/portage/package.accept_keywords`:

```
<=sys-devel/clang-17.0.6 ~arm64
<=sys-devel/clang-18.1.5 ~arm64
```

It should be obvious from here that the first entry is made redundant by the
second entry, so the first entry can be removed.

```
... considered as REDUNDANT_IF_WEAKER
[I] app-misc/brightnessctl [2] (0.5.1@04/26/23): A program to read and control device brightness
```

In this case, `package.accept_keywords` contains this entry:

```
=app-misc/brightnessctl-0.5.1 **
```

As you may recall from the [relevant Gentoo wiki page][4], the special `**`
keyword means the package is always visible, regardless of architecture or
testing status. This was likely necessary at a time when the package was in
testing and didn't have your architecture listed in its keywords. However,
the package has since gained a keyword.

```
$ equery meta '=app-misc/brightnessctl-0.5.1'
 * app-misc/brightnessctl [guru]
Maintainer:  myrvogna@electrosphe.re (Octiabrina Terrien-Puig)
Upstream:    Remote-ID: https://github.com/Hummer12007/brightnessctl
             (github)
Homepage:    https://github.com/Hummer12007/brightnessctl
Location:    /var/db/repos/guru/app-misc/brightnessctl
Keywords:    0.5.1:0: ~amd64 ~arm64
License:     MIT
```

This entry is now weaker than it needs to be, and can be modified.

```
... considered as REDUNDANT_IF_STRANGE
[N] app-office/libreoffice (7.6.4.1{gpkg:2}): A full office productivity suite
```

This is an odd one. In this case, `package.accept_keywords` contained:

```
app-office/libreoffice -~arm64

```

But I had just changed `/etc/portage/make.conf` to list
`ACCEPT_KEYWORDS="arm64"`, so this entry serves no purpose and can be
removed.

```
... considered as REDUNDANT_IF_NO_CHANGE
[I] app-crypt/gnupg (2.4.5@03/09/24): The GNU Privacy Guard, a GPL OpenPGP implementation
```

In this case, `/etc/portage/package.accept_keywords` contained:

```
<=app-crypt/gnupg-2.4.5 ~arm64
```

However, `ACCEPT_KEYWORDS="arm64"` and the metadata for the package lists
`arm64` as well as `~arm64`:

```
$ equery meta '=app-crypt/gnupg-2.4.5'
 * app-crypt/gnupg [gentoo]
Maintainer:  base-system@gentoo.org (Gentoo Base System)
Upstream:    Remote-ID:   cpe:/a:gnupg:gnupg (cpe)
Homepage:    https://gnupg.org/
Location:    /var/db/repos/gentoo/app-crypt/gnupg
Keywords:    2.4.5:0: amd64 arm arm64 ppc ppc64 sparc x86 ~alpha
                      ~amd64-linux ~arm64-macos ~hppa ~ia64 ~loong ~m68k
                      ~mips ~ppc-macos ~riscv ~s390 ~x64-macos ~x64-solaris
                      ~x86-linux
License:     GPL-3+
```

So in this case, this entry can be removed entirely.

# Not Installed Packages

```
Not installed but in /etc/portage/package.{,accept_}keywords:
[N] media-sound/id3v2 ((*)0.1.12-r1): Command line editor for id3v2 tags
Found 11 matches
```

These ones are obvious. The package isn't installed, but we are accepting
keywords for them.

# Pulled Versions of Installed Packages

```
Installed packages with a version not in the database (or masked):
[?] dev-cpp/sdbus-c++ (1.4.0(0/1)@11/29/23 -> ??): High-level C++ D-Bus library
```

These packages are installed, but the versions that are installed can't be
found in the database. For example:

```
$ eix sdbus-c++
[?] dev-cpp/sdbus-c++
     Available versions:  ~*1.4.0-r1(0/1)^t {doc +elogind systemd test tools}
     Installed versions:  1.4.0(0/1)^t(07:08:07 11/29/23)(systemd -doc -elogind -test -tools)
     Homepage:            https://github.com/Kistler-Group/sdbus-cpp
     Description:         High-level C++ D-Bus library
```

Explicitly `emerge`ing them should get the newest version.

[1]: https://www.funtoo.org/Portage_API
[2]: https://dev.gentoo.org/~zmedico/portage/doc/api/
[3]: https://zigford.org/downgrade-gentoo-from-testing-to-stable.html
[4]: https://wiki.gentoo.org/wiki//etc/portage/package.accept_keywords
