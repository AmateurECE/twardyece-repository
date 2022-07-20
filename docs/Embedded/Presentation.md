# Presentation Content and Workflow

## Yocto Build

```shell-session
$ git clone https://github.com/AmateurECE/meta-edtwardy
$ git checkout -b presentation origin/presentation
```

!!! todo "kas file"

```shell-session
$ mkdir build/tmp/deploy/linux
$ cd build/tmp/deploy/linux
$ tar xvf ../beaglebone/core-image-minimal-beaglebone-*.rootfs.tar.xz
```

## SD Card Setup

!!! example "Discuss TFTP server setup on build server"

Program rootfs onto the board, so that we have something to boot from. Then,
we'll build our kernel externally and boot it using TFTP.

```shell-session
$ git clone https://github.com/AmateurECE/meta-edtwardy
$ cd meta-edtwardy/tools/
$ curl tftp://192.168.1.60/beaglebone/core-image-minimal-beaglebone.wic.xz
$ xz -d core-image-minimal-beaglebone.wic.xz
$ sudo umount /dev/sdb{1,2}
$ sudo ./FlashSd.sh core-image-minimal-beaglebone.wic /dev/sdb
```

Need to finagle the SD card image a little. The image we created will want to
boot a kernel from the SD card. We need to fool the kernel into using the SD
card as the root fs, but also create a boot partition that U-boot can save its
environment to. To do this, we use `fdisk`:

* Unmount `/dev/sdb{1,2}`
* Run `fdisk /dev/sdb`
* Print the partition table and save the disk identifier, we need it later.
* Delete partition 1
* Create a new partition of type `Linux filesystem`
* Toggle the bootable flag for partition 1
* Write the partition table

Create a new ext4 filesystem on the SD card, then create `/boot` for U-boot to
write the environment file into:

```shell-session
# mkfs.ext4 -O ^metadata_csum /dev/sdb1
# mkdir /mnt/SD
# mount /dev/sdb1 /mnt/SD
# mkdir /mnt/SD/boot
# touch /mnt/SD/boot/uboot.env
```

## RNDIS Setup

Device side:

```bash
=> env set ethprime usb_ether

=> env print usbnet_devaddr

# Copy the MAC address and increment to set usbnet_hostaddr
=> env set usbnet_hostaddr <MAC Address>

=> env set ipaddr 192.168.5.2

=> env set gatewayip 192.168.5.1
```

Host side:

```shell-session
$ sudo dmesg -W
```

Device side:

```bash
=> ping 192.168.5.1
```

Host side:

```shell-session
$ sudo nmcli con add type ethernet ifname <ifname> ip4 192.168.5.1/24
```

## Netboot Setup

Problem: Now the device can talk to my MacBook, but it can't talk to the TFTP
server.

```shell-session
# sysctl net.ipv4.ip_forward=1
# modprobe nf_nat_tftp
# nft -f ./nat-route.nft
```

```bash
=> ping 192.168.1.60
```

Set `serverip`, so the U-boot `tftp` command knows where to connect to

```bash
=> env set serverip 192.168.1.60
```

Configure U-boot to download images and boot them:

```bash
# Tell U-boot where and how to download the kernel/initramfs/fdt image
=> env set get_linux 'tftp ${loadaddr} linux/zImage'
=> env set get_fdt 'tftp ${fdtaddr} linux/am335x-boneblack.dtb'
=> env set bootcmd 'run get_linux; run get_fdt; bootz ${loadaddr} - ${fdtaddr}'

# Tell kernel via cmdline to send kernel ring buffer to /dev/ttyS0
=> env set bootargs 'console=ttyS0,115200 rootwait root=PARTUUID=<disk>-02'

=> env save
```

## Setup for NFS Boot

On Arch Linux, depends on package `nfs-utils`.

The caveat here is that this creates a _new, distinct_ Ethernet interface when
it boots, which needs to be uniquely configured on the host.

```
/export/rootfs	192.168.5.2(rw,no_root_squash,no_subtree_check) 127.0.0.1(rw,no_root_squash,no_subtree_check)
```

