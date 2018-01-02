---
layout: page
title:	Linux Network
category: blog
description:
---
# Preface

查看网络的命令行工具非常多，而mac 下有一款功能完备网络查看工具：Network Utility

![](/img/linux-net-mac-network-utility.png)

- net-debug-.md
- net-dns

# tool
网络相关的工具有:

	dns: ip 或 ifconfig，dig
	monitor: netstat -lntp 或 ss -plat
	socket: lsof 查看套接字和文件

	ss：套接口统计数据, 参数跟netstat 差不多(see net-netstat.md)
	nc：netcat 网络调试和数据传输
	socat：套接字中继和 tcp 端口转发（类似 netcat）
	scan: nmap, zmap

    nethogs: 按进程查看流量占用
    iptraf: 按连接/端口查看流量
    ifstat: 按设备查看流量
    ethtool: 诊断工具
    其他: dstat, slurm, nload, bmon

# monitor
http://www.binarytides.com/linux-commands-monitor-network/

The tools have different mechanisms of generating the traffic report.

- Some of the tools like nload read the "/proc/net/dev" file to get traffic stats
- whereas some tools use the pcap library to capture all packets and then calculate the total size to estimate the traffic load.

1. Overall bandwidth - nload, bmon, slurm, bwm-ng, cbm, speedometer, netload
2. Overall bandwidth (batch style output) - vnstat, ifstat, dstat, collectl
3. Bandwidth per socket connection - iftop, iptraf, tcptrack, pktstat, netwatch, trafshow
4. Bandwidth per process - nethogs


	yum install ntop -y
	yum install iftop -y

1. ntop 网卡实时流量(不区分上下行)
1. ifstat 网卡实时流量: 区分上下行;
1. iftop 网卡实时流量: 区分上下行; 监听所有的连接
2. iptraf(更强大: 推荐): 支持IP traffic monitor, interface statistic, LAN station monitor, filters and Configure

## ifstat

	$ ifstat -t -i eth0 0.5
	  Time           eth0
	HH:MM:SS   KB/s in  KB/s out
	09:59:21      2.62      2.80
	09:59:22      2.10      1.78
	09:59:22      2.67      1.84
	09:59:23      2.06      1.98
	09:59:23      1.73      1.79

# todo
网络监控工具:
http://mp.weixin.qq.com/s?__biz=MzA3MzYwNjQ3NA==&mid=205572993&idx=1&sn=9c05c68f6209ff990dd0da8e8a77e334&scene=1&from=groupmessage&isappinstalled=0#rd

# centos网络配置(手动设置，自动获取)的2种方法
作者:海底苍鹰
地址:http://blog.51yip.com/linux/1120.html

## 设置网络链接ifcfg-eth0

	cat /etc/sysconfig/network-scripts/ifcfg-eth0

内容如下：

	DEVICE=eth0                               //由eth0来启动
	BOOTPROTO=dhcp                     //获取IP的方式是自动获取，static是固定IP，none是手动
	#BOOTPROTO=none                         //启动为手动
	HWADDR=00:16:D3:A2:F6:09       //网卡的物理地址
	IPV6INIT=yes                              //是否支持IP6
	IPV6_AUTOCONF=yes                //IP6是否自动配置
	ONBOOT=yes                       //启动时网络接口是否有效

	#IPADDR=192.168.1.108                   //设置的IP
	#NETMASK=255.255.255.0                //子网掩码
	#TYPE=Ethernet                                //网络类型
	#GATEWAY=192.168.1.1                            //加上网关
	#DNS1=223.5.5.5	//加上主DNS
	#DNS2=223.6.6.6	//加上次DNS

[For more detail]( https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/s1-networkscripts-interfaces.html)fdsfdsfsb 	sf	sdfbsdf	a

