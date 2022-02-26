---
layout: page
title:	防火墙
category: blog
description:
---
# 原理
参考[Iptables防火墙原理详解](http://segmentfault.com/a/1190000002540601)

## netfilter/iptables
Netfilter是Linux操作系统核心层内部的一个数据包处理模块，它具有如下功能：

1. 网络地址转换(Network Address Translate)
1. 数据包内容修改
1. 以及数据包过滤的防火墙功能

Netfilter 平台中制定了数据包的五个挂载点（Hook Point)，这5个挂载点分别是:

    PRE_ROUTING、INPUT、OUTPUT、FORWARD、POST_ROUTING。

Netfilter 所设置的规则是存放在内核内存中的，而 iptables 是一个应用层的应用程序.

1. tables: iptables 通过 Netfilter 放出的接口来对存放在内核内存中的 XXtables（Netfilter的配置表）进行修改。
2. Chains: 这个XXtables由`表tables`、`链chains`、`规则rules`组成，iptables在应用层负责修改这个规则文件。类似的应用程序还有 firewalld 。

![iptables-framework](/img/iptables-framework.png)

## Tables(filter、nat、mangle等规则表)
4个表:filter,nat,mangle,raw,security，默认表是filter（没有-t 指定表的时候就是filter表）。
表的处理优先级：security>raw>mangle>nat>filter; 表与链之间不是包含关系，而是两个不同的维度

![](/img/iptables_table.jpg)

### filter表
主要用于对数据包进行过滤，根据具体的规则决定是否放行该数据包（如DROP、ACCEPT、REJECT、LOG）。filter 表对应的内核模块为iptable_filter:

    INPUT链：INPUT针对那些目的地是本地的包
    FORWARD链：FORWARD过滤所有不是本地产生的并且目的地不是本地(即本机只是负责转发)的包
    OUTPUT链：OUTPUT是用来过滤所有本地生成的包

### nat表
主要用于修改数据包的IP地址、端口号等信息（网络地址转换，如SNAT、DNAT、MASQUERADE、REDIRECT）(iptable_nat)

    PREROUTING链：作用是在包刚刚到达防火墙时改变它的目的地址
    OUTPUT链：改变本地产生的包的目的地址
    POSTROUTING链：在包就要离开防火墙之前改变其源地址

属于一个流的包(因为包的大小限制导致数据可能会被分成多个数据包)只会经过这个表一次。如果第一个包被允许做NAT或Masqueraded，那么余下的包都会自动地被做相同的操作，也就是说，余下的包不会再通过这个表。

### mangle表
主要用于修改数据包的`TOS（Type Of Service，服务类型`）、`TTL（Time To Live，生存周期）`指以及为数据包设置`Mark`标记，
以实现`Qos(Quality Of Service，服务质量)`调整以及策略路由等应用

    PREROUTING，POSTROUTING，INPUT，OUTPUT，FORWARD。

由于需要相应的路由设备支持，因此应用并不广泛。

### raw表
是自1.2.9以后版本的iptables新增的表，主要用于决定数据包是否被状态跟踪机制处理。在匹配数据包时，*raw表的规则要优先于其他表*。包含两条规则链:

    OUTPUT、PREROUTING

iptables中数据包和4种被跟踪连接的4种不同状态：

    NEW：该包想要开始一个连接（重新连接或将连接重定向）
    RELATED：该包是属于某个已经建立的连接所建立的新连接。例如：FTP的数据传输连接就是控制连接所 RELATED出来的连接。--icmp-type 0 ( ping 应答) 就是--icmp-type 8 (ping 请求)所RELATED出来的。
    ESTABLISHED ：只要发送并接到应答，一个数据连接从NEW变为ESTABLISHED,而且该状态会继续匹配这个连接的后续数据包。
    INVALID：数据包不能被识别属于哪个连接或没有任何状态比如内存溢出，收到不知属于哪个连接的ICMP错误信息，一般应该DROP这个状态的任何数据。

