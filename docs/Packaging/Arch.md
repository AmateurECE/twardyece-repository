---
title: Packaging on Arch Linux
---

# Building Packages

```
makepkg -sicf
```

# Packaging in a Container

Assuming the package directory is the current directory, we can start up an
Arch Linux Container to facilitate packaging. Create a dummy user and install
the `base-devel` package.

```
host$ sudo chown -R 100999:100999 .
host$ podman run -it -v $PWD:/home/user docker.io/archlinux/archlinux:latest
container# useradd -u 1000 -U user
container# pacman -Sy base-devel
container# su user
```

This creates a user with UID 1000 (inside the container). Outside of the
container, this user will have an effective UID based on the mappings setup in
`/etc/subuid`. For a container created by user `edtwardy` on the host, a user
with UID 1000 _inside_ the container will have the effective host UID of
100999, if `/etc/subuid` contains the following mapping:

```
edtwardy:100000:65536
```

The `root` user inside the container will have the effective host UID of the
user who created the container.

To edit files from the host, use `podman-unshare(1)`:

```
host$ podman unshare nvim PKGBUILD
```
