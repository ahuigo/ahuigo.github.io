---
layout: page
title:	tcp/ip 协议
date: 2011-11-11
---
# 互联网协议栈
分为链路层(link), 网络层(Network), 传输层(Transport), 应用层(Application)

应用层
	DHCP DHCPv6 DNS FTP Gopher HTTP IMAP4 IRC NNTP XMPP POP3 SIP SMTP SNMP SSH TELNET RPC RTCP RTP RTSP SDP SOAP GTP STUN NTP SSDP TLS/SSL 更多

传输层
	TCP UDP DCCP SCTP RSVP PPTP

网络层
	IP（IPv4 IPv6） ICMP ICMPv6 IGMP IS-IS IPsec BGP RIP OSPF ARP RARP

数据链路层(设备驱动程序及接口卡)
	Wi-Fi（IEEE 802.11） WiMAX（IEEE 802.16） ATM DTM 令牌环 以太网路 FDDI 帧中继 GPRS EV-DO HSPA HDLC PPP L2TP ISDN SPB STP

物理层
	以太网 调制解调器 电力线通信 同步光网络 G.709 光导纤维 同轴电缆 双绞线

## OSI模型, Open System Interconnection Reference Model

    应用层（application layer）
    OSI Layer 7
    DHCP（v6） DNS FTP Gopher HTTP（SPDY、HTTP/2） IMAP4 IRC NNTP XMPP POP3 SIP SMTP SNMP SSH TELNET RPC RTCP RTP RTSP SDP SOAP GTP STUN NTP SSDP 更多
    表示层（presentation layer）
    OSI Layer 6
    该层被弃用。应用层的HTTP、FTP、Telnet等协议有类似的功能。传输层的TLS/SSL也有类似功能。
    会话层（session layer）
    OSI Layer 5
    该层被弃用。应用层的HTTP、RPC、SDP、RTCP等协议有类似的功能。
    传输层（transport layer）
    OSI Layer 4
    TCP（T/TCP · Fast Open） UDP DCCP SCTP RSVP PPTP(基于TCP) TLS/SSL 更多
    网络层（network layer）
    OSI Layer 3
    IP（v4·v6） ICMP（v6） IGMP IS-IS IPsec BGP RIP OSPF RARP 更多
    数据链路层（data link layer）
    OSI Layer 2
    Wi-Fi（IEEE 802.11） ARP WiMAX（IEEE 802.16） ATM DTM 令牌环 以太网 FDDI 帧中继 GPRS EV-DO HSPA HDLC PPP PPPoE L2TP ISDN SPB STP 更多
    物理层（physical layer）
    OSI Layer 1
    以太网 调制解调器 电力线通信 同步光网络 G.709 光导纤维 同轴电缆 双绞线 更多

## 协议栈通讯示意图
TCP/IP 通讯过程为：

![](/img/tcp-ip-communication.png)

传输层及其下的机制由内核提供，应用层由用户程序提供(socket 编写的用户程序).


![](/img/tcp-ip-communication-router.png)

*物理层*指电信号的传递方式，比如以太网通用网线(双绞线,插孔是8针, RJ45 而电话线插孔是6针的,学名是RJ11)、早期以太网采用的同轴电缆(现主要用于有线电视)、光纤 等都属于物理层。
物理层的能力决定了遇大传输率、传输距离、抗干扰性等。集线器(Hub) 用于双绞线的连接及信号中继(将已衰减的信号放大使之传播得更远)。

*链路层*有以太网、令牌环网等标准，链路层负责网卡设备的驱动、帧同步(就是说从网络上检测到什么信号算作新帧开始)、冲突检测(有冲突时就自动重拔)、数据差错检验等.
链路层的设备有交换机，用于在不同的链路层之间转发数据帧(比如10M 以太网与100M 以太网之间、以太网和令牌环网之间), 由于不同链路层的帧格式不同，交换机要将进来帧拆掉链路层首部后再重新封装转发。

*网络层* 的IP 协议是构成Internet 的基础。Internet 上有大量的路由器根据IP 地址将数据包按照合适的路径转发数据包，数据包从源地址到目的地址往往要经过十多个路由器。路由器往往兼具交换机的功能，可以在不同的链路层转数据帧，因经路由器需要将进来的数据包拆掉链路层和网络层首部并重新封装。IP 协议不保证传输可靠性，数据包在传输过程中可能丢失，传输的可靠性依赖上层协议或应用程序。

*传输层* 负责端到端(end to end, 指源主机和目的主机)的传输, 而网络层负责点到点（point-to-point, 指主机或者路由器）的传输。传输层主要有TCP,UDP 协议。
TCP 是一种面向连接的、可靠的协议(就像打电话，双方拿起电话互通身份后就建立了建立，这边说的话那边*保证*能听得到，并且是按说话的顺序听到的，说完话一方挂机，通讯就终止), TCP 需要双方建立连接，然后tcp 协议保证数据收发的可靠性，丢失的数据包会自动重发, 应用层收到的数据流是可靠的。
而UDP 不面向连接、也不保证可靠性(就像写信，信丢了也不会重发，收到的信也不保证是按顺序的), 使用UDP 协议的应用程序需要自己完成丢包后重发、消息排序。

## 协议栈数据封装
应用层的数据通过协议栈发布到网上时，每层协议都会给数据加一个数据首部(header), 称为封装(encapsulation), 如下图所示：

![](/img/tcp-ip-protocol-data-encapsulation.png)

对于不同协议层的数据而言：在传输层的叫段segment, 在网络层叫数据报datagram, 在链路层叫帧frame. 数据封装成帧后发到物理层的传输介质上，到达目的主机后，数据经过每层协议时，相应的数据善就被剥离。

## 多路传输 Multiplexing
目的主机收到数据包后，如何经过各层协议栈最后到达应用程序呢？这是通过各层协议中数据包的首部 实现的多路传输Multiplexing

![](/img/tcp-ip-data-multiplexing.png)

以太网驱动程序根据数据帧首部中的“上层协议”字段确定该数据帧的有效载荷(payload, 指除去协议首部之外的实际传输数据)是IP、ARP还是RARP 数据报，然后交给相应的协议层处理。
假如是IP 数据报，IP 协议层会根据数据包首部中的“上层协议”字段确定有效载荷是TCP、UDP、ICMP还是IGMP，然后交给相应的协议处理。
假如是TCP或者UDP，TCP 或UDP协议 会根据TCP 或者 UDP 数据包首部"端口号" 字段确定有效载荷应该交给哪个应用程序去处理.

IP 地址是标识网络中不同主机的, 而端口是用于标识同一主机上不同进程地址的, IP 地址和端口号合起来标识网络中唯一的进程.

> Note: 虽然IP ARP RARP 都需要通过以太网驱动程序封装成帧, 但从功能上划分, ARP RARP 属于链路层, IP 属于网络层.
虽然ICMP, IGMP, TCP, UDP 都需要通过IP 协议封装成数据报, 但从功能上划分, ICMP IGMP 与IP 同属网络层, TCP UDP 属于传输层.

# 链路层

