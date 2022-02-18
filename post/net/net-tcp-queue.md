---
layout: page
title:	tcp/ip 协议SYN
date: 2015-11-11
---
# tcp queue 队列
> 本文总结复现 https://cjting.me/2019/08/28/tcp-queue/

## 问题
运行 https://github.com/ahuigo/go-lib/tree/master/net/tcp/tcp-queue 代码

    $ make srv
    $ make client

发现在mac 上出现error, linux 则正常

    error: Get "http://127.0.0.1:7777": read tcp 127.0.0.1:62124->127.0.0.1:7777: read: connection reset by peer

抓包可以发现有大量的reset 报文, 来自于server

    $ sudo tcpdump -nn -i lo0 src port 7777 | grep -F '[R]'
    02:40:25.685415 IP 127.0.0.1.7777 > 127.0.0.1.65363: Flags [R], seq 3818796496, win 0, length 0

注意 tcpdump 中flag 表达

    S: SYN
    F: FIN
    P: PUSH
    R: RST
    U: URG
    W: ECN CWR
    E: ECN Echo
    .: ACK

## 半连接队列（SYN Queue）和全连接队列（Accept Queue）
先说原因：全连接队列满了。

tcp 建立连接过程：
1. Client: 发送 SYN，连接状态进入 SYN_SENT
1. Server: 收到 SYN, 创建连接状态为 SYN_RCVD 的 Socket，响应 SYN/ACK
1. Client: 收到 SYN/ACK，连接状态从 SYN_SENT 变为 ESTABLISHED，响应 ACK
1. Server: 收到 ACK，连接状态变为 ESTABLISHED

server涉及两个队列:
1. SYN_RCVD 半连接queue
1. ESTABLISHED 全连接queue


## somaxconn & tcp_max_syn_backlog
以上两个队列长度涉及这两个配置

全连接队列的大小: `min(backlog, somaxconn)`
1. backlog 为调用 listen 函数时传递的参数
2. somaxconn 是一个系统参数，位置为 /proc/sys/net/core/somaxconn，默认值为 128。

