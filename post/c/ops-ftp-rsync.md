---
layout: page
title:
category: blog
description:
---
# Preface

# rsync

## rsync client

	rsync option source[source2 ... sourceN] destination
	rsync -avz --timeout=10 --port= --delete ip::module/path dest_path
	rsync /etc /home /usr/local /media/BigDisk/backup

local file

	rsync -a mydir otherdir

host:

	rsync -a mydir host:/home/hilo/
	rsync -a mydir rsync://host:/home/hilo/
	rsync -a mydir rsync://host/home/hilo/

module:

	rsync -a mydir host::module/path

user:

	rsync -a mydir user@host
	rsync -a mydir rsync://user@host/path
	rsync -a user@host/home/hilo/ dir

### rsync params

	-a 参数，相当于-rlptgoD，
		-r 是递归
		-l 是链接文件，意思是拷贝链接文件；
		-p 表示保持文件原有权限；
		-t 保持文件原有时间；
		-g 保持文件原有用户组；
		-o 保持文件原有属主；
		-D 相当于块设备文件；
	-z 传输时压缩(gzip)；
	-P 传输进度；
	-u --update  skip files that are newer on the receiver
	-v 传输时的进度等信息，和-P有点关系
	-vvv v 越多，信息越多

不带选项

	rsync file server:/path/
		同步条件：只要文件不一到就同步
		rwx: 如果目的端没有文件，则创建新文件时rwx 与源端一致；否则rwx 不变
		modify time: 目的端的文件modify time 总是被更改为最新的

带`-p` *perserve permissions*:

	rsync -p file server:/path/
		rwx 会和源端操持一致(无论是新老文件)

带`-g` `-o`:

	rsync -go file server:/path/
		保持文件的属组(group)和属主（owner）需要管理员权限

带`-t`:

	rsync -t file server:/path/
		同步条件：只用文件大小或者modify time 时间戳不一致就同步. 它不会检查内容不一致, 除非加`-I`
		modify time: 目的端的文件modify time 与源端一致

带`-I` 确保数据一致:

	rsync -I file server:/path/
		同步条件：无条件的同步所有数据(很慢)
		modify time: 更新为当前时间

带`-l` 同步软件软链接内容(默认情况下，softfile 会被skip)

	rsync -l softfile server:/path/
	rsync -L softfile server:/path/ "同步软链接本身

带`-D` 保持设置原始信息（preserve devices(root only)）

### ssh rsync

	rsync -av --rsh=ssh src dst