## 以太网Ethernet(RFC 894)帧格式
以太网规定，一组电信号构成一个数据包，叫做"帧"（Frame）。每一帧分成两个部分：标头（Head）和数据（Data）。

1. "标头"包含数据包的一些说明项，比如发送者、接受者、数据类型与CRC；"数据"则是数据包的具体内容。

以太帧格式如下:\
![](/img/tcp-ip-ethernet-frame.png)

从左到右依次为:

	目的地址(即MAC 地址):6 bytes
	源地址(MAC地址): 6 bytes
	类型: 2 bytes
		0800(IP)
			数据: 46~1500 bytes
		0806(ARP请求/应答)
			数据: 28 bytes
			PAD: 18 bytes
		8035(RARP请求/应答)
			数据: 28 bytes
			PAD: 18 bytes
	CRC: 4 bytes

其中源地址和目标地址指网卡的物理地址(MAC 地址), 长度是48 bits, 这是网卡在出厂时固化的, 可以通过ifconfig 查看(HWaddr 00:AF:13...). 帧末尾是CRC 校验码.
以太网帧规定数据长度最小46 bytes, 最大1500 bytes, ARP 与 RARP 不足46 需要padding 补齐. 最大值1500(加上head 1518) 称为以太网的最大传输单元(MTU, Max Transform Unit), 不同的网络类型有不同的MTU.
如果以太网帧上的数据长度超过MTU, 那就需要对数据包做分片(fragmentation) 多桢. ifconfig 命令的输出中也有MTU:1500. 这个1500 指的是有效数据的最大长度, 不包含帧首部的长度.

## ARP 数据报格式
> 有了数据包的定义、网卡的MAC地址、广播的发送方式，"链接层"就可以在多台计算机之间传送数据了。

我们需要一种机制，能够从IP地址得到MAC地址。分成两种情况。

1. 第一种情况，如果两台主机不在同一个子网络，只能把数据包传送到两个子网络连接处的"网关"（gateway），让网关去处理。
2. 第二种情况，如果两台主机在同一个子网络，那么我们可以用ARP协议，得到对方的MAC地址。

ARP协议也是发出一个数据包，其中包含它所要查询主机的IP地址，在。它所在子网络的每一台主机，都会收到这个数据包，从中取出IP地址，与自身的IP地址进行比较。如果两者相同，都做出回复，向对方报告自己的MAC地址，否则就丢弃这个包。
总之，有了ARP协议之后，我们就可以得到同一个子网络内的主机MAC地址，可以把数据包发送到任意一台主机之上了。

通过目的主机的IP 和 端口号就访问到目的主机上的应用程序. 但是, 在链路层, 数据包必须有目的主机的MAC硬件地址才行, 如果*目的网卡接收到的数据包的硬件地址与目的机MAC不同*, 数据包会被直接丢弃.

因此通讯前就*源主机必须获取到目的主机的硬件地址*, ARP 协议就是干这个事的. 源主机发起ARP 请求:
1. 源主机发起一个ARP 请求（包含在以太网数据包中, 包含它所要查询主机的IP地址，在对方的MAC地址这一栏，填的是FF:FF:FF:FF:FF:FF，表示这是一个"广播"地址）:
 比如这台192.168.0.1这台主机的MAC 地址是什么, 这个请求被广播到本地网段(192.168.0.*)的所有主机
2. 本地网段(192.168.0.*)中的主机监听到这个ARP 请求, 并发现这个IP就是自己, 就发送一个ARP 应答请求数据包给源主机, 并将自己的MAC 地址填写到ARP 应答数据包中.

每台主机都维护着一张*ARP 缓存表*,这样就不用每次访问某个IP 时都要通过ARP 请求获取目的主机的MAC 地址了. 缓存表的过期时间一般是20分钟.

*ARP数据报格式* 如下:\
![](/img/tcp-ip-arp-data.png)

图中源MAC地址, 目标MAC 地址在以太网首部和ARP 请求的首部各出现了一次, 这对于链路层为以太网的情况来说是多余的, 但是对于非以太网来说可能是必要的.

1. 硬件类型指链路层类型, 1 为以太网;
1. 协议类型指要转换的地址, 0x0800 指IP 地址
1. 对于以太网来说硬件地址长度是6;
1. 对于IP 地址来说, 协议地址长度是4;
1. op 字段为1 表示ARP 请求, 2 为IP 应答;

来分析ARP 请求/响应数据包!
请求帧如下(每行16 bytes)!

	以太网首部(14 bytes)
	0000: ff ff ff ff ff ff 00 05 5d 61 58 a8 08 06
	ARP帧（28字节）
	0000:                                           00 01
	0010: 08 00 06 04 00 01 00 05 5d 61 58 a8 c0 a8 00 37
	0020: 00 00 00 00 00 00 c0 a8 00 02
	填充位（18字节）
	0020:                               00 77 31 d2 50 10
	0030: fd 78 41 d3 00 00 00 00 00 00 00 00

从以请求帧数据可以看到:

	以太网首部:
		ff ff ff ff ff ff 表示目的MAC 地址是一个广播地址
		00 05 5d 61 58 a8 表示源MAC 地址
		08 06 表示上层协议是ARP
	ARP 帧:
		硬件类型00 01 表示以太网
		协议类型0800 表示IP 协议
		MAC 地址长度是06
		协议地址长度是04
		op 0x0001 表示ARP 请求
		发送端以太网地址是: 00 05 5d 61 58 a8
		发送端IP地址是: c0 a8 00 37(192.168.0.55)
		目的端以太网地址是: 00 00 00 00 00 00
		目的端IP地址是: c0 a8 00 02(192.168.0.2)
		填充18 bytes(由于以太网规定小最数据长度是46 bytes, ARP 帧只有28 bytes)

ARP 响应帧:

	以太网首部
	0000: 00 05 5d 61 58 a8 00 05 5d a1 b8 40 08 06
	ARP帧
	0000:                                           00 01
	0010: 08 00 06 04 00 02 00 05 5d a1 b8 40 c0 a8 00 02
	0020: 00 05 5d 61 58 a8 c0 a8 00 37
	填充位
	0020:                               00 77 31 d2 50 10
	0030: fd 78 41 d3 00 00 00 00 00 00 00 00

响应帧解析:

	以太网首部:
		00 05 5d 61 58 a8 表示目的MAC 地址
		00 05 5d a1 b8 40 表示源的MAC 地址
		08 06 表示上层协议是ARP
	ARP 帧:
		硬件类型00 01 表示以太网
		协议类型0800 表示IP 协议
		MAC 地址长度是06
		协议地址长度是04
		op 0x0002 表示ARP 响应
		发送端以太网地址是: 00 05 5d a1 b8 40
		发送端IP地址是: c0 a8 00 02(192.168.0.2)
		目的端以太网地址是: 00 05 5d 61 58 a8
		目的端IP地址是: c0 a8 00 37(192.168.0.55)
		填充18 bytes(由于以太网规定小最数据长度是46 bytes, ARP 帧只有28 bytes)

