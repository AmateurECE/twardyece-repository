# Building the `-edge` kernel for Asahi Linux

I build the kernel from the `~/kernel-build` directory, because I have a
`rustup(1)` override set to use a particular version of rust for the kernel
build. You can check this using `rustup override list`. First, update `$PATH`
to use the Rust binaries we've installed with rustup.

```bash-session
export PATH=$HOME/.cargo/bin:$PATH
```

Just as a sanity check, verify that rust is available:

```bash-session
kernel-build$ make -C /usr/src/linux LLVM=1 O=$PWD rustavailable
```

Generate the kernel configuration. I've been starting with the old
configuration, and it's been good enough so far.

```bash-session
kernel-build$ zcat /proc/config.gz > .config
kernel-build$ make -C /usr/src/linux LLVM=1 olddefconfig prepare O=$PWD
```

Build the kernel and modules, then install the artifacts:

```bash-session
kernel-build$ make -C /usr/src/linux LLVM=1 O=$PWD -j$(nproc)
kernel-build$ sudo make -C /usr/src/linux LLVM=1 O=$PWD install
kernel-build$ sudo make -C /usr/src/linux LLVM=1 O=$PWD modules_install
kernel-build$ sudo make -C /usr/src/linux LLVM=1 O=$PWD dtbs_install
```

After installing:

* Remove old kernels from `/boot`
* Remove old device tree blobs from `/boot/dtbs`
* Remove old modules from `/lib/modules`

I've had to make an update to `/etc/default/update-m1n1` so that the
`update-m1n1` script works. It looks like this for me:

```bash-session
DTBS=$(/bin/ls -d /boot/dtbs/* | sort -rV | head -1)/apple/*.dtb
```

Extract the M1 firmware for m1n1 and update m1n1 itself:

```bash-session
kernel-build$ sudo asahi-fwupdate
kernel-build$ sudo update-m1n1
```

Generate a new initramfs for our fresh kernel:

```
kernel-build$ sudo dracut --kver 6.3.0-asahi-6-edge-ARCH
```

Finally, update GRUB and its configuration to boot with our new kernel:

```bash-session
kernel-build$ sudo grub-install --removable --efi-directory=/boot/EFI --boot-directory=/boot
kernel-build$ sudo grub-mkconfig -o /boot/grub/grub.cfg
```

# Appendix: Patching the Sources

In the past, it's been necessary to patch the sources to fix various bugs. In
this example, I applied a patch that would fix a build-time check on clang:

```bash-session
$ (cd /usr/src/linux && sudo patch -p1 < ~/Git/linux/outgoing/v3-0001-scripts-rust_is_available-Fix-clang-version-check.patch)
```

[1]: https://github.com/AsahiLinux/PKGBUILDs/blob/main/linux-asahi/PKGBUILD
