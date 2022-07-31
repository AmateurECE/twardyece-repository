---
title: Booting the Kernel with QEMU
---

## Building a Kernel that Boots Under QEMU

### Device Support

By default, QEMU creates a virtual PS/2 keyboard for input. Use of this device
requires the `atkbd` driver, which either needs to be built as a module (and loaded
by udev), or built into the kernel. The option `CONFIG_KEYBOARD_ATKBD` configures this
driver.

### Debug Output on Console

Seems silly to call out, but if the debug output on the console is rather terse, even
after specifying `console=ttySX` on the kernel command line, it may be necessary to
increase `CONFIG_CONSOLE_LOGLEVEL_DEFAULT` in the kernel configuration to obtain more
information from the kernel at boot time.

## Starting the Virtual Machine

### Standard Invocation

```
qemu-system-x86_64 \
    --enable-kvm \
    -cpu host \
    -m 512M \
    -smp cpus=2 \
    -monitor stdio \
    -chardev socket,id=serial0,path=${XDG_RUNTIME_DIR}/kvm-console.sock,server=on \
    -serial chardev:serial0 \
    -nographic \
    -kernel bzImage \
    -initrd qemu-debug-minimal-qemu-x86_64.cpio.gz \
    -append 'console=ttyS0,115200n8'
```

### Redirecting Output Devices

1. `-monitor stdio`: Connect the QEMU monitor to stdin and stdout.
2. `-chardev socket,id=serial0,path=${XDG_RUNTIME_DIR}/kvm-console.sock,server=on`:
   Create a character device on the VM that is connected to a UNIX socket at the path
   `${XDG_RUNTIME_DIR}/kvm-console.sock`. This will be a server socket, and QEMU will
   block until a connection on this socket is made.
3. `-serial chardev:serial0`: Create a serial device (which will be enumerated under
   Linux as `/dev/ttyS0` and connect it to the chardev with id `serial0`, created
   above.)
4. `-nographic`: Do not connect a VGA device to the quest.
5. `-append 'console=ttyS0,115200n8`: Append these arguments to the kernel command
   line. This will, of course, put kmsg output on `/dev/ttyS0`. In order to actually
   get a terminal on this serial port, the rootfs will need to be configured to start
   a `getty` instance on this serial port. In Yocto, this is done using the
   `SERIAL_CONSOLES` variable in your machine configuration.

### Connecting minicom to the Unix socket

Install the `minirc-qemu` package from [my pacman repository][1]. This file should
contain the following:

```title="/etc/minirc.qemu"
# Machine-generated file - use "minicom -s" to change parameters.
pu port             unix#/run/user/1000/kvm-console.sock
pu linewrap         Yes
```

To start minicom using this configuration:

```shell-session
$ minicom qemu
```

[1]: https://github.com/AmateurECE/pacman