## Chains(INPUT、FORWARD等链)
在处理各种数据包时，根据防火墙规则的不同介入时机，iptables供涉及5种默认规则链，从应用时间点的角度理解这些链：

    INPUT链：当接收到防火墙本机地址的数据包（入站）时，应用此链中的规则。
    OUTPUT链：当防火墙本机向外发送数据包（出站）时，应用此链中的规则。
    FORWARD链：当接收到需要通过防火墙发送给其他地址的数据包（转发）时，应用此链中的规则。
    PREROUTING链：在对数据包作路由选择之前，应用此链中的规则，如DNAT。
    POSTROUTING链：在对数据包作路由选择之后，应用此链中的规则，如SNAT。

list rules of chain:

    iptables -S INPUT
![chains-flow](/img/net/iptables-flow.gif)

### 遍历链 （Traversing Chains）
关于匹配：

1. 如果链中经过的每一条规则都不能提供完整匹配，那么数据包像这张图片上一样回落到调用链:
    ![](/img/iptables_subtraverse.png)
2. 如果任何时候一个 DROP 目标的规则实现完全匹配，那么丢弃数据包，不进行进一步处理。
3. 如果一个数据包在链中被 ACCEPT，那么它也将被所有超集链 ACCEPT，并且不再遍历其他超集链。 然而，要注意，数据包将以正常的方式继续遍历其他表中的其他链。

### Rules(Action, 动作)
默认情况下，任何链中都没有规则。可以向链中添加自己想用的规则。

1. 链的默认规则通常设置为 ACCEPT，如果想确保任何包都不能通过规则集，那么可以重置为 DROP。
2. 默认的规则总是在一条链的最后生效，所以在默认规则生效前数据包需要通过所有存在的规则。
3. 用户可以加入自己定义的链，从而使规则集更有效并且易于修改。如何使用自定义链请参考 Simple stateful firewall。

防火墙处理数据包的方式（规则）：

1. filter: 
    1. ACCEPT：允许数据包通过
    1. DROP：直接丢弃数据包，不给任何回应信息
    1. REJECT：拒绝数据包通过，必要时会给数据发送端一个响应的信息。
2. nat:
    1.	DNAT:目标地址转换。和SNAT相反，IP包经过route之后、出本地的网络栈之前，重新修改目标地址，源地址不变，在本机建立NAT表项，当数据返回时，根据NAT表将源地址修改为数据发送过来时的目标地址，并发给远程主机。可以隐藏后端服务器的真实地址。
    1.	REDIRECT：是DNAT的一种特殊形式，将网络包转发到本地host上（不管IP头部指定的目标地址是啥），方便在本机做端口转发。

    1.	SNAT：源地址转换。在进入路由层面的route之前，重新改写源地址，目标地址不变，并在本机建立NAT表项，当数据返回时，根据NAT表将目的地址数据改写为数据发送出去时候的源地址，并发送给主机。解决内网用户用同一个公网地址上网的问题。
    1.	MASQUERADE，是SNAT的一种特殊形式，适用于像adsl这种临时会变的ip上

    LOG：在/var/log/messages文件中记录日志信息，然后将数据包传递给下一条规则

除去最后一个LOG，前3条规则匹配数据包后，该数据包不会再往下继续匹配了，所以编写的规则顺序极其关键。

## Iptables Flow(Iptables 流)
![flow.png](/img/iptables-flow.png)
![](/img/iptables_traverse.jpg)

总结出以下规律：

1. 当一个数据包进入网卡时，数据包首先进入`PREROUTING`链，在PREROUTING链中我们有机会修改数据包的DestIP(目的IP)，然后内核的"路由模块"根据"数据包目的IP"以及"内核中的路由表"判断是否需要转送出去(注意，这个时候数据包的DestIP有可能已经被我们修改过了)
1. 如果数据包就是进入本机的(即数据包的目的IP是本机的网口IP)，数据包就会沿着图向下移动，到达INPUT链。数据包到达INPUT链后，任何进程都会-收到它
1. 本机上运行的程序也可以发送数据包，这些数据包经过OUTPUT链，然后到达POSTROTING链输出(注意，这个时候数据包的SrcIP有可能已经被我们修改过了)
1. 如果数据包是要转发出去的(即目的IP地址不再当前子网中)，且内核允许转发，数据包就会向右移动，经过FORWARD链，然后到达POSTROUTING链输出(选择对应子网的网口发送出去)

