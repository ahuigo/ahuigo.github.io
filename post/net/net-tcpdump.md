---
layout: page
title:	tcpdump
category: blog
description:
---
# tcpdump
example: https://www.rationallyparanoid.com/articles/tcpdump.html
book:

学术的说，tcpdump是一种嗅探器（sniffer），利用以太网的特性，通过将网卡适配器（NIC）置于混杂模式（promiscuous）来获取传输在网络中的信息包。

tcpdump可以分为三大部分内容，第一是“选项”，第二是“过滤表达式”，第三是“输出信息”。

> 要用tcpdump抓包，一定要切换到root账户下，因为只有root才有权限将网卡变更为“混杂模式”。

## tcpdump 解析图
    https://github.com/ahuigo/py-lib/blob/master/socket/tcpdump-parse.txt

## tshark
tshark 介绍：https://www.zhihu.com/question/31188903
tshark比较新是wireshark的命令行版。 它和tcpdump 都是基于libpcap的，也都是生成的cap格式文件。

# tcpdump Example

	sudo tcpdump -i lo0 -n -X  -c 1 port 8000
	sudo tcpdump -i en0 -n -X  -c 1 port 8000

	-i interface
		lo0 监听lo0
		any 所有接口(not support promiscuous，监听其它主机的接口 )
	-n
		遇到协议号或端口号时，不要将这些号码转换成对应的协议名称或端口名称。比如，我们希望显示21，而非tcpdump自作聪明的将它显示成FTP。
	-X, -x(小写显示hex，以及显示ascii)
		把协议头和包内容都以16 进制显示出来（tcpdump会以16进制和ASCII的形式显示），这在进行协议分析时是绝对的利器。
	-A
		选项，则tcpdump只会显示ASCII形式的数据包内容，不会再以十六进制形式显示；

	-XX, -xx(小写显示hex，不显示ascii)
		选项，则tcpdump会从以太网部分就开始显示网络包内容，而不是仅从网络层协议开始显示。一般不需要这么低层
	-c count
		只抓一个包
    -S  ack 显示绝对序列号. 默认ack 只会响应seq 的偏移量(相对初始seq)
        ack 是告诉对应下一个包的seq从ack开始
	port 8000
		监听8000 端口

结果示例：

	19:31:52.674271 IP 127.0.0.1.60474 > 127.0.0.1.8000: Flags [S], seq 3581460068, win 65535, options [mss 16344,nop,wscale 5,nop,nop,TS val 652417598 ecr 0,sackOK,eol], length 0
		0x0000:  4500 0040 a548 4000 4006 0000 7f00 0001  E..@.H@.@.......
		0x0010:  7f00 0001 ec3a 1f40 d578 be64 0000 0000  .....:.@.x.d....
		0x0020:  b002 ffff fe34 0000 0204 3fd8 0103 0305  .....4....?.....
		0x0030:  0101 080a 26e3 1a3e 0000 0000 0402 0000  ....&..>........

	1 packet captured
	15 packets received by filter
	0 packets dropped by kernel

# output

    tcpdump -n -s 0
    tcpdump -i any -p -s 0 -w ./netCapture.pcap

    -C filesize 表示存储文件的最大大小；
    -c 5 只抓5个
    -s 表示抓取的网络请求返回的大小，0表示抓取整个网络包；
    -w 表示抓取的包保存的文件路径，此时不会在标准输出打印
    -p, --no-promiscuous-mode
      Don't put the interface into promiscuous mode.
      如果不带 -p 参数，tcpdump 会默认尝试将网络接口设置为“混杂模式”（Promiscuous Mode）: 会捕获物理网络上（同一冲突域或广播域内）所有流经它的数据包，无论这些包的目标地址是不是本机。

    -n     Don't convert addresses (i.e., host addresses, port numbers, etc.) to names

## promiscuous mode, 混杂模式
1. 混杂模式: 让网卡抓取任何经过它的数据包，不管这个数据包是不是发给它或者是它发出的;
2. 如果要使用tcpdump抓取 *其他主机MAC地址* 的数据包，必须开启网卡混杂模式，

