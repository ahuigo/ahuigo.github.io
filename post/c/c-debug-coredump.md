---
layout: page
title:	coredump
category: blog
description:
---
# Preface

1. 前言: 有的程序可以通过编译, 但在运行时会出现Segment fault(段错误). 这通常都是指针错误引起的. 但这不像编译错误一样会提示到文件->行, 而是没有任何信息, 使得我们的调试变得困难起来.
2. gdb: 有一种办法是, 我们用gdb的step, 一步一步寻找. 这放在短小的代码中是可行的, 但要让你step一个上万行的代码, 我想你会从此厌恶程序员这个名字, 而把他叫做调试员. 我们还有更好的办法, 这就是core file.
3. ulimit: 如果想让系统在信号中断造成的错误时产生core文件, 我们需要在shell中按如下设置: #设置core大小为无限 ulimit -c unlimited #设置文件大小为无限 ulimit unlimited 这些需要有root权限, 在ubuntu下每次重新打开中断都需要重新输入上面的第一条命令, 来设置core大小为无限.
4. 用gdb查看core文件:

# coredump on mac OSX
See [signals](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man2/sigaction.2.html#//apple_ref/doc/man/2/sigaction)
then we know a signal like SIGQUIT(3), SIGILL(4), SIGTRAP(5) and others could occured OS would create a core image what we need.

	$ cat coredump.c
	#include <unistd.h>
	#include <signal.h>
	int main(int argc, char ** args) {
	  pid_t pid = getpid();
	  kill(pid, 3);
	}

	$ gcc coredump.c -o core-dump-file
	$ ./core-dump-file

OSX 的coredump 默认在：` /cores/core.pid` , 但是得Enable core-dump-file

	$ ulimit -c
	> 0
	$ ulimit -c unlimited
	$ ulimit -c
	> unlimited

	$ lldb ./core-dump-file /cores/core.19504

# 什么是Core：


## Core Dump时会生成何种文件：
Core Dump时，会生成诸如 `core.进程号` 的文件。

## 为何有时程序Down了，却没生成 Core文件。
Linux下，有一些设置，标明了resources available to the shell and to processes。 可以使用#ulimit -a  来看这些设置。
从这里可以看出，如果 -c 是显示：`core file size  (blocks, -c)`  如果这个值为0，则无法生成core文件。所以可以使用：

	ulimit -c 1024
	# 或者
	ulimit -c unlimited

如果程序出错时生成Core 文件，则会显示Segmentation fault (core dumped) 。


# create core
程序自己产生segmentfault, 或者手动产生

## 如何让一个正常的程序down:

	#kill -s SIGSEGV pid
	kill -s SEGV pid

## core文件的名称和生成路径
若系统生成的core文件不带其它任何扩展名称，则全部命名为core。新的core文件生成将覆盖原来的core文件 。

	/proc/sys/kernel/core_uses_pid 可以控制产生的core文件的文件名中是否添加pid作为扩展，如果添加则文件内容为1，否则为0
	echo "1" >/proc/sys/kernel/core_uses_pid

以下是参数列表:

	%p - insert pid into filename 添加pid
	%u - insert current uid into filename 添加当前uid
	%g - insert current gid into filename 添加当前gid
	%s - insert signal that caused the coredump into the filename  添加导致产生core的信号
	%t - insert UNIX time that the coredump occurred into filename  添加core文件生成时的unix时间
	%h - insert hostname where the coredump happened into filename  添加主机名
	%e - insert coredumping executable name into filename  添加命令名

### Core文件输出在何处：
`/proc/sys/kernel/core_pattern` 可以控制core文件保存位置和文件名格式。
可通过以下命令修改此文件：

	echo "/corefile/core-%e-%p-%t" > core_pattern，可以将core文件统一生成到/corefile目录下，产生的文件名为core-命令名-pid-时间戳
	echo "core" > core_pattern  # 生成 core.pid，存放到当前目录

centos6:

	$ in  /etc/sysctl.conf
	kernel.core_pattern = /var/crash/core-%e-%s-%u-%g-%p-%t

When abrtd.service starts kernel.core_pattern is overwritten automatically by the system installed abrt-addon-ccpp.

	|/usr/libexec/abrt-hook-ccpp %s %c %p %u %g %t e

There are two ways to resolve this:

1. Setting DumpLocation option in the `/etc/abrt/abrt.conf` configuration file.

	# default
	DumpLocation = /var/spool/crash
	# And sysctl kernel.core_pattern's displayed value is a same but actually core file will be created to the directory under /var/crash.

Also if you have selinux enabled you have to run:

	semanage fcontext -a -t public_content_rw_t "/var/crash(/.*)?"  
	setsebool -P abrt_anon_write 1

And finally restart abrtd.service*:

	service abrtd.service restart

2. Stop `abrtd service.` and `kernel.core_pattern` will not be overwritten.

如果是当前目录：

1. 存放Coredump的目录即进程的当前目录，一般就是当初发出命令启动该进程时所在的目录。
3. 可以查看`/proc/<进程pid>/cwd`符号*链接*的目标来确定进程的当前目录地址。
2. 但如果是通过脚本启动，则脚本可能会修改当前目录，这时进程真正的当前目录就会与当初执行脚本所在目录不同。
4. 对于php-fpm 来说，执行脚本时它会change cwd to 脚本所在的目录.(而不是空闲时的目录: kill -s SEGV php-fpm-pid)

## debug
在Linux下要保证程序崩溃时生成 Coredump要注意这些问题：

一、要保证存放Coredump的目录存在且进程对该目录有写权限。
如果是通过脚本启动，则脚本可能会修改当前目录，这时进程真正的当前目录就会与当初执行脚本所在目录不同。这时可以查看`/proc/进程pid>/cwd`符号链接的目标来确定进程当前目录地址(如果没有change pwd)。通过系统服务启动的进程也可通过这一方法查看。

二、若程序调用了`seteuid()/setegid()`改变了进程的有效用户或组，则在默认情况下系统不会为这些进程生成Coredump。

1. 很多服务程序都会调用`seteuid()`，如MySQL，不论你用什么用户运行 mysqld_safe启动MySQL，mysqld进行的有效用户始终是msyql用户。
1. 如果你当初是以用户A运行了某个程序，但在ps里看到的这个程序的用户却是B的话，那么这些进程就是调用了seteuid了。
1. *为了能够让这些进程生成core dump*，需要将`/proc/sys/fs/suid_dumpable` 文件的内容改为1（一般默认是0）。

三、设置足够大的Core文件大小限制了(最好unlimited)。
程序崩溃时生成的 Core文件大小即为程序运行时占用的内存大小。
但是有的情况下，比如缓冲区溢出等错误可能导致堆栈被破坏，经常会出现某个变量的值被修改成乱七八糟的，然后程序用这个大小去申请内存就可能导致程序比平常时多占用很多内存。

# 用gdb查看core文件:

下面我们可以在发生运行时信号引起的错误时发生core dump了. 发生core dump之后, 用gdb进行查看core文件的内容, 以定位文件中引发core dump的行.

	gdb <exec file> <core file>
	gdb ./test test.core
	"在进入gdb后, 用bt命令查看backtrace以检查发生程序运行到哪里, 来定位core dump的文件->行.

## 如何使用Core文件：
在Linux下，使用：

	#gdb -c core.pid program_name

就可以进入gdb模式。
输入where，就可以指出是在哪一行被Down掉，哪个function内，由谁调用等等。

	(gdb) where
	或者输入 bt。
	(gdb) bt

# PHP Core
http://www.laruence.com/2011/06/23/2057.html
https://rtcamp.com/tutorials/php/core-dump-php5-fpm/

## config
First you need to enable core dumps in linux

	su -
	echo '/tmp/core-%e.%p' > /proc/sys/kernel/core_pattern
	echo 0 > /proc/sys/kernel/core_uses_pid
	ulimit -c unlimited

allown fpm coredump(默认的好像):

	echo 'rlimit_core = unlimited' >> /etc/php-fpm.d/www.conf
	service php-fpm restart

## use core
php 在编译时应该开启debug

先通过php-cli 或者 fpm 产生coredump:

	$ php test.php
	Segmentation fault (core dumped)

调试 php/fpm coredump:

    $ gdb [exec file] [core file]
	$ gdb php core.31656
	$ gdb php-fpm core-fpm.31663

fpm coredump example:

	$ sudo gdb /usr/sbin/php5-fpm /tmp/core-php-fpm.31656
	(gdb) bt
	#0  0x000000000061eea1 in gc_zval_possible_root ()
	#1  0x00000000005f6c1f in zend_cleanup_internal_class_data ()
	#2  0x0000000000605839 in zend_cleanup_internal_classes ()
	#3  0x00000000005f4b0b in shutdown_executor ()
	#4  0x00000000005ffd52 in zend_deactivate ()
	#5  0x00000000005a356c in php_request_shutdown ()
	#6  0x00000000006b1819 in main ()

我们看看, Core发生在PHP的什么函数中, 在PHP中, 对于FCALL_* Opcode的handler来说, execute_data代表了当前函数调用的一个State, 这个State中包含了信息:

	(gdb)f 1
	#1  0x00000000006ea263 in zend_do_fcall_common_helper_SPEC (execute_data=0x7fbf400210) at /home/laruence/package/php-5.2.14/Zend/zend_vm_execute.h:234
	234               zend_execute(EG(active_op_array) TSRMLS_CC);
	(gdb) p execute_data->function_state.function->common->function_name
	$3 = 0x2a95b65a78 "recurse"
	(gdb) p execute_data->function_state.function->op_array->filename
	$4 = 0x2a95b632a0 "/home/laruence/test.php"
	(gdb) p execute_data->function_state.function->op_array->line_start
	$5 = 2

现在我们得到, 在调用的PHP函数是recurse, 这个函数定义在/home/laruence/test.php的第二行
