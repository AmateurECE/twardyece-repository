# Building the `-edge` kernel for Asahi Linux

After `sys-kernel/asahi-sources::asahi` has been updated, it's necessary to
patch the kernel sources to make rust available:

```bash-session
/usr/src/linux$ sudo patch -p1 < ~/Git/linux/outgoing/v3-0001-scripts-rust_is_available-Fix-clang-version-check.patch 
```

Just as a sanity check, verify that rust is available:

```bash-session
kernel-build$ make -C /usr/src/linux LLVM=1 O=$PWD rustavailable
```

Generate the kernel configuration. This procedure was taken from the [linux-asahi PKGBUILD][1].

```bash-session
kernel-build$ cat ../PKGBUILDs/linux-asahi/config ../PKGBUILDs/linux-asahi/config.edge > .config
kernel-build$ make -C /usr/src/linux LLVM=1 olddefconfig prepare O=$PWD
```

Build the kernel and modules:

```bash-session
kernel-build$ make -C /usr/src/linux LLVM=1 O=$PWD -j$(nproc)
```

Before installing, it may be necessary to remove old kernels from `/boot` and their modules in `/lib/modules`.
Next, install the kernel and modules:

```bash-session
kernel-build$ sudo make -C /usr/src/linux LLVM=1 O=$PWD install
kernel-build$ sudo make -C /usr/src/linux LLVM=1 O=$PWD modules_install
```

And extract the M1 firmware for m1n1:

```bash-session
kernel-build$ sudo asahi-fwupdate
```

Now presumably, we also have to update m1n1 and the stage-two payload. But,
since we're on Gentoo and building the kernel out-of-tree, we have to
tell the `update-m1n1` script where to find our device tree blobs:

```bash-session
kernel-build$ sudo DTBS=arch/arm64/boot/dts/apple/*.dtb update-m1n1
```

Generate a new initramfs for our fresh kernel:

```
kernel-build$ sudo dracut --kver 6.3.0-asahi-6-edge-ARCH
```

Finally, update GRUB and its configuration to boot with our new kernel:

```bash-session
kernel-build$ sudo grub-mkconfig -o /boot/grub/grub.cfg
```

# Running Android Studio under Sway:

```
_JAVA_AWT_WM_NONREPARENTING=1 STUDIO_JDK=/usr/lib/jvm/java-11-openjdk android-studio
```

[1]: https://github.com/AsahiLinux/PKGBUILDs/blob/main/linux-asahi/PKGBUILD