混杂模式是针对网卡而言的
1. Wireshark默认在混杂模式下抓包，只要经过网卡的数据包都抓取下来
2. unix(windows 下混杂所有网卡) 下只有root用户可以开启混杂模式，开启混杂模式的命令是：

    ifconfig eth0 promisc;# eth0是你要打开混杂模式的网卡

# interface
如果想知道我们可以通过哪几个网卡抓包，可以使用-D参数，如：

    $ tcpdump -D
	0.lo0 127.0.0.1
    1.en0
    2.awdl0
    3.bridge0
    4.en1

# 以太网信息

	-e 显示以太网信息
	sudo tcpdump -i lo0 -n -c 1 -e

它会多一些这样的以太信息：

	AF IPv4 (2)
	OUI，即Organizationally unique identifier，是“组织唯一标识符”，在任何一块网卡（NIC）中烧录的6字节MAC地址中，前3个字节体现了OUI，其表明了NIC的制造组织。通常情况下，该标识符是唯一的。

回顾一下以太网塄我的头格式：

	struct sniff_ethernet {
		u_char ether_dhost[ETHER_ADDR_LEN]; /*目的主机的地址*/
		u_char ether_shost[ETHER_ADDR_LEN]; /*源主机的地址*/
		u_short ether_type; /*IP? ARP? RARP? etc*/
	};

    -l 输出行变为行缓冲
        -l选项的作用就是将tcpdump的输出变为“行缓冲”方式，这样可以确保tcpdump遇到的内容一旦是换行符即将缓冲的内容输出到标准输出，以便于利用管道或重定向方式来进行后续处理。

众所周知，Linux/UNIX的标准I/O提供了全缓冲、行缓冲和无缓冲三种缓冲方式。标准错误是不带缓冲的，终端设备常为行缓冲，而其他情况默认都是全缓冲的。

大家在使用tcpdump时，有时会有这样的需求：“对于tcpdump输出的内容，提取每一行的第一个域，即”时间域”，并输出出来，为后续统计所用”，这种场景下，我们就需要使用到-l来将默认的全缓冲变为行缓冲了。

	$ tcpdump -i eth0 -l |awk '{print $1}' ;#打印时间
	tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
	listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
	22:56:57.571680
	22:56:57.572103
	22:56:57.599515

> 如果不加-l选项，那么只有全缓冲区满，才会输出一次

# Info detail
tcpdump 也可以指定抓包过滤器，其过滤器语言叫做Berkeley包过滤，简称BPF语言。

## -e show mac address

    tcpdump -i INTERFACENAME -e

## -t 输出时不打印时间
不打印开始的时间

	➜  test  sudo tcpdump -i lo0 -c 1
	20:42:28.372742 IP 10.209.12.156.61361 > 10.209.12.156.vcom-tunnel: Flags [S], seq 3578874752, win 65535, options [mss 16344,nop,wscale 5,nop,nop,TS val 656096720 ecr 0,sackOK,eol], length 0

	➜  test  sudo tcpdump -i lo0 -c 1 -t
	IP 10.209.12.156.61360 > 10.209.12.156.vcom-tunnel: Flags [S], seq 3383994986, win 65535, options [mss 16344,nop,wscale 5,nop,nop,TS val 656089608 ecr 0,sackOK,eol], length 0

## -v, 更详细的信息
加了-v选项之后，在原有输出的基础之上，你还会看到tos值、ttl值、ID值、总长度、校验值等。

	$ sudo tcpdump -i lo0 -c 1 -t -v
	IP (tos 0x0, ttl 64, id 30913, offset 0, flags [DF], proto TCP (6), length 64, bad cksum 0 (->931d)!)
    10.209.12.156.61400 > 10.209.12.156.vcom-tunnel: Flags [S], cksum 0x2f0c (incorrect -> 0x560f), seq 1836931889, win 65535, options [mss 16344,nop,wscale 5,nop,nop,TS val 656308489 ecr 0,sackOK,eol], length 0

`-vv` `-vvv`:

	-vv   Even  more  verbose output.  For example, additional fields are printed from
		  NFS reply packets, and SMB packets are fully decoded.

	-vvv  Even more verbose output.  For example, telnet SB ... SE options are printed
		  in full.  With -X Telnet options are printed in hex as well

## -F 指定过滤表达式所在的文件
如果过滤表达式有多个，可以将其写到一个文件`filter.txt`中，然后用`-F filter.txt` 指定

	$ cat filter.txt
	tcp
	port 8001

