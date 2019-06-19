---
title: linux os
date: 2019-06-15
---
# Check os Version

    cat /etc/os-release
    lsb_release -a
    hostnamectl

# vim

    apt-get update
    apt-get install vim

# dpkg

    $ dpkg -s libssl1.0.0
    Version: 1.0.1e-2+deb7u12
    Depends: libc6 (>= 2.7), zlib1g (>= 1:1.1.4), debconf (>= 0.5) | debconf-2.0

    $ dpkg -l | grep libc6
    ii  libc6:i386          