半连接队列的长度由以下过程确定(可参考[Linux 诡异的半连接队列长度](https://www.cnblogs.com/zengkefu/p/5606696.html))

    backlog = min(somaxconn, backlog)
    nr_table_entries = min(backlog, sysctl_max_syn_backlog)
    nr_table_entries = max(nr_table_entries, 8)
    // roundup_pow_of_two: 将参数向上取整到最小的 2^n
    // 注意这里存在一个 +1
    nr_table_entries = roundup_pow_of_two(nr_table_entries + 1)
    max_qlen_log = max(3, log2(nr_table_entries))
    max_queue_length = 2^max_qlen_log

半连接队列的长度实际上由三个参数决定：

1. listen 时传入的 backlog
2. /proc/sys/net/ipv4/tcp_max_syn_backlog，默认为 1024
3. /proc/sys/net/core/somaxconn, 默认为 128

假设 listen 传入的 backlog = 511，其他配置都是默认值， 可算出半连接队列的长度为 256。

    backlog = min(128, 511) = 128
    nr_table_entries = min(128, 1024) = 128
    nr_table_entries = max(128, 8) = 128
    nr_table_entries = roundup_pow_of_two(129) = 256
    max_qlen_log = max(3, 8) = 8
    max_queue_length = 2^8 = 256

现在算知道Nginx, Redis 都把自己的 listen backlog 参数设置为 511 了，因为内核计算过程中有一个奇怪的 +1 操作。

## 半连接队列溢出 & SYN Flood
SYN Flood 的思路:
1. 发送大量的 SYN 数据包给 Server，然后不回应 Server 响应的 SYN/ACK，
2. Server 端就会存在大量处于 SYN_RECV 状态的连接，最终导致半连接队列溢出。

当半连接队列溢出时，Server 收到了新的发起连接的 SYN：

1. 如果不开启 net.ipv4.tcp_syncookies：直接丢弃这个 SYN
    1. 正常用户会受影响
2. 如果开启 net.ipv4.tcp_syncookies：
    1. 如果全连接队列满了，并且 `qlen_young` 的值大于 1：丢弃这个 SYN
    2. 否则，生成 syncookie 并返回 SYN/ACK. //输出 "possible SYN flooding on port %d. Sending cookies.

`qlen_young` 表示目前半连接队列中，没有进行 SYN/ACK 包重传的连接数量。

net.ipv4.tcp_syncookies 配置项，这是内核用于抵御 SYN Flood 攻击的一种方式，它的核心思想在于：
1. 攻击者对于我们返回的 SYN/ACK 包是不会回复的
2. 而正常用户会回复一个 ACK 包。

通过生成一个 Cookie 携带在我们返回的 SYN/ACK 包中，之后我们收到了 ACK 包，我们可以验证 Cookie 是否正确，如果正确，则允许建立连接。否则，就应该是超时移出半连接队列?

### 实现SYN Flood 攻击
    # 安装 Scapy 
    pip install scapy
    # 关闭 net.ipv4.tcp_syncookies 选项 
    sysctl net.ipv4.tcp_syncookies=0

启动一个 py server 来监听 8877 端口，listen 的 backlog 参数为 7, somaxconn 为默认值 128，tcp_max_syn_backlog 为默认值 1024，此时半连接队列的长度为 16: https://github.com/ahuigo/go-lib/tree/master/net/tcp/tcp-queue/

    gcc tcp-recv-server.c && ./a.out
    tcpdump -tn -i lo port 8877

启动 scapy 命令行工具，先来发送一个 SYN 包:

	#sysctl -w net.ipv4.tcp_syncookies=0
    pip install scapy
	hash brew && brew install libpcap
	sudo python send-syn.py

我们会发现，tcpdump 显示收到一个 SYN 包，但是没有对应的 SYN/ACK 回复？？？

    IP 172.21.21.220.40508 > 127.0.0.1.8877: Flags [S], seq 1234, win 8192, length 0
    IP 127.0.0.1.8877 > 172.21.21.220.40508: Flags [S.], seq 4249042998, ack 1235, win 65535, options [mss 16344], length 0
    IP 172.21.21.220.40508 > 127.0.0.1.8877: Flags [R], seq 1235, win 0, length 0

我们用 nc 试一下` nc -4 localhost 8877` 返回正常三握

    IP 127.0.0.1.55540 > 127.0.0.1.8877: Flags [S], seq 1097611481, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 690123930 ecr 0,sackOK,eol], length 0
    IP 127.0.0.1.8877 > 127.0.0.1.55540: Flags [S.], seq 3998235639, ack 1097611482, win 65535, options [mss 16344,nop,wscale 6,nop,nop,TS val 690123930 ecr 690123930,sackOK,eol], length 0
    IP 127.0.0.1.55540 > 127.0.0.1.8877: Flags [.], ack 1, win 6379, options [nop,nop,TS val 690123930 ecr 690123930], length 0

scapy 与nc 为何不同呢？ 因为scapy 发了无效SYN包, 就收到Reset 包

我们可以丢掉Reset 包, 两种办法:
1. 通过防火墙，`iptables -A OUTPUT -p tcp --tcp-flags RST RST -j DROP`
2. 设定无效的src: `ip.src=f"127.0.0.{randint(0, 255)}"`

采用第二种的syn flood:

    while True:
        ip.src=f"127.0.0.{randint(0, 255)}"
        send(ip/tcp)
        sleep(0.01)

然后再发包就可以看到很多 `SYN_RCVD` 半连接

    $ netstat -atn  | ag 8877
    tcp4       0      0  127.0.0.1.8877         127.0.0.20.20          SYN_RCVD

## 全连接队列溢出
当系统收到三次握手中第三次的 ACK 包，正常应该进入全连接，如果全连接队列满了的话：

1. 如果设置了 net.ipv4.tcp_abort_on_overflow，那么直接回复 RST，同时，对应的连接直接从半连接队列中删除
2. 否则，直接忽略 ACK，然后 TCP 的超时机制会起作用，一定时间以后，Server 会重新发送 SYN/ACK

我们来测试一下，关闭 `net.ipv4.tcp_abort_on_overflow`，启动我们的 simple-tcp-server，listen 的 backlog 参数是 1，somaxconn 为 128，因此，全连接队列的长度为 1。

    ip=IP(dst="127.0.0.1")
    tcp=TCP(dport=8877, flags="S")
    idx = 1

    def connect():
        global idx
        ip.src = f"127.0.0.{ idx }"
        synack = sr1(ip/tcp)
        ack = TCP(sport=synack.dport, dport=synack.sport, flags="A", seq=100, ack=synack.seq + 1)
        send(ip/ack)
        idx += 1

因为我们的 Server 从不 accept，所以，每次发起连接后，全连接队列就会添加一项。

使用 `netstat -tn | rg 8877`or`ss -tln` 查看 Socket 状态，同时使用 `tcpdump -tn -i lo port 8877` 抓包，然后我们手动触发 connect 函数。

    第一次，多了一条 ESTABLISHED 的连接，一切正常。
    第二次，又多了一条 ESTABLISHED 的连接，这好像不太对了？
    第三次，多了一条 SYN_RECV 的连接，可以看到 Server 在不停的重发 SYN/ACK 包，对上了。

为什么是两个？全连接队列的长度是 1，应该只有 1 个才对。因为检查全连接队列是否溢出的函数叫做 sk_acceptq_is_full 使用的不是`1>=1`而是`1>1`

    static inline bool sk_acceptq_is_full(const struct sock *sk) {
        return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
    }

我们可以通过 netstat -s | rg -i listen 来得知因为全连接队列溢出导致的连接丢弃数量是多少。

    $ netstat -s | rg -i listen
    20 times the listen queue of a socket overflowed
    2286 SYNs to LISTEN sockets dropped

目前在我的机器上一共是 20 次。每次运行我们自己的 connect 函数，这个数字就会加一。

开启 net.ipv4.tcp_abort_on_overflow 以后，系统会直接发送 RST 而不是忽略 ACK，这里我们要注意一下修改防火墙的规则。

    $ iptables -F OUTPUT # 清空所有规则
    # 只阻止目标端口为 8877 的 RST 包
    $ iptables -A OUTPUT -p tcp --tcp-flags RST RST --dport 8877 -j DROP

使用 connect 函数我们会发现，Server 会返回一个 RST 包，同时也不存在 SYN_RECV 状态的连接。

## 为何Mac 收到RST
因为Mac 的 somaxconn 参数太小. 不过mac 中不叫`net.core.somaxconn`。

`man sysctl` 提到`sys/sysctl.h`

    echo "#include <sys/sysctl.h>" | gcc -M -xc - | ag sysctl
        /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/sys/sysctl.h \
    ag somaxconn  /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk/usr/include/sys/sysctl.h
        501:#define KIPC_SOMAXCONN          3       /* int: max length of connection q */

KIPC_SOMAXCONN 对应的是 kern.ipc.somaxconn

    $ sudo sysctl -w kern.ipc.somaxconn=1000
    kern.ipc.somaxconn: 128 -> 1000







