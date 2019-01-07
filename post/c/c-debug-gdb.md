---
layout: page
title: c-debug-gdb
category: blog
description: 
date: 2018-09-27
---
# 启动gdb
- First, let excute file records Source file a.c via gcc parameter "-g"

	gcc -g a.c

- Second, start gdb

	gdb a.out

- Set breakpoint

	gdb> b 9

- Run program

	gdb> run


启动gdb php可以使用如下几种方式：
## 第1种方式：

    $ gdb ./php7.1/bin/php
    (gdb) b execute_ex
    break point at execute_ex
    (gdb) r text.php
    ....

## 第2种方式：

启动的时候指定要执行的脚本。

	#sudo gdb /usr/bin/php
	......
	Reading symbols from /home/fpm-php5.5.15/bin/php...done.
	(gdb) set args ./test.php
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	......

启动的时候指定php程序的路径。
使用set args 命令指定php命令的参数。

使用r命令开始执行脚本。r即为run的简写形式。也可以使用run命令开始执行脚本。

## 第二种方式：
启动后通过file命令指定要调试的程序。当你使用gdb调试完一个程序，想调试另外一个程序时，就可以不退出gdb便能切换要调试的程序。具体操作步骤如下：

	#sudo gdb ~/home/test/exproxy
	......
	Reading symbols from /home/hailong.xhl/exproxy/test/exproxy...(no debugging symbols found)...done.
	(gdb) file /home/fpm-php/bin/php
	Reading symbols from /usr/bin/php...done.
	(gdb) set args ./test.php
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	......

上面的例子中我们先使用gdb加载了程序exproxy进行调试。然后通过file命令加载了php程序，从而切换了要调试的程序。

gdb的子命令很多，可能有些你也不太熟悉。没关系，gdb提供了help子命令。通过这个help子命令，我们可以了解指定子命令的一些用法。如：

	(gdb) help set
	List of set subcommands:

	set annotate -- Set annotation_level
	set architecture -- Set architecture of target
	set args -- Set argument list to give program being debugged when it is started
	.......
	(gdb) help set args
	Set argument list to give program being debugged when it is started.
	Follow this command with any number of args, to be passed to the program.
	......

可见，通过help命令，我们可以了解命令的功能和使用方法。如果这个子命令还有一些子命令，那么它的所有子命令也会列出来。如上，set命令的set args等子命令也都列出来了

# 设置断点
设置断点的命令是break，缩写形式为b。
设置断点有很多方式。下面我们举例说明下常用的几种方式。

## 根据文件名和行号指定断点
如果你的程序是用c或者c++写的，那么你可以使用“文件名:行号”的形式设置断点。示例如下：

	#gdb /usr/bin/php
	(gdb) set  args ./test.php
	(gdb) b basic_functions.c:4439
	Breakpoint 6 at 0x624740: file /home/php-5.5.15/ext/standard/basic_functions.c, line 4439.
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	hello
	0
	Breakpoint 1, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
	    at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	(gdb)

示例中的(gdb) b basic_functions.c:4439 是设置了断点。断点的位置是basic_functions.c文件的4439行。

可见，断点处是zif_sleep方法。这个zif_sleep方法就是我们php代码中sleep方法在php内核中的实现。

根据规范，php内置提供的方法名前面加上zif_，就是这个方法在php内核或者扩展中实现时定义的方法名。

## 根据文件名和方法名指定断点
有些时候，手头没有源代码，不知道要打断点的具体位置。但是我们根据php的命名规范知道方法名。

如，我们知道php程序中调用的sleep方法，在php内核中实现时的方法名是zif_sleep。

这时，我们就可以通过"文件名:方法名"的方式打断点。示例如下：

	#gdb /usr/bin/php
	(gdb) set  args ./test.php
	(gdb) b basic_functions.c:zif_sleep
	Breakpoint 6 at 0x624740: file /home/php-5.5.15/ext/standard/basic_functions.c, line 4439.
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	hello
	0
	Breakpoint 1, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
	    at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	(gdb)

