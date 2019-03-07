# MiniDAQ-config
This repository provides a detailed description on how to configure a MiniDAQ
server from scratch.

## MiniDAQ-related packages
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
