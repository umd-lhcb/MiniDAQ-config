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


## CentOS 7 package management cheat sheet
CentOS 7 uses `yum` as its preferred package manager.

To install package:
```
# yum install <package_name>
```

To search available package:
```
$ yum search <packge_name>
```

To search on installed packages:
```
$ yum list installed '<regexp_package_name>'
```

To list package content, it is recommended to install `yum-utils`, and do the
following:
```
$ repoquery -l <package_name>
```


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

Then the submodule can be pulled with the following command:
```
git submodule update --init lli-rpms
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


## Compile and install MiniDAQ kernel module
MiniDAQ requires a CERN-developed kernel module to function. We use `dkms` to
compile the module; `dkms` also makes sure that this module will be recompiled
automatically on each kernel update.

First, install:
```
# yum install dkms kernel-devel
```

Now tell `dkms` to manage, build, and install the MiniDAQ kernel module:
```
# dkms add -m lhcb-pcie40-driver -v <version>
# dkms build -m lhcb-pcie40-driver -v <version>
# dkms install -m lhcb-pcie40-driver -v <version>
```
the `<version>` should be the same as the installed `lhcb-pcie40-driver`
package.

Finally, enable `dkms` service so that this module will be automatically
recompiled on each kernel update:
```
# systemctl enable dkms
```


## Install MiniDAQ frontend control software
From the same `readout40-software` repo, pull the following submodules:
```
wincc-fwgbt
wincc-fwhw
wincc-fwminidaq
```
the `git` command can be found in [this section](#install-minidaq).

Now create a **new distributed project** from **WinCC OA Project Administrator**.

Download `fwInstallation` tool from: [3]. Then extract the component
installation tool to the created project, overriding any existing files.

In previous steps, we have installed `lhcb-daq40-jcop`. Use `repoquery` to
locate its files. Run the new project, find the installation tool under the
**JCOP framework** menu, and install the following components from the
`lhcb-daq40-jcop` package:
```
fwCore
fwDIM
fwConfigurationDB
```
then restart the project.

Use the same tool, install the following components from the `readout40-
software` submodules:
```
fwGbt
fwHW
```
restart project again, then install:
```
fwMiniDAQ
```


[3]: http://jcop.web.cern.ch/jcop-framework-component-installation-tool
