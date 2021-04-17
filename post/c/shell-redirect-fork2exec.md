---
layout: page
title:	linux 下的Fork 与 Exec
category: blog
description:
---
# Preface
多进程的的内容包括进程控制, 进程通信, 进程本身的结构.

# 标准管道输入输出
with stdout(cmd get double stdout); stdout pipe to cmd

	echo abc | tee /dev/stdout | wc -l

with tty(screen)

	echo abc | tee /dev/tty | wc -l

标准输入输出:

    /dev/stdin -> /dev/fd/0
    /dev/stdout -> /dev/fd/1
    /dev/stderr -> /dev/fd/2

# 重定向
## 查看进程重定向的文件
通过proc:

    # sleep 130 >& 1.txt &
    [2] 19598
    # ls -la /proc/19598/fd
    lrwx------ 1 root root 64 May 20 19:34 0 -> /dev/pts/1
    l-wx------ 1 root root 64 May 20 19:34 1 -> /root/1.txt
    l-wx------ 1 root root 64 May 20 19:34 2 -> /root/1.txt

通过lsof:

    $ sleep 130 >& 1.txt & 
    [2] 46720
    $ lsof -p 46720       
    COMMAND   PID USER   FD   TYPE DEVICE  SIZE/OFF                NODE NAME
    sleep   46720 ahui    0u   CHR   16,3 0t6198048               13225 /dev/ttys003
    sleep   46720 ahui    1w   REG    1,4         0            33994299 /Users/ahui/test/1.txt
    sleep   46720 ahui    2w   REG    1,4         0            33994299 /Users/ahui/test/1.txt

## 重定向语法
### 重定向：

    < or 0< : 
        $ cat <a.txt
    > or >> or 1> or 1>>:
        $ echo 1 > a.txt
    2> or 2>> : 重定向标准错误
        $ { echo ass; xxxxxxx} 2>a.txt
        zsh: command not found: xxxxxxx

### 叠加重定
`>&` `&>`让stdout+err叠加到别的文件
下面的语法全等价, 都是重定向err+stdout到a.txt

    >& a.txt
    &> a.txt
    >&a.txt
    &>a.txt
    # 可以记忆为`&` 代表err,  `>`代表stdtout

    lsof -p 1134
    0u     CHR    /dev/ttys002
    1w     REG    t.txt
    2w     REG    t.txt

独立的`>&`非法，`>&1`是重复叠加1指向的文件（重复输出）   `2>&2`, `num2>&num1` 同理
 
    go run err.go >&1 | wc -l

可多次重定向

    $ go run err.go 1>1.txt 1>11.txt 2>2.txt 2>3.txt &
    
注意顺序 

    # dup(a.txt, 1) dup(1,2)
    $ go run err.go >a.txt 2>&1
    $ cat a.txt
    msg!!!!
    error!

    # dup(1,2) dup(a.txt, 1)
    $ go run err.go 2>&1 >a.txt
    error!
    $ cat a.txt
    msg!!!!
        

`num2>&num1` `num2>& num1` (`1>& num1`等价 `>& num1`)代表 dup2(num1,num2) (重复输出)

    # err 叠加到1: stdout+err
    ( echo ass; xxxxxxx) 2>&1 | tee stdout.txt

    # stdout 叠加到1: stdout+stdout
    ( echo ass; xxxxxxx) >&1 | tee stdout.txt
    ( echo ass; xxxxxxx) 1>&1 | tee stdout.txt

`num&>` 是很很殊的用法，表示num和error叠加重定向到文件

    # 1+err 重定向到文件1 
    ( echo ass; xxxxxxx) &>1 

    # 2+err(双error) 叠加到文件1 
    ( echo ass; xxxxxxx) 2&>1

参考下面的exec

    >& or &> : 重定向标准输出和标准错误
        $ { echo ass; xxxxxxx} >& a.txt
        ass
        zsh: command not found: xxxxxxx
    2>& 重定向标准错误(重复error, 没有stdout)
        $ { echo ass; xxxxxxx} 2>& a.txt

## 输入重定向
本质是 `fd=open(file, r); 0->fd`

  cat 0<a.txt
  cat <a.txt

本质是 `fd=open(file, rw); 5->fd`

  cat 5<>a.txt

