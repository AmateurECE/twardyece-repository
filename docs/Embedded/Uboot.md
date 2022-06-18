# Working with U-boot

## RNDIS Setup

RNDIS allows U-boot to perform network operations over a USB link to a USB
host, which is especially handy for TFTP-booting when the board doesn't have
an Ethernet connection.

U-boot will only hold the RNDIS interface up for as long as network operations
are being performed. So, when we run the `ping` command:

```
=> ping 192.168.5.1
using musb-hdrc, OUT ep1out IN ep1in STATUS ep2in
MAC <redacted>
HOST MAC <redacted>
RNDIS ready
high speed config #2: 2 mA, Ethernet Gadget, using RNDIS
USB RNDIS network up!
Using usb_ether device
host 192.168.5.1 is alive
=> # Command finishes, so the RNDIS link goes down again.
```

### Device Side

!!! todo "Add CONFIG_'s to set for RNDIS"

RNDIS on U-boot depends on built-in configuration to be present. Of course,
RNDIS is a USB protocol for setting up layer-2 (data link layer) networks in
a point-to-point fashion.

```bash
# Direct U-boot to setup an RNDIS interface for network operations
=> env set ethprime usb_ether

# When the U-boot USB stack is negotiating the link with the USB host, U-boot
# will direct the USB host to use this address as a MAC address for the
# interface
=> env set usbnet_hostaddr <Host MAC Address>

# Note that usbnet_devaddr must be set as well, but may already be set in the
# default environment.
=> env print usbnet_devaddr

# Finally, configure our own IP address and gateway IP.
=> env set ipaddr 192.168.5.2
=> env set gatewayip 192.168.5.1
```

### Host Side

Setup on the host side, of course, depends on whether we're on Windows or
Linux, and what distribution.

When the link goes up for the first time, `udev` will assign an interface name,
such as `enp0s20u2c2` or `enx<mac_address>`. It's difficult to predict the
interface name, but it will be the same whenever the device is hot-plugged.

The easiest way to discover the name is to run `ping <any_ipv4_address>` on the
target, which will negotiate the RNDIS link. While this command is waiting to
timeout, one could run `ip addr show` on the host side to determine the
interface name.

A little manual configuration is necessary in order to set up an IP address.
For Debian, the setup is obvious--add a file in `/etc/network/interfaces.d`.
For systems with NetworkManager, the following command should suffice:

```
# nmcli con add type ethernet ifname enp0s20u2c2 ip4 192.168.5.1/24
```

Any IP address will do as long as it's the *same* address configured as the
`${gatewayip}` in U-boot, and the name specified to `ifname` must be the same
interface name discovered in the previous step. This must also be done while
the RNDIS link is *down*. This command will assign the IP address provided to
the interface, and must be set as the value of `${serverip}` in U-boot in order
for TFTP, etc. to work.

The `ping` command should now work.

## TFTP

### Device Side

!!! todo "Obtain configuration necessary to compile TFTP support into U-boot"

If the network configuration is setup correctly on both the host and device
side, e.g. `ping ${serverip}` works, TFTP configuration is simple:

```
# Setup the TFTP server IPv4 address
=> env set serverip <server_ip_address>
```

Usage of the `tftp` command changes between major releases of U-boot, so
ensure to check `help tftp`.

### Host Side

I find it easy to spin up an OCI container to serve files over TFTP. The
following docker-compose.yaml file will work to serve the contents of the
`./tftp` directory:

```
version: '2.4'
services:
  tftp:
    image: taskinen/tftp
    ports:
      - "69:69/udp"
    volumes:
      - "./tftp:/var/tftpboot:ro"
```
