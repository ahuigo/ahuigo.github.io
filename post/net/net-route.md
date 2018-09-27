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