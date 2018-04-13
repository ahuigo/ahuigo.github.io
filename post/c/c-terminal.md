---
layout: page
title:	linux c 终端、作业与守护进程
category: blog
description: 
---
# Unix 下的终端、作业、守护进程
用户通过终端登录系统后得到一个shell 进程， 这个终端成为shell 进程的控制终端（Controlling Terminal）. [/c/ops-process](/p/c/ops-process) *控制终端是保存在PCB 中的信息*. shell 进程fork 出的子进程时会复制这份PCB, 所以子进程指向的终端也会是这个终端。

默认情况下，*每个进程的标准输入/标准输出/标准错误输出 都是指向控制终端*. 进程从标准输入读，也是从键盘输入; 进程向标准输出/标准错误输出，也是输出到显示器。

控制终端输入一些特殊的控制键*可以给前端进程发信号*，比如Ctrl-C 表示SIGINT, 比如Ctrl-\ 表示SIGQUIT


# 终端设备
每个进程可以通过一个特殊的设备文件`/dev/tty` (标准输入|输出)访问它的控制终端，这是一个*通用的设备文件*。

	>>> open('/dev/stdout','w').write('abc') # stdin/stdout/stderr 都指向当前的tty
	abc3
	>>> open('/dev/fd/1','w').write('abc') # stdout 软链接到 /dev/fd/1
	abc3
	>>> open('/dev/tty','w').write('abc') # tty指向激活的pts: /dev/ttys004 ttys004 === /dev/fd/{0,1,2}的file inode 是一样的
	abc3
	>>> open('/dev/ttys005','w').write('abc') # 输出到别人的pts: /dev/ttys005
	3

其实一个进程要访问它的控制终端既可以通过/dev/tty也可以 通过*控制终端本身对应的设备文件*: `/dev/pts/0`(mac下是`/dev/ttys000`), ttyname 函数可以由文件描述符查出对应的设备文件名. 该文件描述符必须指向终端设备

用ttyname 查看进程的终端设备文件:

	#include <unistd.h>
	#include <stdio.h>
	int main() {
		printf("fd 0: %s\n", ttyname(0));
		printf("fd 1: %s\n", ttyname(1));
		printf("fd 2: %s\n", ttyname(2));
		return 0;
	}

在我的mac 下输出如下, 这表示第一个虚拟终端.第二个虚拟终端为ttys001

	fd 0: /dev/ttys000
	fd 1: /dev/ttys000
	fd 2: /dev/ttys000


## 虚拟终端设备
*字符终端设备 tty1~tty6*
在linux 下使用ctrl+alt-f1 会切换到字符终端/dev/tty1, 一共有6个字符终端(tty1~tty6). 相当于有6个虚拟终端
一台PC 通常只有一套键盘和显示器，也就是只有一套终端设备。但可以通过6个虚拟终端(tty1~tty6) 访问这套物理终端设备。虚拟终端叫Virtual Terminal. 

*tty0 通用字符终端设备*
tty0 表示当前虚拟终端, 使用Ctrl-Alt-F1 时，其实是将tty0 指向第1个虚拟终端tty1. /dev/tty0 就像 /dev/tty 是一个通过终端设备，但它不能像tty 一样表示GUI 终端窗口对应的终端设备。

*pts 图形/网络终端设备*
在linux 下GUI 环境中, 终端设备一般表示为/dev/pts0, 它是第一个图形终端设备，第二个一般名为/dev/pts1..

*串口终端设备ttyS0 ttyS1*
嵌入式开发中，每个串口对就一个终端设备，比如/dev/ttyS0, /dev/ttyS1. 将主机和目标板用串口线连起来，就可以在主机上通过Linux的minicom或Windows的超级终端工具登录到目标板的系统

### 终端TTY和PTS的区别
1. tty: 终端设备的统称(一般为tty1-tty6，数量可以在/etc/inittab里调): tty(硬件键盘显示器) 可以虚拟多个pty(内核模块)
	0. 一端是内核终端模拟器，另一端硬件: 键盘、显示器. fd = open('/dev/tty')
	2. tty 是可激活不同的pts：`$ tty` # 查看当前tty 激活哪个pts, 比如`/dev/pts/6`
