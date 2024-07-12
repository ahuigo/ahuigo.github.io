---
title: shell signal and trap
date: 2024-07-12
private: true
---
## Signal, 信号(trap)
> Refer to: http://billie66.github.io/TLCL/book/zh/chap37.html
> Refer 2: c-signal.md
最常见的系统信号就是 SIGINT（中断），即按 Ctrl + C 所产生的信号。trap命令的-l参数，可以列出所有的系统信号。

    $ kill -l 
    $ trap -l
    1) SIGHUP   2) SIGINT   3) SIGQUIT
    4) SIGILL   5) SIGTRAP  6) SIGABRT
    ... ...

# trap
trap命令用来在 Bash 脚本中响应系统信号, 想当于前端的 addEventListener


## trap命令格式
signal handling syntax:

    $ trap [动作] [信号]
	trap argument signal [signal...]

上面代码中，"动作"是一个 Bash 命令，"信号"常用的有以下几个。

    HUP：编号1，脚本与所在的终端脱离联系。
    INT：编号2，用户按下 Ctrl + C，意图让脚本中止运行。
    QUIT：编号3，用户按下 Ctrl + 斜杠，意图退出脚本。
    KILL：编号9，该信号用于杀死进程。
    TERM：编号15，这是kill命令发出的默认信号。
    EXIT：编号0，这不是系统信号，而是 Bash 脚本特有的信号，不管什么情况，只要退出脚本就会产生。

trap命令响应EXIT信号的写法如下。


    $ trap 'rm -f "$TMPFILE"' EXIT
    # 上面命令中，脚本遇到EXIT信号时，就会执行rm -f "$TMPFILE"。

## trap+EXIT 清理
trap 命令的常见使用场景，就是在 Bash 脚本中指定退出时执行的清理命令。


    #!/bin/bash
    trap 'rm -f "$TMPFILE"' EXIT

    TMPFILE=$(mktemp) || exit 1
    ls /etc > $TMPFILE
    if grep -qi "kernel" $TMPFILE; then
        echo 'find'
    fi

上面代码中，不管是脚本正常执行结束，还是用户按 Ctrl + C 终止，都会产生EXIT信号，从而触发删除临时文件。

> 注意，trap命令必须放在脚本的开头。否则，它上方的任何命令导致脚本退出，都不会被它捕获。

## trap interrupt: sleep
demo1: press`Ctrl+C` to send interrupt signal, 会中断sleep 程序，继续后面的命令

	trap "echo 'I am ignoring interrupted and kill!'" SIGINT SIGTERM
	for i in {1..5}; do
		echo "Iteration $i of 5"
		sleep 5
	done

## trap handler: function
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

### trap handler: 多条命令
如果trap需要触发多条命令，可以封装一个 Bash 函数。

    function egress {
        command1
        command2
        command3
    }

    trap egress EXIT