---
layout: page
title: linux 文件管理
category: blog
description:
---
# Preface
本该讲述的是与shell 相关的 Linux文件管理

# ls

	ll -S 按文件大小排序
	ll -i 查看文件的inode

# find

	find [-H | -L | -P] [-EXdsx] [-f path] path ... [expression]

## -exec

	find . -inum INODE -exec cmd #根据-exec
		-inum #指定文件的inode
		-exec cmd #对匹配文件执行cmd. 特殊字符需要转义. eg. `rm {} \;`
	find . -inum 123 -o -inum 132 -exec rm {} \;

## -name
find -name 支持wildcard("[,],*,?")
	-name pattern
		 True if the last component of the pathname being examined matches pattern.  Special shell pattern matching characters (``['', ``]'', ``*'', and ``?'') may be used as part of pattern.  These characters may be matched explicitly by escaping them with a backslash (``\'').

eg:

	find . -name '[AB].txt'
	find . -name '*.txt'  #或者 find -name \*.txt

## -regex & -iregex
这个参数是匹配path 而不是像-name那样只匹配filename(-iregex same as -regex but ther match is case isensitive)
It support POSIX Basic regular expressions by default (and so does grep).

	$ find  . -maxdepth 1  -regex './\(Ale[xe]\).*'
		a/Alex.SpeechVoice
		a/Alee.SpeechVoice

开启-E 后就可以支持ERE了.

	$ find . -maxdepth -regex './(Alex|John).*'

注意-regex -iregex内部实现强制使用了^$. 即'^Alex$' ,'^Alex', 'Alex$'是等价的, 如果相部分匹配, 一定要加.*

	-regex '.*Alex.*'


## -not & !
实现条件反转, 比如寻找txt文件但过滤掉a.txt

	find . -name \*.txt ! -name 'a.txt'
	find . -name \*.txt -not -name 'a.txt'

# du
du -s dir/* | sort -nr > dir.du

# operater

## truncate

	sudo truncate -s0 path_to_file


# ulimit限制
ulimit 命令设置或报告用户进程资源极限，如 `/etc/security/limits*` `/Library/LaunchDaemons/limit.maxfiles.plist` 及`.profile` 文件所定义。文件包含以下缺省值极限：

	fsize = 2097151
	core = 2097151
	cpu = -1
	data = 262144
	rss = 65536
	stack = 65536
	nofiles = 2000

## ulimit 语法

	ulimit [-acdfHlmnpsStvw] [size]
	选项与参数：
	-a : 显示当前所有的资源限制.
	-n : file descriptors
	-f ：此 shell 可以创建的最大文件容量(一般可能配置为 2GB)单位为 Kbytes
	-t ：可使用的最大 CPU 时间 (单位为秒)
	-d : 设置程序可用数据段(segment)的最大值.单位:kbytes
	-m : 设置可以使用的常驻内存的最大值.单位:kbytes
	-l : 设置在内存中锁定进程的最大值.单位:kbytes
	-v : 设置虚拟内存的最大值.单位:kbytes 5,简单实例:
	-u ：单一用户可以使用的最大程序(process)数量。
	-H ：hard limit ，严格的配置，必定不能超过这个配置的数值；
	-S ：soft limit ，警告的配置，可以超过这个配置值，但是若超过则有警告信息。
	     在配置上，通常 soft 会比 hard 小，举例来说，soft 可配置为 80 而 hard
	     配置为 100，那么你可以使用到 90 (因为没有超过 100)，但介于 80~100 之间时，
	     系统会有警告信息通知你！
	-a ：后面不接任何选项与参数，可列出所有的限制额度；
	-c : 设置core文件的最大值.单位:blocks
	     当某些程序发生错误时，系统可能会将该程序在内存中的信息写成文件(除错用)，
	     这种文件就被称为核心文件(core file)。此为限制每个核心文件的最大容量。
	-p : 设置管道缓冲区的最大值.单位:kbytes
	-s : 设置堆栈的最大值.单位:kbytes

Example:

	ulimit -n 65535

> 省略 Limit 参数时，将会打印出当前资源极限。除非用户指定 -H 标志，否则打印出软极限。当用户指定一个以上资源时，极限名称和单元在值之前打印。如果未给予选项，则假定带有了 -f 标志。

##　列出所有限制

	ulimit -a
	ulimit -f 10240 #用户只能创建10M以下的文件

## 限制文件大小
如果我们想要对由shell创建的文件大小作些限制,如:

	ulimit -f 100 #设置创建文件的最大块(一块=512字节)

	$ cat h>newh
	$ ll h newh
	-rw-r--r-- 1 lee lee 150062 7月 22 02:39 h
	-rw-r--r-- 1 lee lee 51200 11月 8 11:47 newh

文件h的大小是150062字节,而我们设定的创建文件的大小是512字节x100块=51200字节，当然系统就会根据你的设置生成了51200字节的newh文件.

## 限制堆栈
在Linux下写程序的时候，如果程序比较大，经常会遇到“段错误”（segmentationfault）这样的问题，这主要就是由于Linux系统初始的堆栈大小（stack size）太小的缘故，一般为10M。我一般把stacksize设置成256M，这样就没有段错误了！命令为：

	ulimit   -s 262140

如果要系统自动记住这个配置，就添加到`/etc/profile`文件