另外，如果你不知道文件名的话，你也可以只指定方法名。命令示例如下：

	(gdb)b zif_sleep

## 设置条件断点
设置条件断点的形式，就是在设置断点的基本形式后面增加 if条件。示例如下：

	......
	(gdb) b zif_sleep if num > 0
	Breakpoint 9 at 0x624740: file /home/php_src/php-5.5.15/ext/standard/basic_functions.c, line 4439.
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	hello
	0

	Breakpoint 9, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
		at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	(gdb)

## 查看断点
可以使用info breakpoint查看断点的情况。包含都设置了那些断点，断点被命中的次数等信息。示例如下：

	(gdb) info breakpoint
	Num     Type           Disp Enb Address            What
	9       breakpoint     keep y   0x0000000000624740 in zif_sleep at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
		stop only if num > 0
		breakpoint already hit 1 time
	10      breakpoint     keep y   0x0000000000624740 in zif_sleep at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	......

## 删除断点
对于无用的断点我们可以删除。删除的命令格式为 delete breakpoint 断点编号。info breakpoint命令显示结果中的num列就是编号。删除断点的示例如下：

	(gdb) info breakpoint
	Num     Type           Disp Enb Address            What
	9       breakpoint     keep y   0x0000000000624740 in zif_sleep at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
		stop only if num > 0
		breakpoint already hit 1 time
	10      breakpoint     keep y   0x0000000000624740 in zif_sleep at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	(gdb) delete 9
	(gdb) info breakpoint
	Num     Type           Disp Enb Address            What
	10      breakpoint     keep y   0x0000000000624740 in zif_sleep at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	(gdb)
	......

上面的例子中我们删除了编号为9的断点。

# 查看代码
查看代码的子命令是list，缩写形式为l。显示的代码行数为10行,基本上以断点处为中心，向上向下各显示几行代码。示例代码如下：

	#gdb /usr/bin/php
	(gdb) set  args ./test.php
	(gdb) b basic_functions.c:zif_sleep
	Breakpoint 6 at 0x624740: file /home/php-5.5.15/ext/standard/basic_functions.c, line 4439.
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	hello
	0
	Breakpoint 1, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
	    at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	(gdb)l
	4434    /* }}} */
	4435
	4436    /* {{{ proto void sleep(int seconds)
	4437       Delay for a given number of seconds */
	4438    PHP_FUNCTION(sleep)
	4439    {
	4440        long num;
	4441
	4442        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &num) == FAILURE) {
	4443            RETURN_FALSE;

## 指定行号查看代码示例：

	(gdb) list 4442
	4437       Delay for a given number of seconds */
	4438    PHP_FUNCTION(sleep)
	4439    {
	4440        long num;
	4441
	4442        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &num) == FAILURE) {
	4443            RETURN_FALSE;
	4444        }

