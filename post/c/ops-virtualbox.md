---
layout: page
title: 全屏
category: blog
description: 
date: 2018-09-27
---
# install win10
## 提示“Units specified don't exist. SHSUCDX can't install.”
错误原因:虚拟光驱被分配在SATA控制器下面。

1.将端口数改为1(原来是2)，因为SATA控制器下面减少了一个虚拟光驱接口。
![](/img/c/ops/vm/install-win10-sata-num.png)
2.新建一个IDE控制器，并添加一个虚拟光驱+win10.iso(可开启 Use Host I/O cache)


# 网络

## Vitual Machine share network
- Internal（内网模式）: 
  只限VM 之间访问，不能访问主机和外网
- NAT: 
  VM --虚拟的NAT--> 访问其他主机-->访问外网（只能单向访问, vm之间也不可以访问）
- Bridged Adapter 网桥模式: 
  通过桥接网卡(e.g. en0/wifi)，得到独立的ip
- Host-Only: 
  在主机上虚拟一张网卡，VM 通过此网卡vmnet1实现以上的所有的功能。guest 与host机器相当于双绞线互连

### NAT
NAT模式下的虚拟系统的TCP/IP配置信息是由*VMnet8*(NAT)虚拟网络的DHCP服务器提供的，无法进行手工修改，因此虚拟系统也 就无法和本局域网中的其他真实主机进行通讯。

![](/img/ops/virtualbox-nat.png)

对于centos7 可能需要设定:

    $ nmtui ;#nm tool ui
    $ service network restart

> 这种方式也可以实现Host OS与Guest OS的双向访问。但网络内其他机器不能访问Guest OS，Guest OS可通过Host OS用NAT协议访问网络内其他机器。

### bridged adapter
将虚拟网卡桥接到一个物理网卡上面，和linux下一个网卡 绑定两个不同地址类似，实际上是将网卡设置为混杂模式，从而达到侦听多个IP的能力

	Interface: en0 Wifi(ApiPort)
	Adapter Type: Intel PRO/1000 MT desktop(82540EM)
	Promisuous Mode: Allow All
	MAC Address: 0800273***
    
#### replicate physical network connection state 
　　Select if the virtual machine uses a bridged network connection and if you use the virtual machine on a laptop or other mobile device. As you move from one wired or wireless network to another, the IP address is automatically renewed.

　　单机多网卡 或者 笔记本和移动设备使用虚拟机时，当在有线网络和无线网络切换时，勾选了Replicate physical network connection state，虚拟机网卡的ip地址会自动更新，不需要重新设置。

### virutalbox 下windows使用socks5
IE选项卡-局域网代理(跳过本地地址的代理)-高级-套接字

## renew ip
1. release ip

	sudo dhclient -r [interface]

2. obtain ip

	sudo dhclient [interface]

Refer to: [](/p/linux-net)

## query Guest Ip
Refer to [](/bin/getip.py)

	# Update arp table
	for i in {1..255}; do ping -c 1 192.168.0.$i & done
	for i in {1..255}; do ping -c 1 10.209.0.$i & done

	# Find vm name
	VBoxManage list runningvms

	# Find MAC: subsitute vmname with your vm's name
	VBoxManage showvminfo vmname

	# Find IP: substitute vname-mac-addr with your vm's mac address in ':' notation
	arp -a | grep vmname-mac-addr