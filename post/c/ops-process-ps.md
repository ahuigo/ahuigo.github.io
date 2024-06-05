---
layout: page
title: ops-process-ps
category: blog
description: 
date: 2018-09-27
---
# Preface

# processe status
linux上进程有5种状态:

1. 运行(正在运行或在运行队列中等待)
2. 中断(休眠中, 受阻, 在等待某个条件的形成或接受到信号)
3. 不可中断(收到信号不唤醒和不可运行, 进程必须等待直到有中断发生)
4. 僵死(进程已终止, 但进程描述符存在, 直到父进程调用wait4()系统调用后释放)
5. 停止(进程收到SIGSTOP, SIGSTP, SIGTIN, SIGTOU信号后停止运行运行)

ps工具标识进程的5种状态码:

1. R 运行 runnable (on run queue)
1. S 中断 sleeping
1. D 不可中断 uninterruptible sleep (usually IO)
1. Z 僵死 a defunct (”zombie”) process
1. T 停止 traced or stopped

## check pid exist

    kill -0 $pid && echo pid exist
    [ -n "$PID" -a -e /proc/$PID ]
    [ -n "$(ps -p $PID -o pid=)" ]

# ps

	ps -options
	ps [axu] -option
	ps [ajx] -option

-Options:

	-e, -A
		Select all processes.  Identical to -e.
    a   show other users' processes as well as your own
    -f  (linux)Do full-format listing.
        (mac) Display the uid, pid, parent pid, ....
		-L, (linux) the NLWP (number of threads) and LWP (thread ID) columns will be added
	-T Show threads, possibly with SPID column
	-L Show threads, possibly with LWP and NLWP columns
    -A  Display other users' processes, including those without controlling terminals. 
	-a,a
        Display other users' processes, skip without controlling terminals. unless the -x option is also specified
        一般 ax 一起用
	-x,x
		include processes which do not have a controlling terminal.
	-U userlist
        Select by real user ID (RUID) or name
	-u userlist
		Select by effective user ID (EUID) or name
	u
		Display user-oriented format
        ps aux
    -j,j
       Print information associated with the following keywords: user, pid, ppid, pgid, sess, jobc, state, tt, time, and command.
       ps ajx

## header
headers:`man ps`

	C			processor utilization.(see %cpu).
	COMMAND		see args. (alias args, cmd)
	PPID     parent process ID.
	SPID     see lwp. (alias lwp, tid).out.
	LWP      lwp (light weight process, or thread) ID of the lwp being reported.

## OUTPUT MODIFIERS

    c   Show the true command name.
    -l  print: uid, pid, ppid, flags, cpu, pri, nice, vsz=SZ, rss, wchan, state=S, paddr=ADDR, tty, time, and command=CM
    -j  print: user, pid, ppid, pgid, sess, jobc, state, tt, time, and command.
        ps -ej; ps ej
    -L  Show threads, possibly with LWP and NLWP columns.
    m   Show threads after processes.
    -m  Show threads after processes.
    -T  Show threads, possibly with SPID column.

In legacy mode(加`-`前缀就是legacy mode), 此模式只有`-uegl` 四个. 其它选项不受`-`的影响

    -u  show: user, pid, %cpu, %mem, vsz, rss, tt, state, start, time, and command. 
        ps aux === ps u -ax !== ps -aux
            ps -aux  它这时指  ps -a -u x,uname2,uname3(x这个用户不存在)
            建议用 ps ajx

mac:

	-M Show threads

## filter
    
    -a other users' processes as well as your own.
    -x include processes which do not have a controlling terminal.
    -A user process + controlling terminal
    -e identical to -A
        ps -A == ps -e == ps -ax

    -u the processes belonging to the specified usernames.(default own)
        -u user1,user1,...
        -U uid1,uid2,...
	-p pid,pid,...

## sort

	-r      Sort by current CPU usage

## format

### hide title(h)

	 ps -C php -O args h

### info field

	-f
		UID   PID  PPID   C STIME   TTY           TIME CMD
	-u,
		USER  PID  %CPU %MEM      VSZ    RSS   TT  STAT STARTED      TIME COMM
	-l
		UID   PID  PPID   F CPU PRI NI       SZ    RSS WCHAN     S             ADDR TTY           TIME CMD
	-w,w
		Use 132 columns to display information.
		If the -w option is specified more than once(-ww,ww), ps will use as many columns as necessary without regard for your window size

#### get process name

    NAME=`ps -q $PID -o comm=`

查看挂载点：

    MNTNS=`readlink /proc/$PID/ns/mnt`

#### specify field

	ps -o rss,vsz
	ps -o args
	ps -L "list all field
	ps -p 2624 -o lstart; #列出进程创建时间

##### print time

	stime start time
	etime elapsed time

example

	$ ps -p "$$" -o etime=
		11:28 //11 min 28 sec
	$ ps -o stime= "$$"
		21:10 //start at 21:10:00
	$ ps -o stime "$$"
		STIME
		21:10 //start ast 21:10:00

#### specify cmdlist

	-C cmdlist      Select by command name.
		This selects the processes whose executable name is given in cmdlist.

