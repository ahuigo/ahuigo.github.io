---
layout: page
title:	linux ssh tool
category: blog
date: 2016-09-09
private:
description:
---
# OpenSSH
OpenSSH 是SSH 协议的开源软件包（OpenBSD 子项目），它和OpenSSL 是不一样的。它们有不同的目标、不同的发展团队

程度包括

- ssh
	rlogin与Telnet的替代方案。

- scp、sftp
	rcp的替代方案，将文件复制到其他电脑上。

- sshd
	SSH服务器。

- ssh-keygen
	产生RSA或DSA密钥，用来认证用。

- ssh-agent、ssh-add
	帮助用户不需要每次都要输入密钥密码的工具。

- ssh-keyscan
	扫描一群机器，并纪录其公钥。


## ssh-keygen
ssh-keygen - see ssh-client-login

## SSH Client
    ssh user@host echo 1 2
    ssh user@host "echo 1 2"
### config
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
