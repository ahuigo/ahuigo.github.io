---
layout: page
title: ops-sysctl
category: blog
description: 
date: 2018-09-27
---
# sysctl

sysctl 用于get/set kernel state

# list

	sysctl -a
## hardware

	sysctl -a hw.ncpu
	sysctl -a hw

# ip 配置
/etc/sysctl.conf 中关于ip 相关的配置如下

## ipv4

    # linux
	sysctl net.ipv4.tcp_tw_reuse=1 # 表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭；
	sysctl net.ipv4.tcp_timestamps=1 # 开启对于TCP时间戳的支持,若该项设置为0，则下面一项设置 不起作用
	sysctl net.ipv4.tcp_tw_recycle=1 # 表示开启TCP连接中TIME-WAIT sockets的快速回收
    sysctl net.ipv4.tcp_syncookies=0 # 半连接队列满了就丢弃syn

## ipv6
关闭ipv6:

    net.ipv6.conf.all.disable_ipv6=1
    net.ipv6.conf.default.disable_ipv6=1
    net.ipv6.conf.lo.disable_ipv6=1

## syncookie
    # sysctl -n net.ipv4.tcp_syncookies
    OR
    # cat /proc/sys/net/ipv4/tcp_syncookies

## backlog & somaxconn
Linux:

    net.ipv4.tcp_max_syn_backlog = 1024  # limit number of new connections
    net.core.netdev_max_backlog  = 1024
    net.core.somaxconn = 1024        # limit number of new connections

Mac OS X and FreeBSD:

    kern.ipc.somaxconn  = 1024   # limit number of new connections
    kern.ipc.maxsockets = 1024   # Initial number of sockets in memory

# 修改配置
## /etc/sysctl.conf
    vi /etc/sysctl.conf
    sysctl -p

## sysctl 

    # linux
    sysctl net.ipv4.tcp_syncookies=0 # 半连接队列满了就丢弃syn
    # mac
    sudo sysctl -w net.inet.ip.forwarding=0

# start
修改/etc/sysctl.conf 文件，保存后使用`sysctl -p`生效

	sysctl -p