```bash
=> env set bootargs console=ttyS0,115200 root=/dev/nfs rw ip=192.168.5.2::192.168.5.1:::usb0 g_ether.dev_addr=<MAC Address> g_ether.host_addr=<MAC Address> nfsroot=192.168.5.1:/export/rootfs,nfsvers=3,tcp
```

## Setup for Kernel Development

!!! example "Discuss: differences between staging kernel and mainline kernel"

    Default metadata uses `linux-ti-staging` kernel, which is Texas
    Instrument's fork of the kernel--it's their "stable" staging tree for
    tracking development and bug fixes in platform drivers and
    platform-specific code. We want to use `linux-stable`, because we can't
    trust TI to keep their staging tree up-to-date with mainline.

```shell-session
$ git clone https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable
$ cd linux/
$ git checkout -b wii-nunchuk origin/linux-rolling-stable
```

!!! example "Discuss: Discovering `omap2plus_defconfig`"

```shell-session
$ export ARCH=arm
$ export CROSS_COMPILE=arm-linux-gnueabi-
$ export O=/home/edtwardy/Git/Yocto/build/tmp/deploy/images/linux
$ export INSTALL_MOD_PATH=${O}
$ make omap2plus_defconfig
$ make menuconfig
```

Every time a change is made:

```shell-session
$ make -j8 modules
$ make modules_install
$ make -j8
```

!!! example "Discuss: Linux subsystems"

    Begin with a list of them:
    ```shell-session
    ls drivers/
    ```
    For our example, we want to hook into the Linux `input` subsystem, so this
    would go under `drivers/input`, specifically `drivers/input/joystick`.

```shell-session
$ git touch drivers/input/joystick/nunchuk.c
```

## C Driver

```c
// SPDX-License-Identifier: GPL-2.0

#include <linux/delay.h>
#include <linux/i2c.h>
#include <linux/init.h>
#include <linux/input.h>
#include <linux/module.h>

// Per device structure
struct nunchuk_dev {
    struct i2c_client *i2c_client;
};

static int nunchuk_probe(struct i2c_client *client)
{
    return -ENOSYS;
}

static int nunchuk_remove(struct i2c_client *client)
{
}

// Specification of supported Device Tree devices
static const struct of_device_id nunchuk_dt_match[] = {
    { .compatible = "nintendo,nunchuk-white" },
    { },
};
MODULE_DEVICE_TABLE(of, nunchuk_dt_match);

// Driver declaration
static struct i2c_driver nunchuk_driver = {
    .driver = {
        .name = "nunchuk",
        .of_match_table = nunchuk_dt_match,
    },
    .probe_new = nunchuk_probe,
    .remove = nunchuk_remove,
};
module_i2c_driver(nunchuk_driver);

MODULE_LICENSE("GPLv2");
MODULE_AUTHOR("Ethan D. Twardy <ethan.twardy@plexus.com>");
MODULE_DESCRIPTION("Driver for the Nintendo Wii Nunchuk controller");
```

!!! example "Now would be a good time to talk about `Kbuild`"

Plug new driver into `Kconfig`:

```dpatch
diff --git a/drivers/input/joystick/Kconfig b/drivers/input/joystick/Kconfig
index 3b23078bc7b5..10ec19d62300 100644
--- a/drivers/input/joystick/Kconfig
+++ b/drivers/input/joystick/Kconfig
@@ -399,4 +399,11 @@ config JOYSTICK_N64
 	  Say Y here if you want enable support for the four
 	  built-in controller ports on the Nintendo 64 console.
 
+config JOYSTICK_WII_NUNCHUK
+	tristate "Driver for Nintendo Wii Nunchuk Controller"
+	depends on I2C
+	help
+	  This driver adds support for the Wii Nunchuk controller. It does not
+	  support hot-plug, but it does provide a device tree binding.
+
 endif
```

Plug new driver into `Makefile`:

