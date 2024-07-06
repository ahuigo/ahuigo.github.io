---
layout: post
title: ops-init
category: blog
description: 
date: 2018-09-27
---
# Preface

# init

## init
init指linux 系统运行级runlevel 0~6. 可在/etc/inittab中指定:

	id:3:initdefault:

### rc.d
运行级对应的要启动的脚本目录rcN.d(其下的脚本链接到../init.d/):

	/etc/rc.d/rcN.d

rcN.d下的文件是按启动顺序的, 18比10大, 于是在10后启动; S代表start K 代表Kill

	S10network
	K15httpd
	S18sshd
	...

runlevel含义是基于rcN.d的, 不同的OS对于rcN.d的定义是不同的, 对于Red Hat系来说[runlevel](http://en.wikipedia.org/wiki/Runlevel):

	0	Halt(Shutdown)
	1	Single-user Mode
	2	Multi-user Mode
	3	Multi-user Mode with Networking
	4	Not used/User-definable	For special purposes.
	5	Start the system normally with appropriate display manager. ( with GUI )	Same as runlevel 3 + display manager.
	6	Reboot

### /etc/rc.d/{rc.local rc.sysinit}
在所有rcN.d初始化结束后会依次执行: rc.sysinit 、 rc.local、rc

> Mac OSX 应该用的是`/etc/rc.common`

## init.d
如果你执行以下命令, 你会发现:

	ll -id /etc/init.d /etc/rc.d/init.d #它们是硬链接

init.d里面放置的是运行级脚本, 脚本文件写法：vi /etc/init.d/BLAH

	#!/bin/sh
	# SAMPLE BASIC INIT SCRIPT
	#
	# Below is the chkconfig syntax for auto startup at different run levels
	# Note runlevel 2 3 and 5 are level, 69 is the Start order and 68 is the Stop order
	# Make sure these are unique by looking into /etc/rc.d/*
	# Also below is the description which is necessary.
	#
	# chkconfig: 235 69 68
	# description: Description of the Service
	#
	# Below is the source function library
	. /etc/init.d/functions

	if [ -f /etc/sysconfig/BLAH ]; then
	. /etc/sysconfig/BLAH
	fi

	# Below is the Script Goodness controlling the service
	case "$1" in
		start)
			echo -n "Start service BLAH"
			/usr/sbin/BLAH start
			;;
		stop)
			echo -n "Stop service BLAH"
			/usr/sbin/BLAH stop
			;;
		restart)
			echo -n "Restart service BLAH"
			/usr/sbin/BLAH restart
			;;
		*)
			echo "Usage: $0 {start|stop|restart}"
			exit 1 ;;
	esac

### init.d/functions
包括常用的函数: `daemon`, `__pids_pidof`

	daemon():
		Usage: daemon [+/-nicelevel] {program}
		daemon vsftpd
		启动service

	killproc():
		Usage: killproc [-p pidfile] [ -d delay] {program} [-signal]"

	# Output PIDs of matching processes, found using pidof
	__pids_pidof() {
	    pidof -c -o $$ -o $PPID -o %PPID -x "$1" || \
		pidof -c -o $$ -o $PPID -o %PPID -x "${1##*/}"
	}


## service
通过service 可以手动启动init.d下的服务脚本
在linux 中执行:

	service Name argv1 argv2 ...
	service sshd start

实际执行的是:

	/etc/init.d/Name argv1 argv2 ...
	/etc/init.d/sshd start

