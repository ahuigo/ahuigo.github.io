---
layout: page
title:	linux 下的各种日志
category: blog
description:
---
# Preface
linux 下有很多日志，有的是系统级的，有的是应用程序级的. 本文只总结系统级日志。
- dmesg 设备、驱动、系统启动、iptables 日志
- 连接时间相关日志（binary）: /var/log/wtmp, /var/run/utmp
	0. w/who/finger/id/last/lastlog/ac 都是通过分析以上日志得到信息的。

# 连接时间
与连接时间相关的日志文件有（binary）:
1. /var/log/wtmp
2. /var/run/utmp

w/who/finger/id/last/lastlog/ac 都是通过分析以上日志得到信息的。

	# who -- display who is logged in

	# w -- display who is logged in and what they are doing
	$ w
	18:24  up 1 day,  8:34, 1 user, load averages: 1.32 1.30 1.33
	USER     TTY      FROM              LOGIN@  IDLE WHAT
	hilojack console  -                Wed09   32:33 -

	# ac -- display connect-time accounting
	$ ac -p
	root         0.14
	hilojack  7514.36
	total     7514.50
	$ ac -d # display connect time in 24 hours chunk

# 进程监控日志
监控所有进程的操作

	# 开启进程统计日志监控 enable/disable system accounting
	$ accton /var/account/pacct

	#  lastcomm -- show last commands executed in reverse order
	$ lastcomm
	vim               S     root     pts/0      0.03 secs Thu Oct 30 18:34
	lastcomm                root     pts/0      0.00 secs Thu Oct 30 18:34

# syslog/rsyslog 系统服务日志
syslog 是一套记录系统服务日志的service。它主要记录以下日志：

1. /var/log/lastlog ：记录最后一次用户成功登陆的时间、登陆IP等信息
1. /var/log/messages ：记录Linux操作系统常见的系统和服务错误信息
1. /var/log/secure ：Linux系统安全日志，记录用户和工作组变坏情况、用户登陆认证情况
1. /var/log/btmp ：记录Linux登陆失败的用户、时间以及远程IP地址
1. /var/log/cron ：记录crond计划任务服务执行情况

syslog 主要有两种，rsyslog 和 syslog-ng( rsyslog is an alternative logger to syslog-ng and offers many benefits over syslog-ng.)

On mac osx: /var/log/system.log (man syslog)

## facility and priority
facility和priority对应本地syslog服务的”消息来源“（facility）和”紧急程度“（priority），下面会讲到，这两参数通过syslog的配置文件决定log写入到哪个文件中。

	$ cat /etc/syslog.conf
	local4.info            /var/log/test.log
	*.info　　　　　　　　　　/var/log/message
	auth,authpriv.*         /var/log/auth.log
	*.info;mail.none;authpriv.none;cron.none /var/log/messages

`*.info` 意味着info(7) 及info以上的(notie,warning,...) 都会被记录
`;mail.none` 带分号标识、以及`none` 意味着这些facility 都不会被记录

	none		-1
	LOG_EMERG   0   /* system is unusable */
	LOG_ALERT   1   /* action must be taken immediately */
	LOG_CRIT    2   /* critical conditions */
	LOG_ERR     3   /* error conditions */
	LOG_WARNING 4   /* warning conditions */
	LOG_NOTICE  5   /* normal but significant condition */
	LOG_INFO    6   /* informational */
	LOG_DEBUG   7   /* debug-level messages */

## php syslog
Php default syslog's facility is "user" (and cannot be changed)

Example:

	$facility = LOG_LOCAL4;
	openlog( $ident="ident-php", NULL,$facility);
	//openlog('php', LOG_CONS | LOG_NDELAY | LOG_PID, LOG_USER | LOG_PERROR);
	syslog($priority = LOG_ERR,'errors throw out by hilojack');
	syslog(LOG_INFO,'info throw out by hilojack');
	closelog();

如果`local4.* /var/log/messages`, 那么local4 来源的所有级别消息会出现在/var/log/messages.

	Mar 18 14:03:51 hilojack.air ident-php: errors throw out by hilojack
	Mar 18 14:03:51 hilojack.air ident-php: info throw out by hilojack

## php-fpm syslog:

	; Default Value: daemon
	;syslog.facility = daemon

	; Default Value: php-fpm
	;syslog.ident = php-fpm

facility=daemon 默认在`/var/log/messages`

	daemon.*	/var/log/messages

## start/stop syslog/rsyslog

	service rsyslog start
	chkconfig --level 2345 rsyslog on

	service syslog start
	chkconfig --level 2345 syslog on

实际启动的是 /sbin/syslogd 这个守护进程

## syslog 配置
它的配置文件默认是:
1. /etc/syslog.conf 或者 /etc/rsyslog.conf (for rsyslog)
2. /etc/sysconfig/syslog # (for old syslogd)

