# MiniDAQ-config
This repository provides a description on how to configure a MiniDAQ server
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


[1]: http://linuxsoft.cern.ch/cern/centos/7/os/x86_64/images/boot.iso


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
