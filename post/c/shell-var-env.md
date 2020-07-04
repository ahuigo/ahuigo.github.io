---
title: shell 环境变量
date: 2018-10-08
---
# Variable

	let num++
	let ++num

	declare -i num
	num+=1

	((num++))

## unset export
    unset FOO
        -f refer to shell functions
        -n remove the export property from each NAME
        -p display a list of all exported variables and functions

export -n FOO 相当于

    _FOO=$FOO
    unset FOO
    FOO=$_FOO

## readonly

	x=6
	readonly x

## 输出变量

	echo $v
	echo ${v}

### bash 中的换行
建议使用zsh. 因为bash不会将单双引号中的`\n`解析为换行.

	echo "a\nb" #bash 不换行,\n会被原样输出
	echo $'a\nb' #这样才能换行

> 如果需要\n换行, 建议使用zsh 或者 printf 'a\nb %s' $str

## shell 特殊变量

	$$     脚本运行的当前进程的ID号
	$!     *后台运行*的最后一个进程的ID号
	$#     传递到脚本的参数个数
	$@   	传递给脚本的参数数组
	$*   	传递给脚本的参数字符串
	$-     显示shell使用的当前选项
	$?     显示最后命令的退出状态，0表示无错误
	$0 		entrace name
	$PWD	`pwd`
	$UID
	$USER
	$RANDOM 随机数
	$COLUMNS $LINES only for zsh

### PS1

	PS1 命令提示符
	PS1='\[\e[1;31m\][\u@\W]\$\[\e[m\]' #\[\e[1;31m\] 是红色粗体, \[\e[m\] 是正常颜色值.

### Get Script pid
> http://wiki.jikexueyuan.com/project/13-questions-of-shell/exec-source.html

- fork 子进程
- exec 替换当前进程的code(原有程序终止)
- source 在前进程执行code

### Get Script File Path
In bash/zsh:

	$0				Current Script's name
    MY_PATH=$(cd "`dirname $0`" && pwd)

Working Directory:

	pwd

Example:

	$ cat s.sh
	#!/bin/bash
	printf '$0 is: %s\n $BASH_SOURCE is: %s\n' "$0" "$BASH_SOURCE"

	bash-3.2$ ./s.sh
		$0 is: ./s.sh,$BASH_SOURCE is: ./s.sh
	bash-3.2$ source s.sh
		$0 is: bash,$BASH_SOURCE is: s.sh

## 赋值

	v=value #注意=两边不能有空格,这是规定!
	unset v ;#删除字符串

### read 交互

	read [-pt] [variable]
	read [-ers] [-u fd] [-t timeout] [-p prompt] [-a array] [-n nchars] [-d delim] [name name2...]
	选项与参数：
	-p  ：后面可以接提示字符！
	-t  ：后面可以接等待的『秒数！』这个比较有趣～不会一直等待使用者啦！
    -r		do not allow backslashes to escape any characters
    -s		do not echo input coming from a terminal
        http://linuxcommand.org/lc3_man_pages/readh.html
	variable
		默认是REPLY

	## read line
	while read line;
	do
		echo $line
	done < file

	## read line from string
	while read line; do echo $i; done <  <(
		cat<<MM
		124.104.141.23:80
		82.165.135.253:3128
		MM
	)

read without echoing

	read -s var

multiple and line:

	bash-3.2$ read a
	1 2
	bash-3.2$ echo $a
	1 2
	bash-3.2$ read a b c
	1 2
	bash-3.2$ echo $a
	1
	bash-3.2$ echo $b
	2
	bash-3.2$ echo $c

### 声明

	 declare [-aixr] variable
	 typeset [-aixr] variable

	 选项与参数：
	 -a  ：将后面名为 variable 的变量定义成为数组 (array) 类型
	 -i  ：将后面名为 variable 的变量定义成为整数数字 (integer) 类型
	 -x  ：用法与 export 一样，就是将后面的 variable 变成环境变量；
	 -r  ：将变量配置成为 readonly 类型，该变量不可被更改内容，也不能 unset
	 declare -p var  #单独列出变量类型

	unset var #销毁变量

##  环境变量

	env #查看环境变量 与说明
	env var1=1 var2=2 php -r 'var_dump($_SERVER);'  #执行其它信命令时, 指定子进程的环境变量
	set #查看环境变量与自定义变量.
	export  #查看环境变量的生成语句(declare -x)

## 环境配置stty,set

### set
一般地，set 的参数如果以- 为前缀，则表示设置；如果以`+`为前缀，表示取消.

	set # 查看/设置 环境变量与本地变量
	set -x # set -o xtrace 执行时打印语句
	set +x # 执行时不打印语句
	set -e # set -o errexit

	set -o :
		emacs/vi			在进行命令编辑的时候,使用内建的emacs编辑器, 默认选项
		errexit		-e		非0退出状态值(失败),就退出. 判断条件(if/&&/||)中子命令的状态码则没有影响
		xtrace		-x		打开调试回响模式
		verbose		-v		为调试打开verbose模式
		nounset		#		引用未定义的变量(缺省值为"")
		allexport	-a		从设置开始标记所有新的和修改过的用于输出的变量
		braceexpand	-B		允许符号扩展,默认选项
		histexpand	-H		在做临时替换的时候允许使用!和!! 默认选项
		history				允许命令行历史,默认选项
		ignoreeof			禁止coontrol-D的方式退出shell，必须输入exit。
		interactive-comments		在交互式模式下， #用来表示注解
		keyword		-k		为命令把关键字参数放在环境中
		monitor		-m		允许作业控制
		noclobber	-C		保护文件在使用重新动向的时候不被覆盖
		noexec		-n		在脚本状态下读取命令但是不执行，主要为了检查语法结构。
		noglob		-d		禁止路径名扩展，即关闭通配符
		notify		-b		在后台作业以后通知客户
		nounset		-u		在扩展一个没有的设置的变量的时候，    显示错误的信息
		onecmd		-t		在读取并执行一个新的命令后退出
		physical	-P		如果被设置，则在使用pwd和cd命令时不使用符号连接的路径 而是物理路径
		posix		改变shell行为以便符合POSIX要求
		privileged		一旦被设置，shell不再读取.profile文件和env文件 shell函数也不继承任何环境

		if `+o` with no option-name, a series of set commands to recreate current set options is displayed on standard output.
		if `-o` with no option-name, the values of current  options are printed.
