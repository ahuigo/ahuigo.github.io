# wireshark
Refer : http://www.bo56.com/tcpdump-%E5%92%8C-wireshark%E7%BB%84%E5%90%88%E6%8B%B3%EF%BC%8C%E6%8F%AA%E5%87%BA%E6%9C%89%E9%97%AE%E9%A2%98%E7%9A%84%E6%9C%BA%E5%99%A8/

Support: http, tcp, udp
Licence: GPL

> 同类工具有微软的network monitor,sniffer

## install
	brew cask install xquartz
	brew cask install wireshark

## Usage
On Mac:
	http://blog.csdn.net/phunxm/article/details/38590561
On Windows:
	http://www.cnblogs.com/tankxiao/archive/2012/10/10/2711777.html

WireShark 主要分为这几个界面

1. Display Filter(显示过滤器)，  用于过滤
2. Packet List Pane(封包列表)， 显示捕获到的封包， 有源地址和目标地址，端口号。 颜色不同，代表
3. Packet Details Pane(封包详细信息), 显示封包中的字段
4. Dissector Pane(16进制数据)
5. Miscellanous(地址栏，杂项)

## Packet List Pane
封包列表的面板中显示，编号，时间戳，源地址，目标地址，协议，长度，以及封包信息。 你可以看到不同的协议用了不同的颜色显示。
你也可以修改这些显示颜色的规则，  View ->Coloring Rules.

## Packet Details Pane
封包详细信息 各行信息分别为

	Frame:   物理层的数据帧概况
	Ethernet II: 数据链路层以太网帧头部信息
	Internet Protocol Version 4: 互联网层IP包头部信息
	Transmission Control Protocol:  传输层T的数据段头部信息，此处是TCP
	Hypertext Transfer Protocol:  应用层的信息，此处是HTTP协议

## Filter
过滤器有两种，
一种是显示过滤器，就是主界面上那个，用来在捕获的记录中找到所需要的记录
一种是捕获过滤器，用来过滤捕获的封包，以免捕获太多的记录。 在Capture -> Capture Filters 中设置

### Display Filter
位于主界面Filter. Example:

	ip.src==192.168.1.1 or ip.dst==192.168.1.2
	ip.src==10.17.10.138

Shortcuts:

	Ctrl+B	add filter

#### Filter Rule
表达式规则(case sensitive)

1. Protocol Filter, 协议过滤

	tcp，只显示TCP协议。
	http
	udp

2. IP 过滤

	比如 ip.src ==192.168.1.102 显示源地址为192.168.1.102，
	ip.dst==192.168.1.102, 目标地址为192.168.1.102

3. 端口过滤

	tcp.port ==80,  端口为80的
	tcp.port eq 80,  端口为80的
	tcp.srcport == 80,  只显示TCP协议的愿端口为80的。

4. Http模式过滤

	http.request.method=="GET",   只显示HTTP GET方法的。
	http.host=="ahui132.github.io"
	http.host==ahui132.github.io

5. 逻辑运算符为 and or

	adn &&
	or ||

Example:

	ip.src ==192.168.1.102 or ip.dst==192.168.1.102	 源地址或者目标地址是192.168.1.102
	http and (ip.src ==192.168.1.102 or ip.dst==192.168.1.102)
	tcp && http.host==ahui132.github.io

#### Save
Select the filter you no longer want and click Remove.

	Edit > Preferences > Filter Expressions.

### Capture Filter