# Debian
## Further Resources
At the time of this writing, the simplest guide to Debian packaging can be
found in the `packaging-tutorial` package in the Debian repositories.
Install this package in the normal fashion. You can view the file list of this
package at [packages.debian.org](). to see where the tutorial was installed.
If this document ever becomes out of date, this package should be the
reference.

## Introduction
The fundamental container of the Debian package is the `.deb` file. This
file is an `ar` archive. Naturally, this means that one can create
Debian packages the hard way, and some do.

## Setup
Required packages:

1. `build-essential`
2. `devscripts`

## Building an Existing Package
In this example, we'll be rebuillding Dash, a shell program.

1. Install general build dependencies:
```
$ sudo apt-get install --no-install-recommends devscripts fakeroot
```

2. Obtain the sources:
```
$ sudo apt-get build-dep dash
```
Naturally, this requires the `deb-src` repositories to be present in your
`/etc/apt/sources.list`.

3. Create a working directory:
```
$ mkdir debian-tutorial && cd debian-tutorial
```
4. Obtain the source:
```
$ apt-get source dash
```
5. Build the package. The `-us -uc` arguments here disable signing the package
with GPG.
```
$ cd dash-*
$ debuild -us -uc
```

There should now be some new `.deb` files in the parent directory.

## About Source Packages
One source package can generate more than one binary package (`.deb` file).
There are two kinds of packages: _native_, normally for Debian specific
software, and _non-native_, for software developed outside Debian. The main
file in a package is the `.dsc` file, which contains metadata about the
package. Which other files make up the package depends on the version and type
of the source package. See `dpkg-source(1)` for exact details.

1. (1.0 or 3.0; native): `<package>_<version>.tar.gz`
2. (1.0; non-native):
    1. `<package>_<version>.orig.tar.gz`: Upstream source
    2. `<package>_<debversion>.debian.tar.gz`: Patch to add Debian-specific
       changes
3. (3.0; quilt):
    1. `<package>_<version>.orig.tar.gz`: Upstream source
    2. `<package>_<debversion>.debian.tar.gz`: Tarball with the Debian changes

## Creating a Basic Source Package
### Setting Up the File Tree
1. Download the upstream source (from the original developers)
2. Rename to `<sourcePackage>_<upstreamVersion>.orig.tar.gz`
3. Untar it
4. Rename the directory to `<sourcePackage>-<upstreamVersion>`
5. Prepare the Debian packaging system. This creates the `debian` directory
   with lots of files in it.
```
$ cd <sourcePackage>-<upstreamVersion> && dh_make
```
   There are some alternatives to `dh_make` for specific sets of
   packages (e.g. dh-make-perl, dh-make-php, etc.)

### Packaging
All the packaging work should be done by modifying the files in the `debian`
directory:

1. Main files:
    1. `control`: Metadata about the package
    2. `rules`: For building the package
    3. `copyright`: Licensing and copyright information
    4. `changelog`: History of the Debian package
2. Other files:
    1. `compat`
    2. `watch`
    3. `dh_install*` targets
    4. Maintainer scripts
    5. `source/format`
    6. `patches/` (If you need to modify the upstream sources)

### Version Strings
The version for all Debian packages comes in the form
`<upstreamVersion>-<debianVersion>`, where `<upstreamVersion>` is the version
of the upstream repository, and `<debianVersion>` is the version of the Debian
package. It seems like the version of the Debian package restarts when a new
version of the upstream is packaged.

### `debian/changelog`
This file lists the changes to the Debian package (not the source itself), and
gives the current version of the package. This file has a very specific format
which cannot be deviated from, so it is prudent to use the `dch` tool whenever
possible to streamline edition of this file. The `dch -i` command creates a new
changelog entry for a new release.

### `debian/control`
Contains package metadata for the source package itself, and each binary
package built from this source. View the [latest documentation](
https://www.debian.org/doc/debian-policy/ch-controlfields) for format of this
file.

### A Note About Architectures
Architecture is specified in `debian/control`, and the packager has a
few options:

1. `Architecture: any`: Describes a package that works on any architecture, but
   that the binary packages for which are not architecture agnostic (e.g. a C
   program that is portable to any architecture).
2. `Architecture: amd64 i386`: Describes a package that is only compatible with
   amd64 and i386 architectures. Any subset can be specified here.
3. `Architecture: all`: Some binary packages are architecture agnostic (e.g.
   configuration files, Python or Ruby scripts, etc).

### `debian/rules`
This is a Makefile, which is used to build Debian packages. It's documented in
[Debian Policy, chapter 4.8](
https://www.debian.org/doc/debian-policy/ch-source#s-debianrules). At the time
of this writing, there are a few required targets:

1. `build`, `build-arch`, `build-indep`: Should perform the configuration and
   compilation
2. `binary`, `binary-arch`, `binary-indep`: Builds the binary packages. The
   tool `dpkg-buildpackage` will call `binary` to build all the packages, or
   `binary-arch` to build only the `Architecture: any` packages
3. `clean`: Clean up the source directory

You could write shell code in this file directly, but a better practice is to
use a _packaging helper_. At the time of this writing,
`debhelper` (meaning Debhelper 7) is the most popular one.

### `dh`, or Debhelper 7
The goal of this tool is to factor the common tasks in packaging out and to fix
some packaging bugs once for all packages. This tool provides such scripts as
`dh_installdirs`, `dh_compress`, etc. One calls these tools from
`debian/rules`. These tools can be configured either by command parameters or
other files in `debian/`, for example, `package.docs`, `packages.manpages`,
`package.install`, etc. There are some third-party helpers for sets of
packages, such as `python-support`, `dh_ocaml`, etc.

# Gotchas

## Single Binary Packages

When source packages are configured to produce a single binary package (that
is, there's only one `Package` stanza in `debian/control`), the following error
might occur:

```
dh_install: warning: Cannot find (any matches for) "usr/bin/volumetric" (tried
in ., debian/tmp)

dh_install: warning: volumetric missing files: usr/bin/volumetric
```

See the following [Stack Overflow answer](https://unix.stackexchange.com/a/551942/347919) for more information, but the solution is to provide an empty
override for dh_install in `debian/rules`.
