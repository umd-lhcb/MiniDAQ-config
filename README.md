# MiniDAQ-config
This repository provides a detailed description on how to configure a MiniDAQ
server from scratch.

## DIM DNS
### Installation
We need:
```
dim
dim-programs
```
Note that dim-programs only lives in the CERN repo, and it is crucial for the
`GbtServ`.

### Configuring DIM DNS
We need to make `dns` program that comes with `dim-programs` auto start on boot.

Also `dim-programs` doesn't provide a native `systemd` unit, it does provide a
traditional one: `dnsd` under `/etc/init.d`. This will be automatically mapped
by `systemd` as `dnsd.service`.

To make `dns` auto start, we just need to:
```
# systemctl enable dnsd
```
