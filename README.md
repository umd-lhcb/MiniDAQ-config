# MiniDAQ-config
This repository provides a description on how to configure a MiniDAQ server
from scratch.

## MiniDAQ packages
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

## DIM DNS packages
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
