---
layout: page
title:	expect 键盘模拟
category: blog
description:
---
# Preface
Expect 是Tcl/Tk 语言最有名的扩展，可通过[tcl/tk](/p/linux-tcl) 了解tcl/tk 的用法

> 注意：spawn 结束后，一定要加上`interact` 或者`eof`, 否则进程未结束却随着expect 退出而终止

# Cmd，命令
Expect中最关键的四个命令是send,expect,spawn,interact。

	send：用于向进程发送字符串
	expect：从进程接收字符串
	spawn：启动新的进程
	interact：允许用户交互

## send

	expect1.1> send "hello world\nnewline"
	hello world
	newline
	expect1.1> send 'hello world\nnewline'
	'hello world
	newline'

send 支持的选项: 见 http://www.tcl.tk/man/expect5.31/expect.1.html

    -i spawn_id
        发送给指定的进程(spawn_id)
    -s
        缓慢地发送（例如，在串行通信中，为了不使缓冲区溢出）

### send_user
send 用于write to spawn 启动的进程。send_user 用于write 字符到当前终端的stdout

	send_user "Usage: xxxx"

## expect
缺省情况下，expect“侦听”SDTOUT 和 STDERR，直到找到匹配或 timeout 期满为止。

`expect "word"`, `expect "*word*"` 二者是等价的，而且都会匹配换行符

从标准输出/错误读取内容，如匹配到"hi\n", 就执行send

	$ cat test.expect
	expect "Hi\n"
	send "You typed <$expect_out(buffer)>"
	send "But I only expected <$expect_out(0,string)>"

	$ expect test.expect
	some string
	Hi
	You typed <some string
	Hi
	>But I only expected <Hi
	>

其中：

	$expect_out(buffer)		所有expect 读取到的字符
	$expect_out(0,string)	匹配到的字符, "0,string" 是一个key, 而不是两个参数

其实 expect_out 是一个Array:

	foreach k [array name expect_out] {
		puts "$k -> $expect_out($k)"
	}

	# output
	spawn_id -> exp0
	buffer -> .....
	0,string -> Hi

### pattern - body
> expect 的pattern 默认是glob, 但是不是匹配首尾 `^pattern$`. 而是`pattern`
> expect statement require more than one line

	expect [[-opts] pat1 body1] ... [-opts] patn [bodyn]

单一分支

	expect "hi" {send "You said hi"}

多分支

	expect "hi" { send "You said hi\n" } \
		"hello" { send "Hello yourself\n" } \
		"bye" { send "That was unexpected\n" }

等同于:

	expect {
	"hi" { send "You said hi\n"}
	"hello" { send "Hello yourself\n"}
	"bye" { send "That was unexpected\n"}
	}

#### glob-style

	expect "wildcard" {
		cmd
	}

或者:

	expect "wildcard"
	cmd

或者

	expect {
		"wildcard1" cmd
		"wildcard2" {cmd; continue;}
		"wildcard3" {cmd; break}
		"wildcard4" break
		"wildcard5" abort
	}

#### regex

	expect -re 'ab*'' //match 'ab'' 'abx''

其它:

	-re 标志调用 regexp 匹配，
	-ex 表明必须是精确匹配
	-glob 通配符 默认

expect 的其它可选标志包括:

	-i		前者表示要监控产生的进程
	-nocase 后者强迫在匹配之前将进程输出变为小写。

对于完整的说明，在命令提示符下输入 man expect，以查看 Expect 的系统手册页面文档。

## Cmd Interpreter, 命令解析器
按照Tcl 的语法规则，语句是不能换行的，换行是一条语句的结束，以下三条语句中后两条指令会报错. 除非加转义符

	expect "hi" { send "You said hi\n" }
		"hello" { send "Hello yourself\n" }
		"bye" { send "That was unexpected\n" }

expect 的解析规则类似于shell, `{ }` 等是关键字，expect 则是普通的字符

	"expect" "hi" { "send" "You said hi\n" }
	# 这样就不行哦: { 会被解析为普通的参数，而不是expect 的语句边界关键字
	"expect" "hi" "{" "send" "You said hi\n" "}"

## spawn
用于启动一个进程，这个进程的输入连接send, 输出连接expect

spawn 返回一个进程标识。这可以在脚本中保存并设置，这给予了 expect 进程控制能力。

	set spawn_id [spawn ftp host]

> Use `log_user 0` to hide output from expect

## interact
interact 用于将输入输出 重新连接加标准输入与输出。实现交互

	#!/usr/bin/expect
	set timeout -1
	spawn ftp hilojack@hilojack.org
	expect "Password:" { send "mypasswd\n" }
	interact