2. pty: 一套伪终端(Pseudo TTY) 包括一个主设备(PTY Master) 和一个从设备(PTY Slave) 组成。
	0. A pty is pseudo terminal device which is emulated by an other program (example: xterm, screen, or ssh are such programs). 
	1. 一端是pty master(ptmx连接sshd等), 另一端连接多个pty slave(pts): xterm/scrren/ssh,...
	1. A pts(/dev/pts/x) is the slave part of a pty.

### stty 终端控制命令
man stty:

	stty [-a]
	-a  ：将目前所有的 stty 参数列出来；

	Control Characters:
		eof   : End of file 的意思，代表『结束输入』。
		erase : 向后删除字符，
		intr  : 送出一个 interrupt (中断) 的讯号给目前正在 run 的程序；
		kill  : 删除在目前命令列上的所有文字；
		quit  : 送出一个 quit 的讯号给目前正在 run 的程序；
		start=^Q : 在某个程序停止后，重新启动他的 output
		stop=^S  : 停止目前屏幕的输出；
		susp  : 送出一个 terminal stop 的讯号给正在 run 的程序。

	Local Modes:
		$ stty -tostop: 禁止发送 SIGTTOU 信号
		$ stty tostop: 如果后台进程向标准（或错误）输出写数据, 会收到SIGTTOU 信号则使得进程停止, 见(/p/linux-c-terminal, man stty)

```
$ tty # 查看当前tty 激活的pts
/dev/pts/6
$ stty -a #查看所有终端的参数
intr = ^C; quit = ^\; erase = ^?; kill = ^U; eof = ^D; eol = M-^?; eol2 = M-^?; swtch = <undef>; 
start = ^Q; stop = ^S; susp = ^Z; rprnt = ^R; werase = ^W; lnext = ^V; discard = ^O; min = 1; time = 0;
echo  -tostop -echoprt echoctl echoke -flusho -extproc.....
```

### Line Discipline 线路规程

内核中处理终端设备的模块包括硬件驱动程序和线路规程（Line Discipline）。

![](/img/linux-c-terminal-kernel-mode.png)

终端设备驱动程序负责实际硬件的读写，比如：
- 从键盘读取字符, 向显示器输出字符
- 线路规程(Line Discipline) 是一个过滤器，有些特殊的字符不会被read 读取到，而是做特殊的处理。比如Ctrl-Z, 会被线路规程拦截，解释成SIGTSTP 信号发送给前台进程，通常会使进程停止。*线路规程应该过滤哪些字符和做哪些特殊处理是可以配置的*

### 终端设备输入输出缓冲区

![](/img/linux-c-terminal-buffer.png)

如上图所示, 从键盘输入的字符 经过line discipline 过滤后送入到输入队列，用户程序以先进先出的顺序读取输入队列。
- 如终端配置成回显(Echo)，则输入队列中的字符会被写到输出队列, 这样我们即时看到输入的字符同时，程序也读取到了输入的字符
- 如果输入队列满了，再输入的字符就会丢失，此时系统会响铃报警。

# 终端登录过程
系统启动时,init(pid=0) 进程根据/etc/inittab 确定要打开哪些终端。比如：

	1:2345:respawn:/sbin/getty 9600 tty1

- 第一个1 表示这一行配置的是id, 通常要和tty 的后缀一致，比如tty1
- 第二个2345 表示运行级2345 都执行这个配置, 
- 第四个/sbin/getty 96000 tty1 表示init 进程要fork/exec 的命令，打开终端tty1, 波特率是9600（只对串口和Modem 终端有意义）,然后提示用户输入帐号 
- 第三个respawn字段表示init进程会监视getty进程的运行状态，一旦该进程终止，init会再次fork/exec这个命令，所以我们从终端退出登录后会再次提示输入帐号
> 有些新linux 发行版已经不用/etc/inittab了，比如Ubuntu 用/etc/event.d 目录下的配置文件来配置init

