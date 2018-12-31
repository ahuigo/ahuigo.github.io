---
layout: page
title:	linux ssh tool
category: blog
date: 2016-09-09
description:
---
# ssh tool
管理多台ssh 可以参考[pssh](/p/linux-pssh)

# Server
OpenSSH Installations under CentOS Linux

	# To install the server and client type:
	yum -y install openssh-server openssh-clients

Start the service:

	chkconfig sshd on
	service sshd start

Or:

	ssh
		[-D [bind_address:]port] [-e escape_char] [-F configfile]
		[-L [bind_address:]port:host:hostport]

Make sure port 22 is opened:

	netstat -tulpn | grep :22

## Firewall Settings

	vi /etc/sysconfig/iptables

Add the line

	-A RH-Firewall-1-INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT

If you want to restict access to 192.168.1.0/24, edit it as follows:

	-A RH-Firewall-1-INPUT -s 192.168.1.0/24 -m state --state NEW -p tcp --dport 22 -j ACCEPT

If your site uses IPv6, and you are editing ip6tables, use the line:

	-A RH-Firewall-1-INPUT -m tcp -p tcp --dport 22 -j ACCEPT

Save and close the file. Restart iptables:

	service iptables restart

## OpenSSH Server Configuration
sshd_config 是sshd配置文件

	vi /etc/ssh/sshd_config

	# To disable root logins, edit or add as follows:
	PermitRootLogin no

	#Restrict login to user tom and jerry only over ssh:
	AllowUsers tom jerry

	#Change ssh port i.e. run it on a non-standard port like 1235(default listen: 22)
	Port 1235

Save and close the file. Restart sshd:

	service sshd restart

### sshd_config
现把/etc/ssh/ssh_config 和 /etc/ssh/sshd_config的配置说下。

#### 阿里云sshd 自动断开
打开/etc/ssh/sshd_config 添加或修改:

	ClientAliveInterval 120
	ClientAliveCountMax 0

#### /etc/ssh/ssh_config:
Refer http://blog.lizhigang.net/archives/249

	Host *
	选项“Host”只对能够匹配后面字串的计算机有效。“*”表示所有的计算机*。
	ForwardAgent no
	“ForwardAgent”设置连接是否经过验证代理（如果存在）转发给远程计算机。
	ForwardX11 no
	“ForwardX11”设置X11连接是否被自动重定向到安全的通道和显示集（DISPLAY set）。
	RhostsAuthentication no
	“RhostsAuthentication”设置是否使用基于rhosts的安全验证。
	RhostsRSAAuthentication no
	“RhostsRSAAuthentication”设置是否使用用RSA算法的基于rhosts的安全验证。
	RSAAuthentication yes
	“RSAAuthentication”设置是否使用RSA算法进行安全验证。
	PasswordAuthentication yes
	“PasswordAuthentication”设置是否使用口令验证。
	FallBackToRsh no
	“FallBackToRsh”设置如果用ssh连接出现错误是否自动使用rsh。
	UseRsh no
	“UseRsh”设置是否在这台计算机上使用“rlogin/rsh”。
	BatchMode no
	“BatchMode”如果设为“yes”，passphrase/password（交互式输入口令）的提示将被禁止。当不能交互式输入口令的时候，这个选项对脚本文件和批处理任务十分有用。
	CheckHostIP yes
	“CheckHostIP”设置ssh是否查看连接到服务器的主机的IP地址以防止DNS欺骗。建议设置为“yes”。
	StrictHostKeyChecking no
	“StrictHostKeyChecking”如果设置成“yes”，ssh就不会自动把计算机的密匙加入“$HOME/.ssh/known_hosts”文件，并且一旦计算机的密匙发生了变化，就拒绝连接。
	IdentityFile ~/.ssh/identity
	“IdentityFile”设置从哪个文件读取用户的RSA安全验证标识。
	Port 22
	“Port”设置连接到远程主机的端口。
	Cipher blowfish
	“Cipher”设置加密用的密码。
	EscapeChar ~
	“EscapeChar”设置escape字符。

