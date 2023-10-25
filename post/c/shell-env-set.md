---
title: shell set
date: 2021-03-09
private: true
---

## shell set arguments

    $ set a b c
    $ echo $1
    a
    $ echo $2
    b
    $ echo $3
    c

The `--`is the standard "don't treat anything following this as an option"

    $ echo $1,$2,$3
    a,b,c
    $ set -- haproxy "$@"
    $ echo $1,$2,$3,$4   
    haproxy,a,b,c

# set options

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

## error exit

exit when any command fails

    # 会errro exit
    set -e; cmd123; echo "no run"
    # 默认不会退出
    set +e; cmd123; echo "will run"

### pipefail
Refer to:
https://unix.stackexchange.com/questions/14270/get-exit-status-of-process-thats-piped-to-another

By default, we can only get last command exit status

    $ cmd123 | cat; echo $?
    0

We could get error code by `pipefail`

    $ set -o pipefail
    $ false | true; echo $?
    1
    $ true | false | true; echo $?
    1

In `bash`, it has variable called `$PIPESTATUS` (`$pipestatus in zsh`) which
contains the exit status of all the programs in the last pipeline.

    $ true | true; echo "${PIPESTATUS[@]}"
    0 0
    $ false | true; echo "${PIPESTATUS[@]}"
    1 0
    $ false | true; echo "${PIPESTATUS[0]}"
    1

### makefile

多行命令中，默认会退出

    t:
        cmd123; 
        echo "will not run"

单行命令，是一个整体的命令，即使加`set -e`也不会退出

    t:
        set -e
        cmd123; echo "will run"

单行命令内部也要加`set -e` 才可以实现 error exit

    t:
        set -e; cmd123; echo "will run"

或者:

    t:
        cmd123 || exit 1
