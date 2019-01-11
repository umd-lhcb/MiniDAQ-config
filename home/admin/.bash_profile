# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

# User specific environment and startup programs
export PATH=$PATH:$HOME/.local/bin:$HOME/bin
export DIM_DNS_NODE=localhost

# For MiniDAQ
jtagd
GbtServ