## 初始化网络

	$ cat /etc/sysconfig/network
	NETWORKING=yes                                 //网络是否可用
	NETWORKING_IPV6=yes
	HOSTNAME=localhost.localdomain //主机名，主机名在/etc/hosts里面配置


	$ cat /etc/hosts
	127.0.0.1               localhost.localdomain localhost     //根/etc/resolv.conf中search要对应，localhost.localdomain
	::1             localhost6.localdomain6 localhost6

	$ cat /etc/resolv.conf
	#nameserver 223.5.5.5	//加上主DNS
	#nameserver 223.6.6.6	//加上次DNS
	#search localdomain //搜索要找的域名，在/etc/hosts里面设定的有(用于子域名)

## start & restart

	# ifdown eth0
	# ifup eth0
	### RHEL/CentOS/Fedora specific command ###
	# /etc/init.d/network restart

or via `dhclient`:

	# 1. release ip
	sudo dhclient -r [interface]
	# 2. obtain ip
	sudo dhclient [interface]
		-r
			release ip
		interface
			eth0 | wlan1 | ...
		-v
			verbose

Refer to : http://www.cyberciti.biz/faq/howto-linux-renew-dhcp-client-ip-address/

# netstat
/p/linux-net-netstat

# lsof
[/p/linux-process-lsof](/p/linux-process-lsof)

# ifconfig
ifconfig 是用于查看网卡接口的。
对于linux 来说，它会显示网关gateway(route), 而对于mac 它不会显示网关.
不过mac可以使用通过路由表netstat -nr | grep '^default' 查看到网关。或者通过mac 的特有命令`route get default` 得到mac 的网关信息

# DNS
[/p/dns](/p/dns)

# selinux
Refer to [linux-selinux](/p/linux-selinux)

# iptables, 防火墙
Refer to [linux-iptables](/p/linux-iptables)

# route
[net-route](/p/net-route)

