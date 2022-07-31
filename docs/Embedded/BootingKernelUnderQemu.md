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

Seems silly to call out, but if the debug output on the console is rather
terse, even after specifying `console=ttySX` on the kernel command line, it may
be necessary to increase `CONFIG_CONSOLE_LOGLEVEL_DEFAULT` in the kernel
configuration to obtain more information from the kernel at boot time.

## Running the Virtual Machine

### Standard Options

```shell-session
$ qemu-system-x86_64 \
    --enable-kvm \
    -cpu host \
    -m 512M \
    -smp cpus=2 \
    ...
```

1. `--enable-kvm`: Run the virtual machine using KVM.
2. `-cpu host`: Virtualize the host cpu for the guest.
3. `-m 512M`: Provide 512M of memory to the guest.
4. `-smp cpus=2`: Expose two CPU cores to the guest.

### Boot Media

The options below can be used in any sensible combination (as long as SeaBIOS
will be able to locate a bootable kernel, and the kernel can locate an init).

```shell-session
$ qemu-system-x86_64 \
    -kernel bzImage \
    -initrd initrd.cpio.gz \
    -drive format=raw,media=cdrom,file=archlinux.iso \
    -drive format=raw,media=disk,file=installed-image.img \
    ...
```

1. `-kernel bzImage`: Boot the kernel contained in the file `./bzImage`. This
   option can be used to boot compressed or uncompressed kernel images.
2. `-initrd initrd.cpio.gz`: Copy the file `./initrd.cpio.gz` to RAM, and boot
   the kernel with this as its initial ramdisk.
3. `-drive format=raw,media=cdrom,file=archlinux.iso`: Connect a CDROM slot to
   the guest, and use the file `./archlinux.iso` as the image on the CDROM.
4. `-drive format=raw,media=disk,file=installed-image.img`: Connect a SCSI disk
   to the guest, and use the file `./installed-image.img` as the backend.
   Presumably, this file would be a disk image that contains a full filesystem.

### Running on the Local Machine (Without VGA Display)

The following command will create the virtual machine under KVM, booting a
bzImage and utilizing a cpio archive as an initial ramdisk. Additionally, the
virtual VGA card is not utilized, and output devices are redirected to a local
Unix socket.

```shell-session
$ qemu-system-x86_64 \
    --enable-kvm \
    -cpu host \
    -m 512M \
    -smp cpus=2 \
    -monitor stdio \
    -chardev socket,id=serial0,path=${CONSOLE_SOCKET},server=on \
    -serial chardev:serial0 \
    -nographic \
    -vga none \
    -kernel bzImage \
    -initrd qemu-debug-minimal-qemu-x86_64.cpio.gz \
    -append 'console=ttyS0,115200n8'
```

The options to redirect display devices are described below:

1. `-monitor stdio`: Connect the QEMU monitor to stdin and stdout.
2. `-chardev socket,id=serial0,path=${CONSOLE_SOCKET},server=on`:
   Create a character device on the VM that is connected to a UNIX socket at
   the path `${XDG_RUNTIME_DIR}/kvm-console.sock`. This will be a server
   socket, and QEMU will block until a connection on this socket is made. I
   usually have `CONSOLE_SOCKET=${XDG_RUNTIME_DIR}/kvm-console.sock`.
3. `-serial chardev:serial0`: Create a serial device (which will be enumerated
   under Linux as `/dev/ttyS0` and connect it to the chardev with id `serial0`,
   created above.)
4. `-nographic`: Do not connect a VGA device to the quest.
5. `-vga none`: Don't connect a virtual VGA card to the guest.
6. `-append 'console=ttyS0,115200n8`: Append these arguments to the kernel
   command line. This will, of course, put kmsg output on `/dev/ttyS0`. In
   order to actually get a terminal on this serial port, the rootfs will need
   to be configured to start a `getty` instance on this serial port. In Yocto,
   this is done using the `SERIAL_CONSOLES` variable in your machine
   configuration.

### Running on a Remote Machine (Without VGA Display)

```shell-session
$ qemu-system-x86_64 \
    -monitor stdio \
    -chardev socket,id=serial0,host=0.0.0.0,port=3080,server=on \
    -serial chardev:serial0 \
    -nographic \
    -vga none \
    -device isa-applesmc,osk="$OSK" \
    -kernel bzImage \
    -initrd qemu-debug-minimal-qemu-x86_64.cpio.gz \
    -append console=ttyS0,115200
```

These options are mostly the same as in the previous section, so only the
differences are displayed:

1. `-chardev socket,id=serial0,host=0.0.0.0,port=3080,server=on`: Connect the
   console `/dev/ttyS0` to a TCP socket on the host, which is listening for
   connections on IPv4 address 0.0.0.0 and port 3080.

## Client Connections

### Proxying the TCP Connection to a Unix Socket

This can be done using `socat(1)`:

```shell-session
$ socat tcp:192.168.1.60:3080 unix-l:${CONSOLE_SOCK}
```

This will connect a TCP socket with an endpoint to IPv4 address 192.168.1.60
and port 3080 to a Unix socket with the path `${CONSOLE_SOCK}`. As soon as
the connection is made, QEMU will start the guest, so it's advised to have
already started `minicom(1)` on the Unix socket. The connection topography that
this creates is:

```
QEMU <-> TCP Socket <-> socat(1) <-> Unix Socket <-> minicom(1)
```

### Connecting minicom to the Unix socket

Install the `minirc-qemu` package from [my pacman repository][1]. This file
should contain the following:

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
