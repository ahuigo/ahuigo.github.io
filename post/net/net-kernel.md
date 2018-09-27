---
title: ipv4
date: 2018-09-28
---
# ipv4
## ip_forward
首先要开启端口转发器必须先修改内核运行参数ip_forward,打开转发:

	# echo 1 > /proc/sys/net/ipv4/ip_forward   //此方法临时生效
	或
	# vi /ect/sysctl.conf                      //此方法永久生效
	# sysctl -p