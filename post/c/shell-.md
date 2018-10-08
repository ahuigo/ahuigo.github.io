---
title:	Shell Programming
date: 2014-03-05
priority:
---
# Shell Programming

# Signal, 信号(trap)
Refer to:
http://billie66.github.io/TLCL/book/zh/chap37.html

signal handling:

	trap argument signal [signal...]

demo1: press`Ctrl+C` to send interrupt signal

	trap "echo 'I am ignoring interrupted and kill!'" SIGINT SIGTERM
	for i in {1..5}; do
		echo "Iteration $i of 5"
		sleep 5
	done

trap-demo2 : simple signal handling demo

	exit_on_signal_SIGINT () {
		echo "Script interrupted." 2>&1
		exit 0
	}
	exit_on_signal_SIGTERM () {
		echo "Script terminated(kill)." 2>&1
		exit 0
	}
	trap exit_on_signal_SIGINT SIGINT
	trap exit_on_signal_SIGTERM SIGTERM
	for i in {1..5}; do
		echo "Iteration $i of 5"
		sleep 5
	done

# Security

## temp race
给临时文件一个不可预测的文件名是很重要的。这就避免了一种为大众所知的 temp race 攻击。 一种创建一个不可预测的（但是仍有意义的）临时文件名的方法是，做一些像这样的事情：

	tempfile=/tmp/$(basename $0).$$.$RANDOM

`$$` 是pid, `$RANDOM` 的范围比较小`1-32767`.

我们可以使用`mktemp`, 它接受一个用于创建文件名的模板作为参数。这个模板应该包含一系列的 “X” 字符， 随后这些字符会被相应数量的随机字母和数字替换掉。一连串的 “X” 字符越长，则一连串的随机字符也就越长

	tempfile=$(mktemp /tmp/foobar.$$.XXXXXXXXXX) ;# /tmp/foobar.6593.UOZuvM6654

# process

## 子进程退出
shell 本身启动的`cmd &`, 会随着shell 的退出而退出。
sub process 启动的`cmd &`, 会随着shell 的退出, 不会退出，控制权限会被交给shell 的父进程

    `echo "the command"|at now`;

## async 异步执行: wait
> http://billie66.github.io/TLCL/book/zh/chap37.html
wait 命令导致一个父脚本暂停运行，直到一个 特定的进程（例如，子脚本）运行结束。

	# async-parent : Asynchronous execution demo (parent)
	echo "Parent: starting..."
	echo "Parent: launching child script..."
	async-child &
	pid=$!
	echo "Parent: child (PID= $pid) launched."
	echo "Parent: continuing..."
	sleep 2
	echo "Parent: pausing to wait for child to finish..."
	wait $pid
	echo "Parent: child is finished. Continuing..."
	echo "Parent: parent is done. Exiting."

`$!` shell 参数的值，它总是 包含放到*后台执行*的最后一个任务的进程 ID 号。

## check if a command exists

	hash git || { echo 'Err: git is not installed.' ; exit 3; }
	command git || { echo 'Err: git is not installed.' ; exit 3; }
	type git || { echo 'Err: git is not installed.' ; exit 3; }

Refer to:
http://stackoverflow.com/questions/592620/check-if-a-program-exists-from-a-bash-script
http://unix.stackexchange.com/questions/85249/why-not-use-which-what-to-use-then

    ➜ > ~ command -v ls
    alias ls='ls -G'
    ➜ > ~ command -v go
    /usr/local/bin/go
    gopath=$(command)

## errcode
`exit 0 ` 返回一个成功的状态码，非0状态码表示不成功。

默认的管道不会传递errcode(`pipefail` is false).

	$ false | true; echo $?
	0

可以手动开启：

	$ set -o pipefail
	$ false | true; echo $?
	1

## grep & ps
remove grep command while use ps

	ps aux | grep perl | grep -v grep
	ps aux | grep '[p]erl'

Or use `pgrep` instead:

	pgrep perl
	pgrep per[l]

## type
type 用于查看命令的属性

	type command
	type -t command (not support zsh)

## alias

	unalias rgrep

## exec self process

    $ bash -c 'echo $$ ; ls -l /proc/self ; echo foo'
    7218
    lrwxrwxrwx 1 root root 0 Jun 30 16:49 /proc/self -> 7219
    foo
    with

    $ bash -c 'echo $$ ; exec ls -l /proc/self ; echo foo'
    7217
    lrwxrwxrwx 1 root root 0 Jun 30 16:49 /proc/self -> 7217

## multiple command to one

    sh -c 'ls ; ls'
    sh -c 'cmd1 && cmd2'
    sh -c 'cmd1 & cmd2'
    sh -c 'cmd1 ; cmd2'
    sudo -- sh -c 'date; who am i'

1. ampersand `&` is for Asynchronous lists:
1. semi-column `;` is actually a sequential list.
2. `&&` is for combine cmd to one

Empty command is fobidden:

    sh -c 'ls & ;ls'; # syntax error

## execute command `cmd` or $(cmd)
以子进程执行cmd.(你也可通过source 以当前进程执行cmd)

	`cmd` or $(cmd)
	ls -l `locate crontab`

	source cmd or . cmd

\`\`内嵌时需要转义

	echo "`ls \`which ls\``"
	echo "$(ls `which ls`)"

>	ps: a=`cmd` #如果cmd 中含有\r, 则每次\r会把前面的字符给干掉. 可以 a=`cmd | tr "\r\n" "-+"`

shell arguments:
在zsh 中会执行失败zsh为了安全，会将$var 整个字符串视为一个命令（包括其中的空白符）

	var='svn st'; `$var`;
	var='svn st'; $var;