如果源主机和目的主机不在同一网段, ARP 请求的广播帧无法穿过路由器, 源主机与目的主机如何通信?
使用一个中转服务器 也就是  A--->B<---C，B 网关就是中转器,负责接收和转发, 这样A 和 C就能通信了
具体来说, 当源和目的主机不在同一网段时, 源主机的ARP 请求会被路由器网关B 侦听到, 然后网关ARP应答发回网关的MAC 地址. 主机就直接和B 网关通信.
B 网关是对外网的, B 网关会根据目的IP 路由到下一个出口. 网关MAC 冒充了目的主机的MAC, 这种机制叫ARP 代理(Proxy ARP ).

ARP攻击，如何防御？ https://www.zhihu.com/question/23401171
1. 路由器、交换机端校验IP/MAC
1. 客户端IP主动绑定MAC

# IP 数据报
IP 数据报格式(IPv4), 下图中的数据报已经除去以太网首部
![](/img/tcp-ip-ip-data.png)

IP 数据报的首部长度和数据长度是可变长的, 但总是4 bytes(32 bits)的整数部.

1. 对于IPv4, 4位版本字段是4.
2. 4位首部长度数值是以4 bytes 为单位的, 最小值5 表示20 bytes, 也就是不带任何IP选项的IP首部. 4位能表示的最大数值是15, 就是说首部最长为60 bytes.
3. 8位服务类型(TOS) 有3个bit 用来指定IP 数据报的优先级(目前已经废弃), 还有4个位表示可选的服务(最小延迟,最大吞吐量,最大可靠性,最小成本), 还有一个位总是0.
4. 16位部长度是整个数据报(包括IP首部和 IP payload 层数据)的字节数.
5. 每传一个IP 数据报, 16位标识加1, 可用于分片和重新组装数据报.
6. 3位标志和13 位片偏移用于分片, 3位标志DF=0 则表示允许分片,片偏移MF=0 表示没有更多分片了
7. 8位生存时间TTL(Time To Live)是这样用的: 源主机的为数据包设定一个生存时间,比如64, 每经过一个路由就减1, 如果减到0 就表示路由太长了,就丢弃这个数据包, 这个时间单位不是秒,而是跳(hop).
8. 8位协议指示上层协议是TCP/UDP/ICMP/IGMP: 8位上层协议0x11 表示UDP 协议；
9. 16位首部校验和, 只校验IP 首部,数据的检验由更高层协议负责.
10. IPv4 的地址长度是32位

如何确定数据长度? 它等于整个数据报长度(16位总长度) - 4位首部长度

# IP 地址与路由、NAT
IPv4 的IP 地址长度是4 bytes, 通常采用点分十进制表示法(dotted decimal representation).
Internet 被各种路由和网关设备分成很多网段, 这样32 位ip 地址就被分为网络号和主机号两个部分. 相同网络号的主机可以直接通信,不同网络号的主机必须通过路由转发通信.

## IP地址的划分

### 旧时的ABCDE 网段
过去的网络号划分方案, 将IP 地址分成了5类, 如下图(图片出自 TCP/IP Illustrated, Volume 1: The Protocols. W. Richard Stevens.)
![](/img/tcp-ip-ip-submask.1.png)

A类   0.0.0.0到127.255.255.255
B类 128.0.0.0到191.255.255.255
C类 192.0.0.0到223.255.255.255
D类 224.0.0.0到239.255.255.255
E类 240.0.0.0到247.255.255.255

一个A 类网络的地址数量2^24(16M) , 一个B网地址数量是2^16(65536), 一个C网地址数量是256, D 网用作多播地址, E 网保留未用.
这种网络划分方法最大的问题就是, 大多数组织都申请B 网,导致B 网地址很快被用尽. A 网却浪费了大量的地址.

### CIDR IP分类
为了更灵活分类和有效使用ip, 现在都使用子网掩码(subnet mask)来分类网络号, 而不是ip 数值本身决定网络号和主机号. 因为这种方案不区分ABC类(classless), 因为这种方案叫做CIDR(Classless Internet Routing).
通过subnet net, 多个子网就可以汇总成(summarize)一个更大的子网. 比如有8个c网,  这8个c 网站点ip 的高21 位是相同的, 就可以用高21位 为1的子网掩码汇总为一个子网,  再通过同一个ISP(Internet Service Provider) 连接到Internet. 在Internet 上只需要一个路由表项. Internet 上的数据包通过路由器到达ISP, 然后ISP 这边通过次级路由器选路到8个站点中的一个.

	`网络号= ip & subnet_mask`
	`主机号= ip & ~subnet_mask`

IP 和 subnet_mask 可以一起表示, 比如`192.168.0.1/24`, 表示ip 为`192.168.0.1`, subnet 高24位是1

相同网络号的主机位于同一局域网, RFC 1918 规定了用于局域网的私有IP, 这些IP 不会出现在Internet

1. 10.*/8 共有16,777,216(2^24) 个ip
1. 172.16.* ~ 172.31.*/12 共有1,048,576(2^20) 个ip
1. 192.168.*/16 共有65536(2^16) 个ip

另外还有一些特殊的局域网地址

1. 255.255.255.255 表示本网络内部广播, 路由器不转发这样的广播数据包
1. 主机号全为0的地址不能表示主机, 如192.168.10.0/24 它可能会因标准的不同引发混乱
1. 主机号全为1的地址, 表示广播到某一网络的所有主机, 如192.168.10.255/24
1. 127.*/8 只能用于本机环回测试(loop back), loopback 是一种特殊的网络设备, 如果数据包的目的地址是 环回地址 或者 与本机其它网络设备的IP地址相同, 则数据包不会发送到网络介质上, 而是通过环回设备再发回上层协议和应用程序. loopback 设备如下图

![](/img/tcp-ip-loopback.png)

## 路由
解析几个路由相关的名词

- 路由(名词) 数据包从源地址到目的地址所经过的路径, 由一系列路由节点构成
- 路由(动词) 某一路由节点为数据包选择下一个节点的选路过程
- 路由节点 一个具有路由功能的路由器, 它维护一张路由表，通过查询路由表来决定向哪一个接口发送数据包
- 接口 路由节点与某个网络相连的网卡接口
- 路由表 由很多路由条目构成，每个条目指明去往某个网络数据应该由哪个接口发送，其中最后一条是缺省路由条目
- 路由条目 路由表中的一行，主要由目的网络地址、子网掩码、下一跳转地址、发送接口组成，如果数据包的目的网络地址匹配表中的一行，数据包就按规定的接口发送到下一跳转地址
- 缺省路由条目 路由表的最后一行，主要由下一跳转地址和发送接口组成。

