---
layout: page
title:	linux 之进程
category: blog
description:
---
# Preface
本文总结下进程那些事儿

# PCB 进程控制块
linux 中每个进程都是由进程控制块(PCB) 控制的，PCB是一个task_struct 结构体。

- 进程id。系统中每个进程有唯一的id，在C语言中用pid_t类型表示，其实就是一个非负整数。
- 进程的状态，有运行、挂起、停止、僵尸等状态。
- 进程切换时需要保存和恢复的一些CPU寄存器。
- 描述虚拟地址空间的信息。
- 描述控制终端的信息。
- 当前工作目录（Current Working Directory）。
- umask掩码。
- 文件描述符表，包含很多指向file结构体的指针。
- 和信号相关的信息。
- 用户id和组id。
- 控制终端、Session和进程组。
- 进程可以使用的资源上限（Resource Limit）。

*fork 与 exec 是进程控制里非常重要的两个系统调用*
fork 是将父进程的PCB 复制到子进程(除了进程的id). 而exec 用于执行子进程

linux 每一个进程有一个完整独立的虚拟内存，通过mmu 映射到物理内存. 
1. PCB 由内核空间映射
2. 数据、代码段属于性性地址空间
0. fork 不复制数据段/代码段，只复制PCB和页表，页表加只读（Copy on write）

Cow(Copy on write):
一般把这种被共享访问的页面标记为只读。当一个task试图向内存中写入数据时，内存管理单元（MMU）抛出一个异常，内核处理该异常时为该task分配一份物理内存并复制数据到此内存，重新向MMU发出执行该task的写操作。


# ENV 环境变量
fork子程序时，会把自己的环境变量复制给子进程(子进程不能影响父进程的环境变量)。exec 系统调用执行程序时，会把命令行参数与环境变量传给main 函数。

- 通过argc,argv 传递命令行参数
- 通过extern 全局变量 `extern char **environ` 传环境变量

这两个变量会被copy 到在进程的地址空间高位地址, 如图所示：
![](/img/linux-process-env.png)

libc中定义的全局变量environ指向环境变量表数组，数组最后的元素是NULL指针，environ没有包含在任何头文件中，所以在使用时要用extern声明：

	extern char ** environ;
	int i=0;
	while(environ[i] != NULL){
		printf("%s", environ[i]);
	}

## 环境变量相关函数

### getenv

	#include <stdlib.h>
	char *getenv(const char *name);

getenv 返回的是对值的指针, 可以直接通过指针修改*子程序*的环境变量（可能存在指针越界）,这是错误的用法。

	char * path;
	printf("path1:%s\n", getenv("PATH"));
	path = getenv("PATH");
	path[0] = 'H';
	printf("path2:%s\n", getenv("PATH"));

	//path1:/usr/local/bin
	//path2:Husr/local/bin

### setenv
	int setenv(const char *name, const char *value, int rewrite);
		rewrite = 0 不覆盖原来的定义，也不返回错误。
		rewrite != 0 覆盖原来的定义

### unsetenv

	void unsetenv(const char *name);
		即使name没有定义也不返回错误。

# Process Control, 进程控制
linux 进程控制最重要的两个函数就是fork 和exec 了。

	#include <sys/types.h>
	#include <unistd.h>
	pid_t fork(void);
	//失败返回-1

## fork
fork 程序的运行过程如下：

![](/img/linux-process-fork.png)

1. 父进程初始化
2. fork 调用进入内核
3. 内核根据父进程 复制出 子进程， 两者的PCB 信息相同，两者的状态都相同，都还没有从内核中退出。
4. *返回* 这两个进程，都等待从内核返回。系统中还有别的进程等待从内核返回，它们谁先返回取决于内核的调试算法。
5. 如果某个时刻，父进程被调用了，则fork 返回的是子进程的pid，
5. 如果某个时刻，子进程被调用了，则fork 返回的是pid 是0，
5. sleep 会让进程处于sleep 状态，此时内核会调度其它的进程。
5. 以上程序是由shell 启动的，shell 执行程序时shell 处于wait 状态。

fork 进程的特点是调用一次返回两次。父子进程都可以通过getpid得到自己的pid:

	pid_t getpid()

fork 复制PCB 给子进程时，包括了文件描述符，所以有两个相同的文件描述符指向一个file 结构体（其引用计数加1）

