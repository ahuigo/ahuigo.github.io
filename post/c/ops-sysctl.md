---
layout: page
title:
category: blog
description:
---
# Preface

sysctl 用于get/set kernel state

# hardware

	sysctl -a hw.ncpu
	sysctl -a hw

# ip
/etc/sysctl.conf 中关于ip 相关的配置如下

## ipv4

	sysctl net.ipv4.tcp_tw_reuse=1 # 表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭；
	sysctl net.ipv4.tcp_timestamps=1 # 开启对于TCP时间戳的支持,若该项设置为0，则下面一项设置 不起作用
	sysctl net.ipv4.tcp_tw_recycle=1 # 表示开启TCP连接中TIME-WAIT sockets的快速回收

## ipv6
关闭ipv6:

    net.ipv6.conf.all.disable_ipv6=1
    net.ipv6.conf.default.disable_ipv6=1
    net.ipv6.conf.lo.disable_ipv6=1

# start
修改/etc/sysctl.conf 文件，保存后使用`sysctl -p`生效

	sysctl -p
