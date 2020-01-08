---
title: Shell Directory
date: 2020-01-05
private: 
---
# Shell Directory

## tempfile
给临时文件一个不可预测的文件名是很重要的。这就避免了一种为大众所知的 temp race 攻击。 一种创建一个不可预测的（但是仍有意义的）临时文件名的方法是，做一些像这样的事情：

	tempfile=/tmp/$(basename $0).$$.$RANDOM

`$$` 是pid, `$RANDOM` 的范围比较小`1-32767`.

我们可以使用`mktemp`, 它接受一个用于创建文件名的模板作为参数。这个模板应该包含一系列的 “X” 字符， 随后这些字符会被相应数量的随机字母和数字替换掉。一连串的 “X” 字符越长，则一连串的随机字符也就越长

	tempfile=$(mktemp /tmp/foobar.$$.XXXXXXXXXX) ;# /tmp/foobar.6593.UOZuvM6654

### -d参数可以创建一个临时目录。

    $ mktemp -d
    /tmp/tmp.Wcau5UjmN6

### 临时文件所在的目录
-p参数可以指定临时文件所在的目录。默认是使用`$TMPDIR`环境变量指定的目录，如果这个变量没设置，那么使用/tmp目录。

    $ mktemp -p /home/ruanyf/
    /home/ruanyf/tmp.FOKEtvs2H3

## trap
trap命令用来在 Bash 脚本中响应系统信号。

### 信号
最常见的系统信号就是 SIGINT（中断），即按 Ctrl + C 所产生的信号。trap命令的-l参数，可以列出所有的系统信号。


    $ trap -l
    1) SIGHUP   2) SIGINT   3) SIGQUIT
    4) SIGILL   5) SIGTRAP  6) SIGABRT
    ... ...

### trap命令格式
trap的命令格式如下。

    $ trap [动作] [信号]

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

### trap+EXIT 清理
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

### 多条命令
如果trap需要触发多条命令，可以封装一个 Bash 函数。

    function egress {
        command1
        command2
        command3
    }

    trap egress EXIT