### fork 子进程调试
fork 子进程调试, 对于lldb 来说需要先断点，然后用新的*lldb* 去catch 子进程

	lldb> pro at -n a.out -w

对于gdb 来说，只需要断点, 再设置捕获子/父进程:

	gdb> b 11
	gdb> set follow-fork-mode child
	gdb> run

#### fork: retry: Resource temporarily unavailable
/etc/profile: fork: retry: Resource temporarily unavailable

原因：
进程数到达最大值.ulimit -a可以查看当前系统的所有限制值，linux一般默认是1024

解决方法：

  在/etc/security/limits.conf最后增加：

	* soft nofile 65535
	* hard nofile 65535
	* soft nproc 65535
	* hard nproc 65535

重启系统后生效，ulimit –a查看新的限制值；

关于nproc设置：centos6，内核版本是2.6.32.默认情况下，ulimit -u的值为1024，是/etc/security/limits.d/90-nproc.conf的值限

所以如果是centos6的需要如下修改, 首先在/etc/security/limits.conf中修改最大文件数

	* soft nofile 102400

	* hard nofile 102400

然后在/etc/security/limits.d/90-nproc.conf中修改进程数

	* soft nproc 102400

	* hard nproc 102400

## exec
fork 创建子进程后，一般需要调用exec 执行其实程序, exec 的作用是用其它程序的*用户空间代码*和*数据区* 来覆写 新当前进程的代码区和数据区(PCB中的进程号等等都不变).

exec 一共有6 种函数(成功则执行新程序，失败则会返回-1)：

	#include <unistd.h>
	int execl(const char *path, const char *arg, ...);
	int execlp(const char *file, const char *arg, ...);
	int execle(const char *path, const char *arg, ..., char *const envp[]);
	int execv(const char *path, char *const argv[]);
	int execvp(const char *file, char *const argv[]);
	int execve(const char *path, char *const argv[], char *const envp[]);

这几个函数的区别是:

1. l(list) 与v(vector) : 带l 表示参数列表是可变参数`...`, 可变参数最后一个必须是NULL（sentinel的作用）; 带v 表示通过指针数组传多个参数，指针数组最后一个值也必须是空指针NULL, 就像main函数的argv参数或者环境变量表一样
2. 无p 与 p(PATH) : 无p 表示第一个参数是程序的相对或者绝对路径; 有p(PATH) 表示如果第一个参数带`/`, 第一个参数就和无p 一样表示路径，否则它会去PATH 中检查程序的路径。
3. e: 表示可以传一份新的环境变量数组的地址(而不是用继承的环境变量)