# 防火墙

## iptables 进程
There is no such thing as "iptables is running".

If the kernel modules are loaded and rules defined , the firewall is active. 

## 启动服务
查看是否运行:

    service iptables status

centos从7开始默认用的是firewalld，这个是基于iptables的，有iptables的核心，但是iptables的服务是没安装的。

It is possible to go back to a more classic iptables setup. \
First, stop and mask the firewalld service:

    systemctl stop firewalld
    systemctl mask firewalld; 
        #firewalld.service to /dev/null.

Then, install the iptables-services package:

    yum install iptables-services
    systemctl enable iptables
    systemctl [stop|start|restart] iptables

Saving your firewall rules can be done as follows:

    service iptables save
    or
    /usr/libexec/iptables/iptables.init save

重启：

    ## 重启防火墙
    service iptables restart
    ## stop
    service iptables stop; # /etc/init.d/iptables stop

## backoup and Restore
备份当前规则

    iptables-save > iptables.rules

将备份的规则还原

    iptables-restore < iptables.rules

保存当前规则, 以下三种方法都可以

    /usr/libexec/iptables/iptables.init save
    service iptables save
    # 或者直接在配置中写规则
    cat /etc/sysconfig/iptables

## 规则查看
以下都可以

    iptables -L
    iptables --line -vnL
    /etc/init.d/iptables status

参数：

    -L --list [chain]
        list all rules
    -v --verbose
        Verbose output: in/out, pkts/bytes, interface name, TOS masks, ...
        -vv, -vvv
    -t [table type]
        -t nat
    -n, --numeric
        Ip and port will be print in numberic format
    --line 显示rules行号

### 规则文件
简单看看，后面会细讲：

    cat  /etc/sysconfig/iptables    (命令执行的规则只是临时生效)

    *filter
    #允许所有本机向外的访问
    -A OUTPUT -j ACCEPT
    # 允许所有对外访问简写（相当于-A OUTPUT -j ACCEPT)
    :OUTPUT ACCEPT [0:0]
    # 只允许对外端口1024:166083
    :OUTPUT ACCEPT [1024:166083]
    # 允许已经建立的连接或相关的连接通行
    -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    -A INPUT -p icmp -j ACCEPT
    -A INPUT -i lo -j ACCEPT
    # 允许80端口
    -A INPUT –m state –-state NEW –m tcp –p tcp –-dport 80 –j ACCEPT

# 命令
![cli](/img/iptables-cli.png)

## table

    [-t 表名]：该规则所操作的哪个表，可以使用filter、nat等，如果没有指定则默认为filter

## command

    -A：新增一条规则，到该规则链列表的最后一行(优先级最低)
    -I：插入一条规则，原本该位置上的规则会往后顺序移动，没有指定编号则为1
    -D：从规则链中删除一条规则，要么输入完整的规则，或者指定规则编号加以删除
        iptables -D INPUT 3（按号码匹配）
        删除 filter 表 INPUT 链中的第三条规则（不管它的内容是什么）
    -R：替换某条规则，规则替换不会改变顺序，而且必须指定编号。
        iptables -R INPUT 9 -j ACCEPT
        将原来编号为 9 的INPUT规则内容替换为“-j ACCEPT”
    -P --policy：设置某条规则链的默认动作
        iptables -P INPUT DROP
        设置 filter 表 INPUT 链的默认规则是 DROP
    -nL：-L、查看当前运行的防火墙规则列表, -n 数字显示
    -F 清空规则
        iptables -F # 清空 filter 表中的所有规则
        iptables -t nat -F # 清空 nat 表中的所有规则

    -N 新建用户自定义的规则链
    -X 删除用户自定义的规则链

### 默认动作
查看默认:

    iptables -nL -v |grep policy
        Chain INPUT(policy ACCEPT)
        ...

设置默认

    iptables --policy INPUT ACCEPT
    iptables -P INPUT DROP


## chain
- chain名：指定规则表的哪个链，如INPUT、OUPUT、FORWARD、PREROUTING等
- [规则编号]：插入、删除、替换规则时用，--line-numbers显示号码

    -I INPUT 5 插入到第5条