# nmap
常见的网络扫描器有 SSS，X-Scan，Superscan等，功能最强大的当然是[Nmap](http://www.aiezu.com/system/linux/linux_nmap_tutorial.html)

Nmap命令的格式为：

	Nmap [ 扫描类型 ... ] [ 通用选项 ] { 扫描目标说明 }

下面对Nmap命令的参数按分类进行说明：

1. 扫描类型

	-sT	TCP connect()扫描，这是最基本的TCP扫描方式。这种扫描很容易被检测到，在目标主机的日志中会记录大批的连接请求以及错误信息。
	-sS	TCP同步扫描(TCP SYN)，因为不必全部打开一个TCP连接，所以这项技术通常称为半开扫描(half-open)。这项技术最大的好处是，很少有系统能够把这记入系统日志。不过，你需要root权限来定制SYN数据包。
	-sF,-sX,-sN	秘密FIN数据包扫描、圣诞树(Xmas Tree)、空(Null)扫描模式。这些扫描方式的理论依据是：关闭的端口需要对你的探测包回应RST包，而打开的端口必需忽略有问题的包(参考RFC 793第64页)。
	-sP	ping扫描，用ping方式检查网络上哪些主机正在运行。当主机阻塞ICMP echo请求包是ping扫描是无效的。nmap在任何情况下都会进行ping扫描，只有目标主机处于运行状态，才会进行后续的扫描。
	-sU	如果你想知道在某台主机上提供哪些UDP(用户数据报协议,RFC768)服务，可以使用此选项。
	-sA	ACK扫描，这项高级的扫描方法通常可以用来穿过防火墙。
	-sW	滑动窗口扫描，非常类似于ACK的扫描。
	-sR	RPC扫描，和其它不同的端口扫描方法结合使用。
	-b	FTP反弹攻击(bounce attack)，连接到防火墙后面的一台FTP服务器做代理，接着进行端口扫描。

2. 通用选项

	-P0	在扫描之前，不ping主机。
	-PT	扫描之前，使用TCP ping确定哪些主机正在运行。
	-PS	对于root用户，这个选项让nmap使用SYN包而不是ACK包来对目标主机进行扫描。
	-PI	设置这个选项，让nmap使用真正的ping(ICMP echo请求)来扫描目标主机是否正在运行。
	-PB	这是默认的ping扫描选项。它使用ACK(-PT)和ICMP(-PI)两种扫描类型并行扫描。如果防火墙能够过滤其中一种包，使用这种方法，你就能够穿过防火墙。
	-O	这个选项激活对TCP/IP指纹特征(fingerprinting)的扫描，获得远程主机的标志，也就是操作系统类型。
	-I	打开nmap的反向标志扫描功能。
	-f	使用碎片IP数据包发送SYN、FIN、XMAS、NULL。包增加包过滤、入侵检测系统的难度，使其无法知道你的企图。
	-v	冗余模式。强烈推荐使用这个选项，它会给出扫描过程中的详细信息。
	-S <IP>	在一些情况下，nmap可能无法确定你的源地址(nmap会告诉你)。在这种情况使用这个选项给出你的IP地址。
	-g port	设置扫描的源端口。一些天真的防火墙和包过滤器的规则集允许源端口为DNS(53)或者FTP-DATA(20)的包通过和实现连接。显然，如果攻击者把源端口修改为20或者53，就可以摧毁防火墙的防护。
	-oN	把扫描结果重定向到一个可读的文件logfilename中。
	-oS	扫描结果输出到标准输出。
	--host_timeout	设置扫描一台主机的时间，以毫秒为单位。默认的情况下，没有超时限制。
	--max_rtt_timeout	设置对每次探测的等待时间，以毫秒为单位。如果超过这个时间限制就重传或者超时。默认值是大约9000毫秒。
	--min_rtt_timeout	设置nmap对每次探测至少等待你指定的时间，以毫秒为单位。
	-M count	置进行TCP connect()扫描时，最多使用多少个套接字进行并行的扫描。

3. 扫描目标

	目标地址	可以为IP地址，CIRD地址等。如192.168.1.2，222.247.54.5/24
	-iL filename	从filename文件中读取扫描的目标。
	-iR	让nmap自己随机挑选主机进行扫描。
	-p	端口 这个选项让你选择要进行扫描的端口号的范围。如：-p 20-30,139,60000。
	-exclude	排除指定主机。
	-excludefile	排除指定文件中的主机。

# ZMap
作者：仲晨
链接：https://www.zhihu.com/question/21505586/answer/18443313

ZMap发送数据包的速度是Nmap的上千倍。Nmap需要数周时间扫描全部网址，而ZMap只要44分钟扫描全部互联网地址。

- nmap: TCP 三次握手
- ZMap: 第一个SYN，然后等待对方回复SYN-ACK，之后即RST取消连接

## 原因
ZMap的这个策略在nmap中也有实现，即其TCP SYN扫描方式, 关键性的问题出现在对回复的SYN-ACK进行seq number的校验。传统上就需要记录发送时的seq number。
而ZMap是将对方receiver ip地址进行hash，将其处理保存到了sender port和seq number两个字段中，当SYN-ACK回来的时候，就可以根据sender ip、receiver port、ack number这些字段进行校验。
因此避免了状态存储，接近了网络带宽极限。

与Nmap等已有系统对比：
NMap是一个通用网络监测工具，可以适用于不同协议、不同范围的测试。
而ZMap专做单端口、大范围的网络监测。

# ngrok 内网穿透
https://www.imququ.com/post/self-hosted-ngrokd.html?utm_source=tuicool

# Todo
计算机网络:自顶向下方法 http://www.amazon.cn/gp/product/B001TCBSJ0/ref=as_li_ss_tl?ie=UTF8&camp=536&creative=3132&creativeASIN=B001TCBSJ0&linkCode=as2&tag=jysperm07-23

# Reference
[could_not_bind_to_port]

[could_not_bind_to_port]: http://wiki.apache.org/httpd/CouldNotBindToAddress
