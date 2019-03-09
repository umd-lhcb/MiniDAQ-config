# .profile

# Source global definitions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Screen sharing
x0vncserver -PasswordFile=.vnc/passwd -AlwaysShared=1 &