-nobuffer 标志将与模式匹配的字符直接发送给用户。
-re 告诉 interact 将接下来的模式用作标准正规表达式，
"." 是与输入时每个字符匹配的模式。

参考以下这个例子:
http://www.ibm.com/developerworks/cn/education/linux/l-tcl/l-tcl-blt.html#N10609

	#!/usr/local/bin/expect
	# Script to enforce a 10 minute break
	# every half hour from typing -
	# Written for someone (Uwe Hollerbach)
	# with Carpal Tunnel Syndrome.
	# If you type for more than 20 minutes
	# straight, the script rings the bell
	# after every character until you take
	# a 10 minute break.

	# Author: Don Libes, NIST
	# Date: Feb 26, '95

	spawn $env(SHELL)

	# set start and stop times
	set start [clock seconds]
	set stop [clock seconds]

	# typing and break, in seconds
	set typing 1200
	set notyping 600

	interact -nobuffer -re . {
	  set now [clock seconds]

	  if {$now-$stop > $notyping} {
	    set start [clock seconds]
	  } elseif {$now-$start > $typing} {
	    send_user "\007"
	  }
	  set stop [clock seconds]
	}

### interact with multiple mode
Refer to: http://wiki.tcl.tk/3914

"For example, the following command runs interact with the following string-body pairs defined:

- When ^Z is pressed, Expect is suspended. (The -reset flag restores the terminal modes.)
- When ^A is pressed, the user sees "you typed a control-A" and the process is sent a ^A.
- When $ is pressed, the user sees the date.
- When ^C is pressed, Expect exits.
- If "foo" is entered, the user sees "bar".
- When ~~ is pressed, the Expect interpreter runs interactively."

	#!/usr/bin/expect --
	spawn bash
	set CTRLZ \032
	interact {
	    -reset $CTRLZ {exec kill -STOP [pid]}
	    \001   {send_user "you typed a control-A\n";
	            exp_send "\001"
	           }
	    $      {send_user "The date is [exec date]."}
	    \003   exit
	    foo    {send_user "bar"}
	    ~~
	}

以上脚本不带回显的哦

## set, config
set 用于设置变量，其中有些变量, 比如`timeout` 属于expect 配置

	set <var> <value>

	set timeout -1
	# 30s, 命令超时
	set timeout 30
	set var $expect_out(buffer)

	set var hello
	send $var

# wait
wait 用于等待任务(即spawn 启动的进程)结束

	#!/usr/bin/expect
	proc scp {user password host} {
		global env

		set home $env(HOME)

		spawn ssh -o StrictHostKeyChecking=no $user@$host mkdir -p ~/.ssh
		expect "*password:" {send "$password\r"}

		spawn scp -r -o StrictHostKeyChecking=no $home/.ssh/id_rsa $user@$host:~/.ssh
		expect "*password:" {send "$password\r"}

		spawn scp -r -o StrictHostKeyChecking=no $home/.ssh/authorized_keys $user@$host:~/.ssh
		expect "*password:" {send "$password\r"}

		wait
	}

	set user [lindex $argv 0]
	set password [lindex $argv 1]
	set host [lindex $argv 2]

	scp $user $password $host

# loop
exp_continue

	spawn zip -e $backupdir$filename.enc.zip $backupdir$filename
	expect {
		"* password: " {
			send "monkey\r"
			exp_continue
		}
		eof
	}

# Note, 注意
expect 本身的`send` 命令，不一定被`zip` 接收，因为zip 本身有时会反应慢半拍, 可以尝试多`send` 几次(我一般send 5次). (其实zip 支持`-P <password>`)

	/usr/local/bin/expect <<MM
	set timeout 2;
	spawn zip -e data11.zip a.sh b.sh
	send "11\n"
	expect {
		"yes/no" {send "yes\n"; exp_continue}
		"password:" {send "password\r"}
		eof; #
	}
	MM

# demo

## ssh

	#!/usr/bin/expect -f
	set timeout 2;
	set password my_password
	spawn ssh root@ip
	expect {
	 "*yes/no" { send "yes\r"; exp_continue}
	 "*password:" { send "$password\n" }
	}
	interact

## proc

	proc ssh {user password host cmd} {
		global env
		spawn ssh $user@$host
		expect "*password:" {send "$password\n"}
		send "$cmd\n"
	}


# Reference
- [expect by xuanhao]
- [expect manual]

[expect by xuanhao]: http://www.xuanhao360.com/linux-expects/
[expect manual]:
http://linux.die.net/man/1/expect
