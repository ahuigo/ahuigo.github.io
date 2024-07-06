---
title: linux daemon nohub
date: 2024-07-03
private: true
---
# daemon, 守护进程启动方法
> 参考 http://www.ruanyifeng.com/blog/2016/02/linux-daemon.html

1. `& or bg` to run it in the background of terminal session
	1. `fg %1`==`%1`==`%<process_name>`, i.e., `%emacs`
2. `disown <%jobId>`  to run it in the background of operation system
3. nohup -To run a process in no hangup status
4. `kill -SIGCONT PID`: Send a continue signal To continue a stopped process via PID

## background job

	$ sleep 5 &

background job:

    1. 标准输出输入问题：
        1. 继承当前 session （对话）的标准输出（stdout）和标准错误（stderr）。因此，后台任务的所有输出依然会同步地在命令行下显示。
        2. 不再继承当前 session 的标准输入（stdin）。你无法向这个任务输入指令了。如果它试图读取标准输入，就会暂停执行（halt）或退出。
        2. 不再继承当前 session 的标准输入（stdout）。如果它试图读取标准输出，就会暂停执行（halt）或退出。
    2. 进程可能会收到SIGHUP, 而退出

你可以通过以下脚本+ `tail -f a.log`验证：

    import time
    from datetime import datetime

    f = open("a.log",'w+')
    while True:
        s = datetime.now().strftime("%H:%M:%S")
        f.write(s+"\n")
        print(s)
        f.flush()
        time.sleep(1)

## SIGHUP signal
用户退出session 后，会发生：

	1. 用户准备退出 session
	1. 系统向该 session 发出SIGHUP信号
	1. session 将SIGHUP信号发给所有子进程
	1. 子进程收到SIGHUP信号后，自动退出

那么，"后台任务"是否也会收到SIGHUP信号？ 这由 Shell 的huponexit参数决定的。

	$ shopt | grep huponexit

大部分linux 这个参数默认关闭（off）。因此，session 退出的时候，不会把SIGHUP信号发给"后台任务"。所以，一般来说，"后台任务"不会随着 session 一起退出。

## disown(忘记nohup)
因为有的系统的huponexit参数可能是打开的（on）。
更保险的方法是使用disown命令。它可以将指定任务从"后台任务"列表（jobs命令的返回结果）之中移除。一个"后台任务"只要不在这个列表之中，`session 就肯定不会向它发出SIGHUP信号`。 

	$ node server.js &
	$ jobs
    [1]+  Running                 node server.js &
	$ disown
    # 或
    $ disown -h %1

执行上面的命令以后，server.js进程就被移出了"后台任务"列表。你可以执行jobs命令验证，输出结果里面，不会有这个进程。

disown的用法如下。

	# 移出最近一个正在执行的后台任务
	$ disown

	# 移出所有正在执行的后台任务
	$ disown -r

	# 移出所有后台任务
	$ disown -a

	# 不移出后台任务，但是让它们不会收到SIGHUP信号
	$ disown -h

	# 根据jobId，移出指定的后台任务
	$ disown %2

	# 不移出后台任务，但是让它们不会收到SIGHUP信号
	$ disown -h %2

## 标准IO
使用disown命令之后，还有一个问题。那就是，退出 session 以后，如果后台进程与标准I/O有交互，它还是会因为找不到input/output 挂掉。

还是以上面的脚本为例，现在加入一行。

	var http = require('http');

	http.createServer(function(req, res) {
	  console.log('server starts...'); // 加入此行
	  res.writeHead(200, {'Content-Type': 'text/plain'});
	  res.end('Hello World');
	}).listen(5000);

启动上面的脚本，然后再执行disown命令。

	$ node server.js &
	$ disown

接着，你退出 session，访问5000端口，就会发现连不上. 

因为它的tty/pts 随session 退出而关闭，需要对"后台任务"的标准 I/O 进行重定向。

	$ node server.js > stdout.txt 2> stderr.txt < /dev/null &
	$ disown