假设某主机上的网络接口配置和路由表如下:

	$ ifconfig
	eth0      Link encap:Ethernet  HWaddr 00:0C:29:C2:8D:7E
			  inet addr:192.168.10.223  Bcast:192.168.10.255  Mask:255.255.255.0
			  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
			  RX packets:0 errors:0 dropped:0 overruns:0 frame:0
			  TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
			  collisions:0 txqueuelen:100
			  RX bytes:0 (0.0 b)  TX bytes:420 (420.0 b)
			  Interrupt:10 Base address:0x10a0

	eth1      Link encap:Ethernet  HWaddr 00:0C:29:C2:8D:88
			  inet addr:192.168.56.136  Bcast:192.168.56.255  Mask:255.255.255.0
			  UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
			  RX packets:603 errors:0 dropped:0 overruns:0 frame:0
			  TX packets:110 errors:0 dropped:0 overruns:0 carrier:0
			  collisions:0 txqueuelen:100
			  RX bytes:55551 (54.2 Kb)  TX bytes:7601 (7.4 Kb)
			  Interrupt:9 Base address:0x10c0

	lo        Link encap:Local Loopback
			  inet addr:127.0.0.1  Mask:255.0.0.0
			  UP LOOPBACK RUNNING  MTU:16436  Metric:1
			  RX packets:37 errors:0 dropped:0 overruns:0 frame:0
			  TX packets:37 errors:0 dropped:0 overruns:0 carrier:0
			  collisions:0 txqueuelen:0
			  RX bytes:3020 (2.9 Kb)  TX bytes:3020 (2.9 Kb)

	$ netstat -nr # 以数字显示ip, -r 显示路由表
	or
	$ route (mac不支持用route 显示路由表)
	Kernel IP routing table
	Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
	192.168.10.0    *               255.255.255.0   U     0      0        0 eth0
	192.168.56.0    *               255.255.255.0   U     0      0        0 eth1
	127.0.0.0       *               255.0.0.0       U     0      0        0 lo
	default         192.168.10.1    0.0.0.0         UG    0      0        0 eth0

这台主机有两个以太网接口eth0(连到192.168.10.0/24)、eth1(192.168.56.0/24)，以及一个环回接口(127.0.0.0/8)

route 查看到的路由表：

1. Destination 是目的网络地址
2. Gateway 是下一跳地址
2. Genmask 是子网掩码
5. Flags
    1. U标志该条目有效 U	Up—Route is valid
    2. G 标志表示此条目的下一跳转地址是路由器地址，没有G 表示目的网络地址是本网，不需要经过路由转发(因为下一条跳转地址记为*)
	   G Gateway—Route is to a gateway router rather than to a directly connected network or host
	3. H	Host name—Route is to a host rather than to a network, where the destination address is a complete address
	4. R	Reject—Set by ARP when an entry expires (for example, the IP address could not be resolved into a MAC address)
	5. D	Dynamic—Route added by a route redirect or RIP (if routed is enabled)
	6. M	Modified—Route modified by a route redirect
	7. C	Cloning—A new route is cloned from this entry when it is used
	8. L	Link—Link-level information, such as the Ethernet MAC address, is present
	9. S	Static—Route added with the route command
4. Iface 是发送接口, 数据包通过发送接口eth 或者lo 发送到下一跳转地址Gateway.

比如192.168.56.3 这个地址匹配第2条路由条目，数据包就通过eth1 发送到本网
比如192.168.55.2 这个地址匹配默认路由条目，数据包就通过eth0 发送到下一跳路由地址192.168.10.1. 下一路由器会处理后续的跳转

## NAT(Network Address Transfer)
> Refer to: https://blog.51cto.com/381552138/1704565

从内向外，先查路由再NAT的顺序。从外向内的方向，顺序相反
1. 路由：是用路由表转发，路由interface, 会修改MAC
2. NAT: 是IP/PORT 转换，基于NAT表

NAT是通过给内网的主机分配不同端口（也可以在路由中为自己绑定端口）确定回来的包所要修改的IP/port
示例：两台主机(公网209.8.8.100)分别用tcp/icmp 访问 209.8.8.3

    $ show ip nat translations 
    Pro     Inside global     Inside local    outside local Outside global
    icmp    209.8.8.100:3     192.168.1.1:3   209.8.8.3:5     209.8.8.3:5
    tcp     209.8.8.100:25    192.168.1.1:25  209.8.8.3:80    209.8.8.3:80
    icmp    209.8.8.100:3     192.168.1.2:4   209.8.8.3:5     209.8.8.3:5
    tcp     209.8.8.100:25    192.168.1.2:26  209.8.8.3:80    209.8.8.3:80
    Inside global 公网IP
    Inside local  内网IP

# UDP 段格式
![](/img/tcp-ip-udp-data.png)

分析一下基于UDP 的TFTP 协议帧

	以太网首部
	0000: 00 05 5d 67 d0 b1 00 05 5d 61 58 a8 08 00
	IP首部
	0000:                                           45 00
	0010: 00 53 93 25 00 00 80 11 25 ec c0 a8 00 37 c0 a8
	0020: 00 01
	UDP首部
	0020：      05 d4 00 45 00 3f ac 40
	TFTP协议
	0020:                               00 01 'c'':''\''q'
	0030: 'w''e''r''q''.''q''w''e'00 'n''e''t''a''s''c''i'
	0040: 'i'00 'b''l''k''s''i''z''e'00 '5''1''2'00 't''i'
	0050: 'm''e''o''u''t'00 '1''0'00 't''s''i''z''e'00 '0'
	0060: 00

UDP 协议帧分为：

	以太网首部显示：目标MAC 00 05 5d 67 d0 b1, 而源MAC 00 05 5d 61 58 a8, 上层协议是IP(0800)
	IP首部：
		1. 4位版本号:4(100b) 即IPv4, 4位首部长度:5(101b) 即20 bytes IP首部(4位bytes是一个长度)
		2. 8位TOS 服务类型:0x00 即没有使用服务，
		3. 16位总长度字段(包括IP首部和IP 层payload):0x0053, 即83 bytes, 加上以太网首部14 bytes 整个帧共97 bytes;
		4. 16位IP报标识:0x9325, 3位标志字段和13位片偏移为0x0000，就是DF=0 允许分片, 片偏移MF=0 表示没有更多分片了.
		5. 8位TTL 生成时间是0x80; 8位上层协议0x11 表示UDP 协议；16位首部检验和是0x25ec
		6. 32 位源主机是c0 a8 00 37(192.168.0.55)
		7. 32 位目的主机是c0 a8 00 01(192.168.0.1)
	UDP 首部:
		16位源端口号: 0x05d4(1492) 是客户端的端口号, 16位目的端口号:0x0045(69) 是TFTP 服务的well-know 端口号
		16位UDP 长度:0x003f(63) bytes(包括UDP 首部和payload);
		16位UDP 检验和: 0xac40 是UDP 首部和payload 的检验和
	UDP 数据是基于文本协议的，各字段间用0x00 分隔, 开头的0x0001 表示请求读取一个文件， 接下来的字段为：
		c:\qwerq.qwe
		netascii
		blksize 512
		timeout 10
		tsize 0

一般的网络通信就像TFTP 一样包含客户端和服务端，客户端用ip和端口号标识客户端的进程，服务端用ip和端口号标识服务端的进程。因为客户端主动发起请求，服务端被动响应,客户端必须知道服务端的ip 和端口号。所以一些常见的网络协议有默认的服务器端口号，比如HTTP 默认的TCP 端口号80, FTP 默认TCP 协议端口号21，TFTP 默认UDP 协议端口号69.

