---
layout: page
title:	linux top命令简明教程
category: blog
description: 
---
# Preface
linux 下有很多用于查看高负载的命令，比如top 用来查看内存/cpu 消耗的，iotop 用来查看io 消耗的。

# top
top 是一个动态查看进程信息的工具(推荐用`htop`)

	top - 04:18:11 up 29 days,  2:38,  1 user,  load average: 0.00, 0.02, 0.07
	Tasks:  71 total,   1 running,  70 sleeping,   0 stopped,   0 zombie
	Cpu(s):  0.0%us,  0.3%sy,  0.7%ni, 99.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
	Mem:    502440k total,   159412k used,   343028k free,     7824k buffers
	Swap:  1048568k total,      248k used,  1048320k free,    76732k cached

	  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
	27529 root       1 -19  402m 9024 1596 S  0.0  1.8   0:00.07 php-fpm
	27530 www        1 -19  402m 8356  912 S  0.0  1.7   0:00.00 php-fpm

> mac 下top -n3 查看使用率最高的的前3

## 开机信息

	top - 04:18:11 up 29 days,  2:38,  1 user,  load average: 0.00, 0.02, 0.07

第一行是开机信息： 开机了29天2小时38分, 一个用户， 近期的OS 负载：1分钟，5分钟，15分钟

## 进程信息

	Tasks:  71 total,   1 running,  70 sleeping,   0 stopped,   0 zombie

## cpu 信息

	Cpu(s):  0.0%us,  0.3%sy,  0.7%ni, 99.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st

	0.0%us user mode 用户空间占用CPU的百分比
	0.3%sy system mode 内核空间占用CPU的百分比
	0.7%ni 改变过优先级的进程占用CPU的百分比
	99.0%id 空闲CPU的百分比
	0.0%wa IO Waiting 占用CPU的百分比
	0.0%hi 硬中断(Hardware IRQs)占用CPU的百分比
	0.0%si 软中断(Software Interrupt Requests)占用CPU的百分比
	0.0%st steal (time given to other DomU instances)

## 内存信息

	Mem:    502440k total,   159412k used,   343028k free,     7824k buffers

	total 总
	used 使用
	free 未用
	buffers 缓冲交换区占用

## swap 信息

	Swap:  1048568k total,      248k used,  1048320k free,    76732k cached

> 一般可用内存包括：free + buffers + cached

## 进程信息

	  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
	27529 root       1 -19  402m 9024 1596 S  0.0  1.8   0:00.07 php-fpm
	27538 www       20   0  400m  30m  23m S  0.0  6.3   0:00.02 php

	RES — 进程使用的、未被换出的物理内存大小，单位kb。RES=CODE+DATA
	VIRT — 进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES
	SHR — 共享内存大小，单位kb

### Highlight高亮

	h 帮助

### sort

	x 排序序列高亮
	F/O 选择排序序列
	shift + </> 左右改变排序序列

### filed

	f/o add/remove field

### COMMAND

	c 切换显示命令名称和完整命令行
	top -c 启动时

### nice

	r 重新安排进程优先级
		数值越小，级别越高

# 查看io

	iotop -o

# Reference
- [top]
- [swap]

[top]: http://www.cnblogs.com/peida/archive/2012/12/24/2831353.html
[swap]: http://blog.csdn.net/xiangliangyu/article/details/8213127
[mysql swap]: http://blog.sina.com.cn/s/blog_4e46604d01016sp0.html