## 指定方法名查看代码示例：

	......
	(gdb) list zif_sleep
	4434    /* }}} */
	4435
	4436    /* {{{ proto void sleep(int seconds)
	4437       Delay for a given number of seconds */
	4438    PHP_FUNCTION(sleep)
	4439    {
	4440        long num;
	4441
	4442        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &num) == FAILURE) {
	4443            RETURN_FALSE;
	......

# 单步执行
断点附近的代码你了解后，这时候你就可以使用单步执行一条一条语句的去执行。

单步执行有两个命令，分别是step和next。这两个命令的区别在于：

1. step 一条语句一条语句的执行。它有一个别名，s。
2. next 和step类似。只是当遇到被调用的方法时，不会进入到被调用方法中一条一条语句执行。它有一个别名n。

下面我们用两个例子来给你演示下。

step命令示例：

	#gdb /usr/bin/php
	(gdb) set  args ./test.php
	(gdb) b basic_functions.c:zif_sleep
	Breakpoint 6 at 0x624740: file /home/php-5.5.15/ext/standard/basic_functions.c, line 4439.
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	hello
	0
	Breakpoint 1, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
	    at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	.......
	(gdb) s
	4442        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &num) == FAILURE) {
	(gdb) s
	zend_parse_parameters (num_args=1, type_spec=0x81fc41 "l") at /home/php_src/php-5.5.15/Zend/zend_API.c:917
	917 {

可见，step命令进入到了被调用函数中zend_parse_parameters。使用step命令也会在这个方法中一行一行的单步执行。

next命令示例：

	#gdb /usr/bin/php
	(gdb) set  args ./test.php
	(gdb) b basic_functions.c:zif_sleep
	Breakpoint 6 at 0x624740: file /home/php-5.5.15/ext/standard/basic_functions.c, line 4439.
	(gdb) r
	Starting program: /home/fpm-php5.5.15/bin/php ./test.php
	hello
	0
	Breakpoint 1, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
	    at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	.......
	(gdb) n
	4442        if (zend_parse_parameters(ZEND_NUM_ARGS() TSRMLS_CC, "l", &num) == FAILURE) {
	(gdb) n
	4445        if (num < 0) {

可见，使用next命令只会在本方法中单步执行。

## 继续执行
可以使用continue命令。它的作用就是从暂停处继续执行。命令的简写形式为c。

	......
	(gdb) c
	Continuing.
	6

	Breakpoint 1, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
		at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	......

# 查看变量
print命令的简写形式为p。示例代码如下：

	(gdb) n
	4445        if (num < 0) {
	(gdb) print num
	$1 = 10

	(gdb) p/x nu
	$5 = 0x020304
	(gdb) x/b nu
	0x7fffffff05c: 0x02
	(gdb) x/3 nu
	0x7fffffff05c: 0x02 0x03 0x04

print substr(str,0,len=5)

	(gdb) p str@5
	(gdb)
	......

打印出的num的值为10，正好是我们在php代码中调用sleep方法传的值。另外可以使用“print/x my var” 的形式可以以十六进制形式查看变量值。

## set 设置变量
set命令可以直接修改变量的值。示例代码如下：

	Breakpoint 1, zif_sleep (ht=1, return_value=0x7ffff425a398, return_value_ptr=0x0, this_ptr=0x0, return_value_used=0)
		at /home/php_src/php-5.5.15/ext/standard/basic_functions.c:4439
	4439    {
	......
	(gdb) print num
	$4 = 10
	(gdb) set num = 2
	(gdb) print num
	$5 = 2
	......

上面的代码中我们是把sleep函数传入的10改为了2。即，sleep 2秒。注意，我们示例中修改的变量num是局部变量，只能对本次函数调用有效。下次再调用zif_sleep方法时，又会被设置为10。



## 看源码
用gdbtui调试mysql时的截图，这样看代码比使用list命令方便
http://mingxinglai.com/cn/2013/07/gdbtui/

    (gdb) focus on

## 设置观察点
设置观察点的作用就是，当被观察的变量发生变化后，程序就会暂停执行，并把变量的原值和新值都会显示出来。设置观察点的命令是watch。示例代码如下：

	(gdb) watch num
	Hardware watchpoint 3: num
	(gdb) c
	Continuing.
	Hardware watchpoint 3: num

	Old value = 1
	New value = 10
	0x0000000000713333 in zend_parse_arg_impl (arg_num=1, arg=0x7ffff42261a8, va=0x7fffffffaf70, spec=0x7fffffffaf30, quiet=0)
		at /home/php_src/php-5.5.15/Zend/zend_API.c:372
	372                         *p = Z_LVAL_PP(arg);
	(gdb)
	......

上例中num值从1变成了10时，程序暂停了。需要注意的是，你的程序中可能有多个同名的变量。那么使用watch命令会观察那个变量呢？这个要依赖于变量的作用域。即，在使用watch设置观察点时，可以直接访问的变量就是被观察的变量。

# gdb & lldb
> On mac , gdb has been replaced by lldb. [lldb vs gdb](http://lldb.llvm.org/lldb-gdb.html)

## EXECUTION COMMANDS

### launch

#### launch with args

	% gdb --args a.out 1 2 3
	% lldb -- a.out 1 2 3

or

	gdb> set args 1 2 3
	lldb> settings set target.run-args 1 2 3

* set env

	gdb> set env DEBUG 1
	(lldb) env DEBUG=1
	(lldb) set se target.env-vars DEBUG=1
	(lldb) settings set target.env-vars DEBUG=1

* unset env

	gdb> unset env DEBUG
	(lldb) settings remove target.env-vars DEBUG
	(lldb) set rem target.env-vars DEBUG

* show args

	gdb> show args
	lldb> settings show target.run-args

* set env and run

	lldb>  process launch -v DEBUG=1

## process

### pid  Attach to a process with pid 123

	gdb> attach 123
	(lldb) process attach --pid 123
	(lldb) attach -p 123

### pname Attach to a process named "a.out"
	gdb> attach a.out
	(lldb) process attach --name a.out
	(lldb) pro at -n a.out

### Attach to a remote gdb protocol server running on system "eorgadd", port 8000.
	(gdb) target remote eorgadd:8000
	(lldb) gdb-remote eorgadd:8000

### Attach to a remote gdb protocol server running on the local system, port 8000.
	(gdb) target remote localhost:8000
	(lldb) gdb-remote 8000

### Attach to a Darwin kernel in kdp mode on system "eorgadd".
	(gdb) kdp-reattach eorgadd	(lldb) kdp-remote eorgadd

## info & image

### info symbol
Look up information for a raw address in the executable or any shared libraries.

	gdb >  info symbol 0x1ec4
	gdb >  info symbol func
	lldb > image lookup --address 0x1ec4
	lldb > im loo -a 0x1ec4

## list source code

	# list source code from line 1
	gdb> list 1
	# list next 10 line of Source code
	gdb> list <or> <enter>
	gdb> list main

> `list` is usually  abbrevited to `l`

## step

	# step in( source level)
	> s <or> step
	# step over( source level)
	> n <or> <enter>
	# step in ( instruction level )
	> si
	# step over ( instruction level )
	> ni
	# Step out of the currently selected frame.
	> finish or fin

### Watchpoint

	# watch var when it is written to
	gdb> watch var
	lldb> watch set variable var
	lldb> wa s v var

	# delete
	watch del 1
	wa l

### breakpoint(stop)
打断点

	#break on line 9
	b 9
	# break on func main
	b main
	# on file
	b a.c:12
	# continue excute instead of step excute
	c
	# list
	gdb> i break
	lldb> breakpoint list
	lldb> br l
	lldb> b
	# delete
	gdb> delete 1
	lldb> br del 1

#### condition

	gdb> break foo if sum != 0
	(lldb) breakpoint set --name foo --condition '(int)sum != 0'
	(lldb) br s -n foo -c '(int) sum != 0'
	(lldb) b foo -c '(int) sum != 0'

### stop-hook

#### display var when stop
停止时显示变量

	gdb lldb > display var
	lldb >
		target stop-hook add -o "fr v var"
		ta st a -o "fr v var"
	> undisplay

#### display var when func main stop

	lldb > ta st a -n main -o "fr v var"

### backtrace
View call stack:

	(gdb lldb) bt
	#0 add_range (low=1, high=10) at main.c:6
	#1 0x080483c1 in main () at main.c:14

There are 2 frames: 0, 1.

## Variable
gdb 参数：

	x/7db
	x/7w
	f, the display format
		`print`
		`s' (null-terminated string), or
		`i' (machine instruction).
		`x' (hexadecimal) initially.
		`d` decimal
	u, the unit size
		7 size 7
		b Bytes.
		h Halfwords (two bytes).
		w Words (four bytes). This is the initial default.
		g Giant words (eight bytes).

其中, lldb 参数 :

	-f format
		x hex(default)
		d decimal
		b binary

### show via address (x,memory read)
相当于show pointer

    (lldb)  x 0x010bea04
    0x010bea04: 68 65 6c 6c 6f 69 6e 74 31 36 69 6e 74 33 32 69  helloint16int32i

#### read memory

	### Read memory from address 0xbffff3c0 and show 4 hex uint32_t values. 推荐用gdb 语法
	(gdb) x/4xw 0xbffff3c0
	(lldb) x/4xw 0xbffff3c0
	(lldb) memory read --size 4 --format x --count 4 0xbffff3c0
	(lldb) me r -s4 -fx -c4 0xbffff3c0
	(lldb) x -s4 -fx -c4 0xbffff3c0

	### 对变量取地址input
	lldb> x/7xb &var
	lldb> x/7 &var
	lldb> x -fx -c7 &var
    (lldb) expr --raw -- &var
    (*string)  = 0x00000000010bea04


#### save results to a local file as text.

	(gdb) set logging on
	(gdb) set logging file /tmp/mem.txt
	(gdb) x/512bx 0xbffff3c0
	(gdb) set logging off
	(lldb) x/512bx -o/tmp/mem.txt 0xbffff3c0
	(lldb) memory read --outfile /tmp/mem.txt --count 512 0xbffff3c0
	(lldb) me r -o/tmp/mem.txt -c512 0xbffff3c0

### show register

	gdb> p $rsp

#### 寄存器间接寻址

	# via register($) 20bytes
	gdb lldb> x/20 $rsp
	gdb lldb> x/20 $rsp+4

### show variable

	gdb> p var	"show var
	gdb> x/1b &var
	gdb> p &var	"show var's address

show var var pointer:

	gdb> p *pointer
	gdb> x/1b pointer

### view local Variable(info)
相关命令和缩写

    info,i
    frame,fr/f
    print,p

> Mac OSX has no info, but frame has integrated info

View *all locals* in current frames

	gdb > i locals + i args
	lldb > fr v

	gdb > i locals
	lldb > fr v -a (frame variable --no-args)

View specified local variable:

	gdb lldb> p variable
	lldb> fr v variable

	gdb lldb> x/1x &variable

	# show contents of local variable "bar" formatted as hex.
	gdb lldb> p/x bar
	lldb> fr v -fx bar

#### view variable's address

	gdb lldb> p &var
	gdb lldb> p *&var
	gdb lldb> p 0x10

#### print result

	gdb lldb> p 11+3&~3
	gdb lldb> p sizeof(char *)

### Show the global/static variables

	gdb > N/A
	(lldb) target variable
	lldb > ta v

	# show contents of global variable "baz"
	gdb lldb> p paz
	(lldb) ta v baz


### reassign Variable with new value(p)

	gdb> set var sum=0
	gdb> set var arr[1]=0
	gdb lldb> p arr[1]=0
	gdb lldb> p printf("The arr's first value is:%d", arr[1])
		The arr's first value is:0
		$6 = 26 //The printf will return length of string.


## Register
gdb 中register  前有`$`

### view register


	# via p($)
	gdb> p $rax (10进制)
	lldb> p $rax

	# via info/register read (hex)
	gdb > info registers 显示寄存器的值
	lldb > register read
	lldb > reg r
	lldb > register read rax

### write
	gdb > p $rax = 123
	lldb >  register write rax 123
	gdb >  jump *$pc+8
	lldb > register write pc `$pc+8`

## disassemble

	gdb> disassemble
	lldb> disassemble
	lldb>  disassemble --frame
	lldb>  di -f

# 参考
- 调试工具之GDB by 信海龙
http://www.bo56.com/%E8%B0%83%E8%AF%95%E5%B7%A5%E5%85%B7%E4%B9%8Bgdb/#0-tsina-1-88680-397232819ff9a47a7b7e80a40613cfe1