*常见网络协议的默认端口*
使用客户端程序时，须指定服务端的端口号，如果不指定则使用默认的端口号（可使用man tftp, man ftp）.`/etc/services` 列出了所有well-know 常见的服务器端口号和对应的传输层协议，这个是由IANA（Internet Assigned Numbers Authority)规定的. 有些服务的端口号即可以用UDP也可以用TCP，而另外一些UDP和TCP 的同一端口号对应不同的服务

*ephemeral 端口*
很多服务有well-know 端口号，而客户端程序则没有well-know 端口号。一般是客户端每次请求时，由系统自动分配一个端口号，用完就释放，称为ephemeral(短暂的) 的端口号. 因为客户端可能要开大量的进程，占用很多端口号, 会带来端口号的冲突.

*UDP 不面向连接，不保证传输的可靠性*

1. 发送端的UDP 协议只负责把应用层传来的数据封装成段发送给IP协议层就结束了。*不会超时重发*、*不会等待应答*、*不会为数据包编号*也不返回错误信息
2. 接收端的UDP 协议只负责将来自IP 协议层的数据解包再发给应用程序, 不保证接收到的数据是按顺序的。*不会应答*、*也不会乱序重排*(数据包没有编号)
3. 通常UDP 收到的数据包会放在一个固定大小的缓冲区等待应用程序读取。UDP *没有流量控制*，如果发送数据包很快，应用程序读取很慢，则缓冲区会丢失数据包。UDP 不会因数据包丢失而报告错误

UDP 的可靠性只能依赖于应用程序。UDP 协议实现简单，一般用于可靠性不高的消息，而不是发送大量数据。比如TFTP 是基于UDP的，它只能用于传送小文件(trivial 和ftp), 而基于TCP的FTP 协议则适用于各种文件的传输。

# TCP 协议

https://jerryc8080.gitbooks.io/understand-tcp-and-udp/chapter1.html

## TCP 段数据
除于IP 首部 和 以太网首部， TCP 段的数据结构如下:\
![](/img/tcp-ip-tcp-data.png)

1. 和UDP 一样，TCP 也有16 位的源端口号和16位的目的端口号
2. 32位的序号seq: 每发送一个n字节data或一个SYN/FIN 就加n或者1
3. 32位确认序号ack: 期望收到对方下一个报文段的序号值, 即上面提到的seq+n, seq+1
4. 4位TCP首部长度, 数据偏移 Offset: (TCP 协议头长度，最长15: 4*15=60 bytes, 如果没有选项字段最短20 bytes),  TCP报文段的*数据起始处* 距离 *TCP报文的起始处* 有多远
4. Reserved: 6 bit 无用
5. URG(紧急指针)、ACK、PSH、RST、SYN、FIN是六个控制位
	1. PSH=1(Push)表示该报文段高优先级，接收方 TCP 应该尽快推送给接收应用程序，而不用等到整个 TCP 缓存都填满了后再交付。
	2. 复位 RST (Reset)严重错误，需要释放并重新建立连接。
	3. 当 SYN = 1 的时候，表明这是一个请求连接报文段。「同步报文段」。
	4. 终止 FIN (Finis) 一般称携带 FIN 的报文段为「结束报文段」。
6. 16位窗口大小: 2 字节。 告诉对方本端的 TCP 接收缓冲区还能容纳多少字节的数据.
例如，假如确认号是 701 ，窗口字段是 1000。这就表明，从 701 号算起，发送此报文段的一方还有接收 1000 （字节序号是 701 ~ 1700） 个字节的数据的接收缓存空间。
7. 16位校验和 checksum: 由发送端填充，接收端对 TCP 报文段执行 CRC 算法
7. 16位紧急指针: URG = 1 时，发送方 TCP 就把紧急数据插入到本报文段数据的最前面，而在紧急数据后面的数据仍是普通数据。
9. 选项+数据

## TCP头部选项+数据
http://book.51cto.com/art/201306/400264.htm

这部分最多包含40字节，因为TCP头部最长是60字节（TCP首部20字节的固定）。
典型的TCP头部选项结构：
```s
kind(1byte) + length(1byte) + info(n bytes)
```
说明：
1. kind=0 选项表结束选项
2. kind=1 空操作（nop）选项，没有特殊含义
3. kind=2 握手时的最大报文段长度选项（Max Segment Size，MSS）。通常将MSS设置为（MTU-40）字节（减掉的这40字节包括20字节的TCP头部和20字节的IP头部）。这样携带TCP报文段的IP数据报的长度就不会超过MTU（假设TCP头部和IP头部都不包含选项字段，并且这也是一般情况），从而避免本机发生IP分片。对以太网而言，MSS值是1460（1500-40）字节。
4. kind=3是窗口扩大因子选项。TCP连接初始化时，通信双方使用该选项来协商接收通告窗口的扩大因子。
	1. 在TCP的头部中，接收通告窗口大小是用16位表示的，故最大为65535字节，但实际上TCP模块允许的接收通告窗口大小远不止这个数（为了提高TCP通信的吞吐量）。窗口扩大因子解决了这个问题。假设TCP头部中的接收通告窗口大小是N，窗口扩大因子（移位数）是M，那么TCP报文段的实际接收通告窗口大小是N乘2M，或者说N左移M位。注意，M的取值范围是0～14。我们可以通过修改/proc/sys/net/ipv4/tcp_window_scaling内核变量来启用或关闭窗口扩大因子选项。
	1. 和MSS选项一样，窗口扩大因子选项只能出现在同步报文段中，否则将被忽略。但同步报文段本身不执行窗口扩大操作，即同步报文段头部的接收通告窗口大小就是该TCP报文段的实际接收通告窗口大小。当连接建立好之后，每个数据传输方向的窗口扩大因子就固定不变了。关于窗口扩大因子选项的细节，可参考标准文档RFC 1323。
5. kind=4是选择性确认（Selective Acknowledgment，SACK）选项。TCP通信时，如果某个TCP报文段丢失，则TCP模块会重传最后被确认的TCP报文段后续的所有报文段，这样原先已经正确传输的TCP报文段也可能重复发送，从而降低了TCP性能。SACK技术正是为改善这种情况而产生的，它使TCP模块只重新发送丢失的TCP报文段，不用发送所有未被确认的TCP报文段。选择性确认选项用在连接初始化时，表示是否支持SACK技术。我们可以通过修改/proc/sys/net/ipv4/tcp_sack内核变量来启用或关闭选择性确认选项。
6. kind=5是SACK实际工作的选项。该选项的参数告诉发送方本端已经收到并缓存的不连续的数据块，从而让发送端可以据此检查并重发丢失的数据块。每个块边沿（edge of block）参数包含一个4字节的序号。其中块左边沿表示不连续块的第一个数据的序号，而块右边沿则表示不连续块的最后一个数据的序号的下一个序号。这样一对参数（块左边沿和块右边沿）之间的数据是没有收到的。因为一个块信息占用8字节，所以TCP头部选项中实际上最多可以包含4个这样的不连续数据块（考虑选项类型和长度占用的2字节）。
7. kind=8是时间戳选项。该选项提供了较为准确的计算通信双方之间的回路时间（Round Trip Time，RTT）的方法，从而为TCP流量控制提供重要信息。我们可以通过修改/proc/sys/net/ipv4/tcp_timestamps内核变量来启用或关闭时间戳选项。