调用示例：

	char *const ps_argv[] ={"ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL};
	char *const ps_envp[] ={"PATH=/bin:/usr/bin", "TERM=console", NULL};
	execl("/bin/ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL);
	execv("/bin/ps", ps_argv);
	execle("/bin/ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL, ps_envp);
	execve("/bin/ps", ps_argv, ps_envp);
	execlp("ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL);
	execvp("ps", ps_argv);


其实只有execve(2) 是真正的系统调用, 其它的5个函数都在间接的调用execve, 所以其它5 个函数都在`man 3`

![](/img/linux-process-exec.png)

操练一下：

	#include <unistd.h>
	#include <stdlib.h>
	int main(void) {
		execlp("ps", "ps", "-o", "pid,ppid,pgrp,session,tpgid,comm", NULL);//第一个ps 表示实际执行的程序，而第二参数ps 会作为ps 程序的第一个参数
		perror("exec ps");//exec 执行成功的话，这一句以及以下的代码就不会执行了
		exit(1);
	}

### 用exec 实现重定向
因为exec 打开新程序时，原来的文件描述符还是保留的，所以可以利用这一点实现重定向。
> 实上，在每个文件描述符中有一个close-on-exec标志，如果该标志为1，则调用exec时关闭这个文件描述符。该标志默认为0，可以用fcntl函数将它置1

首先来一段转换为大写的代码:

	/* upper.c */
	#include <stdio.h>
	int main(void) {
		int ch;
		while((ch = getchar()) != EOF) {
			if(ch >= 'a' && ch <= 'z'){
				ch -= 0x20;
			}
			putchar(ch);
		}
		return 0;
	}

执行效果如：

	$ ./upper
	abc
	ABC
	<ctrl-d>

	$ ./upper < file
	THIS IS FILE

现在利用exec 来实现重定向: 先打开一个文件，然后定向到标准输入， 然后启动uppper 处理这个已经打开的文件描述符(即标准输入)

	/* wrapper.c */
	#include <unistd.h>
	#include <stdlib.h>
	#include <stdio.h>
	#include <fcntl.h>
	int main(int argc, char *argv[]) {
		int fd;
		if (argc != 2) {
			fputs("usage: wrapper file\n", stderr);
			exit(1);
		}
		fd = open(argv[1], O_RDONLY);
		if(fd<0) {
			perror("open");
			exit(1);
		}
		dup2(fd, STDIN_FILENO);
		close(fd);
		execl("./upper", "upper", NULL);
		perror("exec ./upper");
		exit(1);
	}

upper 程序只关心输入，不关心输入来自于文件还是终端：

	$ ./wrapper file
	THIS IS FILE

## 进程管理

### 进程终止过程
一个进程终止时，会做以下事情:
1. 关闭打开的文件描述符，释放代码数据区
2. 但是进程的PCB还保留着，内核在其中保存了：如果是正常终止则保存着*退出状态*，如果是异常终止则保存着导致该*进程终止的信号*是哪个。

这些进程的父进程会调用wait 或者 waitpid 获取这些信息，并彻底清除掉这个进程。shell 使用'echo $?' 就是通过调用wait 或者 waitpid 得到的进程退出状态的。

### 僵尸进程
如果一个进程退出后，父进程还没有调用wait/waitpid 那这个进程就被叫作僵尸进程(Zombie)。任何进程退出时，都是Zombie 进程，不过通常情况下其父进程会立即用wait/waitpid 清理之。
如果父进程没有调用wait/waitpid, 而直接终止了，那么init 进程会作为新的父进程。如果父进程即不退出，也不调用wait/waitpid 那么，僵尸进程就得不到清理。

比如这个：

	#include <unistd.h>
	#include <stdlib.h>
	int main(void) {
		pid_t pid=fork();
		if(pid<0) {
			perror("fork");
			exit(1);
		}
		if(pid>0) { /* parent */
			while(1);
		}
		/* child */
		return 0;
	}

僵尸进程是不能被kill的，因为它已经被终止了。只能通过父进程调用wait/waipid 来清理了（父进程挂了，那么init这个元老进程会负责清理的工作）

### wait和waitpid函数
这两个函数的作用是回收并获取子进程的信息，wait和waitpid函数的原型是:

	#include <sys/types.h>
	#include <sys/wait.h>
	pid_t wait(int *status);
	pid_t waitpid(pid_t pid, int *status, int options);

*返回* 调用成功的话则返回子进程的pid, 错误则返回-1, 调用过程中, 可能会：

1. 阻塞(子进程还在运行)
2. 带子信息返回(如果子进程已经结束，等待父进程读取终止信息)
2. 带出错信息(-1)返回(没有其它任何子进程)

*阻塞与pid* 这两函数的区别是：

1. wait 等待第一个终止的子进程，而waitpid 则可以指定要终止的子进程的pid, 如果pid=-1，则等待第一个子进程结束
2. wait会使父进程阻塞，而如果在waitpid 中指定options 参数中指定WNOHANG=1(WaitNoHang) 则可以使父进程不阻塞，直接返回0

*status* 如果status 不为空指针，则子进程的信息通过这个status 传出。
*options* 仅针对waitpid, WNOHANG==1 为非阻塞

waitpid 示例:

	#include <sys/types.h>
	#include <sys/wait.h>
	#include <unistd.h>
	#include <stdio.h>
	#include <stdlib.h>

	int main(void) {
		pid_t pid;
		pid = fork();
		if (pid < 0) {
			perror("fork failed");
			exit(1);
		}
		if (pid == 0) {
			int i;
			for (i = 3; i > 0; i--) {
				printf("This is the child\n");
				sleep(1);
			}
			exit(3);
		} else {
			int stat_val;
			waitpid(pid, &stat_val, 0);
			if (WIFEXITED(stat_val))
				printf("Child exited with code %d\n", WEXITSTATUS(stat_val));
			else if (WIFSIGNALED(stat_val))
				printf("Child terminated abnormally, signal %d\n", WTERMSIG(stat_val));
		}
		return 0;
	}

子进程的终止信息在一个int中包含了多个字段，用宏定义可以取出其中的每个字段：

- 如果子进程是正常终止的，WIFEXITED 取出的字段值非零，WEXITSTATUS 取出的字段值就是子进程的退出状态；
- 如果子进程是收到信号而异常终止的，WIFSIGNALED取出的字段值非零，WTERMSIG取出的字段值就是信号的编号。

	WIFEXITED(status)
		 True if the process terminated normally by a call to _exit(2) or exit(3).

	WIFSIGNALED(status)
		 True if the process terminated due to receipt of a signal.

	WEXITSTATUS(status)
		 If WIFEXITED(status) is true, evaluates to the low-order 8 bits of the argument passed to _exit(2) or exit(3) by the child.

	WTERMSIG(status)
		 If WIFSIGNALED(status) is true, evaluates to the number of the signal that caused the termination of the process.

# IPC, InterProcess Communication 进程间通信
每个进程有自己独立的用户空间，而且只能访问自己的用户空间，进程间只能依赖内核:
进程A 将数据通过内核写到内核缓冲区，进程B 再从内核缓冲区读取数据。

IPC 主要有这三种方式：管道(pipe), FIFO(mkfifo, named pipe), UNIX Domain Socket

Linux进程间通信由以下几部分发展而来：

1. 早期UNIX进程间通信：包括管道、FIFO(named pipe)、信号。
2. 基于System V的进程间通信：包括System V消息队列、System V信号灯（Semaphore）、System V共享内存。
3. 基于Socket进程间通信
3. 基于POSIX进程间通信：包括POSIX消息队列、POSIX信号灯、POSIX共享内存。Refer to: [c-io](/p/c-io),
	POSIX 既有BSD的特性也有SYSV的特性，此外还有一些Linux特有的特性，比如epoll(7)，注：epoll 是比select/poll 更高效的监听socket 的方式
4. IPC(RPC/LPC)

## 异步同步阻塞非阻塞
https://cloud.tencent.com/developer/article/1005481
http://www.cnblogs.com/zm-0713/p/5064168.html

1. 同步：数据由内核空间复制回进程缓冲时阻塞(如recvfrom)
	1. 同步阻塞BIO： BlockIO
	2. 同步非阻塞NIO(Non-Block): 
        1. IO 复用:
            1. 阻塞的地方:
                1. 阻塞在select, poll, epoll（等待可用描述符)
                2. 读取数据的I/O系统调用如recvfrom 也是阻塞的(copy data from kernel to user)
            2. select:
                1. select(rlist,wlist,timeout=0)+ 轮询判断FD_ISSET(fd, &rset)，且有FD_SETSIZE 最大1024限制
                2. 被监控的fds需要`用户空间与内核空间`, `全部`+`来回拷贝`会有性能损坏，所以fds集合大小得限制(限制1024)。
                3. 被监控的fds集合需要遍历
            3. poll: 
                1. int poll(struct pollfd *fds, nfds_t nfds, int timeout)
                2. 没有FD_SETSIZE 限制: 使用了`pollfd`结构而不是使用宏的1024 的不可变fd_set结构
                3. 仍然要遍历+性能问题
            4. epool: 直接返回准备就绪的描述符+不会大规模的拷贝(epoll的时间复杂度O(log n)))
                1. 将`文件描述符`的事件存放到内核的一个事件表中，这样在用户空间和内核空间的copy只需一次。
                1. 引入epoll_ctl系统调用(增、删、改、查): 将高频调用的epoll_wait和低频的epoll_ctl隔离开
                    1. epoll_ctl通过(EPOLL_CTL_ADD、EPOLL_CTL_MOD、EPOLL_CTL_DEL)三个操作来分散对需要监控的fds集合的修改，做到了有变化才变更
                    2. epoll 使用红黑树来组织监控的fds集合: (增、删、改、查)效率
                2. 对于高频epoll_wait的可读就绪的fd集合返回的拷贝问题:
                    1. epoll通过内核与用户空间mmap(内存映射)同一块内存来解决
                4. epoll callback: 
                    1. 直接操作epoll去构造维护事件的循环, 造成callback hell, 注册回调与回调的可以封装，并抽象成EventLoop
                    2. 诸如libev, libevent之类, uvloop 继承自libuv
                5. epoll 特点： 也可以叫做Reactor，事件驱动，事件轮循（EventLoop）
                    1. 采用的是异步非阻塞回调, 嵌套回调极难维护: 
                    2. 没有FD_SETSIZE限制，O(1)时间，N倍并发
                    3. libevent是基于epoll系统调用的事件驱动库
                6. epoll 模式
                    1. LT模式：当epoll_wait检测到描述符事件发生，应用程序可以不立即处理该事件。下次调用epoll_wait时，会再次响应应用程序并通知此事件。
            　　     1. ET模式：当epoll_wait检测到描述符事件发生，应用程序必须立即处理该事件。如果不处理，下次调用epoll_wait时，不会再次响应应用程序并通知此事件
                7. kqueue 类似epoll 是mac osx 提供的
        2. 协程: 没有 EventLoop 的回调(同步写法, 但是底层的回调依然是callback hell)
            1.  golang 的 goroutine，
            2.  luajit 的 coroutine，
            3.  Python 的 gevent: 基于 Greenlet 与 Libev，
                1. greenlet 是一种微线程或者协程，在调度粒度上比 PY3 的协程更大。
                2. greenlet 存在于线程容器中，其行为类似线程，有自己独立的栈空间，不同的 greenlet 的切换类似操作系统层的线程切换。
            4.  erlang 的 process，
            5.  scala 的 actor 等
        3. IO信号驱动(SIGIO)：信号发生在IO之前，IO由进程完成
            1. 即描述符就绪时，内核发送 SIGIO 信号，
            2. 当从内核态返回用户态时：由用户态的*信号处理程序*去完成io操作
            3. signal handler call the actual I/O operation (man 2 recvfrom) blocks the process.
            4. 适用场景：
                1. 不适合TCP套接字：信号驱动式IO不适合处理TCP套接字，因为信号产生的过与频繁，在TCP中，连接请求完成、断开连接发起、断开连接完成、数据到达、数据送走。。。都会产生SIGIO。但我们真正只需要它在数据到达或者数据送走的时候才产生信号
                2. 适合UDP套接字：SIGIO信号在数据报到达套接字以及套接字上发生异步错误才会发生

2. 异步(AIO): copy from kernel to buffer, then sig notification, 
	3. `aio_read` 注册信号事件(比如SIGALRM)，*内核完成读写*后（读取的数据会复制到用户态），
	4. signal 再通知执行用户层 调用aio_read 指定的 `signal_handler`。
	5. 中间任何步骤都没有阻塞(甚至是内核复制数据到用户态缓冲区), 这在文本编辑器读写大文件时很有用, 网络编程则极少用
		1. linux: AIO 不少缺点
		2. Windows: IOCP 比较成熟
		3. .NET: BeginInvoke/EndInvoke

## ipcs(IPC status)
ipcs -- report System interprocess communication facilities status

	 -a		 All
	 -m      Display information about active shared memory segments.
     -p      Show the pid information for active semaphores, message queues, and shared memory segments.
     -Q      Display system information about messages queues.
     -q      Display information about active message queues.
     -S      Display system information about semaphores.
	 -s      Display information about active semaphores.

查看共享内存段进程的uid/pid:

	ipcs -p -m

## LPC and RPC
按调用端位置可分为 LPC(Local Procedure Call) 与 RPC(Remote Procedure Call).

*本地过程调用(LPC)* 用在多任务操作系统中，使得同时运行的任务能互相会话。这些任务共享内存空间使任务同步和互相发送信息。
*远程过程调用（RPC)*，只是在网上工作

### RPC
为了编制可在各种计算机和网络通信协议中都能运行的程序, 一个新的协议RPC 应运而生，开发者不用考虑底层的网络和网络上数据传输所用的协议
RPC 可以基于HTTP 协议，也可以基于 在TCP 上设计的自定义的二进制或者文本协议

php 的RPC 远端过程调用框架有:

#### Yar(http)
- 鸟哥的yar http框架: yar_server(new API)+yar_client, 可以用msgpack 这个扩展，它高效实现了二进制打包协议，也可用json 协议打包数据。yar 客户端服务端需要它.
yar 是基于http 的(http 传输头部有点浪费):


这里有一个对应的yar client for js:
https://github.com/ahuigo/yar-javascript-client

> Multiple transfer protocols supported (http implemented, tcp/unix will be supported later)
> Multiple data packager supported (php, json, msgpack built-in)

*DEBUG*
Usual RPC calls will be issued as HTTP POST requests. If a HTTP GET request is issued to the uri, the service information (commented section above) will be printed

因为它是HTTP RPC，所以可以用curl 调试:

	curl 'http://localhost:8080/a.php' -d ''
	...PHP Yar ServerQPHPYAR_a:3:{s:1:"i";i:0;s:1:"s"...

#### json-rpc
https://github.com/jcubic/json-rpc for php and js
https://github.com/jcubic/json-rpc

#### workerman-thrift-rpc
workerman-thrift-rpc是一个以workerman作为服务器容器，使用Thrift协议及其传输层模块搭建起来的跨语言的RPC远程调用框架。

workerman-thrift-rpc的目标是解决异构系统之间通信的问题，workerman-thrift-rpc使用PHP开发远程调用服务， 然后使用thrift自动生成C++, Java, Python, PHP, Ruby, Erlang, Perl, Haskell, C#, Cocoa, JavaScript, Node.js, Smalltalk, OCaml等这些语言的客户端， 通过这些客户端去调用PHP语言开发的服务。

http://www.workerman.net/workerman-thrift

#### workerman-json-rpc
workerman-json-rpc是一个以workerman作为服务器容器，使用Json作为协议简单高效的RPC远程调用框架。
http://www.workerman.net/workerman-jsonrpc

> Protocol Buffers 在文档方面比thrift丰富，而且比thrift简单 。 见 [](/p/data-format)

## pipe, 管道
Pipe 是一种基本的IPC 机制，由pipe 函数创建:

	#include <unistd.h>
	int pipe(int filedes[2]);
	//成功返回0 失败返回-1

调用pipe函数时在内核中开辟一块缓冲区（称为管道）用于通信，它有一个读端一个写端，然后通过filedes参数传出给用户程序两个文件描述符，filedes[0]指向管道的读端，filedes[1]指向管道的写端 。所以管道在用户程序看起来就像一个打开的文件，通过read(filedes[0]);或者write(filedes[1]);向这个文件读写数据其实是在读写内核缓冲区。

![](/img/linux-process-ipc-pipe.png)

*代码示例*:

	#include <stdlib.h>
	#include <unistd.h>
	#define MAXLINE 80

	int main(void) {
		int n;
		int fd[2];
		pid_t pid;
		char line[MAXLINE];

		if (pipe(fd) < 0) {
			perror("pipe");
			exit(1);
		}
		if ((pid = fork()) < 0) {
			perror("fork");
			exit(1);
		}
		if (pid > 0) { /* parent */
			//必须关闭，否则可能会存在read 阻塞，而不是返回0 (相当于EOF)
			close(fd[0]);
			write(fd[1], "hello world\n", 12);
			wait(NULL);
		} else {       /* child */
			//必须关闭，否则可能会存在write 阻塞，而不是SIGPIPE
			close(fd[1]);
			n = read(fd[0], line, MAXLINE);
			write(STDOUT_FILENO, line, n);
		}
		return 0;
	}

### 管道限制
1. 一个管道只能实现*单向通信*(如果两端都对管道写数据，则无法分清数据是谁的; 而且, 要对pipe 及时做close, pipe 的引用数不为0，在多进程中容易产生进程读写阻塞)
2. 管道是通过打开的文件描述符实现的, 要通信的两个进程*必须从公共的祖先*继承这个文件描述符。

### 管道的4种特殊情况(假设都是阻塞I/O操作，没有设置O_NONBLOCK标志)
1. 如果管道所有的write 端都关闭了（write 端引用计数为0）, 当管道没有数据可读时，read 会返回0， 而不像文件那样返回EOF.
1. 如果管道有write 端没有关闭（write 端引用计数大于0）, 当管道没有数据可读时，read 会被阻塞
1. 如果管道所有的 read 端都关闭了（read 端引用计数为0）, 如果这时在write 端写数据，进程会收到信号 SIGPIPE (默认不处理这个信号会导致进程异常终止)
1. 如果管道有 read 端没有关闭（read 端引用计数大于0）, 如果这时在write 端写数据写满了，再次write的话会使得进程被阻塞

### shell 管道命令
shell 管道符，就是通过管道实现命令间的消息传递的

	#include <stdlib.h>
	#include <stdio.h>
	#include <unistd.h>
	#include <string.h>
	#define CMD_LEN 3
	int main(int argc, char **argv) {
		char *const cmds[][4] = {{ "df", NULL}, {"gawk", "/dev/{print }", NULL}, {"grep", "disk", NULL}};
		pid_t pid;
		int i;

		int fd[2];
		int in = 0;
		//return 0;
		for(i=0; i< CMD_LEN ; i++){
			pipe(fd);
			pid = fork();
			if(pid < 0){
				exit(1);
			}
			printf("pid=%d: i=%d,in=%d, fd[0]=%d, fd[1]=%d\n", pid, i,in, fd[0], fd[1]);
			//child		关闭:	新in:fd[0], 旧out: 1
			//			使用: 	旧in:0 		新out:fd[1]
			if(pid == 0){
				//read from 0
				close(fd[0]);

				//write to fd[1]
				close(1);
				dup2(fd[1], 1);
				close(fd[1]);//输出到fd[1]
				execvp(cmds[i][0], cmds[i]);//替换代码区

			//parent 关闭: 	旧in:0 		新out:fd[1],
			//		 使用:	新in:fd[0], 旧out: 1
			}else{
				//close in ;
				//then read from fd[0]
				//if(in != 0){
				//	close(in);
				//}

				//in = fd[0];
				dup2(fd[0], 0);
				close(fd[0]);

				close(fd[1]);
				//waitpid(pid, NULL, 0);//不需要等待子进程结束, 因为read 管道时，本身带阻塞
			}
		}

		char status = *argv[1];
		printf("%c\n", status);
		if(status == '0'){
			//df |grep dev
			char buf[10000];
			i = read(in, buf, 10000);
			write(1, buf, i); //不能使用，printf("%s", buf); 因为buf 的字符串不一定是以\0结尾的
		}else if(status == '1'){
			//df |grep dev | grep disk
			//dup2(0, 1);
			//execvp(cmds[i][0], cmds[i]);
			char * const args[] = {"cat", NULL};
			execvp("cat", args);
		}
		return 0;
	}

shell 管道流程图:

![](/img/linux-process-ipc-pipe-shell.1.png)
![](/img/linux-process-ipc-pipe-shell.2.png)

## 其它IPC
进程间通信必须通过内核提供的通道，关键是如何标识这样的管道：

1. 管道是通过文件描述符(fd)来标识通道的，但是fd最大的限制是*通信间的进程必须从公共的父进程继承fd*.
2. 文件路径名也可以标识这样的通道: FIFO 和 UNIX Domain Socket 都是通过特殊的文件路径名标识 通信通道的。

## FIFO
FIFO 通过一个fifo 文件来标识内存中的通道, 可以由mkfifo 创建:

	$ mkfifo fifo; l
	prw-r--r--    1 hilojack  staff     0B Oct 20 12:51 fifo

FIFO 没有数据块，仅用来标识内核中的一条通道，其数据位于内核的缓冲区。 各进程可能通过read/write 读写之。

## UNIX Domain Socket
UNIX Domain Socket 通过一个socket 文件来标识内存中的通道, 这些socket 文件通常放在/var/run

	ls -l /var/run/*.socket
	srw-rw-rw-  1 root  daemon     0B Oct 20 11:05 /var/run/systemkeychaincheck.socket

Refer [c-socket](/p/c-socket)

# 汇总进程间通信方法
1. 通过fork 使子进程继承父进程打开的文件描述符
1. 通过wait/waitpid 获取子进程的结束信息, 并且释放子进程
3. 通过公共文件（用文件路径标识）共享信息, 也可以通过文件锁实现进程间的同步
2. 通过pipe 来共享信息(依赖于fork，使文件描述符继承)
3. 通过FIFO（用文件路径标识）共享信息
3. 通过UNIX Domain Socket（用文件路径标识）共享信息, 目前应该最广泛的IPC 机制
4. 通过进程之间互发信号，一般使用SIGUSR1和SIGUSR2实现用户自定义功能
5. 通过 mmap函数，几个进程可以映射同一内存区

# 参考
[linux c process]

[linux c process]: http://akaedu.github.io/book/ch30s03.html
