# MiniDAQ-config
This repository provides a prescription on how to configure a MiniDAQ server
from scratch.

Current software versions:
* Firmware: `firmware/lhcb_daq_firmware_readout40_pcie40v1_minidaq_forUT_Bologna+realsim_12+12links_unset_090620.sof`
* `gbtserv`: 6.2.11 (probably need ask experts to get latest `rpm` package).
* WinCC OA: 3.16.
* For all WinCC OA MiniDAQ components, use latest `git master` (as of Jun 12, 2020).


## Install CentOS 7
We can download a CentOS 7 installation media from cern: [1].

Then write the ISO to a USB drive with the following command:
```
# dd if=<path_to_iso> of=/dev/sdX
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

To remove packages and all its dependencies, it is recommended to add the
following line to `/etc/yum.conf`:
```
clean_requirements_on_remove=1
```

We can force `yum` to check if there's any unneeded packages:
```
# yum autoremove
```

To deal with `.rpmsave` and `rpmnew` files, install `rpmconf` and:
```
# rpmconf -a
```
Follow the instructions on-screen.


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

To also share login screen, follow the RedHat instruction (13.1.4): [2].


[2]: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-tigervnc


## Install MiniDAQ
From the `daq40` repos, we need to install the following packages:
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

We also need to install the following packages from `daq40lli` repos:
```
lhcb-pcie40lli
lhcb-pcie40lli-devices
```

The MiniDAQ frontend control software is based on WinCC OA, a proprietary
industry control platform. The WinCC rpms are located in `rpm` folder. Install
all of them (those rpms can only be obtained with special CERN permission).

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

Clone the following projects:
```
git clone https://gitlab.cern.ch/lhcb-readout40/software/wincc-fwgbt.git
git clone https://gitlab.cern.ch/lhcb-readout40/software/wincc-fwhw.git
git clone https://gitlab.cern.ch/lhcb-readout40/software/wincc-fwminidaq.git
```

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
fwFSMConfDB
fwTrending
```
then restart the project.

Use the same tool, install the following components from the projects we just
cloned:
```
fwGbt
fwHW
```
restart project again, then install:
```
fwMiniDAQ
```


[3]: http://jcop.web.cern.ch/jcop-framework-component-installation-tool
[4]: https://gitlab.cern.ch/lhcb-readout40


## On the placement of WinCC OA license file
One can obtain an one-year WinCC OA license from CERN by filling out a form.
The license file is named as `shield.txt`

The preferred location of the license is:
```
/opt/WinCC_OA/3.16
```