## 实际的SYN 包
我们来看一段实际的一段SYN 包：
```s
21:43:45.360608 IP 106.120.206.249.60987 > 120.24.83.10.81: Flags [S], seq 1244600374, win 65535, options [mss 1386,nop,wscale 5,nop,nop,TS val 802678219 ecr 0,sackOK,eol], length 0
	0x0000:  4514 0040 d98f 4000 3006 6c80 6a78 cef9  E..@..@.0.l.jx..
                 IPv4: version:4, 长度:5(20 bytes) tos:14, 16位整个数据报总长度: 0040(IP首部+IP payload 层, 0040=64bytes)
                    d98f:(55695) 每传一个IP 数据报, 16位标识加1, 可用于分片和重新组装数据报
                        当数据报由于长度超过网络的MTU而必须分片时，这个标识字段的值就被复制到所有的数据报的标识字段中。
                        相同的标识字段的值使分片后的各数据报片最后能正确地重装成为原来的数据报。
                    4000: 
                        1. 3位标志: 但目前只有2位有意义
                            最低位记为MF(More Fragment)。
                                MF=1即表示后面“还有分片”的数据报。
                                MF=0表示这已是若干数据报片中的最后一个。
                            中间的一位记为DF(Don’t Fragment)，意思是“不能分片”。
                                只有当DF=0时才允许分片
                        2. 13 位片偏移用于分片
                            片偏移以8个字节为偏移单位。除了最后一个分片，每个分片的长度一定是8字节（64位）的整数倍。
                    3006:
                        1. 8位生存时间TTL(Time To Live)是这样用的: 源主机的为数据包设定一个生存时间,比如64, 每经过一个路由就减1, 如果减到0 就表示路由太长了,就丢弃这个数据包, 这个时间单位不是秒,而是跳(hop).
                        1. 8位协议指示上层协议是TCP/UDP/ICMP/IGMP: 8位上层协议0x11 表示UDP 协议；
                    6c80:
                        1. 16位首部校验和, 只校验IP 首部,数据的检验由更高层协议负责.
                    6a78 cef9: IPv4 的源地址长度是32位
	0x0010:  7818 530a ee3b 0051 4a2f 1836 0000 0000  x.S..;.QJ/.6....
                IPv4:
                    7818 530a: IPv4 的目标地址长度是32位
                TCP:
                    ee3b 源端口 0051 目标端口
                    4a2f 1836(seq=1244600374) 32序号
                    0000 0000(ack=0) 32位确认序号

	0x0020:  b002 ffff cc1d 0000 0204 056a 0103 0305  ...........j....
                      b002 :  4位TCP首部长度(1011b: 4*11=44bytes, 选项字段占24)+6位保留位+6bit组(URG/ACK/PSH/RST/SYN/FIN)
					  ffff : window: 65535
					  cc16: 16bit检验和=52246
					  0000: 没有设置URG, 紧急指针无意义 TCP头20 bytes结束
					  0204: kind=2, length(MSS)=4 (4x4=16bit, 2bytes)
					  056a: MSS=1386 bytes
					  01: kind=1,nop, 
					  0303: kind=3 窗口扩大因子, length=3
					  05: 

	0x0030:  0101 080a 2fd7 e5cb 0000 0000 0402 0000  ..../...........
```

## TCP connect,TCP 连接
下图是TCP 连接建立与断开示意图：两条竖线表示两端，向下表示时序，数据包从一端到另一端是需要时间的，所以箭头是斜的;

箭头上方标示的是数据包，比如:` SYN,8000(0),ACK 1001, <mess 1024> ` 表示SYN 位有效，32位序号是8000, 不含有效载荷(0,数据字节0)，ACK 位有效，32位确认序号是1001, 带mess 选项值为1024(最大段尺寸).

![](/img/tcp-ip-tcp-connect.png)

### TCP 连接建立过程是：
1. 客户端发出段1，SYN 请求序号seq是1000，这个序号在每发送一个数据字节或者SYN/FIN 位时就加1，即用于数据包重排，也可用于丢包检查。
另外，规定*SYN 位和FIN 位也要占1个序号*，虽然没有发送数据，但是由于发送了一个SYN, 下次再发送应该用序号1001.
*mess 表示最大段尺寸*，如果一个段太大，封装成帧后超过链路层帧的最大帧长度，就必须在IP 层分片，为避免这种情况，客户端必须声明自己支持的最大段尺寸，建议服务器发来的段不要超过这个长度。
2. 服务器发出段2，也带SYN 位，同时带ACK 应答表示确认，确认序号是1001(表示1000 序号及以前的所有段都已经收到),下次发送请求时应该使用序号是1001的段，也就是应答来自客户端的请求。同时，通过SYN 向客户端发起连接请求，请求序号是8000, 声明自己能接受的最大段尺寸是1024bytes
3. 客户端针对来自服务端的SYN 8000 连接请求 作出应答：ACK 8001

通过SYN-ACK 机制就建立了客户端到服务器(SYN-ACK)，以及服务器到客户端的两个连接(SYN-ACK)，在这个建立过程中，一共有3次握手(其中服务器发起的连接SYN 请求与ACK 响应合并为一个段发出), 叫three-way-handshake. 连接的建立确立了: 双方的数据包的初始序号，最大段尺寸

> SYN/ACK Synchronize/Acknowledge

异常位*RST*
在TCP 协议中，如果接收方收到段，读取到的端口没有匹配到本机的进程，就会应答一个包含RST 复位的段。例如机器并没有任何进程使用8080 端口，如果客户端用telnet 连接8080端口，服务器就会应用一个RST 段

	$ telnet 192.168.0.200 8080
	Trying 192.168.0.200...
	telnet: Unable to connect to remote host: Connection refused

### TCP 数据传输过程
1. 客户端发送段4，序号为1001(带20 bytes 数据), 并在ACK 应答中告诉接收方8001 序号之前的数据已经收到了
2. 服务端发送段5，序号是8001(带10 bytes 数据), 并在ACK应答中告诉客户端1021 序号之前(1001-1020)的数据都收到了
3. 客户端发送段6, 在ACK 应答中告诉服务端8011 序号前的段(8001-8010)都已经收到。

*为什么要有ACK 和 确认序号？
	这是为了确保对方能正确接收到数据，如果一方发出SYN 段后，另一方没有在有限时间内返回ACK 应答，或者确认序号显示有序号 丢失，那就需要重发SYN 数据包(应用程序将数据交给TCP 协议层时，每次发送的数据包会被缓冲到发送缓冲区，直到收到ACK 应答并确认数据包被安全的发送到目的地)

*TCP 协议是全双工(full-duplex)的协议*

- TCP 协议并非是一问一答的情景，当TCP 连接建立后，任何一方都可以同时向对方主动发起数据.
- 半双工(half-duplex) 的协议在同一时间的，只能是一方向另一方发数据，这样话，就不需要双方各自己维护一套序号了

