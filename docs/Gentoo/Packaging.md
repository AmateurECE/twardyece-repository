---
title: Packaging
---

## Applying Patches to Packages

Very often, while working on a package, I want to test my changes before
committing. Naturally, Portage has a workflow for this, which is documented
[here][1]. Generally, it looks like this:

```bash-session
checkout$ ln -s $PWD /etc/portage/patches/${CATEGORY}
# Make my changes...
checkout$ git format-patch -p HEAD^
checkout$ sudo emerge -av ${CATEGORY}/${PN}
```

Note that this does work when building ebuilds manually from the command-line!
For example, in the case of developing a new ebuild for a package.

## Testing an ebuild on the command line

This can be done using `ebuild(1)`:

```bash-session
sudo ebuild ./package-version.ebuild manifest clean install
```

The arguments are a number of targets to run, but these three are pretty
standard--regenerate a `Manifest` file from the ebuild to contain metadata
for Portage, clean the build directory, and test all the build steps up
through installation to a package sysroot (N.B., not installation _of_ the
package).

To actually install the package, append `qmerge` to the end of the command, so
that the package is merged after installation.

To test the build using a specific use flag, set the `USE` environment variable:

```
sudo USE=introspection ebuild ./wireplumber-0.5.2.ebuild manifest clean install
```

# Generating Metadata

All packages must include metadata. The schema for `metadata.xml` is described
[here][2]. Use `metagen` to generate metadata and use `pkgdev` to commit the
changes.

```
$ metagen -e ethan.twardy@gmail.com --type person
$ git add metadata.xml
$ pkgdev commit
```

# Installing binary-only `.deb` and `.rpm` packages

Apparently, the [`unpacker.eclass`][3] can be used to extract and install
binary-only packages that come in the form of `.deb` and `.rpm` archives.

[1]: https://wiki.gentoo.org/wiki//etc/portage/patches
[2]: https://devmanual.gentoo.org/ebuild-writing/misc-files/metadata/index.html
[3]: https://devmanual.gentoo.org/eclass-reference/unpacker.eclass/index.html
