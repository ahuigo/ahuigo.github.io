---
title: net-route
date: 2018-09-28
---
# Preface
1. traceroute [option] host, 路由经过的节点
    1. -m 10 跳数设置
1. check route
    0. netstat -nr
        1. ifconfig |grep gateway ;#linux only
        2. route get default | grep gateway ; # mac only

# netstat -nr
## route解释
```
$ netstat -nr      
Internet6:
Destination                             Gateway                                 Flags               Netif Expire
default                                 fe80::%utun0                            UGcIg               utun0       
default                                 fe80::%utun1                            UGcIg               utun1       
default                                 fe80::%utun2                            UGcIg               utun2       
::1                                     ::1                                     UHL                   lo0       
fe80::%utun0/64                         fe80::1785:b6f8:da9:e7d3%utun0          UcI                 utun0       
fe80::1785:b6f8:da9:e7d3%utun0          link#18                                 UHLI                  lo0       
fe80::%utun1/64                         fe80::482:9d73:2870:2e7f%utun1          UcI                 utun1       
fe80::482:9d73:2870:2e7f%utun1          link#19                                 UHLI                  lo0       
fe80::%utun2/64                         fe80::ce81:b1c:bd2c:69e%utun2           UcI                 utun2       
fe80::ce81:b1c:bd2c:69e%utun2           link#20                                 UHLI                  lo0       
ff00::/8                                fe80::1785:b6f8:da9:e7d3%utun0          UmCI                utun0       
ff00::/8                                fe80::482:9d73:2870:2e7f%utun1          UmCI                utun1       
ff00::/8                                fe80::ce81:b1c:bd2c:69e%utun2           UmCI                utun2       
```
说明(post/net/net-tcpip.md):  
1. Destination 是目的网络地址: 
    - 前面的default是默认规则默认地址, 
    - `ff00::/8`表示前8位是`ff`的目标, 这是ipv6多播 (Multicast) 地址. 一个源发送数据包给一组特定的目标设备，这些设备都加入了同一个多播组
    - `ff02::` 是这个多播空间中的一个特定子范围，`02`称为链路本地范围 (Link-Local Scope) 多播地址。
        路由器绝不会将链路本地范围的多播数据包转发到其他网络链路上
        - ff02::1 是所有节点 (All Nodes) 的链路本地多播地址。
            像是一个公共频道，链路上所有 IPv6 设备(打印机、手机、)都在收听。路由器用它来向所有设备广播网络配置信息。
        - ff02::2 是所有路由器 (All Routers) 的链路本地多播地址。
            像是一个给管理员（路由器）的频道。路由器会监听此地址并提供网络配置信息。
    - `ff01::%lo0/32` 其实表示的是: `ip%<interface>/32`，后面是（类似url中的#）
        这个表达式指的是在环回接口 (lo0) 上的，所有属于 ff01:0000::/32 这个范围内的接口本地多播 IPv6 地址。`
2. Gateway 是下一跳地址
3. Iface 是接口

### Gateway 下一跳地址
假设你的路由表中有这样一条规则（简化）：

    Destination        Gateway            Flags        Netif
    default            192.168.1.1        UGScg        en0

    Destination: default: 这条规则适用于所有没有更具体匹配规则的目标（即互联网上的大部分地址）。
    Gateway: 192.168.1.1: 这是下一跳地址。你的电脑会将发往互联网的数据包先发送给 IP 地址为 192.168.1.1 的设备（这通常是你家或办公室的路由器）。
    Netif: en0: 数据包将通过 en0 (例如 Wi-Fi 接口) 发送。

数据包发送流程图（以 curl http://202.100.1.1 为例） 假设本地主机 IP 为 192.168.1.201，目标公网 IP 为 202.100.1.1，流程如下：

1. 本地主机处理（192.168.1.201）
    步骤 1：确定路由
        目标 IP（202.100.1.1）不在本地子网（192.168.1.0/24）内，匹配默认路由，**下一跳为 192.168.1.1**（本地路由器）。
    步骤 2：封装数据包
        IP 层：源 IP 为 192.168.1.201，目标 IP 为 202.100.1.1。
        MAC 层：源 MAC 为本地网卡 MAC 地址，目标 MAC 为路由器 LAN 接口的 MAC 地址（通过 ARP 协议获取）。
    步骤 3：发送至路由器
        数据包通过 en0 接口发送到 192.168.1.1。
2. 本地路由器处理（192.168.1.1）
    步骤 1：解封装与路由查询
        路由器剥离 MAC 头部，根据目标 IP（202.100.1.1）查询自身路由表，确定出口为 WAN 接口（公网 IP 假设为 218.1.1.1）。
    步骤 2：NAT 转换（若启用）
        若路由器开启 NAT（网络地址转换），会将源 IP 192.168.1.201 替换为自身 WAN 接口的公网 IP（218.1.1.1），以便公网设备响应。
    步骤 3：重新封装与转发
        IP 层：源 IP 为 218.1.1.1，目标 IP 为 202.100.1.1。
        MAC 层：源 MAC 为路由器 WAN 接口 MAC，目标 MAC 为运营商网关或下一跳路由设备的 MAC。
        数据包通过 WAN 接口发送至公网。
3. 公网传输（互联网）
    数据包通过各级路由器的路由转发（基于 BGP、OSPF 等协议），最终到达目标服务器 202.100.1.1。
4. 目标服务器响应（202.100.1.1）
    服务器收到请求后，返回响应数据包，其路由路径与请求路径反向：
    202.100.1.1 → 公网路由器 → 本地路由器 WAN 接口 → 本地路由器 LAN 接口（192.168.1.1）→ 本地主机（192.168.1.201）。

### 模拟ip数据包
如果一个请求候想命中最后一条路由规则, 就需要指定目标地址`ff00::/8`  +`utun2`, 方法有:
```bash
# 先在新终端窗口运行 tcpdump 监控 utun0 接口上的 IPv6 流量: 
sudo tcpdump -i utun0 -n ip6

