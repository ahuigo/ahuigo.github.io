---
layout: page
title:
category: blog
description:
---
# Preface
通过iostat方便查看CPU、网卡、tty设备、磁盘、CD-ROM 等等设备的活动情况, 负载信息。

	iostat[参数][时间][次数]

	-C 显示CPU使用情况
	-d 显示磁盘使用情况
	-k 以 KB 为单位显示
	-m 以 M 为单位显示
	-N 显示磁盘阵列(LVM) 信息
	-n 显示NFS 使用情况
	-p[磁盘] 显示磁盘和分区的情况
	-t 显示终端和CPU的信息
	-x 显示详细信息
	-V 显示版本信息

# cpu属性值说明：

	%user：CPU处在用户模式下的时间百分比。
	%nice：CPU处在带NICE值的用户模式下的时间百分比。
	%system：CPU处在系统模式下的时间百分比。
	%iowait：CPU等待输入输出完成时间的百分比。
	%steal：管理程序维护另一个虚拟处理器时，虚拟CPU的无意识等待时间百分比。
	%idle：CPU空闲时间百分比。

注：如果%iowait的值过高，表示硬盘存在I/O瓶颈，%idle值高，表示CPU较空闲，如果%idle值高但系统响应慢时，有可能是CPU等待分配内存，此时应加大内存容量。%idle值如果持续低于10，那么系统的CPU处理能力相对较低，表明系统中最需要解决的资源是CPU。

# disk属性值说明：

	rrqm/s: 每秒进行 merge 的读操作数目。即 rmerge/s
	wrqm/s: 每秒进行 merge 的写操作数目。即 wmerge/s
	r/s: 每秒完成的读 I/O 设备次数。即 rio/s
	w/s: 每秒完成的写 I/O 设备次数。即 wio/s
	rsec/s: 每秒读扇区数。即 rsect/s
	wsec/s: 每秒写扇区数。即 wsect/s
	rkB/s: 每秒读K字节数。是 rsect/s 的一半，因为每扇区大小为512字节。
	wkB/s: 每秒写K字节数。是 wsect/s 的一半。
	avgrq-sz: 平均每次设备I/O操作的数据大小 (扇区)。
	avgqu-sz: 平均I/O队列长度。
	await: 平均每次设备I/O操作的等待时间 (毫秒)。
	svctm: 平均每次设备I/O操作的服务时间 (毫秒)。
	%util: 一秒中有百分之多少的时间用于 I/O 操作，即被io消耗的cpu百分比

备注：如果 %util 接近 100%，说明产生的I/O请求太多，I/O系统已经满负荷，该磁盘可能存在瓶颈。如果 svctm 比较接近 await，说明 I/O 几乎没有等待时间；如果 await 远大于 svctm，说明I/O 队列太长，io响应太慢，则需要进行必要优化。如果avgqu-sz比较大，也表示有当量io在等待。

# 查看TPS和吞吐量

	/root$iostat -d -k 1 1
	Linux 2.6.32-279.el6.x86_64 (colin)   07/16/2014      _x86_64_        (4 CPU)

	Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
	sda               1.95         0.74        35.44    4572712  218559410
	dm-0              3.08         0.28        12.17    1696513   75045968
	dm-1              5.83         0.46        23.25    2857265  143368744
	dm-2              0.01         0.00         0.02      11965     144644

tps：该设备每秒的传输次数（Indicate the number of transfers per second that were issued to the device.）。“一次传输”意思是“一次I/O请求”。多个逻辑请求可能会被合并为“一次I/O请求”。“一次传输”请求的大小是未知的。

	kB_read/s：每秒从设备（drive expressed）读取的数据量；
	kB_wrtn/s：每秒向设备（drive expressed）写入的数据量；
	kB_read：读取的总数据量；kB_wrtn：写入的总数量数据量；

# Reference
- [iostat]

[iostat]: http://linuxtools-rst.readthedocs.org/zh_CN/latest/tool/iostat.html
