---
layout: page
title:	linux ssh tool
category: blog
date: 2016-09-09
private:
description:
---
# SSH Client

## config
以下 `~/.ssh/config` 包含了可以避免在特定网络环境中连接被断掉的情况的设置、使用压缩（这对于通过低带宽连接使用 scp 很有用），以及使用一个本地控制文件来开启到同一台服务器的多通道：

	TCPKeepAlive=yes
	ServerAliveInterval=15
	ServerAliveCountMax=6
	Compression=yes
	ControlMaster auto
	ControlPath /tmp/%r@%h:%p
	ControlPersist yes

	Host 10.10.10.*
	User hilo
	Port 22
	IdentityFile ~/.ssh/rsa

### keep session alive
> https://support.suso.com/supki/SSH_Tutorial_for_Linux#Keeping_Your_SSH_Session_Alive

in ~/.ssh/config:

    # Host alias_host
    # Host m56
	Host *
	Protocol 2
	TCPKeepAlive yes
	ServerAliveInterval 60

## scp & sftp
openssh 包 包含这两个程序

### scp

如果我们想要 从远端系统，remote-sys 的家目录下复制文档 document.txt，到我们本地系统的当前工作目录下， 可以这样操作：

From remote to local

	$ scp remote-sys:document.txt .
	$ scp hilo@remote-sys:document.txt .

	# recursive download
	$ scp -r user@your.server.example.com:/path/to/dir /home/user/Desktop

从本地到远端：

	$ scp .ssh/id_rsa.pub username@hostname:/home/username/.ssh/authorized_keys

### sftp
就是 sftp 不需要远端系统中运行 FTP 服务器。它仅仅要求 SSH 服务器。 这意味着任何一台能用 SSH 客户端连接的远端机器，也可当作类似于 FTP 的服务器来使用。 这里是一个样本会话：

	$ sftp remote-sys
	> bye

> 也可在浏览器中使用sftp:// 访问

## connect
### debug

	ssh username@host -p port
		-v verbose
		-T Disable pseudo-tty allocation(for test)

指定使用哪个密钥(private key)

		ssh -i ~/.ssh/deploy-key -T git@github.com
		ssh -i ~/.ssh/id_rsa  -T git@github.com
		ssh -i ~/.ssh/id_rsa.pem  -T git@github.com

### port

	-p port

### connect X server
假设我们正坐在一台装有 Linux 系统， 叫做 linuxbox 的机器之前，且系统中运行着 X 服务器，现在我们想要在名为 remote-sys 的远端系统中 运行 xload 程序，但是要在我们的本地系统中看到这个程序的图形化输出。我们可以这样做：

	[me@linuxbox ~]$ ssh -X remote-sys
	me@remote-sys's password:
	Last login: Mon Sep 08 13:23:11 2008
	[me@remote-sys ~]$ xload

这个 xload 命令在远端执行之后，它的窗口就会出现在本地。在某些系统中，你可能需要 使用 “－Y” 选项，而不是 “－X” 选项来完成这个操作。

## excute command

	ssh user@host bash < my.sh $1 $2
	ssh user@host 'cat file.txt; ls'
	//host 后的所有参数会作为cmd 发给远程服务器，所以不用加引号
	ssh user@host cat file.txt; ls

	echo str | ssh user@server 'cat'

## autossh
添加的一个-M 5678参数，负责通过5678端口监视连接状态，连接有问题时就会自动重连，去掉了一个-f参数，因为autossh本身就会在background运行。

    autossh -M 5678 user1@123.123.123.123 -f
    /bin/su -c '/usr/bin/autossh -M 5678 -NR 1234:localhost:2223 user1@123.123.123.123 -p2221' - user1

## non interactive login

### 利用公私钥作验证(e.g.:RSA)
原理： 当ssh登录时,ssh程序会发送私钥去和服务器上的公钥做匹配.如果匹配成功就可以登录了

1. 本地只需要: .ssh/id_rsa

过程：
1.生成自己的公钥与私钥

	$ ssh-keygen -t rsa
	//or
	$ ssh-keygen -t rsa -P "passwd" -f ~/.ssh/id_rsa -C 'x@qq.com'

	# 或者将其它人的pub 导入ssh server
	cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
	# 改变权限，必须
	chmod 700 ~/.ssh
	chmod 600 ~/.ssh/authorized_keys
	chmod 600 -R ~/.ssh/* # 非必须

2.通过scp 或者ssh-copy-id 把公钥pub 传到远程

	$ scp .ssh/id_rsa.pub [-P 22] username@hostname:/home/username/.ssh/authorized_keys
	#或者用这个自动将`-i id_rsa` 对应的公钥(.ssh/id_rsa.pub) 传到远程服务器(~/.ssh/authorized_keys)
	ssh-copy-id [-i [~/.ssh/id_rsa ]] -P 22 [user@]hostname # 这个不是通用的命令，mac 下就没有
	#或者手动copy：
	cat ~/.ssh/id_rsa.pub | ssh user@machine "mkdir ~/.ssh; cat >> ~/.ssh/authorized_keys"

小结: 其实你可以一步到位：

	ssh-keygen -t rsa; ssh-copy-id user@host;

> authorized_keys 644，.ssh 700

#### 检验

	$ ssh -vT git@github.com-hilolt
	OpenSSH_6.2p2, OSSLShim 0.9.8r 8 Dec 2011
	debug1: Reading configuration data /Users/hilojack/.ssh/config
	debug1: /Users/hilojack/.ssh/config line 12: Applying options for github.com-hilolt
	debug1: Reading configuration data /etc/ssh_config
	debug1: identity file /Users/hilojack/.ssh/id_rsa_hilolt type 1

可参考：
http://www.cnblogs.com/weafer/archive/2011/06/10/2077852.html
http://www.chinaunix.net/old_jh/4/343905.html

### rsync
rsync 是一个同步命令，它是通过ssh 来下的，如果同步时不想输入密码:

	rsync --rsh='sshpass -p password ssh -l username' host.example.com:path

### sshpass
如果想scp 不输入密码, 可以借助sshpass:

cat ssh_login.sh:

	#!/usr/bin/env bash
	sshpass -p password ssh "$@"
	sshpass -p "passwd" ssh yourUserName@host
	sshpass -p "passwd" ssh -l yourUserName host


Then:

	scp -S ssh_login.sh file user@host:path

### expect

	#!/usr/bin/expect
	spawn ssh -o StrictHostKeyChecking=no -l username hostname
	expect "password:"
	send "password\r"
	interact

### 堡垒机
穿过堡垒机传文件 有几个方法
1. scp 先传到堡垒机
2. ssh -N -f -L 2120:目标机IP:22 root@跳板机IP -p 跳板机端口
3. lrzsz: https://github.com/mmastrac/iterm2-zmodem
    1. 然后找到iTerm2的配置项：iTerm2的Preferences-> Profiles -> Default -> Advanced -> Triggers 添加triggers。
    2. 参考: https://yanyinhong.github.io/2017/12/26/How-to-use-lrzsz/

# Security
参考[ssh security]，保护你的ssh

1. 将port 从22 改成其它端口
2. 定义有限的用户列表, 利用PAM API(Pluggable Authentication Modules)
3. 要求提供特殊的"序列"识别用户: 端口敲门, 必须依次访问某些特定的端口序列，才能进入系统

# Reference
- [ssh copy]
- [ssh security]

[ssh copy]: http://ahei.info/ssh-copy-id.htm
[ssh security]:
http://www.ibm.com/developerworks/cn/aix/library/au-sshlocks/