### TCP 关闭连接的过程
1. 客户端发送段7, FIN，发送序号是1021（0）,ACK 应答显示8011 序号前的段已经收到
2. 服务端发送段8，ACK 应答说1022 前的段已经收到(客户端关闭连接, 开始处理半连接状态)
3. 服务端发送段9，FIN, 发送序号是8011(0), ACK 应答说1022 前的序号已经收到
4. 客户端发送段10，ACK 应答说8012 前的序号已经收到(服务端关闭连接)

TCP 关闭连接时，通常需要4次握手，因为服务端的ACK 应答与FIN 请求没有合并到一个段。
这样就允许半连接的状态存在了: 服务器还可以向客户端发送数据。

### TCP 流量控制
UDP 中如果发送方的速度快于接收方，会导致接收方因来不及读取缓冲区则丢失数据段. TCP 使用滑动窗口(Sliding Window)控制发送速度(也就是将接收缓冲区大小反馈给对方), 如图:
![](/img/tcp-ip-tcp-sliding-window.png)

连接建立：

1. 发送端发起连接请求1：SYN 0(0), 窗口大小4k（我的接收缓冲区空闲4K), 声明最大段尺寸1460
2. 接收端发起被动请求2：SYN 8000(0), 并返回ACK 1, 窗口大小6k(我的接收缓冲区空闲6k), 最大段尺寸1024
3. 客户端应答3: ACK 8001(0), win(4k)

通过连接发送数据段(通过win 控制发送速度, 不至于使接收方缓冲区溢出)：

1. 发送方发送数据4：1(1024), ACK 8001(0), win(4k) 接收方win还剩余5k
1. 发送方发送数据5：1025(1024), ACK 8001(0), win(4k) 不需要确认上一个数据段被接收到，就可以发送第二个段，只需要确定对方的缓冲区没有溢出
3. 发送方发送数据6: 2049(1024), ACK 8001(0), win(4k) 接收方win还剩余3k
3. 发送方发送数据7: 3073(1024), ACK 8001(0), win(4k) 接收方win还剩余2k
3. 发送方发送数据8: 4097(1024), ACK 8001(0), win(4k) 接收方win还剩余1k
3. 发送方发送数据9: 5121(1024), ACK 8001(0), win(4k) 接收方win还剩余0k, 不能再发送数据了
4. 接收方返回消息10: ACK 6145, win 2k, 接收方win还剩余2k
4. 接收方返回消息11: ACK 6145, win 4k, 剩接收方win还剩余4k
3. 发送方发送数据12: 6145(1024), ACK 8001(0), win(4k), 接收方win还剩余3k
3. 发送方发送数据和关闭请求13: FIN, 7169(1024), ACK 8001(0), win(4k), 接收方win还剩余2k

接收方读取接收缓冲区的剩余数据，并关闭连接：

1. 接收方读取数据14：ACK 8194(7169+1024+FIN), win 2k (发送方关闭连接)
1. 接收方读取数据15：ACK 8194(7169+1024+FIN), win 4k
1. 接收方读取数据16：ACK 8194(7169+1024+FIN), win 6k
1. 接收方关闭连接17：FIN, 8001(0), ACK 8194(7169+1024+FIN), win 6k
1. 发送方应答关闭连接18：ACK 8002, win 4k (接收方关闭连接)

从图中可以看到窗口读取完数据后会向右滑动，所以叫滑动窗口（Sliding Window), 它保证了:

1. 当对方的接收win 满了，就停止发送数据段
2. 发送方需要以不超过最大段尺寸的长度(本例是1k )发送数据， 而接收方则可以以任意长度读取数据. 因为应用程序会把数据看作一个整体，或说是一个流stream; 在底层数据会被拆分成多个包，这对应用程序是不可见的。因此TCP 协议是面向流stream 的，而UDP 协议是只能以消息为单位，而不是一次提供任意字节的数据。

### 缓冲区
发送缓冲区、接收缓冲区设置

    int setsockopt(SOCKET s,int level,int optname,const char* optval,int optlen);

    SOCKET socket = ...
    int nRcvBufferLen = 64*1024;
    int nSndBufferLen = 4*1024*1024;
    int nLen          = sizeof(int);

    setsockopt(socket, SOL_SOCKET, SO_SNDBUF, (char*)&nSndBufferLen, nLen);
    setsockopt(socket, SOL_SOCKET, SO_RCVBUF, (char*)&nRcvBufferLen, nLen);

查看linux tcp(read/write) buffer size 的min/defaut/max ：

    [root@node2 ~]# cat /proc/sys/net/ipv4/tcp_rmem
    4096 87380 4194304
    [root@node2 ~]# cat /proc/sys/net/ipv4/tcp_wmem
    4096 16384 4194304

解释：

    http://www.man7.org/linux/man-pages/man7/tcp.7.html
       tcp_rmem (since Linux 2.4)
              This is a vector of 3 integers: [min, default, max].  These
              parameters are used by TCP to regulate receive buffer sizes.
              TCP dynamically adjusts the size of the receive buffer from
              the defaults listed below, in the range of these values,
              depending on memory available in the system.

       tcp_wmem (since Linux 2.4)
              This is a vector of 3 integers: [min, default, max].  These
              parameters are used by TCP to regulate send buffer sizes.  TCP
              dynamically adjusts the size of the send buffer from the
              default values listed below, in the range of these values,
              depending on memory available.