## -w -r 流量保存与回放
保存流量：

	$ tcpdump -i eth0 -w flowdata

flowdata 是一个binary! 查看的话需要借助`-r`

	sudo tcpdump -r flowdata

# tcp
参考`man tcpdump`找到 TCP Packets

分析tcp 包时，不要限制`dst or src`：

	sudo tcpdump -i en5 -n -A host ahuigo.github.io

## 三次握手
```
IP 101.40.192.114.32783 > 120.24.83.10.cslistener: Flags [S], seq 1971667394, win 65535, options [mss 1452,nop,wscale 5,nop,nop,TS val 1164830998 ecr 0,sackOK,eol], length 0
IP 120.24.83.10.cslistener > 101.40.192.114.32783: Flags [S.], seq 421939181, ack 1971667395, win 28960, options [mss 1460,sackOK,TS val 722141796 ecr 1164830998,nop,wscale 7], length 0
IP 101.40.192.114.32783 > 120.24.83.10.cslistener: Flags [.], ack 1, win 4140, options [nop,nop,TS val 1164831047 ecr 722141796], length 0
IP 101.40.192.114.32783 > 120.24.83.10.cslistener: Flags [P.], seq 1:82, ack 1, win 4140, options [nop,nop,TS val 1164831047 ecr 722141796], length 81
IP 120.24.83.10.cslistener > 101.40.192.114.32783: Flags [.], ack 82, win 227, options [nop,nop,TS val 722141845 ecr 1164831047], length 0
IP 120.24.83.10.cslistener > 101.40.192.114.32783: Flags [P.], seq 1:331, ack 82, win 227, options [nop,nop,TS val 722141849 ecr 1164831047], length 330
IP 120.24.83.10.cslistener > 101.40.192.114.32783: Flags [F.], seq 331, ack 82, win 227, options [nop,nop,TS val 722141850 ecr 1164831047], length 0
IP 101.40.192.114.32783 > 120.24.83.10.cslistener: Flags [.], ack 331, win 4129, options [nop,nop,TS val 1164831097 ecr 722141849], length 0
IP 101.40.192.114.32783 > 120.24.83.10.cslistener: Flags [.], ack 332, win 4129, options [nop,nop,TS val 1164831097 ecr 722141850], length 0
IP 101.40.192.114.32783 > 120.24.83.10.cslistener: Flags [F.], seq 82, ack 332, win 4129, options [nop,nop,TS val 1164831097 ecr 722141850], length 0
IP 120.24.83.10.cslistener > 101.40.192.114.32783: Flags [.], ack 83, win 227, options [nop,nop,TS val 722141898 ecr 1164831097], length 0
```

## format
> man 8 tcpdump 

The general format of a tcp protocol line is:

	src > dst: flags data-seqno ack window urgent options

1. Flags are some combination of:
  S (SYN), F (FIN), P (PUSH), R (RST), U (URG), W (ECN CWR), E (ECN-Echo) or `.(ACK)`, or `none` if no flags are set. 
  
2. Data-seqno: \
	describes the portion of sequence space covered  by  the  data in this packet . 
3. Ack: \
	is sequence number of the next data expected the other direction on this connection. 
4. Window: \
	is the number of bytes of  receive *buffer space available* the other direction on this connection.  
