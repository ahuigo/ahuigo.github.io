---
layout: page
title: net-netstat
category: blog
description: 
date: 2018-09-28
---
# Preface
- netstat
- ss 参数形式如netstat

# netstat
> http://billie66.github.io/TLCL/book/zh/chap17.html

netstat的输出结果可以分为两个部分：

1. 一个是Active Internet connections，称为有源TCP连接，其中"Recv-Q"和"Send-Q"指%0A的是接收队列和发送队列。这些数字一般都应该是0。如果不是则表示软件包正在队列中堆积。这种情况只能在非常少的情况见到。

2. 另一个是Active UNIX domain sockets，称为有源Unix域套接口(和网络套接字一样，但是只能用于本机通信，性能可以提高一倍)。
	1. Proto显示连接使用的协议,
	1. RefCnt表示连接到本套接口上的进程号,
	1. Types显示套接口的类型,
	1. State显示套接口当前的状态,
	1. Path表示连接到套接口的其它进程使用的路径名。

## format

	-n 以数学显示地址，而非地址符号(比如用127.0.0.1 代替localhost)
	-o, --timers
       Include information related to networking timers
	-v
	   Tell the user what is going on by being verbose.

### linux only

	-p 显示进程信息(PID/PNAME)
	-e 显示扩展信息，例如uid等(linux only)

## loop

	-c <seconds> 每隔一个固定时间，执行该netstat命令(linux only)

## filter

### listening
list `ESTABLISHED` and `CONNECTED` by default

	-a (all)
		Show both listening and non-listening sockets.

linux only:

	-l 仅列出有在 Listening (监听) 的服務状态(linux only)

mac only:

	 -l    Print full IPv6 address.
	 -W    In certain displays, avoid truncating addresses even if this causes some fields to overflow.

### protocol
linux only

	-t (tcp)仅显示tcp相关选项
	-u (udp)仅显示udp相关选项
	-x 仅显示UNIX相关选项

MAC only:

	-p protocol
	netstat -ap tcp | grep ridmi (8000端口)
	netstat -anp tcp | grep 8000
	lsof -i :8000

[维基TCP/UDP 端口](http://zh.wikipedia.org/zh-cn/TCP/UDP%E7%AB%AF%E5%8F%A3%E5%88%97%E8%A1%A8)

#### protocol statistics

	-s 按各个协议进行统计
	# netstat -s | grep -i listen
    383 SYNs to LISTEN sockets dropped

### route

	-r 显示路由信息，路由表
	-i 显示网络接口
	route (mac不支持用route 显示路由表)

mac only:

	-ib    show the number of bytes in and out(mac only)
	-iR     show link-layer reachability information for a given interface
	-id     show drop packets number

## port and process
find which process occupy specified port:
http://www.cyberciti.biz/faq/what-process-has-open-linux-port/

### windows
1. 找到port 对应的pid
    1. netstat -ano|findstr 8080
2. kill pid:
    1. 方法一：使用任务管理器杀死进程
        2. 打开任务管理器->查看->选择列->然后勾选PID选项，回到任务管理器上可以查看到对应的pid，然后结束进程
    2. 方法二：使用命令杀死进程
        1. 首先找到进程号对应的进程名称
            tasklist|findstr [进程号]；如：tasklist|findstr 3112
        2. 然后根据进程名称杀死进程
            taskkill /f /t /im [进程名称]；如：taskkill /f /t /im /javaw.exe

### netstat
1. netstat - a command-line tool that displays network connections, routing tables, and a number of network interface statistics.

	$ sudo netstat -tulpn |grep 8888 ;# tcp/udp/listen/pid/num
	tcp        0      0 10.13.130.47:8000           0.0.0.0:*                   LISTEN      10557/php
	$ ls -l /proc/10557/exe
	lrwxrwxrwx 1 hilojack hilojack 0 Jun  8 17:09 /proc/10557/exe -> /usr/bin/php

### fuser port/protocol
1. fuser - a command line tool to identify processes using files or sockets.

    # sudo fuser port/protocol
    # sudo fuser 80/tcp
    80/tcp:             3813
    # ls -l /proc/3813/exe
    lrwxrwxrwx 1 vivek vivek 0 2010-10-29 11:00 /proc/3813/exe -> /usr/bin/transmission

### /proc/
Task: Find Out Current Working Directory Of a Process

	$ ls -l /proc/3813/cwd
	lrwxrwxrwx 1 vivek vivek 0 2010-10-29 12:04 /proc/3813/cwd -> /home/vivek
	$ pwdx 3813
	lrwxrwxrwx 1 vivek vivek 0 2010-10-29 12:04 /proc/3813/cwd -> /home/vivek

# ss
> for linux
ss：套接口统计数据

    $ netstat -lntp
    $ ss -lntp
    ....
    $ ss -ln
    RecvQ SendQ LocalAddress:port

参数类似netstat:

	-l listening
	-a both listening and non-listening socket
	-n --number
	-p show process
	-t tcp
	-u udp