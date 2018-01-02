---
layout: page
title:	Secure Shell(ssh)
category: blog
description:
---
# Preface
本文介绍协议，具体工具请参考[/p/net-ssh-tool](/p/net-ssh-tool)
Secure Shell 是建立在传输层和应用层基础上的安全协议(它属于应用层)，为计算机的Shell 提供安全的传输环境

应用：
传统的网络协议如 FTP/POP/Telnet 都是明文传送数据与密钥，很容易受到中间人（man in the middle）攻击

SSH 可以有效确保:

1. 登录安全，数据加密，防止DNS/IP 欺骗
2. 可以提供数据压缩
3. 可以为FTP/POP/PPP 提供安全的通道

# SSH 协议框架
SSH 协议框架 包括三个协议：

1. 传输层协议(Transport Layer Protocol): 提供*服务器认证*、*数据机密性*、*信息完整性*等支持
2. 用户认证协议(User Authentication Protocol): 提供服务器对*客户端的身份鉴别*
3. 连接协议(Connection Prococol): 将加密的信息隧道复用成 多个逻辑通道，提供给高层应用协议使用

同时还为高层应用协议提供扩展支持，这些扩展可以独立于SSH 基本协议框架

[SSL VS SSH](http://security.stackexchange.com/questions/1599/what-is-the-difference-between-ssl-vs-ssh-which-is-more-secure)

		  SSL              SSH
	+-------------+ +-----------------+
	| Nothing     | | RFC4254         | Connection multiplexing
	+-------------+ +-----------------+
	| Nothing     | | RFC4252         | User authentication
	+-------------+ +-----------------+
	| RFC5246     | | RFC4253         | Encrypted data transport
	+-------------+ +-----------------+

# SSH 安全验证
从客户端来看 SSH 安全验证包括两个级别：

1. 基于密码的验证：通过帐号密码和帐号登录远程主机，所有的数据都会被加密。但是无法避免中间人
2. 基于密钥的验证: 你首先创建一对密钥，将公钥上传到远程的主机。服务器会用这个公钥鉴定是否是来自你的请求, 并用于加密给你的数据，这有效避免了中间人

在服务端来看:

1. 在第一种方案中，服务端会把自己的公钥发给相关的客户端，客户端使用这个公钥加密上行的数据。
1. 在第二种方案中，存在一个密钥认证中心，所有提供服务的主机都将自己的公钥存放在认证中心，客户端需要保存一份认证中心的公钥(~/.ssh/known_hosts)。在这种情况下，客户端需要先访问认证中心得到公钥，然后才能访问服务器

# SSH 协议的可扩展能力
SSH 协议允许自定义加密算法（如RSA/ DSA）, 客户端定义密钥规则，高层扩展功能性应用协议(扩展大多遵循IANA 规定，特别是消息编码和命名规则)

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
on mac osx/linux

	ssh-keygen - authentication key generation, management and conversion
		-f ~/.ssh/id_rsa
		-t rsa/dsa

Example

	ssh-keygen -t rsa -C "your_email@example.com"
	# Generating public/private rsa key pair.
		id_rsa.pub/id_rsa

# Reference
- [Secure_Shell]

[Secure_Shell]: http://zh.wikipedia.org/wiki/Secure_Shell