## login
getty 根据命令行参数打开终端设备作为它的控制端，把文件描述符0、1、2都指向该终端设备，然后提示用户输入帐号。用户输入帐号后,getty 的任务就完成了，它再执行login 程序：

	execle("/bin/login", "login", "-p", username, NULL, envp);

## passwd
login 程序提示用户输入密码(此时会关闭终端的回显)，然后验证帐号密码。如果不正确，login 程序终止, init 程序会再次fork/exec 执行getty 进程。如果密码正确，login 设置环境变量，并设置当前工作目录为用户的主目录，然后执行shell:

	execl("/bin/bash", "-bash", NULL);
	
Note, argv[0] 前有一个"-", 这样bash 就知道知道是以login shell 启动的，执行登录shell 启动脚本（比如/etc/profile, .profile ,.bash_profile）. 从getty 开始exec 到login, 再exec 到shell, 其实都是同一个进程，因此控制终端没有变，文件描述符0,1,2 也指向控制终端。


## 网络终端登录过程(伪终端, Pseudo TTY)
虚拟终端(字符终端为6个，即tty1~tty2) 或串口终端(受限于串口数量)的数目是有限的。然而网络终端或者图形终端窗口的数目却是不受限制的，这通过伪终端(Pseudo TTY) 实现的。

一套伪终端(Pseudo TTY) 包括一个主设备(PTY Master) 和一个从设备(PTY Slave) 组成。
*关于主设备*
- 主设备从概念上相当于键盘或显示器，不过它不是真正的硬件，而是一个内核模块; 
- 操作它的不是用户而是另外一个进程（比如telnetd, sshd, etc.）
- 与/dev/tty1 这样的终端设备模块类似, 不过它的底层驱动程序不是*访问硬件*，而是访问*主设备(内核模块)*


![](/img/inux-c-terminal-pts.png)

上图用telnet 为例说明了网络登录过程，以及伪终端设备的使用:
1. *用户通过telnet 连接到服务器*。服务有两种监听连接请求的配置：
如果服务器配置为独立(standalone) 模式，则在服务器端监听连接请求的是一个telnetd 进程，它fork 出telnetd 子进程来服务客户端，父进程仍然监听连接请求；
如果服务器配置为inetd 或者 xinetd 监听连接请求. inetd 称为Internet Super-Server Daemon, 它监听系统中的多个网络服务端口；如果连接请求的端口号与telnet 服务端口号一致，就fork/exec 出telnetd 进程来服务客户端。xinetd 是inetd 的升级版，配置更为灵活。

2. telnetd 子进程打开一个伪终端设备。然后fork 出一个子进程： 
父子进程将文件描述符0,1,2 指向控制终端, 二者通过伪控制终端通信;
父进程操作伪终端的主设备(PTY Master), 子进程操作伪终端的从设备(PTY Slave) ;
父进程还负责和telnet 客户端通信，而子进程负责用户登录过程（getty提示帐号输入，login提示密码输入，执行shell）,这个shell 认为自己的控制终端就是伪终端(-bash). 伪终端的主设备可以看作键盘或者显示器，操作它telnetd 父进程 可以看作是用户。

3. 网络用户输入的字符发送给telnetd 服务器，telnetd 再将字符发送给伪终端。shell 进程并不知道自己连接的是伪终端还是真正的键盘/显示器，也不知道操作终端的用户还是telnetd。shell 只管将标准输出、标准错误输出写到终端，伪终端再将输出发给telnetd, telnetd 发给telnet 客户端。

如果telnet 与服务器之间的网络延迟较大，我们会看到输入的字符回显就有明显延迟，因为每一个字符都要走一次服务器，真的是这样！

