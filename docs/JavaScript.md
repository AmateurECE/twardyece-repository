---
title: 'Package Management in JavaScript'
---

# Upgrading Dependencies of a Package

Often, we want to explicitly update versions of dependencies called out in our
`package.json` file. To do this, utilize the `ncu` tool (available via
`npm-check-updates` package in both the Arch Linux repositories and NPM):

```bash-session
$ ncu --upgrade
```

This will overwrite dependencies specified in `package.json` with the latest
available from NPM. Finally, run `npm i` to upgrade the installed packages.
