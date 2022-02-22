---
title:	Shell 工具集合
category: blog
date: 2016-09-27
---
# System debug, 系统调试工具

- web: 对于 Web 调试，curl 和 curl -I 很方便灵活，或者也可以使用它们的同行 wget，或者更现代的 httpie。
- disk/cpu/network: 要了解磁盘、CPU、网络的状态，使用 `iostat，netstat，top（或更好的 htop）和（特别是）dstat`。 dstat：有用的系统统计数据
- 对于更深层次的系统总览，可以使用 glances。它会在一个终端窗口中为你呈现几个系统层次的统计数据，对于快速检查各个子系统很有帮助。
- 要了解内存状态，可以运行 free 和 vmstat，看懂它们的输出结果吧。特别是，要知道“cached”值是Linux内核为文件缓存所占有的内存，因此，要有效地统计“free”值。
- Java 系统调试是一件截然不同的事，但是对于 Oracle 系统以及其它一些 JVM 而言，不过是一个简单的小把戏，你可以运行 kill -3 <pid>，然后一个完整的堆栈追踪和内存堆的摘要（包括常规的垃圾收集细节，这很有用）将被转储到stderr/logs。

- 对于查看磁盘满载的原因，ncdu 会比常规命令如 du -sh * 更节省时间。

- 使用 mtr 作路由比tracerout 追踪更好，可以识别网络问题。
- 要查找占用带宽的套接字和进程，试试 iftop 或 nethogs 吧。

- 掌握 strace 和 ltrace。如果某个程序失败、挂起或崩溃，而你又不知道原因，或者如果你想要获得性能的大概信息，这些工具会很有帮助。注意，分析选项（-c）和使用 -p 关联运行进程。

- 掌握 ldd 来查看共享库等。

- 知道如何使用 gdb 来连接到一个运行着的进程并获取其堆栈追踪信息。
- 使用 /proc。当调试当前的问题时，它有时候出奇地有帮助。样例：/proc/cpuinfo，/proc/xxx/cwd，/proc/xxx/exe，/proc/xxx/fd/，/proc/xxx/smaps。

- 当调试过去某个东西为何出错时，sar 会非常有帮助。它显示了 CPU、内存、网络等的历史统计数据。

- 对于更深层的系统和性能分析，看看 stap (SystemTap)，perf) 和 sysdig 吧。

- 确认是正在使用的 Linux 发行版版本（支持大多数发行版）：lsb_release -a。

## 运维工具
OM(Operation Maintenance) 运维工具

1. Bootstrapping： Kickstart、Cobbler、rpmbuild/xen、kvm、lxc、Openstack、 Cloudstack、Opennebula、Eucalyplus、RHEV
1. 配置类工具: Capistrano、Chef、puppet、func、salstack、Ansible、rundeck
1. 监控类工具: Cacti、Nagios(Icinga)、Zabbix、基于时间监控前端Grafana、Mtop、MRTG(网络流量监控图形工具)、Monit 
1. 性能监控工具: dstat(多类型资源统计)、atop(htop/top)、nmon(类Unix系统性能监控)、slabtop(内核slab缓存信息)、sar(性能监控和瓶颈检查)、sysdig(系统进程高级视图)、tcpdump(网络抓包)、iftop(类似top的网络连接工具)、iperf(网络性能工具)、smem)(高级内存报表工具)、collectl(性能监控工具)
1. 免费APM工具: mmtrix(见过的最全面的分析工具)、alibench
1. 进程监控: mmonit、Supervisor 
1. 日志系统: Logstash、Scribe
1. 绘图工具: RRDtool、Gnuplot
1. 流控系统: Panabit、在线数据包分析工具Pcap Analyzer
1. 安全检查: chrootkit、rkhunter
1. PaaS： Cloudify、Cloudfoundry、Openshift、Deis （Docker、CoreOS、Atomic、ubuntu core/Snappy） 
1. Troubleshooting:Sysdig 、Systemtap、Perf
1. 持续集成: Go、Jenkins、Gitlab
1. 磁盘压测: fio、iozone、IOMeter(win)
1. Memcache Mcrouter(scaling memcached)
1. Redis Dynomite、Twemproxy、codis/SSDB/Aerospike
1. MySQL 监控: mytop、orzdba、Percona-toolkit、Maatkit、innotop、myawr、SQL级监控mysqlpcap、拓扑可视化工具 
1. MySQL基准测试: mysqlsla、sql-bench、Super Smack、Percona's TPCC-MYSQL Tool、sysbench 
1. MySQL Proxy: SOHU-DBProxy、Altas、cobar、58同城Oceanus
1. MySQL逻辑备份工具: mysqldump、mysqlhotcopy、mydumper、MySQLDumper 、mk-parallel-dump/mk-parallel-restore
1. MySQL物理备份工具: Xtrabackup、LVM Snapshot
1. MongoDB压测: iibench&sysbench