## nohup 命令
还有比disown更方便的命令，就是nohup。 nohup 的用途就是让提交的命令忽略 hangup 信号
>当用户注销（logout）或者网络断开时，终端会收到Linux HUP信号（hangup）信号从而关闭其所有子进程。因此，我们的解决办法就有两种途径：要么让进程忽略Linux HUP信号，要么让进程运行在新的会话里从而成为不属于此终端的子进程。

nohup命令不会自动把进程变为"后台任务"，所以必须加上`&`符号

	$ nohup node server.js 2>&1 &
	$ nohup node server.js >> nohup2.out 2>&1 &

nohup命令对server.js进程做了三件事。
1. 阻止SIGHUP信号发到这个进程。
2. 关闭标准输入。该进程不再能够接收任何输入，即使运行在前台。
3. 重定向标准输出和标准错误到文件nohup.out。

nohup 默认会将 1+2 pipe append to nohup.out， 所以不需要加

	>> nohup.out 2>&1

注意python print 不会写出nohup:

> It looks like you need to flush stdout periodically (e.g. `sys.stdout.flush()`). 
> In my testing Python doesn't automatically do this even with print until the program exits.

### setsid
> 参考： https://www.cnblogs.com/JohnABC/p/4828724.html
nohup无疑能通过忽略Linux HUP信号 信号来使我们的进程避免中途被中断，但如果我们换个角度思考，如果我们的进程不属于接受Linux HUP信号的终端的子进程，那么自然也就不会受到Linux HUP信号的影响了。setsid 就能帮助我们做到这一点。

    man setsid: runs a program in a new session. 

setsid 示例

    [root@pvcent107 ~]# setsid ping www.ibm.com
    [root@pvcent107 ~]# ps -ef |grep www.ibm.com
    root     31094     1  0 07:28 ?        00:00:00 ping www.ibm.com
    root     31102 29217  0 07:29 pts/4    00:00:00 grep www.ibm.com

值得注意的是，上例中我们的进程 ID(PID)为31094，而它的父 ID（PPID）为1（即为 init 进程 ID），并不是当前终端的进程 ID。请将此例与nohup 例中的父 ID 做比较。

### &
当我们将"&"也放入“()”内之后，我们就会发现所提交的作业并不在作业列表中，也就是说，是无法通过jobs来查看的。让我们来看看为什么这样就能躲过Linux HUP信号的影响吧。

    [root@pvcent107 ~]# (ping www.ibm.com &)
    [root@pvcent107 ~]# ps -ef |grep www.ibm.com
    root     16270     1  0 14:13 pts/4    00:00:00 ping www.ibm.com
    root     16278 15362  0 14:13 pts/4    00:00:00 grep www.ibm.com

从上例中可以看出，新提交的进程的父 ID（PPID）为1（init 进程的 PID），并不是当前终端的进程 ID。因此并不属于当前终端的子进程，从而也就不会受到当前终端的Linux HUP信号的影响了。

## redirect outputs of a running process

    # -m option is just a shortcut to -o FILE -e FILE.
    reredirect -m FILE PID
    reredirect -o FILE1 -e FILE2 PID
    reredirect -m /dev/null pid

## restart process
如果进程能响应HUP
kill -HUP `cat gunicorn.pid`

## Screen 命令与 Tmux 命令
另一种思路是使用 terminal multiplexer （终端复用器：在同一个终端里面，管理多个session），典型的就是 Screen 命令和 Tmux 命令。

Tmux 比 Screen 功能更多、更强大 见[/p/linux-tmux](/p/linux-tmux)


## Systemd
除了专用工具以外，Linux系统有自己的守护进程管理工具 Systemd 。它是操作系统的一部分，直接与内核交互，性能出色，功能极其强大。我们完全可以将程序交给 Systemd ，让系统统一管理，成为真正意义上的系统服务。
see [systemd](/c/linux-systemd.md)

# flock
任务加锁

    flock -xn
        -s, --shared             get a shared lock
        -x, --exclusive          get an exclusive lock (default)
        -u, --unlock             remove a lock
        -n, --nonblock           fail rather than wait

它可以帮助你在 shell 脚本或其他命令行任务中添加锁机制，以防止并发执行

    # 如果锁已经被其他进程持有，那么立即退出，而不是等待锁被释放。
    flock -xn /tmp/lockfile -c /path/to/script.sh
