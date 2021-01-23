---
title: linux os
date: 2019-06-15
---
# Check os Version

CISC 复杂指令集

    X86架构: intel/amd/via
        i386: 或称IA-32 
        amd64: AMD64 / Intel64

RISC 精简指令集主要有三种

    ARM
        arm, arm64
    SPARC(Oracle)
    Power PC(IBM)
    
## 查看CPU支持的指令集
    cat /proc/cpuinfo
    gcc -march=native -Q --help=target|grep march

查看CPU信息(硬件架构等)

    # lscpu
    # arch
    # uname -m
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