## Parameter & Xmatch

    [-i|o 网卡名称]：i是指定数据包从哪块网卡进入，o是指定数据包从哪块网卡输出
    [-p 协议类型]：可以指定规则应用的协议，包含tcp、udp和icmp等
    -s, --source address[/mask][,...]
        [-s 源IP地址]：源主机的IP地址或子网地址
    -d address[/mask]：目标主机的IP地址或子网地址
    [--sport 源端口号]：数据包的IP的源端口号
    [--dport目标端口号]：数据包的IP的目标端口号

### ip and port

    -s 指定源地址
    -d 指定目的地址
        -s 10.209.0.213/16 C网
        -s 0/0 全部(可以不写)
        -s 192.168.0.1-192.168.0.200

port

    --port 端口
    --sport源端口
    --dport目的端口，端口必须和协议一起来配合使用
        --sport 1024:65535
        ! --sport 30:1024 反向匹配
        # 允许访问22端口
        iptables -A INPUT -p tcp --dport 22 -j ACCEPT

### interface

    -i --in-interface 进入网络接口
        可以指定eth0,lo 等网络接口
    -o --out-interface 流出网络接口
        -o !eth0

### -p

    -p protocol  比对通讯协议
        -p用来指定协议可以是tcp，udp，icmp等也可以是数字的协议号，
        -p !tcp 反向匹配

    --tcp-flags  比对 TCP
        iptables -p tcp --tcp-flags SYN,FIN,ACK SYN
        TCP状态旗号包括：SYN（同步）、ACK（应答）、FIN（结束）、RST（重设）、URG（紧急）、PSH（强迫推送）
        等均可使用于参数中，除此之外还可以使用关键词 ALL 和 NONE 进行比对

    --icmp-type
        iptables -A INPUT -p icmp --icmp-type 8
        用来比对 ICMP 的类型编号，可以使用代码或数字编号来进行比对。 案例ICMP类型是:8

### -m
-m, extend matches，这个选项用于提供更多的匹配参数

    -m matchname [per-match-options]
        tcp
        icmp
        state
        mac
        limit
        mark
        owner
        multiport

比如:

    -A INPUT -s 192.168.1.0/24 -p tcp -m tcp --dport 80 -j ACCEPT

    -m state --state ESTABLISHED,RELATED
    -m tcp --dport 22
    -m multiport --dports 80,8080
    -m icmp --icmp-type 8

    -m limit --limit
        用来比对某段时间内封包的平均流量，下面的例子是用来比对每秒平均流量是否超过一次 3 个封包。
        iptables -A INPUT -m limit --limit 3/sec
        一次同时涌入的包超过5个
        -m limit --limit-burst 5
    -m mac --mac-source
        # 匹配来源网络接口地址（不可用于OUTPUT, POSTROUTING, 因为封包要送到网 卡后，才能由网卡驱动程序通过ARP通讯查出目的地的mac地址, 在此之前iptables 无法以得到distination-mac-source）
        -m mac --mac-source 00:00:00:00:00:01
     -m owner
         #用来匹配来自本机的封包
         -m owner --uid-owner 500
         -m owner --gid-owner 500
        #特定进程
         -m owner --pid-owner 100
        #匹配特定连接(session id)
        -m owner --sid-owner 100
    -m mark
        #用来匹配封包是否被表示某个号码，当封包被 匹配成功时，我们可以透过 MARK 处理动作，将该封包标示一个号码，号码最大不可以超过 4294967296。
        iptables -t mangle -A INPUT -m mark --mark 1
    -m state --state Status
        匹配连接状态：NEW,ESTABLISHED,RELATED,INVALID

## action

    <-j 动作>：处理数据包的动作，包括ACCEPT、DROP(timeout)、REJECT(Destination port unreachable)等
    -j targetname [per-target-options]

拒绝 17500 端口的任何数据包, 但是返回一个错误回应: unreachable：

    # iptables -R INPUT 2 -p tcp --dport 17500 -j REJECT --reject-with icmp-port-unreachable

# example

## default

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

