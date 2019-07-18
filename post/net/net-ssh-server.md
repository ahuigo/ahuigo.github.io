---
title: SSH SERVER 的配置
date: 2019-06-23
---
# SSH SERVER
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

### ssh_config
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