BSD 系列的UNIX 在/dev 目录下创建了很多的ptyXX/ttyXX 设备文件，ptyXX 是主设备，相对应的ttyXX 是从设备(不是所有的tty 都是伪终端的从设备)。伪终端的数据取决于内核配置。	
SYS V 系列UNIX, 伪终端的主设备是/dev/ptmx (mx is short of Mutiplex), 意思是多个主设备复用同一个设备文件，每打开一次/dev/ptmx, 内核就分配一个主设备，同时在/dev/pts/ 目录下创建一个从设备文件。当终端关闭时，就从/dev/pts 目录下删除相应的从设备文件。与tty 字符终端区分开了	
Linux 同时支持以下两种伪终端，目前的标准倾向于SYS V 的伪终端。	


# 作业
[信号](/p/linux-c-signal) 所说的"shell 可以同时运行一个前端进程和多个后台进程" 是不准确的。实际上，shell 分前后台控制的不是进程，而是作业(job) 或者 进程组(Process Group). 一个前台作业可以有多个进程组成，一个后台作业也可以有多个进程组成。shell 可以有一个前台作业，和多个后台作业, 这称为作业控制(job control). 例如启动一个后台作业和一个前台作业（5个进程）

	$ proc1 | proc2 &
	$ proc3 | proc3 | proc4

proc1 和 proc2 属于同一个进程组， proc3/proc4/proc5 属于同一个前台进程组。这些进程组的控制端终端都是shell，它们属于同一个session。 当用户按下Ctrl-C 时，内核会向前台进程组中的所有进程发送SIGINT 信号。 各进程、进程组 与session 的关系:
![](/img/linux-c-job-session.png)

从session 的角度重新审视登录和执行命令的过程：
1. getty 或者 telnetd 进程在打开终端设备之前调用setsid 创建新的session, 该进程叫Session Leader, 该进程的id 也可以看作session 的id; 然后该进程打开终端设备作为这个Session 中所有进程的控制终端。
2. 在登录过程中，getty 或者telnetd 进程变成login, 再变成shell, 但是仍然是同一个进程，即Session Leader.
3. shell 进程fork 出的子进程，拷贝了相同的session、进程组和控制终端，
但是shell 调用setpid 函数将作业中的某个子进程指定为一个新的进程组的Leader. 然后调用setpgid 将其它子进程也转移到这个进程组中。
如果这个进程组需要在前台运行，就调用tcsetpgrp 函数将它设置为前台进程组，由于一个Session 只能有一个前台进程组，所以shell 当前进程组就变成后台进程组了。

在上例中，proc3~5 组成一个前台进程组，其中有一个进程是该进程组的Leader, shell 调用wait 等待它们运行结束。一旦它们全部运行结束，shell 就调用tcsetpgrp 函数将自己提到前台继续接受命令。
如果前台进程组产生了一个新的子进程proc6, 这个子进程也属于该前台进程组，但是shell 并不知道该子进程， 也不会wait 该子进程。
也就是说proc1 | proc2 | proc3 是shell 的作业，而子进程不是. 所以作业和进程组是有区别的，作业一结束，shell 就把自己提到前台，如果原来的前台进程组还存在，它就自动变成后台前台组。

	ps -o pid,ppid,pgrp,session,tpgid,comm | cat
	  PID  PPID  PGRP  SESS TPGID COMMAND
	15301 15299 15301 15301 15333 zsh
	15333 15301 15333 15301 15333 ps
	15334 15301 15333 15301 15333 cat

在以上例子中，可以看出：
1. 从ppid 看出zsh 是两个子进程的父进程
1. 从PGRP 看出zsh 是属于一个进程组，ps/cat 属于另外一个进程组(ps 这进程组的Leader)
1. 从SESS 看出三个进程属于同一个Session(zsh 是Session Leader)
1. 从TPGID 看出前台进程组的id 是15333, 也就是ps/cat 所在进程组id 位于前台

	ps -o pid,ppid,pgrp,session,tpgid,comm | cat &
	[1] 15398 15399
	  PID  PPID  PGRP  SESS TPGID COMMAND
	15301 15299 15301 15301 15301 zsh
	15398 15301 15398 15301 15301 ps
	15399 15301 15398 15301 15301 cat