## ftp
ftp 默认有两个端口，先用21端口做认证，再用20端口做文件传输

    #允许FTP服务的21和20端口
    iptables -A INPUT -p tcp --dport 21 -j ACCEPT
    iptables -A INPUT -p tcp --dport 20 -j ACCEPT

    ###Allow FTP connections on port 21 incoming and outgoing
    -A INPUT -p tcp -s 10.209.0.214/24 --sport 1024:65535 -d 0/0 --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
    -A OUTPUT -p tcp -s 0/0 --sport 21 -d 0/0 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT

    ###Allow FTP port 20 for active connections incoming and outgoing
    -A INPUT -p tcp --sport 1:65535 --dport 20 -m state --state ESTABLISHED -j ACCEPT
    -A OUTPUT -p tcp --sport 20 --dport 1:65535 -m state --state ESTABLISHED,RELATED -j ACCEPT

## http

    -A INPUT -p tcp -m tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
    # 上面的太啰嗦了，简化为如下
    -A INPUT -p tcp --dport 80 -j ACCEPT

## icmp

    iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
    iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT

## FORWARD 接口转发
iptables forwarding between two interface [closed]
1. wlan0 (station) - Connected to the internet 
2. wlan1 (AP) - Other clients connect to it.

I would like for clients connected to wlan1 to be able to access the internet on wlan0. 

    # 1. Enable forwarding on your linux box:
    echo 1 > /proc/sys/net/ipv4/ip_forward

    # 2. Allow (or all of) packets to traverse your router
    iptables -A FORWARD -i wlan1 -o wlan0 -j ACCEPT

    # 3. As someone stated, as netfilter is a stateless firewall, allow traffic for already established connections
    iptables -A FORWARD -i wlan0 -o wlan1 -m state --state ESTABLISHED,RELATED  -j ACCEPT

    # 4. Change the source address on packets going out to the internet
    iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE

## REDIRECT, 端口转发
首先要开启端口转发器必须先修改内核运行参数ip_forward,打开转发:

    # echo 1 > /proc/sys/net/ipv4/ip_forward   //此方法临时生效

或

    # vi /ect/sysctl.conf                      //此方法永久生效
        net.ipv4.ip_forward=1
    # sysctl -p # 重载sysctl.conf

数据包进入INPUT链之前，修改目标地址（端口）: `--to-ports`缩写`--to`

    iptables -t nat -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 8080
    # iptables -A INPUT -s 172.29.88.0/24 -p tcp -m state --state NEW -m tcp --dport 8080 -j ACCEPT

此时外部访问: 
1. http://outer.ip:80 没有问题， 
2. http://localhost:80或http://127.0.0.1:80 都是不行

这是因为本地数据包产生的目标地址不经过PREROUTING，你需要额外添加这条 OUTPUT 规则： *(REDIRECT 被限定用于NAT 表的:PREROUTING/OUTPUT)*

    iptables -t nat -A OUTPUT -p tcp --dport 80 -j REDIRECT --to-ports 8080

### DNAT, ip+port 转发
利用DNAT 规则可以达到同样的效果: DNAT 可以同时改变IP 和 port

    iptables -t nat -A PREROUTING -p tcp -i eth0 -d $YOUR_HOST_IP --dport 80 -j DNAT --to $YOUR_HOST_IP:8080
    iptables -t nat -A OUTPUT -p tcp -d $YOUR_HOST_IP --dport 80 -j DNAT --to 127.0.0.1:8080
    iptables -t nat -A OUTPUT -p tcp -d 127.0.0.1      --dport 80 -j DNAT --to 127.0.0.1:8080
    iptables -t nat -A OUTPUT -p tcp  --dport 80 -j DNAT --to 127.0.0.1:8080