/etc/ssh/sshd_config:

	Port 22
	“Port”设置sshd监听的端口号。
	ListenAddress 192.168.1.1
	“ListenAddress”设置sshd服务器绑定的IP地址。
	HostKey /etc/ssh/ssh_host_key
	“HostKey”设置包含计算机私人密匙的文件。
	ServerKeyBits 1024
	“ServerKeyBits”定义服务器密匙的位数。
	LoginGraceTime 600
	“LoginGraceTime”设置如果用户不能成功登录，在切断连接之前服务器需要等待的时间（以秒为单位）。
	KeyRegenerationInterval 3600
	“KeyRegenerationInterval”设置在多少秒之后自动重新生成服务器的密匙（如果使用密匙）。重新生成密匙是为了防止用盗用的密匙解密被截获的信息。
	PermitRootLogin no
	“PermitRootLogin”设置root能不能用ssh登录。这个选项一定不要设成“yes”。
	IgnoreRhosts yes
	“IgnoreRhosts”设置验证的时候是否使用“rhosts”和“shosts”文件。
	IgnoreUserKnownHosts yes
	“IgnoreUserKnownHosts”设置ssh daemon是否在进行RhostsRSAAuthentication安全验证的时候忽略用户的“$HOME/.ssh/known_hosts”
	StrictModes yes
	“StrictModes”设置ssh在接收登录请求之前是否检查用户家目录和rhosts文件的权限和所有权。这通常是必要的，因为新手经常会把自己的目录和文件设成任何人都有写权限。
	X11Forwarding no
	“X11Forwarding”设置是否允许X11转发。
	PrintMotd yes
	“PrintMotd”设置sshd是否在用户登录的时候显示“/etc/motd”中的信息。
	SyslogFacility AUTH
	“SyslogFacility”设置在记录来自sshd的消息的时候，是否给出“facility code”。
	LogLevel INFO
	“LogLevel”设置记录sshd日志消息的层次。INFO是一个好的选择。查看sshd的man帮助页，已获取更多的信息。
	RhostsAuthentication no
	“RhostsAuthentication”设置只用rhosts或“/etc/hosts.equiv”进行安全验证是否已经足够了。
	RhostsRSAAuthentication no
	“RhostsRSA”设置是否允许用rhosts或“/etc/hosts.equiv”加上RSA进行安全验证。
	RSAAuthentication yes
	“RSAAuthentication”设置是否允许只有RSA安全验证。
	PasswordAuthentication yes
	“PasswordAuthentication”设置是否允许口令验证。
	PermitEmptyPasswords no
	“PermitEmptyPasswords”设置是否允许用口令为空的帐号登录。
	AllowUsers admin
	“AllowUsers”的后面可以跟着任意的数量的用户名的匹配串（patterns）或user@host这样的匹配串，这些字符串用空格隔开。主机名可以是DNS名或IP地址。

# client

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
	$scp -r user@your.server.example.com:/path/to/dir /home/user/Desktop/

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
	#或者用这个自动将公钥(.ssh/id_rsa.pub) 传到远程服务器(~/.ssh/authorized_keys)
	ssh-copy-id [-i [~/.ssh/id_rsa.pub ]] -P 22 [user@]hostname # 这个不是通用的命令，mac 下就没有
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

### 利用sshpass

	sshpass -p "passwd" ssh yourUserName@host
	sshpass -p "passwd" ssh -l yourUserName host

### rsync
rsync 是一个同步命令，它是通过ssh 来下的，如果同步时不想输入密码:

	rsync --rsh='sshpass -p password ssh -l username' host.example.com:path

### sshpass
如果想scp 不输入密码, 可以借助sshpass:

cat ssh_login.sh:

	#!/usr/bin/env bash
	sshpass -p password ssh "$@"

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