换一个执行后台作业的例子：
1. [1] 代表的是后台作业号
2. 从TPGID 可看出前台进程组属于15301, 这个组只包括一个进程，即zsh

## 与作业控制有关的信号
1. SIGTSTP 信号，默认动作是进程停止（Ctrl-Z 会触发此信号）,这个信号处理动作是不可自定义的
1. SIGCONT 信号，使进程继续运行（fg bg 都会使得进程收到此信号）
1. SIGTTIN 信号，默认动作是使进程停止，后台进程组中的进程读取标准输入时，会收到此信号，比如cat &
1. SIGTTOU 信号，默认动作是使进程停止，后台进程向标准(错误)输出时，会收到此信号, 仅当终端被设置为禁止后台进程写(stty tostop) 才会触发此信号产生
1. SIGTERM信号, 默认动作是终止进程，但是已经停止的进程不会立即处理此信号，只有当进程重新运行前才处理此信号
1. SIGKILL信号，该信号即不能被阻塞，也不能被忽略，也不能自定义处理动作，该信号得得进程被终止

SIGTSTP 和 SIGKILL 信号都不能设置自定义处理函数，这保证了管理员在怀疑进程有问题时，准确的停止或者终止进程。

### 与作业控制相关的命令
	fg %jobN 将指定的后台进程组切换到前台, 进程组中的每个进程发送SIGCONT 信号，使得进程继续执行
	bg %jobN 向指定的后台进程组中的每个进程发送SIGCONT 信号，使得进程继续执行
	Ctrl-Z 将当前的前台进程组切换为后台进程组(shell 本身除外), 进程组中每个进程都会收到SIGTSTP 该信号默认动作是使进程停止
	jobs 查看所有作号信息

### 后台进程读写标准输入与标准输出
如果后台作业试图读取标准输入，内核会向其发送SIGTTIN 信号，该信号的默认处理动作是使进程停止。

	$ cat &
	[1] 15659
	[1]  + 15659 suspended (tty input)  cat
	
用fg 将cat 作业提到前台运行后，cat 将挂起等待终端输入，每一次回车后，cat 回显后又会继续挂起。直到使用Ctrl-Z， 使cat 进程收到SIGTSTP 而停止，并且进程切换到后台

	$ fg %1
	[1]  + 15659 continued  cat
	hello
	hello
	^Z
	[1]  + 15659 suspended  cat

此时如果用bg %1 给作业进程组中的每个进程发送SIGCONT 信号，进程又开始运行了. 可是当后台cat 试图读取标准输入时，又会收到SIGTTIN 信号而停止

	$  bg %1
	[1]  + 15659 continued  cat
	[1]  + 15659 suspended (tty input)  cat

默认后台进程是被允许直接输出数据到标准输出的，但是这会干扰前台shell的输出，此时可以用终端选项`stty tostop`禁止后台进程写数据，此时后台进程会收到SIGTTOU 信号而停止

	➜  ~  cat a.txt &
	[1] 15939
	aa
	[1]  + 15939 done       cat a.txt
	➜  ~  stty tostop
	➜  ~  cat a.txt &
	[1] 15949
	[1]  + 15949 suspended (tty output)  cat a.txt

### 终止后端进程
向一个已经停止的后台进程发送SIGTERM, 后台进程不会立即终止，它只能能重新运行前处理终止信号。向后台进程发送SIGKILL 信号会使得进程被立即终止

	➜  ~  kill 15659
	➜  ~  ps
	  PID TTY          TIME CMD
	15301 pts/3    00:00:00 zsh
	15659 pts/3    00:00:00 cat
	15842 pts/3    00:00:00 ps
	➜  ~  kill -KILL 15659
	[1]  + 15659 killed     cat