### 异机端口转发
要实现的是所有访问 192.168.10.100:81 的请求，转发到 172.29.88.56:80 上，在 192.168.10.100 是哪个添加规则:

    ```s
    # 如果你用tcpdump 在192.168.10.100 上监听，81或者8081 都通抓取到:tcpdump -s 0 -i eth1 -nn -X   port 8081/80, 
    # 可以发现只有client 到 172的syn 包，没有ack 包; 因为172的ack 包会直接发回了client的port(但是mac地址对不上), 并没有返回192代理点
    #      192.168.10.95.55751 > 192.168.100.81
    #      192.168.10.95.55751 > 172.29.88.56.8081
    # netstat -an |grep 55121
    iptables -t nat -A PREROUTING -i eth0 -p tcp -d 192.168.10.100 --dport 81 -j DNAT --to-destination 172.29.88.56:8081
    # 我们需要将syn中的source变成代理ip（当包返回时，代理ip会根据NAT表将包转发到原来的client)
    iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 192.168.10.100
    # 也可以精确到-p tcp --to-source 192.168.10.100:81, iptables nat 表项会自己维护tcp 端口关系, 或者ip nat映射
    ```

或者匹配到tcp：

    iptables -t nat -A PREROUTING -d 192.168.10.100 -p tcp --dport 81 -j DNAT --to 172.29.88.56:8081
    iptables -t nat -A POSTROUTING -d 172.29.88.56 -p tcp --dport 80 -j SNAT --to-source 192.168.10.100

为什么加`SNAT`：
1. 在进入路由层面的route之前，重新 *改写源地址*，目标地址不变，并在本机建立NAT表项，
2. 当数据返回时，根据NAT表将目的地址数据改写为数据发送出去时候的源地址*恢复原地址*，并发送给主机。解决内网用户用同一个公网地址上网的问题。

需要注意的是，如果你的FORWARD链默认为DROP，上面所有端口转发都必须建立在FORWARD链允许通行的情况下：

iptables -A FORWARD -d 172.29.88.56 -p tcp --dport 8081 -j ACCEPT
iptables -A FORWARD -s 172.29.88.56 -p tcp -j ACCEPT

关于参数:
1. `--to` 可以代替`--to-source` 和`--to-destination`, 反过来就不行

## 日志(Add Chain)
LOG 目标可以用来记录匹配某个规则的数据包。和 ACCEPT 或 DROP 规则不同，进入 LOG 目标之后数据包会继续沿着链向下走。

创建 logdrop 链：

     iptables -N logdrop

定义规则：

     iptables -A logdrop -m limit --limit 5/m --limit-burst 10 -j LOG
     iptables -A logdrop -j DROP
     # 或者
     iptables -A INPUT -m limit --limit 5/m --limit-burst 10 -j LOG
     iptables -A INPUT -j DROP

现在任何时候想要丢弃数据包并且记录该事件，只要跳转到 logdrop 链，例如：

    # iptables -A INPUT -m conntrack --ctstate INVALID -j logdrop

使用 -m limit，可以使用 --limit 来设置平均速率或者使用 --limit-burst 来设置起始触发速率。在上述 logdrop 例子中：

    iptables -A logdrop -m limit --limit 5/m --limit-burst 10 -j LOG

添加一条记录所有通过其的数据包的规则。开始的连续10个数据包将会被记录，之后每分钟只会记录5个数据包。

vi /etc/rsyslog.conf 编辑日志配置文件，添加kern.=notice /var/log/iptables.log，可以将日志记录到自定义的文件中。

    service rsyslog restart #重启日志服务

## 防止DoS攻击
SYN洪水是攻击者发送海量的SYN请求到目标服务器上的一种DoS攻击方法，下面的脚本用于预防轻量级的DoS攻击：

    iptables -N syn-flood   (如果您的防火墙默认配置有“ :syn-flood - [0:0] ”则不许要该项，因为重复了)
    iptables -A INPUT -p tcp --syn -j syn-flood   
    iptables -I syn-flood -p tcp -m limit --limit 2/s --limit-burst 5 -j RETURN   
    iptables -A syn-flood -j REJECT   

    # 防止DOS太多连接进来,可以允许外网网卡每个IP最多15个初始连接,超过的丢弃
    # 需要iptables v1.4.19以上版本：iptables -V 
    iptables -A INPUT -p tcp --syn -i eth0 --dport 80 -m connlimit --connlimit-above 20 --connlimit-mask 24 -j DROP   
    #用Iptables抵御DDOS (参数与上相同)   
    iptables -A INPUT -p tcp --syn -m limit --limit 5/s --limit-burst 10 -j ACCEPT  
    iptables -A FORWARD -p tcp --syn -m limit --limit 1/s -j ACCEPT 
    iptables -A FORWARD -p icmp -m limit --limit 2/s --limit-burst 10 -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type 0 -s ! 172.29.73.0/24 -j DROP

