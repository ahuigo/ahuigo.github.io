---
title: linux os
date: 2019-06-15
---
# Check os Version
## os
check os:

    lsb_release -a
    cat /etc/os-release

## 查看CPU支持的指令集
    cat /proc/cpuinfo
    gcc -march=native -Q --help=target|grep march

查看CPU信息(硬件架构等)

    # lscpu
    # arch
    # uname -m
    hostnamectl

    $ cat /proc/cpuinfo | grep MHz
    cpu MHz		: 2127.998

### simple cpu
核数

### CISC 复杂指令集

    X86架构: intel/amd/via
        i386: 或称IA-32 
        amd64: AMD64 / Intel64

RISC 精简指令集主要有三种

    ARM
        arm, arm64
    SPARC(Oracle)
    Power PC(IBM)
    
## memory
    free -h

## disk
You should get 1 for hard disks and 0 for a SSD

    cat /sys/block/sda/queue/rotational
    sudo fdisk -l /dev/sda

### mount partition
First find partition's uuid

    lsblk -o NAME,FSTYPE,UUID
    # or
    sudo blkid

then:

    sudo cp /etc/fstab /etc/fstab.old

sudo vim /etc/fstab 

    UUID=<uuid> /         ext4 umask=0077 0 1
    UUID=<uuid> /mnt/sda3 ext4 defaults 0 0
    UUID=<uuid> /mnt/sda4 ntfs uid=1000,gid=1000,umask=0022,sync,auto,rw 0 0

参考 https://help.ubuntu.com/community/Fstab or `man fstab`

    [Device] [Mount Point] [File System Type] [Options] [Dump] [Pass]
    <options>
        Mount options of access to the device/partition (see the man page for mount).
    <dump>
        Enable or disable backing up of the device/partition (the command dump). This field is usually set to 0, which disables it.
    <pass num>
        Controls the order in which fsck checks the device/partition for errors at boot time. The root device should be 1. Other partitions should be 2, or 0 to disable checking.





# dpkg
## find file which pckages contain

    $ dpkg -s libssl1.0.0
    Version: 1.0.1e-2+deb7u12
    Depends: libc6 (>= 2.7), zlib1g (>= 1:1.1.4), debconf (>= 0.5) | debconf-2.0

    $ dpkg -l | grep libc6
    ii  libc6:i386          

## list installed files
    dpkg-query -L <package_name>
    dpkg-deb -c <package_name.deb>