---
layout: page
title:	edit
category: blog
description:
---

# System debug, 系统调试工具

- web: 对于 Web 调试，curl 和 curl -I 很方便灵活，或者也可以使用它们的同行 wget，或者更现代的 httpie。
- disk/cpu/network: 要了解磁盘、CPU、网络的状态，使用 `iostat，netstat，top（或更好的 htop）和（特别是）dstat`。 dstat：有用的系统统计数据
- 对于更深层次的系统总览，可以使用 glances。它会在一个终端窗口中为你呈现几个系统层次的统计数据，对于快速检查各个子系统很有帮助。
- 要了解内存状态，可以运行 free 和 vmstat，看懂它们的输出结果吧。特别是，要知道“cached”值是Linux内核为文件缓存所占有的内存，因此，要有效地统计“free”值。
- Java 系统调试是一件截然不同的事，但是对于 Oracle 系统以及其它一些 JVM 而言，不过是一个简单的小把戏，你可以运行 kill -3 <pid>，然后一个完整的堆栈追踪和内存堆的摘要（包括常规的垃圾收集细节，这很有用）将被转储到stderr/logs。

- 对于查看磁盘满载的原因，ncdu 会比常规命令如 du -sh * 更节省时间。

- 使用 mtr 作路由追踪更好，可以识别网络问题。
- 要查找占用带宽的套接字和进程，试试 iftop 或 nethogs 吧。

- 掌握 strace 和 ltrace。如果某个程序失败、挂起或崩溃，而你又不知道原因，或者如果你想要获得性能的大概信息，这些工具会很有帮助。注意，分析选项（-c）和使用 -p 关联运行进程。

- 掌握 ldd 来查看共享库等。

- 知道如何使用 gdb 来连接到一个运行着的进程并获取其堆栈追踪信息。
- 使用 /proc。当调试当前的问题时，它有时候出奇地有帮助。样例：/proc/cpuinfo，/proc/xxx/cwd，/proc/xxx/exe，/proc/xxx/fd/，/proc/xxx/smaps。

- 当调试过去某个东西为何出错时，sar 会非常有帮助。它显示了 CPU、内存、网络等的历史统计数据。

- 对于更深层的系统和性能分析，看看 stap (SystemTap)，perf) 和 sysdig 吧。

- 确认是正在使用的 Linux 发行版版本（支持大多数发行版）：lsb_release -a。

## device 相关
每当某个设备的行为异常时（可能是硬件或者驱动器问题），使用dmesg。 dmesg：启动和系统错误信息

# Directory 工具
diff dir

	diff -r dir1 dir2 | grep dir1 | awk '{print $4}' > difference1.txt

1. `diff -r dir1 dir2` shows which files are only in dir1 and those only in dir2
2. `diff -r dir1 dir2 | grep dir1` shows which files are only in dir1


# file 相关工具
格式转换相关：

- 如果你必须处理 XML，xmlstarlet 虽然有点老旧，但是很好用。
- 对于 JSON，使用jq。
- 对于 Excel 或 CSV 文件，csvkit 提供了 in2csv，csvcut，csvjoin，csvgrep 等工具。
- 对于亚马逊 S3 ，s3cmd 会很方便，而 s4cmd 则更快速。亚马逊的 aws 则是其它 AWS 相关任务的必备。

## zip

	zip -e test [file ...]
		-e encrypt prompt to input password
	zip -e -P <password> test [file ...]
	unzip -x test.zip -d dir

## stat
stat：文件信息

## diff 工具

### diff
对源代码打补丁的标准工具是 diff 和 patch。
用 diffstat 来统计 diff 情况。

> 注意 diff -r 可以用于整个目录，所以可以用 diff -r tree1 tree2 | diffstat 来统计（两个目录的）差异。

## icdiff 对比文件改动
icdiff支持非交互式、左右对比、高亮。 Ps: git 内置了icdiff

	$ git icdiff

## od
od -- octal, decimal, hex, ASCII dump

	od -t xCc a.txt #16进制显示
	od -t oCc a.txt #8进制显示
		x hex
			x4 4bytes long
			x1 1bytes long
			xC  1bytes long
		o octal

		c list character iterate

## strings
用于过滤二进制文件中的不可见字符，strings（加上 grep 等）可以让你找出一点文本。

## zless
使用 zless，zmore，zcat 和 zgrep 来操作压缩文件

## hd
对于二进制文件，使用 hd 进行简单十六进制转储，以及 bvi 用于二进制编辑。

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

# xargs
shell 中很多命令都是支持read from stdin的。 对于不支持stdin 的ls 可以使用xargs

	xargs [-0Epn] command
	 -0      Change xargs to expect NUL (``\0'') characters as separators, instead of spaces and newlines.  This is expected to be used in concert with the -print0 function in find(1).

     -E eofstr
             Use eofstr as a logical EOF marker.
	 -p      Echo each command to be executed
	 -n number
		 use number of parameter in each exec command
	 -J replstr
		 Replacing one or more occurrences of replstr in up to replacements arguments
		 The replstr must show up as a distinct argument to xargs
	 -I replstr
		Replacing one or more occurrences of replstr in up to replacements arguments
	 -t
	 	Echo the command to be executed to standard error immediately before it is executed.