# 1. 向所有链路本地节点的多播地址 ff02::1 发送 ping 请求，并强制从 utun0 接口发出(下一跳发出的地址是Gateway)
sudo ping6 -I utun2 ff02::1
# 2. curl
curl --interface utun0 "http://[ff02::1]/"
```
## 删除route

    sudo route delete -inet6 ff00::/8 -ifp utun1
    sudo route delete -inet6 ff00::/8 -ifp utun2

# route

    route -- manually manipulate the routing tables

## check route
check route tables

	$ netstat -nr
	$ route (for linux only)

check gateway(route)

	$ netstat -nr | grep default |grep -o -E '\d{1,3}(\.\d{1,3}){3}'
	$ route get default | grep gateway (for mac only)
	$ route get baidu.com | grep gateway (for mac only)
	$ ifconfig |grep gateway (for linux only)

## add route

	route add 1.0.1.0/24 "$gateway"
	route del 1.0.1.0/24 "$gateway"

# vpn route
打开 http://ip.chinaz.com 显示的是国内 IP，说明智能加速安装成功
> vpn的原理就是修改route， 添加interface

## install

	sudo cp ip-up ip-down /etc/ppp/
	cd /etc/ppp; sudo chmod a+x ip-up ip-down

## uninstall

	sudo rm /etc/ppp/{ip-up,ip-down}

cat ip-up

	# Generate on 2014-07-02 04:38 by VPNCloud
	export PATH="/bin:/sbin:/usr/sbin:/usr/bin"
	OLDGW=`netstat -nr | grep '^default' | grep -v 'ppp' | sed 's/default *\([0-9\.]*\) .*/\1/'`
	if [ ! -e /tmp/pptp_oldgw ]; then
		echo "${OLDGW}" > /tmp/pptp_oldgw
	fi
	killall -HUP mDNSResponder # 或者 dscacheutil -flushcache
	route add 1.0.1.0/24 "${OLDGW}"
	route add 1.0.2.0/23 "${OLDGW}"
	route add 1.0.8.0/21 "${OLDGW}"
	route add 1.0.32.0/19 "${OLDGW}"
	route add 1.1.0.0/24 "${OLDGW}"
	route add 1.1.2.0/23 "${OLDGW}"
	route add 1.1.4.0/22 "${OLDGW}"

http://igfvv.com/local-routing-table-for-mac-os-x
https://www.ytvpn.com/admin/speed_up


内网
ip-down 里增加：

	route delete 172.16.0.0/12 ${OLDGW}
	route delete 10.0.0.0/8 ${OLDGW}
	route delete 192.168.0.0/16 ${OLDGW}
	route delete 202.108.0.0/16 ${OLDGW}

ip-up 里增加：

	route add 172.16.0.0/12 "${OLDGW}"
	route add 10.0.0.0/8 "${OLDGW}"
	route add 192.168.0.0/16 "${OLDGW}"
	route add 202.108.0.0/16 ${OLDGW}

# system proxy
查看系统代理：

    $ scutil --proxy
    <dictionary> {
    HTTPEnable : 0
    HTTPSEnable : 0
    ProxyAutoConfigEnable : 0 // 1 表示启用PAC 文件
    SOCKSEnable : 0
    }