# 守护进程
linux 系统启动时，会启动很多系统服务进程，比如上文讲到的inetd(Interface Super-Server Daemon), 这些系统服务进程没有控制终端，不可以和用户直接交互。其它进程则是在用户登录是创建，在运行结束或用户注销时终止，是临时的。但系统服务进程不受用户登录注销的影响，因为它们一直运行着，所以也叫守护进程（Daemon Process）

用ps ajx 查看一下守护进程:
1. a 列出当前用户和其它用户的进程，
2. x 列出有控制终端的进程和无控制终端的进程
3. j 列出与作业控制相关的信息

	$ ps axj
	 PPID   PID  PGID   SID TTY      TPGID STAT   UID   TIME COMMAND
		0     1     1     1 ?           -1 Ss       0   0:01 /sbin/init
		0     2     0     0 ?           -1 S<       0   0:00 [kthreadd]
		2     3     0     0 ?           -1 S<       0   0:00 [migration/0]
		2     4     0     0 ?           -1 S<       0   0:00 [ksoftirqd/0]
	...
		1  2373  2373  2373 ?           -1 S<s      0   0:00 /sbin/udevd --daemon
	...
		1  4680  4680  4680 ?           -1 Ss       0   0:00 /usr/sbin/acpid -c /etc
	...
		1  4808  4808  4808 ?           -1 Ss     102   0:00 /sbin/syslogd -u syslog

解释一下以上进程信息：
1. TPGID 为-1 的都是没有控制终端的进程，也就是Daemon 守护进程。
1. 在COMMAND 中有`[]`括起来的名字表示内核线程，这些线程在内核中创建，没有用户空间代码，因此没有程序文件名和命令行.通常以k打头的表示kernel. udevd负责维护/dev, acpid 负责电源管理，syslogd 负责维护/var/log下的日志

## 创建守护进程
创建守护进程的关键是调用setsid函数创建一个新的Session，并成为Session Leader。

	#include <unistd.h>
	pid_t setsid(void);
	//成功返回pid, 出错返回-1

调用这个函数前，当前进程不允许是进程组的Leader, 否则函数会返回-1. Leader 可以通过fork 子进程，再间接调用setsid 创建守护进程

成功调用setsid 的结果是：
1. 创建一个新的Session Leader, 当前进程的id 就是Session 的id
2. 创建一个新的进程组，当前进程id 就是新进程组的Process Group Leader
3. 如果当前进程原本有一个控制终端，则它会失去这个控制终端。所谓的失去控制终端是指，原来的控制终端仍然是打开的，仍然可以读写，但只是一个普通的打开文件，而不是控制终端了。

	#include <stdlib.h>
	#include <stdio.h>
	#include <unistd.h>
	#include <fcntl.h>
	void daemonize(){
		pid_t pid;
		pid = fork();
		if(pid <0){
			perror("fork error");
			exit(1);
		}else if(pid !=0 ){//parent
			exit(0);
		}
		pid = setsid();
	
		/*
		 * Change the current working directory to the root.
		 */
		if (chdir("/") < 0) {
			perror("chdir");
			exit(1);
		} 
	
		//close fd 0
		close(0);
		open("/dev/null", O_RDWR);//new fd 0
		dup2(0, 1);
		dup2(0, 2);
	
	}
	int main() {
		daemonize();
		while(1);
		return 0;
	}

创建守护进程后，主要做了两个工作：
1. 将当前目录切换到根目录
2. 将标准输入0, 标准输出1, 标准错误输出2 重定向到/dev/null

Linux 也提供了一个daemon(3) 函数实现daemonize 的功能，它带有两参数指示是否切换到根目录 以及是否要将fd 012 定向到/dev/null

运行a.out 时，它不受用户登录注销影响：

	$ ps x |grep a.out
	 4321   ??  Ss     0:00.00 ./a.out
	$ ps xj |grep a.out
	hilojack  4321     1  4321      0    0 Ss     ??    0:00.00 ./a.out
	$ kill 4321
	$ ps xj |grep a.out

# 参考
- [linux c terminal]

[linux c terminal]: http://akaedu.github.io/book/ch34.html