## chkconfig
chkconfig serviceName 与 service Name 不同，前者用于开机运行级(和init级相关，涉及/etc/rc.d/rcN.d). 而后者service Name 用于手动开启关闭某些服务(涉及/etc/init.d/). 不过它们的启动脚本都指向/etc/init.d/xxx (比如:

	# chkconfig --level 016 BLAH off (to turn off at run level 016)
	/etc/rc.d/rc[016].d/K68BLAH -> ../init.d/BLAH
	# chkconfig --level 235 BLAH on (to turn on at run level 235)
	/etc/rc.d/rc[235].d/S69BLAH -> ../init.d/BLAH

### 命令

	chkconfig --add name：增加一项新的服务。chkconfig确保每个运行级有一项启动(S)或者杀死(K)入口。如有缺少，则会从缺省的`init.d/`脚本自动建立, 比如(/etc/rc.d/rc3.d/S69BLAH -> ../init.d/BLAH)。
    chkconfig --del name：删除服务，并把相关符号连接从/etc/rc[0-6].d删除。
    chkconfig [--level levels] name <on|off|reset>：设置某一服务在指定的运行级是被启动，停止还是重置。on|off|reset 对应于运行级脚本中的start|stop|restart 方法

以ssh 为例子:

	#rpm -qa |grep ssh 检查是否装了SSH包
	# 没有的话yum install openssh-server
	chkconfig --list sshd 检查SSHD是否在本运行级别下设置为开机启动
	chkconfig --level 2345 sshd on  如果没设置启动就设置下.
	service sshd restart  重新启动
	netstat -antp |grep sshd  看是否启动了22端口.确认下.
	iptables -nL  看看是否放行了22口.
	setup---->防火墙设置   如果没放行就设置放行.

# 新一代服务管理
## systemd
linux 下的init(service/chkconfig) 这种系统服务管理器比较臃肿了，

1. 一是启动时间长。init进程是串行启动，只有前一个进程启动完，才会启动下一个进程。
2. 二是启动脚本复杂。init进程只是执行启动脚本，不管其他事情。脚本需要自己处理各种情况，这往往使得脚本变得很长。

e.g

    $ sudo /etc/init.d/apache2 start
    # 或者
    $ service apache2 start

而systemd是一种更加优秀的服务管理器。

# profile(login shell)
## login shell
/etc/profile 是启动初始化脚本(login shell 才会读), 它会执行以下脚本

	/etc/inputrc 输入键相关
	/etc/profile.d/ 子目录
	/etc/sysconfig/i18n 由/etc/profile.d/lang.sh呼叫

### ~/.bash_profile ~/.profile
这几个文件是次启动脚本(同样是login shell 才会读)，对于bash 来说，它会顺序遍历以下脚本并执行第一个：

	~/.bash_profile
	~/.bash_login
	~/.profile

## non-login(.bashrc .zshrc)
这两个文件是non-login 就会读：

	/etc/zshrc ~/.zshrc
	/etc/bashrc ~/.bashrc

默认的.bashrc 会调用/etc/bashrc:

	# ~/.bashrc
	if [-f /etc/bashrc ];then
		. /etc/bashrc
	fi

	# /etc/bashrc (/etc/zshrc 也如此)
	   . /etc/profile.d/*.sh;


.zshrc 与 .bashrc 在创建用户时，拷贝自/etc/skel

	 /etc/skel/.bashrc
	 /etc/skel/.zshrc

### *ctl
许多*ctl 实际是对一些服务的单独封装. 比如: apachectl 就是对httpd的独立封装

	vi `which apachectl`

在Mysql中mysql.service 也是对mysql_safe启动的单独封装

## sudo
sudo 会使用root用户:
2. 即不会使用login shell 定义的env: e.g. `~/.profile`
1. 也不会执行 non-login shell`~/.bashrc/.zshrc` 

sudo's -E and -i options.

    -E, --preserve-env
         preserve their existing environment variables
    -i, --login
        Run the shell specified by the target user's password database entry as a login shell.
        This means that login-specific resource files such as `.profile, .bash_profile or .login` will be read by the shell.

所以我们可以有几个选择：

    # use /root/.profile
    sudo -i bash -c 'echo $PATH'

    # or explicitly source .profile with:
    sudo sh -c '. ~/.profile; echo $PATH'

    # keep env
    sudo -E bash -c 'echo $PATH'