Example:

	echo -e "string1\x00string2\x00end\x00string3"| xargs -0p -E'end' echo
	ls | grep .php$ | xargs -n 1 php -l
	# Use "%" as a variable that store parameter
	ls | grep .php$ | xargs -n 1 -J % mv % dst/
	xargs -n 1 -J % -I % echo cp -r % ../v4_feed/%

	cut -d':' -f1 /etc/passwd |head -n 3| xargs finger
	cut -d':' -f1 /etc/passwd |head -n 3| xargs -p -n 2 finger #每个命令执行时都需要提示.
	cut -d':' -f1 /etc/passwd |head -n 3| xargs -p -n 2 -E 'root' finger #见到root 后截止

> xargs 可以用于不支持管道的命令, 比如ls. 有的命令可通过参数"-"支持管道, 就不需要xargs 了
> 当 xargs 后面没有接任何的命令时，默认是以 echo 来进行输出喔！

## xargs eval
eval is a shell builtin command, not a standalone executable. Thus, xargs can't run it directly. You probably want:

	ls -1 | gawk '{print "`mv "$0" "tolower($0)"`"}' | xargs -t sh -c "eval {}"
	sh -c "$cmd" '2nd,3rd,.. args is ignored'

# grep

	grep [-acinv] [--color=auto] [--] 'pattern' filename
	选项与参数：
	-x : whole line
	-a ：将 binary 文件以 text 文件的方式搜寻数据
	-c ：计算找到 '搜寻字符串' 的次数
	-i ：忽略大小写的不同，所以大小写视为相同
	-I : ingore binary file
	-n ：顺便输出行号
	-v ：反向选择，亦即显示出没有 '搜寻字符串' 内容的那一行！
	-V : version
	-F : 不解释pattern, pattern作为固定的字符串
	-f patterns-file
	-l, --files-with-matches(相当于-m 1 -H)
		 Only the names of files containing selected lines are written to standard output.  grep will only search a file until a match has been found, making searches potentially less expensive.
     -m NUM, --max-count=NUM
          Stop  reading  a  file after NUM matching lines.
	-L, --files-without-match
	-o : 只输出匹配字符串
	--include=PATTERN     Recurse in directories only searching file matching PATTERN.
	--exclude=PATTERN     Recurse in directories skip file matching PATTERN.
    --exclude-dir=PATTERN
	--color=auto ：可以将找到的关键词部分加上颜色的显示喔！

	-h, --no-filename
	-H, --with-filename
	-E, --extended-regexp
	-e 'pattern1' -e pattern2
	-P perl patterns

## max-count

	-m max-count 匹配次数

## other grep:

	fgrep
		grep -F
	rgrep
		grep -r
	agrep
		approximate grep
	zgrep
		grep compress file

## grep binary

	-I
       ignore binary
    -a, --text
       Process a binary file as if it  were  text

## grep context

	-C num context num
		-C 2  The default is 2 and is equivalent to -A 2 -B 2

## grep filter self
Refer to: [](/p/shell)

Remove grep command while use ps

	ps aux | grep perl | grep -v grep
	ps aux | grep [p]erl

## exclude file & dir

	--exclude=\*.{html,htm,js}
    grep -R --exclude-dir=node_modules 'some pattern' /path/to/search

## multi patterns

	-e 'pattern1' -e pattern2
	-f pattern.txt

If you want to do the minimal amount of work, change

	grep -o -P 'PATTERN' file.txt

to

	perl -nle'print $& if m{PATTERN}' file.txt

So you get:

	var1=`perl -nle'print $& if m{(?<=<st:italic>).*(?=</italic>)}' file.txt`
	var2=`perl -nle'print $& if m{(property:)\K.*\d+(?=end)}' file.txt`

However, you can achieve simpler code with extra work.

	var1=`perl -nle'print $1 if m{<st:italic>(.*)</italic>}' file.txt`
	var2=`perl -nle'print $1 if /property:(.*\d+)end/' file.txt`

> $print $& 打印全部匹配到的字段,  而print $1而为打印第一个括号

## print the filename only

	-L, --files-without-match
		Only the names of files not containing selected lines are written to standard output.  Pathnames are listed once per file searched.  If the standard input is searched, the string ``(standard input)'' is written.

	-l, --files-with-matches
		Only the names of files containing selected lines are written to standard output.  grep will only search a file until a match has been found, making searches potentially less expensive.  Pathnames are listed once per file searched.  If the standard input is searched, the string ``(standard input)'' is written.

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
	$   echo 'abc' | tr 'a-z' '[x*2]C'
	xxC
	$   echo 'abccccdddccc' | tr -s 'abc' 'ABC'
	ABCdddC
	$ echo 'abcxd' | tr -d 'xd'
	abc
	$ echo '1' | tr '\x31' '\x32'
	2
	$ echo '1ahui2' | tr '[:digit:]' ' '
	1    2

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
