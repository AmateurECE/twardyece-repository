# Applying Patches to Packages

Very often, while working on a package, I want to test my changes before
committing. Naturally, Portage has a workflow for this, which is documented
[here][1]. Generally, it looks like this:

```bash-session
checkout$ ln -s $PWD /etc/portage/patches/${CATEGORY}/${PN}
# Make my changes...
checkout$ git format-patch -p HEAD^
checkout$ sudo emerge -av ${CATEGORY}/${PN}
```

[1]: https://wiki.gentoo.org/wiki//etc/portage/patches
