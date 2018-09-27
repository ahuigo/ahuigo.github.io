---
layout: page
title: ops-supervisor
category: blog
description: 
date: 2018-09-27
---
# Preface
Supervisor 是一个超级简单的监控-重启命令
1. monitor 监控程序, 当其它程序发生错误时，自动重启
2. control a number of processes on UNIX-like operating systems.

# conf
	```
	$ cat /etc/supervisord.conf
	[include]
	files = supervisord.d/*.conf supervisord.d/*/*.conf

	$ cat /etc/supervisord.d/fetch_weibo.conf
	[program:fetch_weibo]
	command=/usr/local/bin/php fetch_weibo.php
	user=hilo
	directory=/home/hilo
	autostart=true
	startsecs=10
	autorestart=true
	startretries=100

	redirect_stderr         = true
	stdout_logfile_maxbytes = 50MB
	stdout_logfile_backups  = 10
	stdout_logfile          = /srv/awesome/log/app.log
	```

# 启动supervisor

	$ supervisord -c supervisord.conf
	$ systemctl start supervisord

	$ supervisord -c supervisord.conf reload
	$ systemctl reload supervisord

# 使用supervisorctl管理程序

	1）开启/停止某个程序
	 supervisorctl [start | stop | restart] [program名称]      //在supervisord.conf中定义的
	 supervisorctl start fetch_weibo

	2）查看进程状态
	supervisorctl status

# service 系统服务
/etc/init.d/supervisord

	#!/bin/sh
	# Source init functions
	. /etc/rc.d/init.d/functions

	prog="supervisord"

	prog_bin="/usr/local/bin/supervisord"
	PIDFILE="/tmp/supervisord.pid"

	start()
	{
	        echo -n $"Starting $prog: "

	# Source init functions
	. /etc/rc.d/init.d/functions

	prog="supervisord"

	prog_bin="/usr/local/bin/supervisord"
	PIDFILE="/tmp/supervisord.pid"
	start() {
	        echo -n $"Starting $prog: "
	        daemon $prog_bin --pidfile $PIDFILE
	        [ -f $PIDFILE ] && success $"$prog startup" || failure $"$prog startup"
	        echo
	}

	stop() {
	        echo -n $"Shutting down $prog: "
	        [ -f $PIDFILE ] && killproc $prog || success $"$prog shutdown"
	        echo
	}

	case "$1" in
	  start)
	    start
	  ;;
	  stop)
	    stop
	  ;;
	  status)
	        status $prog
	  ;;
	  restart)
	    stop
	    start
	  ;;
	  *)
	    echo "Usage: $0 {start|stop|restart|status}"
	  ;;

	esac

添加为系统服务

	mv supervisord.sh  /etc/init.d/supervisord
	chkconfig --add  supervisord
	chkconfig --level 345 supervisord on

start & stop:

	service supervisord [start | stop]