If the receive buffer is full and the other end of the TCP connection tries to send additional data, the kernel will refuse to ACK the packets. 
the sender blocks or gets `EAGAIN/EWOULDBLOCK`(non-block), depending on blocking/non-blocking mode.
This is just regular [TCP congestion control](https://en.wikipedia.org/wiki/TCP_congestion_control).
https://stackoverflow.com/questions/12931528/c-socket-programming-max-size-of-tcp-ip-socket-buffer

Note:
一个socket有两个滑动窗口(一个sendbuf、一个recvbuf)，两个窗口的大小是通过setsockopt函数设置
1. 发送方的滑动窗口维持着当前发送的帧序号，已发出去帧的计时器，接收方当前的窗口大小(由接收方ACK通知)
2. 接收方滑动窗口保存的有已接收的帧信息、期待的下一帧的帧号等
 
# TCP/IP 的状态转移图
第一幅图是根据W.Richard Stevens的《TCP/IP详解》一书的TCP状态转换图，第二幅图是@neo 所注的注解，出处[coolshell](http://coolshell.cn/articles/1484.html)

![](/img/tcp-ip-state-transfer.1.jpg)

![](/img/tcp-ip-state-transfer.2.jpg)

我自己画了一幅比较简单状态图ppt , 补充了FIN_WAIT1 FIN_WAIT2 两种状态

![](/img/tcp-ip-state-transfer.3.png)

关于 TIME_WAIT 过渡到 CLOSED 状态说明：
从 TIME_WAIT 进入 CLOSED 需要经过 2MSL，其中 MSL 就叫做 最长报文段寿命（Maxinum Segment Lifetime），根据 RFC 793 建议该值(TCP_TIMEWAIT_LEN)这是为 2 分钟,(Linux 默认是30s)，也就是说需要经过 4 分钟，才进入 CLOSED 状态。

[tcp-ip.key](/doc/tcp-ip.key)

## 为什么要有2MSL的 TIME_WAIT, 不直接进入CLOSED：
1. 防止因为客户端因为回应的ACK丢失，*服务端一直处于LAST_ACK 状态*: 在MSL 时间内，服务端没有收到ACK, 会重新发起FIN, 直到：
    1. 放弃断开连接
    2. 收到ACK包结束
    3. 收到RST包重启
2. 防止上一次连接中的包，迷路后重新出现，影响新连接(经过2MSL,上一次连接中所有的重复包都会消失)

TIME_WAIT 连接太多会占用端口资源(src:ip+port,dst:ip+port)和内存，可以考虑:
1. tcp_tw_recycle tcp_tw_reuse
2. tcp_max_tw_buckets设置为很小的值(默认是18000). 
    1. 当TIME_WAIT连接数量达到给定的值时，所有的TIME_WAIT连接会被立刻清除，并打印警告信息。没有等到2MSL 关闭，会影响新连接
3. 减小TCP_TIMEWAIT_LEN值，减少等待时间，需要编译

## tcp_tw_reuse tcp_tw_recycle 
### tcp_tw_reuse 
将处于TIME_WAIT状态的socket用于新的TCP连接，影响连出的连接。
1. 只适合客户端发起方(TIME_WAIT一般出现在发起方)
2. TIME_WAIT创建时间超过1秒才可以被复用

tcp_tw_recycle=1 是更激进的快速回收( removed from Linux 4.12), 
1. 没有1秒的限制(远端来的包时间戳小于上次记录的时间戳就丢). 
但是这个时间戳是相对的，nat/lvs 等没法保证时间戳是单调递增的(多个客户端的时间戳不同步）

LVS 做负载均衡(一种NAT)，当请求到达 LVS 后，它修改地址数据后便转发给后端服务器，但不会修改时间戳数据
1. 对于后端服务器来说，请求的源地址就是 LVS 的地址: 原本不同客户端的请求经过 LVS 的转发，就可能会被认为是同一个连接
2. 加之不同客户端的时间可能不一致，所以就会出现时间戳错乱的现象

导致客户端明明发送的 SYN，但服务端就是不响应 ACK，确认数据包不断被丢弃的现象：

    shell> netstat -s | grep timestamp … packets rejects in established connections because of timestamp

参考：https://juejin.im/post/5c0642e65188251a82662912

## socket: Broken pipe
对一个对端已经关闭的socket调用两次write, 第二次将会生成SIGPIPE信号
比如:
1. curl 因为execute_timeout 超时, 关闭socket(不是connect_time)

# Security

## SYN FLOOD
如果C 向S 发送大量的带有伪造的client ip 的询问包SYN, S 就会向不存在的client ip 发送SYN/ACK 包信息。 当S 发送了SYN/ACK 后，S 会进程一个half-open 的半开状态(不是半连接单工)，这种状态非常耗费系统的资源，Client ip 是伪造的，S 就会进入漫长的等待。当这种半开状态的连接超过一定值时，服务器会因为资源耗尽而瘫痪。

- 如果确定服务器受到了SYN FLOOD?
用netstat 查看是否有大量的`SYN_RCVD`连接(握手的第二步)

服务器往往半开连接数限制都比较大（或者干脆没限制)，可以设置一下这个值以应对SYN FLOOD.

## http 请求无响应
有次排查了一个奇怪的问题：

    for ((i=0;i<100;i++>)); do curl 'http://local/hello'; done
    有几台卡在connect(syn_sent)

奇怪的是localhost 都卡在connect
1. 先netstat -an 发现TIME_WAIT 非常多
    1. /var/log/messager 也有包time wait bucket table overflow
        1. 统计TIME_WAIT 有1w: `netstat -nt|awk  '/^tcp/{++state[$NF]} END{for k in state print k,"\t",state[k]}'`
            TIME_WAIT 135975
            CLOSE_WAIT 2...
        2. 但是net.ipv4.tcp_max_tw_buckets 为18000 没超啊, 改大也没用 `sysctl -w net.ipv4.tcp_max_tw_buckets=500000`
    2. 对比两台机器参数: `sysctl -a|grep net` 发现改成`net.ipv4.tcp_syncookies=1`就正常了. 

`man 7 tcp;man listen` 了解下:
1. net.ipv4.tcp_max_syn_backlog 服务端处理SYN_RECV状态的连接队列长度，就是半连接，多余的就丢包，客户端无响应
2. net.core.somaxconn
    1. 首先，listen方法支持一个叫backlog的参数，这个参数定义的值为已经完成三次握手但应用层还没有来得及accept的连接队列长度。当队列满时，新来的请求将收到ECONNREFUSED错误。
    2. somaxconn限制了这个backlog可以设置的最大上限(比如1024).
        如果listen的backlog大于net.core.somaxconn，那么实际的backlog将是net.core.somaxconn。
3. net.ipv4.tcp_syncookies=1, 用于阻止 SYN flood 攻击的技术: [SYN Cookie的原理和实现](https://blog.csdn.net/zhangskd/article/details/16986931)
    0. 接收到SYN包并返回TCP SYN+ACK包时，不分配一个专门的数据区，而是根据这个SYN包计算出一个cookie值,作为将要返回的SYN ACK包的初始序列
    1. 允许服务器当 SYN 队列被填满时避免丢弃*新连接*。相反，服务器会表现得像 SYN 队列扩大了一样。服务器会返回适当的 SYN+ACK 响应，但会*丢弃 SYN 队列条目*

复盘：
SYN_RECV队列已经超过了tcp_max_syn_backlog的长度，导致后续的请求直接被丢弃，客户端无法收到任何响应直到请求超时。
通过设置syn_cookie的值/或者增加tcp_max_syn_backlog，使得在半连接队列满时仍然可以响应请求。

# Config
如果压测的时候出现大量的`[error] socket: 2001824064 address is unavailable.: Cannot assign requested address`

客户端频繁的连服务器，由于每次连接都在很短的时间内结束，导致很多的TIME_WAIT，以至于用光了可用的端口号，所以新的连接没办法绑定端口，所以 要改客户端机器的配置

在/etc/sysctl.conf里加, 或者在命令行：

	sysctl net.ipv4.tcp_timestamps=1 # 开启对于TCP时间戳的支持,若该项设置为0，则下面两项设置 不起作用
	sysctl net.ipv4.tcp_tw_reuse=1 # 表示开启重用。允许将TIME-WAIT sockets重新用于新的TCP连接，默认为0，表示关闭；
	sysctl net.ipv4.tcp_tw_recycle=1 # 表示开启TCP连接中TIME-WAIT sockets的快速回收( removed from Linux 4.12)

# 参考
- 本文图文均参考[TCP/IP 协议]

[TCP/IP 协议]: http://akaedu.github.io/book/ch36.html
