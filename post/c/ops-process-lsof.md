---
layout: page
title:
category: blog
description:
---
# Preface


# lsof
[/p/linux-process-lsof](/p/linux-process-lsof)

List Open File


## format

	-n  inhibits  the conversion of network numbers to host names for network files.
	-P  inhibits  the  conversion  of port numbers to port names for network files.

## via socket
Find original owning process of a Linux socket

	sudo lsof /dev/shm/mc.sock
	lsof -U #all UNIX socket

## and logic

	-a	and logic.
	-U -a -ufoo
		selects -U(socket) that belong to processes owned by user‘‘foo’’.

## via fd

	$ strace -p <pid> -f
	poll([{fd=5, events=POLLIN|POLLPRI|POLLRDNORM|POLLRDBAND}], 1, 1000) = 0 (Timeout)
	$ lsof -d 5 | grep <pid>
	php        2624      www    5u  IPv4        3876970637      0t0        TCP *:45473->host-31.alipay.com:https (ESTABLISHED)


## via port and protocol

	-i [i]
	-i [46][protocol][@hostname|hostaddr][:service|port]
		selects  the  listing  of  files any of whose Internet address matches the address specified in i.
		46	ipv4 or ipv6

example

	lsof -i :portNumber
	lsof -i tcp:portNumber
	lsof -i udp:portNumber
	lsof -i :80
	lsof -i :80 | grep LISTEN

列出目前连接主机nf5260i5-td上端口为：20，21，80相关的所有文件信息，且每隔3秒重复执行

	lsof -i @nf5260i5-td:20,21,80 -r 3

### via protocol

	lsof -n -i4TCP:$PORT | grep LISTEN

## user
查看用户username的进程所打开的文件

	$ lsof -u username
	# 用户打开的进程
	$ ps -lu username

## via process
查询init进程当前打开的文件

	$lsof -c init

查询指定的进程ID(23295)打开的文件：

	$lsof -p 23295
	$lsof -p $$
	$lsof -p pid1 -p pid2

## via dir
查询指定目录下被进程开启的文件（使用+D 递归目录）：

	$lsof +d mydir1/

# find process

	lsof file 查看文件被哪些进程使用
	fuser -m -u file
		-m 显示pid
		-u 显示owner
		-k kill 占用的进程


# Reference
- [c-debug-tool]

[c-debug-tool]: http://linuxtools-rst.readthedocs.org/zh_CN/latest/advance/02_program_debug.html#nm