5. Urg: \
indicates there is `urgent' data in the packet. 
6. Options are tcp options enclosed in angle brackets: see net-tcpip.md
       (e.g., <mss 1024>).

## 绝对序列号seq
tcp在收到第一条数据包之后，后续的数据包，是使用之前数据包的偏移来显示的，这个“1” 就是seq 4071349707的偏移1，也就是4071349708.
如果一开始不习惯这样，同时验证这个说法，我们可以使用tcpdump -i lo -S 来打印出绝对序列号

# filter
可以通过命令man pcap-filter来查得


    sudo tcpdump -i eth0 -n "dst host 192.168.1.1 and dst port 80"
    sudo tcpdump -i any -Xn "host 192.168.1.1 and port 80"

## logic
在 tcpdump 的过滤表达式中，逻辑运算符: not , and , or。

	'condition1 and condition2 or condtion3'
        相当于： 'condition1 and (condition2 or condtion3)'
	'condition1 or condition2 and condtion3'

## filter help
packet filter syntax

	man pcap-filter

> 你会发现，过滤表达式大体可以分成三种过滤条件，“类型”、“方向”和“协议”，这三种条件的搭配组合就构成了我们的过滤表达式。

## complex filter
精确地捕获那些**带有实际数据负载**的 TCP 包:
这个 `tcpdump` 过滤器 `'(((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'` 

让我们一步步来拆解它：

- `ip[2:2]`**: 表示从 IP 头部偏移 2 个字节开始，读取 2 个字节。
    * 结果：`ip[2:2]` = IP 数据包的总长度（包含 IP 头部和其后的所有数据，单位：字节）。**
- `ip[0]` 是 IP 头部第一个字节。
    * IP 头部第一个字节的前 4 位是 IP 版本号
    * 后 4 位是 **IP 头部长度 (Internet Header Length, IHL)
- `ip[0]&0xf`:提取出 **IHL** 字段的值。
- `ip[0]&0xf)<<2)`:  因为 IHL 的单位是 4 字节的字，所以将其乘以 4 即可得到以字节为单位的 IP 头部长度。
    * 结果：`((ip[0]&0xf)<<2)` = IP 头部长度（单位：字节）。**

- `ip[2:2] - ((ip[0]&0xf)<<2)`**:
    *  这个表达式计算的是：`(IP 数据包总长度) - (IP 头部长度)`。 
    * 结果：`ip payload length` = IP 数据包的负载长度（即 IP 头部之后的数据部分的长度）
    * 对于 TCP 数据包来说，这就是整个 TCP 段（包含 TCP 头部和 TCP 有效载荷）的长度，单位：字节。

解析 TCP 头部长度
*   **`tcp[12]`**:
    *   `[12]` 表示从 TCP 头部偏移 12 个字节开始，读取 1 个字节。
    *   在 TCP 头部中，偏移 12 个字节的位置是 **数据偏移 (Data Offset)** 字段（也称为 TCP 头部长度），它是一个 4 位的字段，位于该字节的高 4 位。低 4 位是保留字段和一些标志位。
*   **`(tcp[12]&0xf0)`**:
    *   `&0xf0` 是一个位掩码操作。`0xf0` 在二进制中是 `11110000`。
    *   这个操作会保留 `tcp[12]` 的高 4 位，即提取出 **数据偏移** 字段的值。这个值仍然是左移了 4 位的。
    *   **结果：`(tcp[12]&0xf0)` = TCP 头部长度（未转换成字节，值在高 4 位）。**

*   **`((tcp[12]&0xf0)>>2)`**:
    *   `>>2` 是右移 2 位操作，相当于除以 $2^2 = 4$。
        *   数据偏移字段的值本身就是以 4 字节的字为单位的 TCP 头部长度。
        *   所以，先用 `&0xf0` 提取出高 4 位的值（它已经代表了乘以 16 的效果），然后右移 2 位，
    *   **结果：`((tcp[12]&0xf0)>>2)` = TCP 头部长度（单位：字节）。**

计算 TCP 有效载荷（数据）长度
* `((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2))`**:
    * 这个表达式计算的是：`(IP 负载长度) - (TCP 头部长度)`。
    *  因此，`(整个 TCP 段的长度) - (TCP 头部长度)` = **TCP 有效载荷（数据）的长度**。

## protocol

	tcpdump -i lo0 <protocol>
		tcp, udp, arp, ip, ether,ip6,rarp 等, 但tcpdump 不深入到应用层协议(eg. http)

tcp vs udp

	tcpdump -i lo0 'tcp'

	# 抓DNS请求数据
	tcpdump -i eth1 udp dst port 53

udp:

    sudo tcpdump -i eth0 udp
    sudo tcpdump -i eth0 proto 17

## dst & src
可以借助`or` `and`, 限制源与目的机ip

	$ tcpdump -i eth0 'dst 8.8.8.8'
    $ tcpdump -i any -n -X  -c 100 'dst 172.16.110.14 and port 80'
	$ tcpdump -i eth0 -c 3 'dst port 53 or dst port 80'
    tcpdump -n "dst host 192.168.1.1 and (dst port 80 or dst port 443)"

tcpdump还支持如下的类型：

	host：指定主机名或IP地址，例如
		’host roclinux.cn’或’host 202.112.18.34′
		'host roclinux.cn and (baidu.com or qiyi.com)'
	net ：指定网络段，例如
		’arp net 128.3’或’dst net 128.3′
	portrange：指定端口区域，例如
		’src or dst portrange 6000-6008′
		如果我们没有设置过滤类型，那么默认是host。

## port
filter port

    tcpdump port 22
    tcpdump "port 22"
    tcpdump "tcp port 22"
    tcpdump tcp port 22

port range

    tcpdump portrange 1-1023
    tcpdump -n udp dst portrange 1-1023

read/save pcap

    tcpdump -Z root -r src.pcap "tcp port 4500" -w dst.pcap

我想获取使用ftp端口和ftp数据端口的网络包

	tcpdump 'port ftp or ftp-data'

“这个ftp、ftp-data到底对应哪个端口？除了ftp/ftp-data，还有哪些服务名称我可以直接用呢？”

在Linux系统中，/etc/services这个文件里面，就存储着所有知名服务和传输层端口的对应关系。这个对应关系是由IANA组织（the Internet Assigned Numbers Authority，互联网数字分配机构）来全权负责的，你可以到这个链接http://www.iana.org/assignments/port-numbers通过Web方式查到

## example
【例子4】- 我想获取roclinux.cn和baidu.com之间建立TCP三次握手中第一个网络包，即带有SYN标记位的网络包，另外，目的主机不能是qiyi.com

	tcpdump 'tcp[tcpflags] & tcp-syn != 0 and not dst host qiyi.com'

	# 计算抓10000个SYN包花费多少时间，可以判断访问量大概是多少。
	time tcpdump -n -i eth0 'tcp[tcpflags] = tcp-syn' -c 10000 > /dev/null


这个语句看着比较复杂，其实如果要把这段解释清楚的确不容易，需要你具备计算机网络专业知识才行。这个我会安排一章来讲。

	tcp[tcpflags] # tcp标记
	tcp[tcpflags] & tcp-syn # 通过与tcp-syn 得到syn 标记位， 借此就判断是否是SYN(tcp 的第一句)

【例子5】- 打印IP包长超过576字节的网络包

	tcpdump 'ip[2:2] > 576'

【例子6】- 打印广播包或多播包，同时数据链路层不是通过以太网媒介进行的。

	tcpdump 'ether[0] & 1 = 0 and ip[16] >= 224'

# filter protocol
协议过滤必须单独提出来讲:

	proto[offset:size]

proto就是protocol的缩写，表示这里要指定的是某种协议的名称，比如ip、tcp、ether。其实proto这个位置，总共可以指定的协议类型有15个之多，包括：

	ether – 链路层协议
	fddi – 链路层协议
	tr – 链路层协议
	wlan – 链路层协议
	ppp – 链路层协议
	slip – 链路层协议
	link – 链路层协议
	ip arp rarp tcp udp icmp ip6 radio

如果只设置了offset，而没有设置size，则默认提取1个字节。比如`ip[2:2]`，就表示提取出第3、4个字节；而ip[0]则表示提取ip协议头的第一个字节。

在我们提取了特定内容之后，我们就需要设置我们的过滤条件了，我们可用的“比较操作符”包括：`>，<，>=，<=，=，!=`，总共有6个。

## offset
有一些常用的偏移量，可以通过一些名称来代替，比如icmptype表示ICMP协议的类型域、icmpcode表示ICMP的code域，tcpflags则表示TCP协议的标志字段域。

更进一步的，对于ICMP的类型域，可以用这些名称具体指代：

	icmp-echoreply, icmp-unreach, icmp-sourcequench, icmp-redirect, icmp-echo, icmp-routeradvert, icmp-routersolicit, icmp-timxceed, icmp-paramprob, icmp-tstamp, icmp-tstampreply, icmp-ireq, icmp-ireqreply, icmp-maskreq, icmp-maskreply。

而对于TCP协议的标志字段域，则可以细分为:

	tcp-fin, tcp-syn, tcp-rst, tcp-push, tcp-ack, tcp-urg。

## ICMP offset
如果想查看哪些ICMP包中“目标不可达、主机不可达”的包，请使用这样的过滤表达式：

	icmp[0:2]==0x0301
	icmp[10:4] range from 10 to 13 bytes

## tcp offset
tcp 包本身有个偏移20(ip包头占用0x14=20字节）

    tcp[0:2] 源端口2节字
    tcp[2:2] 目标端口2节字
    tcp[3] tcp[3:1]==80 80端口

    # tcp[20:4]==0x47455420   "GET "
    tcpdump -i en0 -n -X -A  "tcp[20:4]==0x47455420"

要提取TCP协议的SYN、ACK、FIN标识字段，语法是：

	tcp[tcpflags] & tcp-syn
	tcp[tcpflags] & tcp-ack
	tcp[tcpflags] & tcp-fin

要提取TCP协议里的SYN-ACK数据包，不但可以使用上面的方法，也可以直接使用最本质的方法：

	tcp[13]==18

fiter port 22 and FIN flag

    tcpdump -Z root -r src.pcap "tcp port 22 and (tcp[tcpflags] & tcp-fin != 0)" -w dst.pcap

# tshark
> Refer to: https://www.cnblogs.com/liun1994/p/6142505.html

有些参数和tcpdump 一样的

    -c 500

## interface or cap

    tshark -i eth0
    tshark -p: 以非混合模式工作，即只关心和本机有关的流量。

## output 

### output file
    tshark -r test.cap
    w: -w <outfile.cap|->
    -F: -F <output file type>,设置输出的文件格式，默认是.pcapng,使用tshark -F可列出所有支持的输出文件类型。

### select protocol

    O: -O <protocols>,只显示此选项指定的协议的详细信息。

### output time
　　-t: -t a|ad|d|dd|e|r|u|ud 设置解码结果的时间格式。“ad”表示带日期的绝对时间，“a”表示不带日期的绝对时间，“r”表示从第一个包到现在的相对时间，“d”表示两个相邻包之间的增量时间（delta）。
　　-u: s|hms 格式化输出秒；

### -l flush
flush everty packet:

　　-l: 在输出每个包之后flush标准输出

### -n 禁止网络对象名称解析
    -n :禁止网络对象名称解析

### output fields
打印http.host和http.request.uri

    -T fields -e http.host -e http.request.uri 

果-T fields选项指定，使用-E来设置一些属性， header=y意思是头部要打印;

    -T fields -E header=y
　　-E: -E <fieldsoption>=<value>如
　　　　header=y|n
　　　　separator=/t|/s|<char>
　　　　occurrence=f|l|a
　　　　aggregator=,|/s|<char>

-z 输出数据

    tshark -r vmx.cap -q -n -t ad -z follow,tcp,ascii
　　　　-t ad: 输出格式化时间戳;

#### output format(-T)
　　-T: -T pdml|ps|text|fields|psml,设置解码结果输出的格式，包括text,ps,psml和pdml，默认为text

    tshark -r temp.cap -R "ssl" -V -T text
　　　　-T text: 格式化输出，默认就是text;
　　　　-V: 增加包的输出;//-q 过滤tcp流13，获取data内容

#### output port

    -e "ip.src" -e tcp.srcport -e ip.dst -e tcp.dstport

### output statistic

    tshark -n -q -z http,stat, -z http,tree
　　　注释:
　　　　-q: 只在结束捕获时输出数据，针对于统计类的命令非常有用;
　　　　-z: 各类统计选项，具体的参考文档，后面会介绍，可以使用tshark -z help命令来查看所有支持的字段;
　　　　　　 http,stat: 计算HTTP统计信息，显示的值是HTTP状态代码和HTTP请求方法。
　　　　　　 http,tree: 计算HTTP包分布。 显示的值是HTTP请求模式和HTTP状态代码。

//抓取500个包提取访问的网址打印出来
tshark -s 0 -i eth0 -n -f 'tcp dst port 80' -R 'http.host and http.request.uri' -T fields -e http.host -e http.request.uri -l -c 500
　　　注释: 
　　　　-f: 抓包前过滤；
　　　　-R: 抓包后过滤；
　　　　-l: 在打印结果之前清空缓存;
　　　　-c: 在抓500个包之后结束;

### output name interpret

    -n: 禁止所有地址名字解析（默认为允许所有）
    -N: 启用某一层的地址名字解析。“m”代表MAC层，“n”代表网络层，“t”代表传输层，“C”代表当前异步DNS查找。如果-n和-N参数同时存在，-n将被忽略。如果-n和-N参数都不写，则默认打开所有地址名字解析。

### select proto

    -d: 将指定的数据按有关协议解包输出,如要将tcp 8888端口的流量按http解包，应该写为“-d tcp.port==8888,http”;tshark -d. 可以列出所有支持的有效选择器。

## filter
### -f capture filer
    -f 'tcp dst port 80' 

### -R read filter

    -R 'http.host and http.request.uri' 
    -R: -R <read filter>,
    -Y: -Y <display filter>


## proto
### http

    tshark  -s 512 -i eth0 -n -f 'tcp dst port 80' -R 'http.host and http.request.uri' -T fields -e http.host -e http.request.uri -e frame.time -l 

解释

    -i eth0 :捕获eth0网卡 
    -s  512 :只抓取前512个字节数据
    -f 'tcp dst port 80' :只捕捉协议为tcp,目的端口为80的数据包
    -R 'http.host and http.request.uri' :过滤出http.host和http.request.uri 过滤已经捕获的包（wireshark的ilter）
    -T fields -e http.host -e http.request.uri :打印http.host和http.request.uri
    -l ：输出到标准输出

#### ssl 

    tshark -n -t a -R ssl -T fields -e "ip.src" -e "ssl.app_data"

### mysql
    tshark -s 512 -i eth0 -n -f 'tcp dst port 3306' -R 'mysql.query' -T fields -e mysql.query

# tcpdump with Wireshark
> http://blogread.cn/it/article/7130?f=catemore

对Android网络抓包分析，一般是使用tcpdump抓个文件，再到PC用Wireshark打开分析。能不能达到直接使用Wireshark的效果？ 答案是可以的，至少已经非常接近了。实现起来很简单，原理就是将tcpdump的数据重定向到网络端口，再通过管道(pipe)转到wireshark就可以了。

   Android上使用的指令:

   i. tcpdump

正是因为可以生成libpcap格式的数据，Wireshark可以加以处理。

 官网:http://www.tcpdump.org/

 下面这个链接介绍了Android版本的编译:

 http://omappedia.org/wiki/USB_Sniffing_with_tcpdump
   ii. netcat, 又称为瑞士军刀，小巧而功能强悍。如果在手机没有nc指令，可以方便地使用busybox提供的版本(直接到Google Play里安装)。

http://www.busybox.net/
   iii. Wireshark, 不嗦了。

http://www.wireshark.org/
   两条指令

   准备好了工具，依下面的方式执行两条指令就可以了 (只需要替换tcpdump所在的路径，以及nc前要不要加个busybox):

   i. 使用adb shell在Android设备上执行:

tcpdump -n -s 0 -w - | busybox nc -l -p 11233

* 其中nc -l -p 11233, 即建立一个服务器端，以11233端口提供服务。需要以root用户执行。
   ii. 在主机的命令下执行:

    adb forward tcp:11233 tcp:11233 && nc 127.0.0.1 11233 | wireshark -k -S -i -

* 其nc 127.0.0.1 11233，即建立一个客户端，连接到本机的11233端口。wireshark的参数见后面的补充说明。
* 在Mac OS下有时需要在wireshark前加上sudo, 不然打开失败。如果没有看到结果，可以在nc指令加-v参数，显示更多的信息来查看。比如出现”Connection refused“时，注意检查指定的端口号是否正确。

   也可以参考这里:

http://www.kandroid.org/online-pdk/guide/tcpdump.html
   效果如下，注意标题显示”Capturing from Standard Input”。 04

   补充说明

   i. tcpdump详解

http://www.cnblogs.com/ggjucheng/archive/2012/01/14/2322659.html
   ii. 什么是libpcap格式

http://wiki.wireshark.org/Development/LibpcapFileFormat
   iii. wireshark参数

http://man.lupaworld.com/content/network/wireshark/c9.2.html

 官方:http://www.wireshark.org/docs/man-pages/wireshark.html


# Reference
- [tcpdump by roclinux]

[tcpdump by roclinux]:
http://roclinux.cn/?p=2474
