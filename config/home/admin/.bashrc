# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source DIM env variables
if [ -f /etc/sysconfig/dim ]; then
    . /etc/sysconfig/dim
fi

# Quartus related
export QUARTUSPATH=$HOME/opt/intelFPGA_lite/18.1
export PATH=$PATH:${QUARTUSPATH}/quartus/bin
export PATH=$PATH:${QUARTUSPATH}/nios2eds/bin