## 输出重定向
本质是 `fd=open(file, w+[append]); [1-n]->fd`

    command-line1 [1-n]>file
    command-line1 [1-n]>>file

将标准出、标准错误导向/dev/null

    cmd &>/dev/null
    cmd >&/dev/null

## 绑定重定向
`&[n]` 代表是已经存在的文件描述符，`&1` 代表输出 `&2`代表错误输出 `&-`代表关闭与它绑定的描述符

  Command >&m	把1指向 m 描述符所在的结构体
  Command [n]>&m	把描述符n 指向到文件描述符m中所指向的结构体
  Command <&-	关闭标准输入
  Command 0<&-	关闭标准输入
  Command 0>&-	同上
  Command 3>&-	关闭 fd3

eg:

    $ exec 6>&1
    #将fd 6绑定 1指向的文件

    $ ls  /dev/fd/
    0  1  2  3  6
    #出现文件描述符6

    $ exec 1>suc.txt
    #将接下来所有命令标准输出，绑定到suc.txt文件（输出到该文件）

    $ ls -al
    #执行命令，发现什么都不返回了，因为标准输出已经输出到suc.txt文件了

    $ exec 1>&6
    #恢复标准输出


    $ exec 6>&-
    #关闭fd 6描述符

    $ ls /dev/fd/
    0  1  2  3

分析:

  1. 6>&1: 6 -> 1 -> stdout
  2. 1>suc.txt: 1->suc.txt, 6->stdout
  3. 1>&6: 1->6->stdout
  3. 6>&-: 1->stdout

如果`exec 1>suc.txt`, 怎么恢复呢?  因为标准输出的文件描述符还有: `2`,`/dev/tty`, 所以:

    # 恢复方法1
    exec 1>&2
    # 恢复方法2
    exec 1>/dev/tty

# exec
虽然exec和source都是在父进程中直接执行，但exec这个与source有很大的区别，source是执行shell脚本，而且执行后会返回以前的shell。而exec的执行不会返回以前的shell了，而是直接把以前登陆shell作为一个程序看待，在其上进行复制。

exec命令示例

    exec ls
    在shell中执行ls，ls结束后不返回原来的shell中了
    exec <file
    将file中的内容作为exec的标准输入
    exec >file
    将file作为标准写出
    exec 3<file
    将file读入到fd3中
    sort <&3
    fd3中读入的内容被分类
    exec 4>file
    将写入fd4中的内容写入file中
    ls >&4
    Ls将不会有显示，直接写入fd4中了，即上面的file中
    exec 5<&4
    创建fd4的拷贝fd5
    exec 3<&-
    关闭fd3

## exec的重定向
先上我们进如/dev/fd/目录下看一下：

    root@localhost:~/test#cd /dev/fd
    root@localhost:/dev/fd#ls
    0  1  2  255
    默认会有这四个项：
		0是标准输入，默认是键盘。
		1是标准输出，默认是屏幕/dev/tty
		2是标准错误，默认也是屏幕

当我们执行exec 3>test时：

    root@localhost:/dev/fd#exec 3>/root/test/test
    root@localhost:/dev/fd#ls
    0  1  2  255  3
    root@localhost:/dev/fd#

看到了吧，多了个3，也就是又增加了一个设备，这里也可以体会下linux设备即文件的理念。这时候fd3就相当于一个管道了，重定向到fd3中的文件会被写在test中。关闭这个重定向可以用exec 3>&-。

## 应用举例：

    exec 3<test
    while read -u 3 pkg
    do
    echo "$pkg"
    done

### 利用pipeline 控制进程数量
利用wait 等待所有的子进程，利用 read -u9 阻塞等待pipe

    # Author: cloud@txthinking.com
        max_process=5
    fd=/tmp/google-hosts.fd
    mkfifo $fd
    exec 9<>$fd
    rm $fd
    for((i=0;i<$max_process;i++))
    do
        echo
    done >&9

    n=0
    for((i=0;i<20;i++))
    do
        {
            echo "inner n="$n 
            read -u9
            {
                date
                echo >&9
            }
        }&
        n=$(($n+1))
        echo "n="$n $(($max_process*2))
        if [ $(($n%$(($max_process*2)))) -eq 0 ]
        then
            echo "wait n="$n $(($max_process*2))
            wait
        fi
    done
    wait
    exec 9>&-


