---
title: linux os
date: 2019-06-15
---
# os
获取os 信息脚本: a/tool/os/os-info.py

## Check OS Version
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
    shared：被多个进程共享的内存量。
    buff/cache：被系统用作缓存和缓冲区的内存量。(如读取fs缓存)这部分内存可以被重新分配给应用程序使用，所以在某种程度上，它也可以被视为可用内存。

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
## display card

$ lspci -v | less
$ lspci -v | grep -i vga

# network
## mac address
    cat /sys/class/net/eno1/address