打开这个rsyslog.conf 可以看到其中主要有以下几个部分：

	### MODULES ####
	$ModLoad imuxsock # provides support for local system logging (e.g. via logger command)

	#### GLOBAL DIRECTIVES ####
	# Use default timestamp format
	$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

	#### RULES ####
	# Log all kernel messages to the console.
	# Logging much else clutters up the screen.
	#kern.*                                                 /dev/console

	# Log anything (except mail) of level info or higher.
	# Don't log private authentication messages!
	*.info;mail.none;authpriv.none;cron.none                /var/log/messages

	# The authpriv file has restricted access.
	authpriv.*                                              /var/log/secure

	# Log all the mail messages in one place.
	mail.*                                                  -/var/log/maillog


	# Log cron stuff
	cron.*                                                  /var/log/cron

	# Everybody gets emergency messages
	*.emerg                                                 *

	# Save news errors of level crit and higher in a special file.
	uucp,news.crit                                          /var/log/spooler

	# Save boot messages also to boot.log
	local7.*                                                /var/log/boot.log

你需要经常修改的就是Rules了

### syslog rules
syslog rules 语法为

	msg_type.err_type action

msg_type 包括: auth,authpriv,security;cron,daemon,kern,lpr,mail, mark,news,syslog,user,uucp,local0~local7.
err_type 包括: debug,info,notice,warning|warn;err|error;crit,alert,emerg|panic
action 包括: file,user,console,@remote_ip

例子：

	*.info;mail.none;authpriv.none;cron.none /var/log/messages
　　表示info级别的任何消息都发送到/var/log/messages日志文件，但邮件系统、验证系统和计划任务的错误级别信息就除外，不发送（none表示禁止）
　　cron.* /var/log/cron 表示所有级别的cron信息发到/var/log/cron文件
　　*.emerg * 表示emerg错误级别（危险状态）的所有消息类型发给所有用户

# logrotate 日志转存服务
当系统日志积累的太多，就需要将日志转移出去了，这个时候就需要使用logrotate 了。logrotate 的配置文件在/etc/logrotate.conf

logrotate是基于CRON来运行的，其脚本是「/etc/cron.daily/logrotate」：

	#!/bin/sh

	/usr/sbin/logrotate /etc/logrotate.conf
	EXITVALUE=$?
	if [ $EXITVALUE != 0 ]; then
		/usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
	fi
	exit 0

实际运行时，Logrotate会调用配置文件「/etc/logrotate.conf」：

	# see "man logrotate" for details
	# rotate log files weekly
	weekly

	# keep 4 weeks worth of backlogs
	rotate 4

	# create new (empty) log files after rotating old ones
	create

	# uncomment this if you want your log files compressed
	#compress

	# RPM packages drop log rotation information into this directory
	include /etc/logrotate.d

	# no packages own wtmp -- we'll rotate them here
	/var/log/wtmp {
	    monthly
	    minsize 1M
	    create 0664 root utmp
	    rotate 1
	}

	# system-specific logs may be also be configured here.

### 例子
转存一周的nginx 日志压缩文件，/etc/logrotate/nginx

	/usr/local/nginx/logs/*.log {
		daily
		dateext
		compress
		rotate 7
		sharedscripts # 如果没有这一行，则每转存一个log 就会执行以下命令。有这一行，就会在转存完所有的log 后统一执行以下命令
		postrotate
			kill -USR1 `cat /var/run/nginx.pid`
		endscript
	}

为/var/log/httpd/access.log和/var/log/httpd/error.log日志设置转储参数。转储5次，转储时发送邮件给root@localhost用户，当日志文件达到100KB时才转储，转储后重启httpd 服务，那么可以直接在/etc/logrotate.conf文件的最后添加如下：

　　/var/log/httpd/access.log /var/log/http/error.log{
	　　rotate 5
	　　mail root@localhost
	　　size=100k
	　　sharedscripts
		　　/sbin/killall -HUP httpd
	　　endscript
　　}

如果你等不及CRON，可以通过如下命令来手动执行：

	$ logrotate -f /etc/logrotate.d/nginx

当然，正式执行前最好通过Debug选项来验证一下，这对调试也很重要：

	$ logrotate -d -f /etc/logrotate.d/nginx


问题：如何告诉应用程序重新打开日志文件？

以Nginx为例，是通过postrotate指令发送USR1信号来通知Nginx重新打开日志文件的。但是其他的应用程序不一定遵循这样的约定，比如说MySQL是通过flush-logs来重新打开日志文件的。更有甚者，有些应用程序就压根没有提供类似的方法，此时如果想重新打开日志文件，就必须重启服务，但为了高可用性，这往往不能接受。还好Logrotate提供了一个名为copytruncate的指令，此方法采用的是先拷贝再清空的方式，整个过程中日志文件的操作句柄没有发生改变，所以不需要通知应用程序重新打开日志文件，但是需要注意的是，在拷贝和清空之间有一个时间差，所以可能会丢失部分日志数据。


# 参考
- [那些linux 日志]
- [logrotate]

[那些linux 日志]: http://www.itokit.com/2012/0602/74289.html
[logrotate]: http://huoding.com/2013/04/21/246
