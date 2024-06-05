---
title: linux package
date: 2022-04-01
private: true
---
# dpkg
## find file which pckages contain

    $ dpkg -s libssl1.0.0
    Version: 1.0.1e-2+deb7u12
    Depends: libc6 (>= 2.7), zlib1g (>= 1:1.1.4), debconf (>= 0.5) | debconf-2.0

    $ dpkg -l | grep libc6
    ii  libc6:i386          

## list installed package files
    dpkg-query -L <package_name>
    dpkg-deb -c <package_name.deb>

    apt-get install docker
    dpkg-query -L docker