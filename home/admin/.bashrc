# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
export DIM_DNS_NODE=localhost

# Quartus related
export QUARTUSPATH=$HOME/opt/intelFPGA_lite/18.1
export PATH=$PATH:${QUARTUSPATH}/quartus/bin
export PATH=$PATH:${QUARTUSPATH}/nios2eds/bin
