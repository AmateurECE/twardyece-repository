---
title: Booting the Kernel with QEMU
---

# Specifying the Kernel

```shell-session
$ qemu-system-x86_64 -kernel arch/x86_64/boot/bzImage
```

# Without Graphics

Specify the `-nographic` option, and instruct the kernel to send output to the
console with `console=ttyS0` on the kernel command line.

```shell-session
$ qemu-system-x86_64 <...other args...> -nographic -append console=ttyS0
```

# Exiting Emulation

Do this with the key combination `^A X`.