# firewalld
> 参考: https://linux.cn/article-8098-1.html

firewalld是iptables的一个封装，[可以让你更容易地管理iptables规则](https://www.jianshu.com/p/70f7efe3a227)。
虽然iptables命令仍可用于firewalld

    1，firewalld使用区域和服务而不是链式规则；
    2，firewalld可以动态修改单条规则，动态管理规则集，允许更新规则而不破坏现有会话和连接。(还是要reload)
    3，firewalld默认是拒绝的，而iptables默认允许
    4，firewalld自身并不具备防火墙的功能，是和iptables一样需要通过内核的netfilter来实现。

## firewall 管理
    启动服务，并在系统引导时启动该服务：
        sudo systemctl start firewalld
        sudo systemctl enable firewalld

    要停止并禁用：
        sudo systemctl stop firewalld
        sudo systemctl disable firewalld

    检查防火墙状态。输出应该是 running 或者 not running。
        sudo firewall-cmd --state

    要查看 FirewallD 守护进程的状态：
        sudo systemctl status firewalld

    重新加载 FirewallD 配置：
        sudo firewall-cmd --reload

## 配置文件
FirewallD 使用 XML 进行配置, 不要动他，用firewall-cmd 管理！
1. /usr/lib/FirewallD 下保存默认配置，如默认区域和公用服务。 更新时都会覆盖这些文件。
1. /etc/firewalld 下保存系统配置文件。 这些文件将覆盖默认配置。

## 配置集
有两个集：
1. 运行集: firewall-cmd 命令适用于运行时配置，但使用 --permanent 标志将保存到持久配置中。
2. 持久集

将规则同时添加到持久规则集和运行时规则集中。 

    sudo firewall-cmd --zone=public --add-service=http --permanent
    sudo firewall-cmd --zone=public --add-service=http

将规则添加到持久规则集中并重新加载 FirewallD。 permannent 需要reload！

    sudo firewall-cmd --zone=public --add-service=http --permanent
    sudo firewall-cmd --reload

reload 命令会删除所有运行时配置并应用永久配置。因为 firewalld 动态管理规则集，所以它不会破坏现有的连接和会话。
而iptables，在修改了规则后必须得全部刷新才可以生效；iptables --flush

## 区域
firewall 按区域管理(public, home,...):

get 默认的区域:

    sudo firewall-cmd --get-default-zone
        public

modify 修改默认的区域

    sudo firewall-cmd --set-default-zone=internal

get active: 查看你网络接口使用的区域

    sudo firewall-cmd --get-active-zones
        public
        interfaces: enp0s17

get 特定区域的所有配置：

    sudo firewall-cmd --zone=public --list-all

get all zone with config: 得到所有区域的配置： 

    sudo firewall-cmd --list-all-zones

## 服务
每个区域可以提供很多服务: http, ssh,...
1. 默认支持的服务的配置文件位于 /usr/lib /firewalld/services，
2. 用户创建的服务文件在 /etc/firewalld/services 中。

要查看默认的可用服务：

    sudo firewall-cmd --get-services

比如，要启用或禁用 HTTP 服务： 

    sudo firewall-cmd --zone=public --add-service=http --permanent
    sudo firewall-cmd --zone=public --remove-service=http --permanent

### 端口/协议 启用
比如：允许或者禁用 12345 端口的 TCP 流量。

    sudo firewall-cmd --zone=public --add-port=1500/tcp --permanent
    sudo firewall-cmd --zone=public --remove-port=1500/tcp --permanent

remove:

    firewall-cmd --permanent --remove-port=443/tcp --default-zone

### 端口转发
下面是在同一台服务器上将 80 端口的流量转发到 12345 端口。

    sudo firewall-cmd --zone="public" --add-forward-port=port=80:proto=tcp:toport=12345

要将端口转发到另外一台服务器上：

1、 在需要的区域中激活 masquerade。

    sudo firewall-cmd --zone=public --add-masquerade

2、 添加转发规则。例子中是将本地的 80 端口的流量转发到 IP 地址为 ：123.456.78.9 的远程服务器上的  8080 端口。

    sudo firewall-cmd --zone="public" --add-forward-port=port=80:proto=tcp:toport=8080:toaddr=123.456.78.9

要删除规则，用 --remove 替换 --add。比如：

    sudo firewall-cmd --zone=public --remove-masquerade

### 构建规则集
例如，以下是如何使用 FirewallD 为你的服务器配置基本规则（如果您正在运行 web 服务器）。

1.将 eth0 的默认区域设置为 dmz。 在所提供的默认区域中，dmz（非军事区）是最适合于这个程序的，因为它只允许 SSH 和 ICMP。

    sudo firewall-cmd --set-default-zone=dmz
    sudo firewall-cmd --zone=dmz --add-interface=eth0

2、 把 HTTP 和 HTTPS 添加永久的服务规则到 dmz 区域中：

    sudo firewall-cmd --zone=dmz --add-service=http --permanent
    sudo firewall-cmd --zone=dmz --add-service=https --permanent

 3、 重新加载 FirewallD 让规则立即生效：

    sudo firewall-cmd --reload

如果你运行 firewall-cmd --zone=dmz --list-all， 会有下面的输出：

    dmz (default)
        interfaces: eth0
        sources:
        services: http https ssh
        ports:
        masquerade: no
        forward-ports:
        icmp-blocks:
        rich rules:

这告诉我们，dmz 区域是我们的默认区域，
1. 它被用于 eth0 接口中所有网络的源地址和端口。 
2. 允许传入 HTTP（端口 80）、HTTPS（端口 443）和 SSH（端口 22）的流量，并且由于没有 IP 版本控制的限制，这些适用于 IPv4 和 IPv6。 
3. 不允许IP 伪装以及端口转发(masquerade) 
4. 我们没有 ICMP 块，所以 ICMP 流量是完全允许的。
5. 没有丰富Rich规则，允许所有出站流量。

## 高级
### 丰富规则
丰富规则的语法有很多` man firewalld.richlanguage`。 
使用 `--add-rich-rule、--list-rich-rules 、 --remove-rich-rule 和 firewall-cmd` 命令来管理它们。

这里有一些常见的例子：

允许来自主机 192.168.0.14 的所有 IPv4 流量。

    sudo firewall-cmd --zone=public --add-rich-rule 'rule family="ipv4" source address=192.168.0.14 accept'

拒绝来自主机 192.168.1.10 到 22 端口的 IPv4 的 TCP 流量。

    sudo firewall-cmd --zone=public --add-rich-rule 'rule family="ipv4" source address="192.168.1.10" port port=22 protocol=tcp reject'

允许来自主机 10.1.0.3 到 80 端口的 IPv4 的 TCP 流量，并将流量转发到 6532 端口上。 

    sudo firewall-cmd --zone=public --add-rich-rule 'rule family=ipv4 source address=10.1.0.3 forward-port port=80 protocol=tcp to-port=6532'

将主机 172.31.4.2 上 80 端口的 IPv4 流量转发到 8080 端口（需要在区域上激活 masquerade）。

    sudo firewall-cmd --zone=public --add-rich-rule 'rule family=ipv4 forward-port port=80 protocol=tcp to-port=8080 to-addr=172.31.4.2'

列出你目前的丰富规则：

    sudo firewall-cmd --list-rich-rules

### iptables 的直接接口
FirewallD 提供了一个直接Direct接口，允许你给它传递原始 iptables 命令。 直接接口规则不是持久的，除非使用 --permanent。

要查看添加到 FirewallD 的所有自定义链或规则：

    firewall-cmd --direct --get-all-chains
    firewall-cmd --direct --get-all-rules

# 参考
- [Mac 下的iptables](/p/net-iptables-mac.md)
- Linux 防火墙 iptables 初学者教程:
   http://segmentfault.com/a/1190000000448609
