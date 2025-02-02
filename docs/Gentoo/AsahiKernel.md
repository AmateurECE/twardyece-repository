# Building the `-edge` kernel for Asahi Linux

I build the kernel from the `~/kernel-build` directory. Just as a sanity check,
verify that rust is available:

```bash-session
kernel-build$ make -C /usr/src/linux LLVM=1 O=$PWD rustavailable
```

## Building with a Rustup toolchain

If it's not, there are a few alternatives. We can use a toolchain installed via
`rustup` to build the kernel. Install the toolchain using rustup. Recall that
the kernel needs the rust-src component to build. Set a `rustup` override, and
update the `$PATH` to point to the right directory:

```
rustup override set 1.84.0
export PATH=$HOME/.cargo/bin:$PATH
```

## Building with the Gentoo toolchain

The recent versions of `sys-kernel/asahi-sources` ebuild depends on a recent
version of rust, installed with the `rust-src` and `rustfmt` USE flags. Use
`eix` and `equery uses` to see which versions are available to build. Make sure
`$PATH` points to the right installation of `cargo`, and that `eselect` is
using the right version of Rust (the one with the `rust-src` and `rustfmt`
flags).

```
[kernel-build]$ which cargo
/usr/bin/cargo
[kernel-build]$ equery uses '=dev-lang/rust-1.82.0-r101'
[ Legend : U - final flag setting for installation]
[        : I - package is installed with flag     ]
[ Colors : set, unset                             ]
 * Found these USE flags for dev-lang/rust-1.82.0-r101:
 U I
 + + rust-src                 : Install rust-src, needed by developer tools and for
                                build-std (cross)
 + + rustfmt                  : Install rustfmt, Rust code formatter
[kernel-build]$ eselect rust list
Available Rust versions:
  [1]   rust-1.82.0 *
  [2]   rust-1.83.0
```

## Building the kernel

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