你可以用eval, `sh -c`

	`eval "$cmd"`;
	`sh -c "$cmd"`;
	# 或者这样，让zsh 原样输出$var
	setopt shwordsplit; `$var`;

请参考：[Why does $var where var="foo bar" not do what I expect?](http://zsh.sourceforge.net/FAQ/zshfaq03.html)

## Process Substitution - 进程替换
有些命令需要以文件名为参数(file args)，这样一来就不能使用管道。这个时候 `<()` `>()` 就显出用处了，它可以接受一个命令，并把它转换成临时文件名。

	# 下载并比较两个网页
	diff <(wget -O - url1) <(wget -O - url2)
	echo <(echo "foo"); # ///dev/fd/17
	# 将临时文件通过管道传给命令
	wget -q -O >(cat) url

	# 替换符号不分开！
	➜ > py git:(gh-pages) ✗cat <( echo abc )
	abc
	➜ > py git:(gh-pages) ✗cat < ( echo abc )
	zsh: unknown file attribute:

再来一个例子

	while read attr links owner group size date time filename; do
		cat <<- EOF
			Filename:     $filename
			Size:         $size
			Owner:        $owner
			Group:        $group
			Modified:     $date $time
			Links:        $links
			Attributes:   $attr
		EOF
	done < <(ls -l | tail -n +2)

> 注意# tail -n +2, 用的+ 号哦

### pipe stdout while keeping it on screen

	#with Process Substitution
	echo abc | tee >(cmd)
	#with stdout(cmd get double stdout); stdout pipe to cmd
	echo abc | tee /dev/stdout | cmd
	#with tty(screen)
	echo abc | tee /dev/tty | cmd

## heredoc and nowdoc
Act as stdin

	# heredoc 任何字词都可以当作分界符 (cat < file)
	cat  << MM
	echo $? #支持变量替换
	MM

	#nowdoc 加引号防止变量替换
	cat << 'MM' > out.txt
	echo $?
	MM

	# `<<-` ignore tab
	if true ; then
		cat <<- MM | sudo tee -a file > /dev/null
		The leading tab is ignored.
    MM
	fi
	# nowdoc + ignore tab(not include space) MM 仍然要顶行写
	cat <<-'MM' | sudo tee -a a.txt > /dev/null
		echo $PATH
    MM

## here string
> Note: here string 结尾会追加'\n'

Act as stdin

    python <<<'import os;os._exit(0)'
	tr a-z A-Z <<< 'one two'
	cat <<< 'one two'

	cat <<< $PATH a.txt
	echo "$PATH" | cat a.txt

Note that here string behavior can also be accomplished (reversing the order) via piping and the echo command, as in:

	echo 'one two' | tr a-z A-Z

## Caculation

### expr
expr 算式:

	x=`expr $x + 1` ; #$x 与 + 与 1 之间必须有空格, 否则被expr视为字符串

### bc expression
	x=`echo $x^3 | bc`; #bc 较expr限制少, 支持大量的数学符号(而expr 仅支持+-*/%)

### let
let 数学式:

	let x=$x+1;echo $x; # let 没有返回值的

### 双括号(())
1. 支持-+*/%
2. 支持随机数

	echo $((RANDOM%100))

# debug 调试

## read args through pipe to sh

	echo "echo \$@" | sh -s 1 2 3
	echo "echo \$@" | zsh -s 1 2 3

## time

	time cmd

	$ time (for m in {1..100000}; do [[ -d . ]];done;)
	real	0m0.438s
	user	0m0.375s
	sys	0m0.063s

## Record commands and results
log command

	script [record_file]
		record_file: default typescript

Refer to: [stackoverflow](http://stackoverflow.com/questions/15698590/how-to-capture-all-the-commands-typed-in-unix-linux-by-any-user)

Also you record results via `redirection` and `exec`:

	set -x
	exec 2>> record.txt 1>>record.txt

## debug 参数
shell 支持一些调试参数：

	-n 不执行，用于检查语法错误
	-v Prints shell input lines as they are read.(set -v, set -o verbose)
	-x Print command traces before executing command.(set -x, set -o xtrace)

## 调试参数使用场景
1. 在命令行 sh -x a.sh
1. 在脚本的头部 `#/bin/sh -x`
1. 在脚本中用set 设置 `set -x` 或者 `set -o xtrace`, 用于在命令执行前打印命令


	set -x			# activate debugging from here
	w
	set +x			# stop debugging from here

# shell login

## 作为交互登录Shell启动，或者使用--login参数启动
*登录Shell*就是在输入用户名和密码*登录*后得到的Shell.  但是从*图形界面*的窗口管理器登录之后会显示桌面而不会产生登录Shell（也不会执行启动脚本），在图形界面下打开终端窗口得到的Shell也不是登录Shell。

交互式的登录shell 会依次执行:

1. /etc/profile
2. ~/.bash_profile、~/.bash_login和~/.profile三个文件中的一个
3. 退出登录时会执行~/.bash_logout脚本

## 以交互非登录Shell启动
图形界面下开一个终端窗口，或者在登录Shell提示符下再输入bash命令

1. ~/.bashrc

一般~/.bash_profile 会包含 ~/.bashrc

## 非交互Shell
为执行脚本而fork出来的子Shell是非交互Shell

# Reference
- [TLCL] The Linux Command Line book
- [shell manual] 51yip shell manual

[TLCL]: http://billie66.github.io/TLCL/book/
[shell manual]: http://manual.51yip.com/shell/
[bash 进阶]:  http://blog.sae.sina.com.cn/archives/3606
