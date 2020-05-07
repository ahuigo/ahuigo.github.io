---
layout: page
title: ops-process-lsof
category: blog
description: 
date: 2018-09-27
---
# lsof
[/p/linux-process-lsof](/p/linux-process-lsof)

List Open File. 比如查看所有打开file descriptor

    lsof | wc -l

## format

	-n  inhibits  the conversion of network numbers to host names for network files.
	-P  inhibits  the conversion of port numbers to port names for network files.

## via socket
Find original owning process of a Linux socket

	sudo lsof /dev/shm/mc.sock

## filter
	-U          #selects the listing of UNIX domain socket files.
    -u users    #selects  the  listing of files for the user whose login names or
                user ID numbers  are  in  the  comma-separated  set  s  -  e.g.,
                ``abe'',  or  ``548,root''.

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

find all listen port

     sudo lsof -i -P -n | grep LISTEN

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

	$lsof -c <进程名>
	$lsof -c init

查询指定的进程ID(23295)打开的文件：

	$lsof -p 23295
	$lsof -p $$
	$lsof -p pid1 -p pid2

    # OR
    ls -l /proc/23295/fd/

## via dir
查询指定目录下被进程开启的文件（使用+D 递归目录）：

	$lsof +d mydir1/

# /proc(procfs File System)
/proc (or procfs) is a pseudo-file system that it is dynamically generated after each reboot. It is used to access kernel information.

    /proc/PID/cmdline : process arguments
    /proc/PID/cwd : process current working directory (symlink)
    /proc/PID/exe : path to actual process executable file (symlink)
    /proc/PID/environ : environment used by process
    /proc/PID/root : the root path as seen by the process. For most processes this will be a link to / unless the process is running in a chroot jail.
    /proc/PID/status : basic information about a process including its run state and memory usage.
    /proc/PID/task : hard links to any tasks that have been started by this (the parent) process.

# List File Descriptors in Kernel Memory

    $ sysctl fs.file-nr
    fs.file-nr = 1020	0	70000
    # or
    $ cat /proc/sys/fs/file-nr

Where:

    1020 The number of allocated file handles.
    0 The number of unused-but-allocated file handles.
    70000 The system-wide maximum number of file handles.

find out the system-wide maximum number of file handles:

    $ sysctl fs.file-max
    fs.file-max = 70000

# find process

	lsof file 查看文件被哪些进程使用
	fuser -m -u file
		-m 显示pid
		-u 显示owner
		-k kill 占用的进程


# References
- [c-debug-tool]

[c-debug-tool]: http://linuxtools-rst.readthedocs.org/zh_CN/latest/advance/02_program_debug.html#nm