## 自动管理
配置类工具: Capistrano、Chef、puppet、func、salstack、Ansible、rundeck
用得最多的应该是ansible, 它基于ssh 不需要安装服务端

## device 相关
每当某个设备的行为异常时（可能是硬件或者驱动器问题），使用dmesg。 dmesg：启动和系统错误信息

# Directory 工具
diff dir

	diff -r dir1 dir2 | grep dir1 | awk '{print $4}' > difference1.txt

1. `diff -r dir1 dir2` shows which files are only in dir1 and those only in dir2
2. `diff -r dir1 dir2 | grep dir1` shows which files are only in dir1

# cut

	cut -d: -f 1,3
	cut -d: -f 1
	cut -d: -f 2-
	cut -d: -f -3
	-d "delim"
        Use delim as the field delimiter character instead of the tab character.
	-f list
	 -b list
		 The list specifies byte positions.
     -c list
        The list specifies character positions.
	cut -c 2

tab delim

    cut -f2 -d$'\t'
    # ctrl+v tab
    cut -f2 -d'    '

# sort

	sort [-fbMnrtuk] [file or stdin]
	选项与参数：
	-f  ：忽略大小写的差异，例如 A 与 a 视为编码相同；
	-b  ：忽略最前面的空格符部分；
	-M  ：以月份的名字来排序，例如 JAN, DEC 等等的排序方法；
	-r  ：反向排序；
	-u 去重
	-n 数字
	-r 降序
	-o file 防止重定向清空文件sed a.txt > a.txt
	-k 2 指定排序列
	-t '一个字符' 指定分隔符, 默认是空格" ", 不是TAB
	-s --stable
		stable sort

稳定排序: 先排序将要字段2，再以`-s` 稳定排主字段1

	sort -k 2| sort -s -k 1

多字段排序

    sort -k2 -k1 <people.txt
    sort -k2,2 -k1,1 <people.txt
    sort -k2b,2 -k1,1 <people.txt
    sort -k2n,2 -k1,1 <people.txt

# uniq

	uniq [-ic]
	选项与参数：
	-i  ：忽略大小写字符的不同；
	-c  ：进行计数(sort后)
	-d      Only output lines that are repeated in the input.
    -u      Only output lines that are not repeated in the input.
	-f num  Ignore the first num fields in each input line when doing comparisons.
    -s chars Ignore the first chars characters in each input line when doing comparisons.

Example:

	cat a b | sort | uniq > c # c 是 a 和 b 的并集
	cat a b | sort | uniq -d > c # c 是 a 和 b 的交集(重复)
	cat a b | sort | uniq -u > c # c 是 a 和 b 的差集(不重复)

统计重复日志文件中url 的访问pv 次数(同一ip 算一次)，并按从高到低排序`sort|uniq -c|sort -r -d`:

	//日志格式: ip url
	cat a.log | sort | uniq | awk '{print $2}' | sort | uniq -c | sort -r -d

# tr, col, join, paste, expand(字符转换命令)

## tr
Usage:

	-d wildcard
	   posix_regex
		删除
	-c wilcard_pattern wildcard_replace
		对wildcard_pattern 取反
	-s, --squeeze-repeats
		replace each input sequence of a repeated character that is listed in SET1 with a single occurrence of that character

删除一段文字, 或者替换字符

	echo 'a : b' | tr 'a-z' 'A-Z' #替换 -有特别的含义哦
	echo 'a : b' | tr 'a\-z' 'A\-Z' #- 需要转义
	echo 'a : b' | tr -d 'ab'; #删除

Special character:

	 tr '\n' ','
	 tr '\r' ','
	 tr 'A-Z' ','

