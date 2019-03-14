# MiniDAQ-config
This repository provides a prescription on how to configure a MiniDAQ server
from scratch.


## Install CentOS 7
We can download a CentOS 7 installation media from cern: [1].

Then write the ISO to a USB drive with the following command:
```
dd if=<path_to_iso> of=/dev/sdX
```
note that `sdX` is the root of the USB device node, not a partition like
`sdXN`.

**WARNING**: This will rewrite all data on the USB drive.

Follow the instructions on the graphical installer. For software repo, it is
recommended to use UMD mirror:
```
base: http://mirror.umd.edu/centos/7.6.1810/os/x86_64/
extra: http://mirror.umd.edu/centos/7.6.1810/extras/x86_64/
updates: http://mirror.umd.edu/centos/7.6.1810/updates/x86_64/
```

It is recommended to use LVM partitioning scheme, for it's easier to backup and
resize.

Create a user `admin`, and use the password sticked on the chasiss of the
MiniDAQ server.


[1]: http://linuxsoft.cern.ch/cern/centos/7/os/x86_64/images/boot.iso


## Copy configuration files
All configuration files are located in `config` of this project. Copy
`confg/etc` to `/etc`, and `config/home/admin` to `/home/admin`.

* Files under `config/etc` configures USB blaster (for MiniDAQ FPGA programming),
  network interface naming, screen resolution, and a minimal MiniDAQ
  configuration.

* Files under `config/home/admin` configures `$PATH`, and physical screen sharing.


## Remote access
SSH will be enabled by CentOS installer by default. To enable remote screen
sharing, install:
```
tigervnc (client)
tigervnc-server
tigervnc-server-minimal
```

Use `vncpasswd` to set an additional password for sharing physical screen. Then
the configuration file copied in the previous section should take care of the
rest.

To also share login screen, follow the RedHat instruction: [2].


[2]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-tigervnc


## Install MiniDAQ
From the `daq40/ecs` repos, we need to install the following packages:
```
gbtserv
lhcb-daq40-common
lhcb-daq40-doc
lhcb-daq40-jcop
lhcb-pcie40-driver
lhcb-pcie40-firmware
lhcb-pcie40-tools
lhcb-pcie40-tools-debuginfo
```

We also need to clone the `readout40-software/lli-rpms`, and install:
```
lhcb-pcie40lli
lhcb-pcie40lli-devices
```

The `readout40-software` repo can be cloned with the following link (CERN
credential required):
```
https://gitlab.cern.ch/lhcb-readout40/readout40-software.git
```

The MiniDAQ frontend control software is based on WinCC OA, a proprietary
industry control platform. The WinCC rpms are located in `rpm` folder. Install
all of them.

The license file, `shield.txt`, can be acquired from CERN. It should be put
inside the root directory of WinCC OA installation. For example:
```
/opt/WinCC_OA/3.15
```

Now we also need to make GBT server, `GbtServ`, autostart on boot:
```
# systemctl enable gbtserv
```


## Install DIM DNS
We need to install the following packages:
```
dim
dim-programs
```
Note that dim-programs only lives in the CERN repo, and it is crucial for the
`GbtServ`.

We need to make `dns` program that comes with `dim-programs` auto start on boot.

Also `dim-programs` doesn't provide a native `systemd` unit, it does provide a
traditional one: `dnsd` under `/etc/init.d`. This will be automatically mapped
by `systemd` as `dnsd.service`.

To make `dns` auto start, we just need to:
```
# systemctl enable dnsd
```