# kill 信号
kill -15 默认向进程发送GIGTERM 信号

	kill -l 用于显示所有信号
	kill -l SEGV 查看信号值

	HUP    1    终端断线(如果忽略HUP, 终端关闭时进程不会退出)
	INT     2    中断（同 Ctrl + C）
	QUIT    3    退出（同 Ctrl + \）
	TERM   15    终止(默认)
	KILL    9    强制终止
	CONT   18    继续（与STOP相反， fg/bg命令）
	STOP    19    暂停（同 Ctrl + Z）
	SEGV	11	segmentfault

# redirect output of an already running process

    tail -f /proc/$PID/fd/1
    cat /proc/$PID/fd/1

Firstly I run the command `cat > foo1` in one session and test that data from stdin is copied to the file.
Then in another session I redirect the output.

Firstly find the PID of the process:

    $ ps aux | grep cat
    rjc 6760 0.0 0.0 1580 376 pts/5 S+ 15:31 0:00 cat

Now check the file handles it has open:

    $ ls -l /proc/6760/fd
    total 3
    lrwx—— 1 rjc rjc 64 Feb 27 15:32 0 -> /dev/pts/5
    l-wx—— 1 rjc rjc 64 Feb 27 15:32 1 -> /tmp/foo1
    lrwx—— 1 rjc rjc 64 Feb 27 15:32 2 -> /dev/pts/5

Now run GDB:

    $ gdb -p 6760 /bin/cat
    GNU gdb 6.4.90-debian

    [license stuff snipped]

    Attaching to program: /bin/cat, process 6760

    [snip other stuff that's not interesting now]

    (gdb) p close(1)
    $1 = 0
    (gdb) p creat(“/tmp/foo3″, 0600)
    $2 = 1
    (gdb) q
    The program is running. Quit anyway (and detach it)? (y or n) y
    Detaching from program: /bin/cat, process 6760

The `p` command in GDB will print the value of an expression, an expression can be a function to call, it can be a system call…

1. So I execute a *close()* system call and pass file handle 1,
2. then I execute a *creat()* system call to *open a new file*. The result of the creat() was 1 which means that it replaced the previous file handle.
* If I wanted to use the same file for stdout and stderr or if I wanted to replace a file handle with some other number then I would need to call the *dup2()* system call to achieve that result.

For this example I chose to use *creat()* instead of *open()* because there are fewer parameter.
The C macros for the flags are not usable from GDB (it doesn’t use C headers) so I would have to read header files to discover this – it’s not that hard to do so but would take more time.

Note that *0600* is the octal permission for the owner having read/write access and the group and others having no access.
It would also work to use 0 for that parameter and run chmod on the file later on.

After that I verify the result:

    ls -l /proc/6760/fd/
    total 3
    lrwx—— 1 rjc rjc 64 2008-02-27 15:32 0 -> /dev/pts/5
    l-wx—— 1 rjc rjc 64 2008-02-27 15:32 1 -> /tmp/foo3 <====
    lrwx—— 1 rjc rjc 64 2008-02-27 15:32 2 -> /dev/pts/5

Typing more data in to *cat* results in the file */tmp/foo3* being appended to.

If you want to close the original session you need to close all file handles for it, open a new device that can be the controlling tty, and then call *setsid()*.

Reference: http://stackoverflow.com/questions/1323956/how-to-redirect-output-of-an-already-running-process

## reredirect
https://github.com/jerome-pouiller/reredirect/

    reredirect -m FILE PID

## dupx
Dupx is a simple \*nix utility to redirect standard output/input/error of an already running process.

http://www.isi.edu/~yuri/dupx/

## strace
http://superuser.com/questions/473240/redirect-stdout-while-a-process-is-running-what-is-that-process-sending-to-d/535938#535938

## pexpect
https://eli.thegreenplace.net/2017/interacting-with-a-long-running-child-process-in-python/



# Rerference
- [memory]
- [fork]

[fork]: http://www.cnblogs.com/hicjiajia/archive/2011/01/20/1940154.html "x1"
[memory]: http://arhythmically40.rssing.com/chan-19541204/all_p4.html#item76
[fork exec]: http://www.cnblogs.com/hicjiajia/archive/2011/01/20/1940154.html

