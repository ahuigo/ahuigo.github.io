---
layout: page
title:	linux
category: blog
description:
---
# Preface
在工作中，我们可能会有同步操作多台linux 服务器的需要。过去的做法是用for 循环执行: `ssh $ip < work.sh $1 $2 &`

其实，我们还可以借助以下命令(前提是已经建立信任):

    pssh pdsh clusterssh clusterit mussh

# Gravitational Teleport
Gravitational Teleport
Modern SSH server for teams managing distributed infrastructure

# pssh
pssh 与mpssh, 都是多主机并行运行命令

	[root@server pssh-2.2.2]# pssh -P -h iplist.txt uptime
	192.168.9.102:  14:04:58 up 26 days, 17:05,  0 users,  load average: 0.07, 0.02, 0.00
	192.168.9.102: [1] 14:04:58 [SUCCESS] 192.168.9.102 9922
	192.168.8.171:  14:04:59 up 35 days,  2:01,  6 users,  load average: 0.00, 0.00, 0.00
	192.168.8.171: [2] 14:04:59 [SUCCESS] 192.168.8.171 22
	192.168.9.104:  14:04:59 up 7 days, 20:59,  0 users,  load average: 0.10, 0.04, 0.01
	192.168.9.104: [3] 14:04:59 [SUCCESS] 192.168.9.104 9922

	[root@server pssh-2.2.2]# cat iplist.txt
	192.168.9.102:9922
	192.168.9.104:9922
	192.168.8.171:22

假如想将输出重定向到一个文件 加`-o file` 选项

# Ansible
Ansible 是一个比Puppet, Chef 更轻量的provisioning 工具，不需要启动daemon进程。这点跟跟pssh差不多，但是比pssh更加强大。

	$ yum install -y ansible
	$ ansible --version
	  ansible 2.0.0.2
	    config file = /etc/ansible/ansible.cfg
	    configured module search path = Default w/o overrides

# pscp
把文件并行地复制到多个主机上 注意 是从服务器端给客户端传送文件:

	[root@server pssh-2.2.2]# pscp -h iplist.txt /etc/sysconfig/network /tmp/network   //标示将本地的/etc/sysconfig/network传到目标服务器的/tmp/network

# prsync
使用rsync协议从本地计算机同步到远程主机

	[root@server ~]# pssh -h iplist.txt -P mkdir /tmp/etc
	[root@server ~]# prsync -h iplist.txt -l dongwm -a -r /etc/sysconfig /tmp/etc //标示将本地的/etc/sysconfig目录递归同步到目标服务器的 /tmp/etc目录下,并保持原来的时间戳,使用用户 dongwm

# pslurp
将文件从远程主机复制到本地,和pscp方向相反:

	[root@server ~]# pslurp -h iplist.txt   -L /tmp/test -l root /tmp/network test  //标示将目标服务器的/tmp/network文件复制到本地的/tmp/test目录下,并更名为test
	[1] 14:53:54 [SUCCESS] 192.168.9.102 9922
	[2] 14:53:54 [SUCCESS] 192.168.9.104 9922
	[root@server ~]# ll /tmp/test/192.168.9.10
	192.168.9.102/ 192.168.9.104/
	[root@server ~]# ll /tmp/test/192.168.9.102/
	总计 4.0K
	-rw-r--r-- 1 root root 60 2011-04-22 14:53 test
	[root@server ~]# ll /tmp/test/192.168.9.104/
	总计 4.0K
	-rw-r--r-- 1 root root 60 2011-04-22 14:53 test

# pnuke 并行在远程主机杀进程:

	[root@server ~]# pnuke -h iplist.txt   syslog //杀死目标服务器的syslog进程
	[1] 15:05:14 [SUCCESS] 192.168.9.102 9922
	[2] 15:05:14 [SUCCESS] 192.168.9.104 9922

# Reference
- [pssh 批量操作] by dongweiming

[pssh 批量操作]: http://dongweiming.github.io/blog/archives/%E4%BD%BF%E7%94%A8pssh%E8%BF%9B%E8%A1%8C%E5%B9%B6%E8%A1%8C%E6%89%B9%E9%87%8F%E6%93%8D%E4%BD%9C/