Example:

	$   echo '123456' | tr  '12345' '[A-Z]'
	[ABCD6
    $  echo '123456' | tr  '12345' 'AB' ; #(但是这里会有B补足)
    ABBBB
	$   echo 'abc' | tr 'a-z' '[x*]' ;# x* 匹配多个
	xxx
	$   echo 'abc' | tr 'a-z' '[x*]C' ;# x*2 最多匹配两个
	xxC
	$   echo 'abc' | tr 'a-z' '[x*2]' ;# x*2 匹配2个(但是这里会有补足)
	xxx
	$   echo 'abccccdddccc' | tr -s 'abc' 'ABC'
	ABCdddC
	$ echo 'abcxd' | tr -d 'xd'
	abc
	$ echo '1' | tr '\x31' '\x32'
	2
	$ echo '1ahui2' | tr '[:digit:]' ' '
	 ahui 

posix:

	tr -d '[[:space:]]'

### ROT13
The ROT13 and ROT47 are fairly easy to implement using the Unix terminal application tr; to encrypt the string "The Quick Brown Fox Jumps Over The Lazy Dog" in ROT13:

  $ # Map upper case A-Z to N-ZA-M and lower case a-z to n-za-m
  $ echo "The Quick Brown Fox Jumps Over The Lazy Dog" | tr 'A-Za-z' 'N-ZA-Mn-za-m'
  Gur Dhvpx Oebja Sbk Whzcf Bire Gur Ynml Qbt

and the same string for ROT47:

  $ echo "The Quick Brown Fox Jumps Over The Lazy Dog" | tr '\!-~' 'P-~\!-O'
  %96 "F:4< qC@H? u@I yF>AD ~G6C %96 {2KJ s@8

and in the Vim text editor, one can ROT13 a selection with the command: `g?`

## col
过滤控制字符
转换tab

	echo -e "a\tb" |col -x # -x 转换tab为空白
	man col |col -b # 过滤控制字符
	man col |cat -A # 显示控制字符
    tr '\r' '\n'

## expand
将tab替换成空格(-t 指定空格数, 默认是8个)

	expand [-t] file
	expand -t 8 file  #与 col -x 相同
	expand - #从stdinput 读取

expand 和 unexpand：在制表符和空格间转换

## join

	join [-ti12] file1 file2
	选项与参数：
	-t  ：join 默认以空格符分隔数据，并且比对『第一个字段』的数据，
		  如果两个文件相同，则将两笔数据联成一行，且第一个字段放在第一个！
	-i  ：忽略大小写的差异；
	-1  ：这个是数字的 1 ，代表『第一个文件要用那个字段来分析』的意思；
	-2  ：代表『第二个文件要用那个字段来分析』的意思。

	$ join -t ':' -1 4 -2 3 /etc/passwd /etc/group  # 如果是乱序的需要对字段进行sort
	0:root:x:0:root:/root:/bin/bash:root:x:root
	1:bin:x:1:bin:/bin:/sbin/nologin:bin:x:root,bin,daemon
	2:daemon:x:2:daemon:/sbin:/sbin/nologin:daemon:x:root,bin,daemon

join multiple line:

	 tr '\n' ','

## paste
直接将两个文件按行以tab连一行

	paste [-d] file1 file2
	选项与参数：
	-d  ：后面可以接分隔字符。默认是以 [tab] 来分隔的！
	-   ：如果 file 部分写成 - ，表示来自 standard input 的数据的意思。

# split

	split [-bl] file [option] PREFIX
	选项与参数：
	-b  ：后面可接欲分割成的文件大小，可加单位，例如 b, k, m 等；
	-l  ：以行数来进行分割。
	-a <suffix_num_length>
	-d
		use numeric suffixes instead of alphabetic(for linux)

	PREFIX ：代表前导符的意思，可作为分割文件名的前导文字。
		default x00 x01 ....

	split -b 100k file pre_hilo
	cat pre_hilo* > file

	split -l3 -d -a 2 a.txt profile-

# other
m4：简单的宏处理器

yes：大量打印一个字符串

env：（以特定的环境变量设置）运行一个命令（脚本中很有用）

look：查找以某个字符串开头的英文单词（或文件中的行）

fmt：格式化文本段落

pr：格式化文本为页/列

fold：文本折行

column：格式化文本为列或表

gpg：加密并为文件签名

toe：terminfo 条目表

tac：逆序打印文件

comm：逐行对比分类排序的文件

units：单位转换和计算；将每双周（fortnigh）一浪（浪，furlong，长度单位，约201米）转换为每瞬（blink）一缇（缇，twip，一种和屏幕无关的长度单位）（参见： /usr/share/units/definitions.units）（LCTT 译注：这都是神马单位啊！）

glances：高级，多个子系统概览

sar：历史系统统计数据

# tar

	-T <file>
		read file name list  from <file>
		git ... --name-only | tar czvf a.tgz -T -

If you want to remove the first n leading components of the file name, you need strip-components

	tar xvf tarname.tar --strip-components=2

## exclude

	tar czvf tarname.tar --exclude=.git dir
