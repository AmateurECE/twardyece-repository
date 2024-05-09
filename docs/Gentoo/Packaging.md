# Gentoo

## Applying Patches to Packages

Very often, while working on a package, I want to test my changes before
committing. Naturally, Portage has a workflow for this, which is documented
[here][1]. Generally, it looks like this:

```bash-session
checkout$ ln -s $PWD /etc/portage/patches/${CATEGORY}/${PN}
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

[1]: https://wiki.gentoo.org/wiki//etc/portage/patches