### path rule
dir:

    #if rsync has no dirb, rsync will create dirb first
    dira dirb -> mv dira dirb/ # dirb/dira
    dira/ dirb -> mv dira/* dirb/

file:

    # file
    filea fileb -> mv filea fileb
    filea dirb -> mv filea dirb/fileb

### rsync delete
只查看同步文件，不执行。

	-n, --dry-run
		rsync -a --delete ip:/home/dir mydir --dry-run

其它:

	–delete-excluded：专门指定一些要在目的端删除的文件。
	–delete-after：默认情况下，rsync是先清理目的端的文件再开始数据同步；如果使用此选项，则rsync会先进行数据同步，都完成后再删除那些需要清理的文件。

### partial

	-–partial

这就是传说中的断点续传功能。默认情况下，rsync会删除那些传输中断的文件，然后重新传输。但在一些特别情况下，我们不希望重传，而是续传。

### rsync include
Just change your include pattern adding a trailing / at the end of include pattern and it'll work:

	rsync -avz --delete --include=specs/install/project1/ \
    --exclude=specs/* \
	--exclude=dir \
		/srv/http/projects/project/ user@server.com:~/projects/project

Or, in alternative, prepare a filter file like this:

	$ cat << EOF >pattern.txt
	> + specs/install/project1/
	> - specs/*
	> EOF

Then use the --filter option:

	rsync -avz --delete --filter=". pattern.txt" \
    /srv/http/projects/project/ \
    user@server.com:~/projects/project

For More: search RULES in man rsync

### rsync filter
PATTERN 是一个shell 通配符

	--exclude=e/f/ 不匹配子目录e/f/
	--exclude=e/f 不匹配子目录e/f/ 也不匹配子文件夹本身 e/f
	--exclude='e/f/*' 不匹配子目录e/f/ 下的所有文件

#### filter

	rsync -avn   --filter='- e/f' '--exclude=d/x/*'  a/ b

		exclude, - specifies an exclude pattern.
		include, + specifies an include pattern.
		merge, . specifies a merge-file to read for more rules.
		dir-merge, : specifies a per-directory merge-file.
		hide, H specifies a pattern for hiding files from the transfer.
		show, S files that match the pattern are not hidden.
		protect, P specifies a pattern for protecting files from deletion.
		risk, R files that match the pattern are not protected.
		clear, ! clears the current include/exclude list (takes no arg)

#### rsync exclude

	--exclude=PATTERN       exclude files matching PATTERN
	--exclude-from=FILE     read exclude patterns from FILE
	--include=PATTERN       don't exclude files matching PATTERN
	--include-from=FILE     read include patterns from FILE

如果你不希望同步一些东西到目的端的话，可以使用`-–exclude`选项来隐藏，rsync还是很重视大家隐私的，你可以多次使用`-–exclude`选项来设置很多的“隐私”。

	rsync -avz --exclude=/home/user1/dir /home/user2/;# 错误
	rsync -avz --exclude=dir /home/user2/;# 正确

如果你要隐藏的隐私太多的话，在命令行选项中设置会比较麻烦，rsync还是很体贴，它提供了–exclude-from选项，让你可以把隐私一一列在一个文件里，然后让rsync直接读取这个文件就好了。


# server rsync
有两种方法同步远程服务器的文件

1. 远程服务部署一个rsyncd 进程 监听同步请求
2. `--rsh=ssh` 选项，指示 rsync 使用 ssh 程序作为它的远程 shell。通过 ssh 加密通道，把数据 安全地传送到远程主机中

## config

	uid = nobody
	gid = nobody
	use chroot = yes
	max connections = 4
	syslog facility	= 指定rsync 向syslog 发送消息的级别
	syslog facility = local5
	pid file = /var/rsyncd.pid

	[ftp]
    hosts allow = 1.16.0.0/16 10.209.0.157
    hosts deny  = *
    path = /www/proj
    uid = ftp
    gid = ftp
    read only   = false
    list        = true
    pid file = /var/rsyncd.pid
    log file = /var/logs/rsyncd.pid
	lock file = /tmp/rsyncd/rsyncd.lock
	exclude = 与client 使用-exclude 相同
	include = 与client 使用-include 相同

start:

	rsync --daemon --config=/etc/rsyncd.conf --port=873

install:

	curl -s https://github.com/ahui132/php-lib/blob/master/app/rsync.sh | sh

### port
default port:873

### password

	auth users = root,hilojack # 必须为系统实体帐户，密码除外
	secrets file = /etc/rsync.secrets

	$ cat /etc/rsync.secrets
	hilojack:mypasswd
	$ chmod 600 /etc/rsync.secrets # 强制

client:

	$ cat .rsync.pwd
	mypasswd
	$  rsync -avz --password-file=/home/.rsync.pwd hilojack@host::module /home/

Also we can specify password via `export RSYNC_PASSWORD="password";`

	$ RSYNC_PASSWORD="password";  rsync -avz user@host/src dst

## debug
/var/log/messages
`rvn` dry-run

## rsync: failed to set times Operation not permitted (1)
sync on the destination end is not running as a user

	sudo chown user/root destination/

### error in socket
rsync error: error in socket IO

### selinux
将 selinux 对 rsync 的限制全部去掉：

	/usr/sbin/setsebool -P rsync_disable_trans 1

或者禁止整个 selinux ：

	sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# inotify
inotify是Linux核心子系统之一，做为文件系统的附加功能，它可监控文件系统并将异动通知应用程序。本系统的出现取代了旧有Linux核心里，拥有类似功能之dnotify模块。

inotify的原始开发者为John McCutchan、罗伯特·拉姆与Amy Griffis。于Linux核心2.6.13发布时(2005年六月十八日)，被正式纳入Linux核心[1]。尽管如此，它仍可通过补丁的方式与2.6.12甚至更早期的Linux核心集成。

inotify的主要应用于桌面搜索软件，像：Beagle，得以针对有变动的文件重新索引，而不必没有效率地每隔几分钟就要扫描整个文件系统。相较于主动轮询文件系统，通过操作系统主动告知文件异动的方式，让Beagle等软件甚至可以在文件更动后一秒内更新索引。

此外，诸如：更新目录查看、重新加载设置文件、追踪变更、备份、同步甚至上传...等许多自动化作业流程，都可因而受惠。

# 用tar 备份文件系统

## 增量备份
通过`-g` 指定一个用于记录上次(不是每次)备份日志的文件快照(第一次会自动创建)，实现已经备份过的文件不再备份，变动(atime 修改了或者新增)的文件才备份。

	# 增量备份
	tar -g /tmp/snapshot_data.snap -czpf backup.tgz --exclude=./cache dir/
	# 恢复
	tar -xzpf backup.tgz -C dir/

## exclude & include

	--exclude pattern<wildcard>
             Do not process *files* or *directories* that match the specified pattern.  Note that exclusions take precedence over patterns or filenames specified on the command line.
			 --exculde '*1/w*' match 'path/w1/w2', not match './w3/w4'
			 --exculde pattern1 --exclude pattern2

	--exclude-from file_exclude_rules
		$ cat rules.txt
		*.bak
		/cache
		.svn
		--exclude-from rules.txt


	--include pattern<wildcard>
             Process only files or directories that match the specified pattern.  Note that exclusions specified with --exclude take precedence over inclusions.  If no inclusions are
             explicitly specified, all entries are processed by default.  The --include option is especially useful when filtering archives.  For example, the command
                   tar -c -f new.tar --include='*foo*' @old.tgz
             creates a new archive new.tar containing only the entries from old.tgz containing the string `foo'.

## inotify
inotify是一种强大的、细粒度的、异步的文件系统事件监控机制，Linux内核从2.6.13开始引入，允许监控程序打开一个独立文件描述符，并针对事件集监控一个或者多个文件，例如打开、关闭、移动/重命名、删除、创建或者改变属性。

CentOS6自然已经支持：
使用ll /proc/sys/fs/inotify命令，是否有以下三条信息输出，如果没有表示不支持。

# ftp

## active and passive
ftp 通信有两个通信通道，
- 命令通道: 客户端端口N 与 服务端端口21(客户端发起初始化连接，服务端响应控制端口)
- 数据通道: 客户端端口 与 服务端端口(active 与 passive)

根据数据通道建立的不同，ftp 有active 与 passive 两种模式:
- active: 服务器端(20)初始化数据连接到客户端的数据端口N+1， 客户端发送ACK响应到服务器的数据端口
- passive: 客户端(N+1)初始化数据连接到服务器指定的任意端口(P>=1024, 不是20端口) 服务器发送ACK响应和数据到客户端的数据端口

## start

	yum install ftp vsftpd -y
	#config vsftpd
	sed -i '/^#chroot_local_user/a chroot_local_user=YES' /etc/vsftpd/vsftpd.conf
	#echo '/usr/sbin/vsftpd ' >> /etc/rc.d/rc.local
	chkconfig --level 235 vsftpd on
	#/usr/sbin/vsftpd [/etc/vsftpd/vsftpd.conf ]
	service vsftpd start

## client

	-i  Turns off interactive prompting during multiple file transfers.
	-n	Restrains ftp from attempting ``auto-login'' with login name

Example

	#!/bin/bash
	ftp -i -n  << END
	open 172.16.88.149
	user hilojack mypasswd
	binary
	hash
	put public/index.php public/index.php
	ls
	lcd /
	bye
	END

## sftp

	sftp [user@]host[:file ...]
		download file
	scp -r user@host:file

sftp

	(
	  echo "
	  ascii
	  cd pub
	  lcd dir_name
	  put filename
	  close
	  quit
		"
	) | sftp -oPort=21 "userid"@"servername"

lftp

	lftp -u ${USER},${PASSWORD} sftp://${IP}:${PORT}<<EOF
	lcd ${LOCALDIR}
	mget ${DIR}/${FILENAME}
	bye
	EOF

	lftp -e 'mirror -R /local/log/path/ /remote/path/' -u user,password sftp.foo.com

Connection
Connect to FTPS with specific port, username and password.

	lftp -p PORT -u USERNAME,PASSWORD ftps://FTP.ADDRESS
	lftp -p PORT -u USERNAME,PASSWORD sftp://FTP.ADDRESS
		> open -p PORT -u USERNAME,PASSWORD ftps://FTP.ADDRESS

> Note that it won’t actually connect until you use other commands such as `ls`.

## config
/etc/vsftpd/vsftpd.conf

	listen=YES use_localtime=YES
	anonymous_enable=YES

	sudo vsftpd [vsftpd.conf]

### file mode

	file_open_mode=0755 #本地用户上传档案后的档案权限，与chmod 所使用的数值相同。默认值为0666。
	local_umask=022		#本地用户新增档案时的umask 值。 默认值为077。
	anon_umask=077		#设置匿名登入者新增或上传档案时的umask 值。默认值为077，则新建档案的对应权限为700。

Refer to: http://yuanbin.blog.51cto.com/363003/108262/

### chroot_local_user

	chroot_local_user=YES

Allow local users to log in.( This is default)

	local_enable=YES
	#write_enable=YES

## security
security: 'one_process_model' is anonymous only

	#one_process_model=YES

## 500 OOPS
500 OOPS: cannot read config file: /etc/vsftpd/vsftpd.conf

	sudo chown root /etc/vsftpd/vsftpd.conf
	sudo service vsftpd start

## userlist( 530 Permission denied)
530 Permission denied

	userlist_enable=YES
	userlist_deny=YES
	userlist_file=/etc/vsftpd/user_list #要阻止的用户(530 Permission denied.)

这个配置与`userlist_deny`, `userlist_enable` 有关

- If userlist_deny=NO, only allow users in this file
- If userlist_deny=YES (default), never allow users in this file, and  do not even prompt for a password.

	cat /etc/vsftpd/user_list
	root

### pam (530 login failed)
非匿名用户 必须通过pam 认证，没有认证的话, 会登录失败(530 login failed)

	pam_service_name=vsftpd
	# vim /etc/pam.d/vsftpd //指定pam 黑名单文件
	auth       required pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
	# pam 限制名单
	file=/etc/vsftpd/ftpusers
		#Users that are not allowed to login via ftp
		root

## debug

### log

	tail -f /var/log/secure
	#The name of the log file is xferlog, usually it's under /var/log/ directory.

## 其它原因

	service iptables stop #关闭防火墙
	sudo setenforce 0 #关闭selinux