Example

	$ ps ef -o command,vsize,rss,size -C php-fpm
	COMMAND                        VSZ   RSS  SIZE
	php-fpm: master process (/u 459152  9912  3304
	 \_ php-fpm: pool www       459152  7732  3304
	 \_ php-fpm: pool www       459152  7732  3304

### 打印指令
print command name (not path)

	ps c
		Show the true command name. not from argv

### 字段说明

	USER: 行程拥有者
	PID: pid
	%CPU: 占用的 CPU 使用率
	TTY: 终端的次要装置号码 (minor device number of tty)
	STAT: 该行程的状态:
		R: running
		S: sleeping
		D: uninterruptible sleep (usually IO)
		Z: zombie
		T: stop
	START: 行程开始时间
	TIME: 执行的时间
	COMMAND:所执行的指令

	PR — 进程优先级
	NI — nice值。负值表示高优先级，正值表示低优先级

#### MEM
内存占用：
- 进程独立申请的内存USS
- 进程之间共享的内存 shared library
- 缓存：
    1. 文件系统缓存(读文件的缓存)
        操作系统为了提高磁盘访问速度，会将读取的数据缓存在内存中。这种机制使得频繁访问的文件不需要每次都从慢速的磁盘读取，而可以直接从快速的 RAM 中获取，大幅提升性能。文件系统缓存通常会占据大量的内存空间。
    2. Slab 分配器缓存：
        Linux 内核使用 slab 分配器来管理内核对象（如进程描述符、文件对象等）的内存分配和回收。Slab 缓存可以提高内存分配的效率，并减少内存碎片。
    3. Buffers：
        Buffers 是内核用来存放有关 I/O 操作的原始块设备数据的内存区域。比如说，在写入数据到磁盘之前，数据可能会先被暂存到 buffers 中。
    4. 临时文件（tmpfs/shm）：
        如果应用程序使用共享内存（例如 POSIX 共享内存）或者 tmpfs（一种基于内存的文件系统），这些内存映射的文件和共享内存段也会被包括在 working_set_bytes 中。
- 交换空间（SWAP）

参考 [PSS/USS 和 RSS 其实是一回事，吗？](https://changkun.de/blog/posts/pss-uss-rss/)
- USS: Unique Set Size, the physical memory occupied by the process, does not calculate the memory usage of the `shared library`.
- PSS: Proportion Set Size, the actual physical memory used, shared libraries, etc. are allocated `proportionally`.
- VSS: Virtual Set Size, virtual memory footprint, including shared libraries.
- RSS: Resident Set Size, actual physical memory usage, including shared libraries.

rss 是进程占用的物理内存，但是所有进程加起来的rss 会超过物理内存（因为进程间有很多内存是共享的, 比如共享库）
Generally we have `VSS >= RSS >= PSS >= USS`

    USS - Unique Set Size: 进程独自占用的内存（不包括共享库占用）
    PSS: 实际使用的物理内存（共享库按照进程数等比例划分）
	RSS: 常驻内存——程序+共享库(不同进程会重复计算共享库大小)+部分堆栈内存(另外部分堆栈内存是在交换区VSZ)
        在 top 命令里对应的是 REZ
	VSS:(VSZ) virt=swap+rss, 它是申请且未归还的虚拟地址空间

	rss       RSS    resident set size, the non-swapped physical memory that a task has used (in kiloBytes). (alias rssize, rsz).
	vsz       VSZ    virtual memory size of the process in KiB (1024-byte units).(alias vsize)

可以用pmap 查看进程所用的非共享物理内存(writeable/private)

	➜  ~  pmap -d 15102
	15102:   redis-server
	Address           Kbytes Mode  Offset           Device    Mapping
	0000000000400000     424 r-x-- 0000000000000000 0fc:00001 redis-server
	00007fd1fc77f000    1576 r-x-- 0000000000000000 0fc:00001 libc-2.12.so
	00007fd1fd3d6000       4 r---- 000000000001f000 0fc:00001 ld-2.12.so
	mapped: 40048K    writeable/private: 29064K    shared: 0K

top 中的MEM：

	RES — 进程使用的、未被换出的物理内存大小，单位kb。RES=CODE+DATA
	VIRT — 进程使用的虚拟内存总量，单位kb。VIRT=SWAP+RES
	SHR — 共享内存大小，单位kb(物理内存)

# 查看进程

	ps -ef | grep <pid>

# pstree

	$ pstree -p 3027
	-+= 00001 root /sbin/launchd
	\-+= 03001 root /usr/sbin/httpd -D FOREGROUND
	\--- 03027 www /usr/sbin/httpd -D FOREGROUND
	$ pstree -alp 3027
        -a     Show command line arguments.
        -l     Display long lines.
        -p, --show-pids
        -n     Sort processes with the same ancestor by PID instead of by
              name.  (Numeric sort.)

# proc
proc(`man 5 proc`) 可以获取更详细的进程信息

	/proc/<pid>/cwd
	/proc/<pid>/cmdline
	/proc/<pid>/port

## process status
可以查看进程的内存使用情况:

- 包括虚拟内存大小（VmSize），物理内存大小（VmRSS），数据段大小（VmData），栈的大小 （VmStk），代码段的大小（VmExe），共享库的代码段大小（VmLib）等等。
- VmData，VmStk，VmExe和VmLib之和并不等于VmSize。这是因为共享库函数的数据段没有计算进去（VmData仅包含程序的数据段，不包括共享库函数的数据段， 也不包括通过mmap映射的区域。VmLib仅包括共享库的代码段，不包括共享库的数据 段）

	cat /proc/<pid>/status

## smaps
通过`/proc/<pid>/smaps`可以查看进程整个虚拟地址空间的映射情况，它的输出从低地址到高地址按顺序输出每一个映射区域的相关信息，如下所示：

	$ cat /proc/<pid>/smaps
	注意：rwxp中，p表示私有映射（采用Copy-On-Write技术）。 Size字段就是该区域的大小。