```dpatch
diff --git a/drivers/input/joystick/Makefile b/drivers/input/joystick/Makefile
index 5174b8aba2dd..5b191766003d 100644
--- a/drivers/input/joystick/Makefile
+++ b/drivers/input/joystick/Makefile
@@ -39,3 +39,4 @@ obj-$(CONFIG_JOYSTICK_WARRIOR)		+= warrior.o
 obj-$(CONFIG_JOYSTICK_WALKERA0701)	+= walkera0701.o
 obj-$(CONFIG_JOYSTICK_XPAD)		+= xpad.o
 obj-$(CONFIG_JOYSTICK_ZHENHUA)		+= zhenhua.o
+obj-$(CONFIG_JOYSTICK_WII_NUNCHUK)	+= nunchuk.o
```

!!! example "Build check"

    ```shell-session
    $ cd ../../../../
    $ kas-container build meta-edtwardy/kas/beaglebone-kirkstone.yaml
    ```

Add device tree integration:

```devicetree
// SPDX-License-Identifier: GPL-2.0-only

#include "am335x-boneblack.dts"

&am33xx_pinmux {
        i2c1_pins: pinmux_i2c1_pins {
                pinctrl-single,pins = <
                    // I2C1 SCL
                    AM33XX_PADCONF(AM335X_PIN_SPI0_D1, PIN_INPUT_PULLUP, MUX_MODE2)
                    // I2C1 SDA
                    AM33XX_PADCONF(AM335X_PIN_SPI0_CS0, PIN_INPUT_PULLUP, MUX_MODE2)
                >;
        };
};

&i2c1 {
        status = "okay";
        clock-frequency = <100000>;
        pinctrl-0 = <&i2c1_pins>;
        pinctrl-names = "default";

        joystick@52 {
                compatible = "nintendo,nunchuk-white";
                reg = <0x52>;
        };
};
```

```dpatch
diff --git a/drivers/input/joystick/nunchuk.c b/drivers/input/joystick/nunchuk.c
index 4430fdee79a4..427e0eccb557 100644
--- a/drivers/input/joystick/nunchuk.c
+++ b/drivers/input/joystick/nunchuk.c
@@ -11,13 +11,71 @@ struct nunchuk_dev {
     struct i2c_client *i2c_client;
 };
 
+static int nunchuk_init(struct i2c_client* client) {
+    u8 buf[2] = {0};
+    int result = 0;
+
+    buf[0] = 0xf0;
+    buf[1] = 0x55;
+
+    result = i2c_master_send(client, buf, 2);
+    if (0 > result) {
+        dev_err(&client->dev, "i2c send failed (%d)\n", result);
+        return result;
+    }
+
+    udelay(1000);
+
+    buf[0] = 0xfb;
+    buf[1] = 0x00;
+
+    result = i2c_master_send(client, buf, 2);
+    if (0 > result) {
+        dev_err(&client->dev, "i2c send failed (%d)\n", result);
+        return result;
+    }
+
+    return 0;
+}
+
 static int nunchuk_probe(struct i2c_client *client)
 {
-    return -ENOSYS;
+    struct nunchuk_dev *nunchuk = NULL;
+    struct input_dev *input = NULL;
+    int result = 0;
+
+    // Allocate per device structure
+    nunchuk = devm_kzalloc(&client->dev, sizeof(*nunchuk), GFP_KERNEL);
+    if (IS_ERR(nunchuk)) {
+        return -ENOMEM;
+    }
+
+    // Initialize device
+    result = nunchuk_init(client);
+    if (0 > result) {
+        return result;
+    }
+
+    // Allocate input device
+    input = devm_input_allocate_device(&client->dev);
+    if (IS_ERR(input)) {
+        return -ENOMEM;
+    }
+
+    // Register the input device when everything is ready
+    result = input_register_device(input);
+    if (0 > result) {
+        dev_err(&client->dev, "Cannot register input device (%d)\n", result);
+        return result;
+    }
+
+    return 0;
 }
 
 static int nunchuk_remove(struct i2c_client *client)
 {
+    // Nothing to do!
+    return 0;
 }
 
 // Specification of supported Device Tree devices
```
