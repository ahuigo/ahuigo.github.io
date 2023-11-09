---
layout: page
title: ops-process-lsof
category: blog
description: 
date: 2018-09-27
---
# lsof: list open file
[/p/linux-process-lsof](/p/linux-process-lsof)

List Open File. 比如查看所有打开file descriptor

    lsof | wc -l

## format

	-n  inhibits  the conversion of network numbers to host names for network files.
	-P  inhibits  the conversion of port numbers to port names for network files.

### 显示fd
>参考：https://linuxtools-rst.readthedocs.io/zh_CN/latest/tool/lsof.html
lsof 输出有一列是fd

    $ sleep 130 >& 1.txt & 
    [4] 48020
    $ lsof -p $!          
    COMMAND   PID USER   FD   TYPE DEVICE  SIZE/OFF      NODE NAME
    sleep   48020 ahui    0u   CHR   16,3 0t6282450     13225 /dev/ttys003
    sleep   48020 ahui    1w   REG    1,4         0  33995271 /Users/a/1.txt
    sleep   48020 ahui    2w   REG    1,4         0  33995271 /Users/a/1.txt
    sleep   48020 ahui    6u   CHR   16,3 0t6282450     13225 /dev/ttys003

FD：文件描述符，应用程序通过文件描述符识别该文件。如cwd、txt, 1w等:

    （1）cwd：表示current work dirctory，即：应用程序的当前工作目录，这是该应用程序启动的目录，除非它本身对这个目录进行更改
    （2）txt ：该类型的文件是程序代码，如应用程序二进制文件本身或共享库，如上列表中显示的 /sbin/init 程序
    （3）lnn：library references (AIX);
    （4）er：FD information error (see NAME column);
    （5）jld：jail directory (FreeBSD);
    （6）ltx：shared library text (code and data);
    （7）mxx ：hex memory-mapped type number xx.
    （8）m86：DOS Merge mapped file;
    （9）mem：memory-mapped file;
    （10）mmap：memory-mapped device;
    （11）pd：parent directory;
    （12）rtd：root directory;
    （13）tr：kernel trace file (OpenBSD);
    （14）v86  VP/ix mapped file;
    （15）0：表示标准输入
    （16）1：表示标准输出
    （17）2：表示标准错误

一般在标准输出、标准错误、标准输入后还跟着文件状态模式：r、w、u等

    （1）u：表示该文件被打开并处于读取/写入模式
    （2）r：表示该文件被打开并处于只读模式
    （3）w：表示该文件被打开并处于
    （4）空格：表示该文件的状态模式为unknow，且没有锁定
    （5）-：表示该文件的状态模式为unknow，且被锁定

同时在文件状态模式后面，还跟着相关的锁

    （1）N：for a Solaris NFS lock of unknown type;
    （2）r：for read lock on part of the file;
    （3）R：for a read lock on the entire file;
    （4）w：for a write lock on part of the file;（文件的部分写锁）
    （5）W：for a write lock on the entire file;（整个文件的写锁）
    （6）u：for a read and write lock of any length;
    （7）U：for a lock of unknown type;
    （8）x：for an SCO OpenServer Xenix lock on part      of the file;
    （9）X：for an SCO OpenServer Xenix lock on the      entire file;
    （10）space：if there is no lock.

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
通过fd 查找打开的文件

	$ strace -p <pid> -f
	poll([{fd=5, events=POLLIN|POLLPRI|POLLRDNORM|POLLRDBAND}], 1, 1000) = 0 (Timeout)
	$ lsof -d 5 | grep <pid>
	php        2624      www    5u  IPv4        3876970637      0t0        TCP *:45473->host-31.alipay.com:https (ESTABLISHED)


## via port and protocol

	-i [i]
	-i [46][protocol][@hostname|hostaddr][:service|port]
		selects  the  listing  of  files any of whose Internet address matches the address specified in i.
		46	ipv4 or ipv6

显示所有tcp:

    $ sudo lsof -iTCP -sTCP:ESTABLISHED,LISTEN -n -P
    COMMAND     PID USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
    postgres    530 ahui    8u  IPv4 0x803b407c764b7f2b      0t0  TCP 127.0.0.1:5432 (LISTEN)
    参数：
        -iTCP：选择列出所有 TCP 网络文件。
            -iTCP:$PORT 选择端口
            -i:80 只选择端口
        -sTCP:ESTABLISHED,LISTEN。选择TCP状态 ESTABLISHED 和 LISTEN 状态的 TCP 连接。
        -n：阻止尝试将网络编号转换为名称。
        -P：阻止尝试将端口号转换为名称。
    输出：
        SIZE/OFF 代表常规文件的偏移，对于网络socket无意义。
        NODE    文件inode 或 TCP/UDP
        NAME    文件或socket链接



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

# 系统相关
## /proc(procfs File System, linux only)
/proc (or procfs) is a pseudo-file system that it is dynamically generated after each reboot. It is used to access kernel information.

    /proc/PID/cmdline : process arguments
    /proc/PID/cwd : process current working directory (symlink)
    /proc/PID/exe : path to actual process executable file (symlink)
    /proc/PID/environ : environment used by process
    /proc/PID/root : the root path as seen by the process. For most processes this will be a link to / unless the process is running in a chroot jail.
    /proc/PID/status : basic information about a process including its run state and memory usage.
    /proc/PID/task : hard links to any tasks that have been started by this (the parent) process.

## List File Descriptors in Kernel Memory

    # linux
    $ sysctl fs.file-nr
    fs.file-nr = 1020	0	70000
        第一个值（1020）：当前系统已分配（已打开）的文件描述符数量。
        第二个值（0）：系统中当前在使用但还未关闭（也就是“孤立”了）的文件描述符数量。这种情况可能发生在文件被删除或文件系统被卸载，但相关进程尚未关闭对应文件描述符的情况下。
        第三个值（70000）：系统配置的最大文件描述符数量。
    # or
    $ cat /proc/sys/fs/file-nr

    # mac
    $ sysctl kern.num_files
    kern.num_files: 8927 (当前打开的文件描述符)
    $ launchctl limit maxfiles (每个进程所允许的最大打开文件数量的限制)
    maxfiles    256            unlimited
        256: （soft limit），指单个用户或进程在没有特殊权限的情况下能够打开的最大文件数。
        unlimited（hard limit），表示系统级别的最大值，即系统允许一个进程最多可以打开的文件数量。
        soft limit 用户可以修改; 而hard limit 只能sudo/root 才可以修改



Where:

    1020 The number of allocated file handles.
    0 The number of unused-but-allocated file handles.
    70000 The system-wide maximum number of file handles.

find out the system-wide maximum number of file handles:

    $ sysctl fs.file-max
    fs.file-max = 70000

# find process by file

	lsof file 查看文件被哪些进程使用
	fuser -m -u file
		-m 显示pid
		-u 显示owner
		-k kill 占用的进程

# References
- [c-debug-tool]

[c-debug-tool]: http://linuxtools-rst.readthedocs.org/zh_CN/latest/advance/02_program_debug.html#nm