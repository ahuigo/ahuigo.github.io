---
layout: page
title:	linux c 信号
category: blog
description: 
---
# Preface
信号处理的一个经典场景:
1. shell 启动一个进程
2. 用户按下ctrl+c 键盘产生一个硬件中断
3. 如果cpu 正在执行这个进程的代码, 则暂停这个进程，cpu 从用户态切换到内核态 处理这个硬件中断
4. 内核态的终端处理程序将ctrl-c 解析为一个SIGINT 信号，记录到进程的PCB 中（也可以说是向进程发送了一个SIGINT 信号）
5. 然后cpu 从内核态切换到进程态前，会检查到PCB 有无待处理的信号。本例中，cpu 会发现PCB 中有一个SIGINT 信号， 这个信号默认是终止程序执行，不必再返回用户空间

关于ctrl-c 产生的int 中断: 
它只影响shell 前台进程(不带&, shell 被wait waitpid 所阻塞); 不影响shell 后台进程(带&)

# 信号与进程的关系:
1. 它们是异步的(Asynchronous)

# 信号定义与分类
kill -l 查看系统定义的信号列表:

> 1) SIGHUP       2) SIGINT       3) SIGQUIT      4) SIGILL
 5) SIGTRAP      6) SIGABRT      7) SIGBUS       8) SIGFPE
 9) SIGKILL     10) SIGUSR1     11) SIGSEGV     12) SIGUSR2
13) SIGPIPE     14) SIGALRM     15) SIGTERM     16) SIGSTKFLT
17) SIGCHLD     18) SIGCONT     19) SIGSTOP     20) SIGTSTP
21) SIGTTIN     22) SIGTTOU     23) SIGURG      24) SIGXCPU
25) SIGXFSZ     26) SIGVTALRM   27) SIGPROF     28) SIGWINCH
29) SIGIO       30) SIGPWR      31) SIGSYS      34) SIGRTMIN
35) SIGRTMIN+1  36) SIGRTMIN+2  37) SIGRTMIN+3  38) SIGRTMIN+4

这些信号的宏定义位于signal.h, 编号34 以上的是实时信号，34以下的为非实时信号.

1. Ctrl-c发送SIGINT(2)(这在Python中其实被封装成了KeyboardInterrupt异常)，
2. `Ctrl-\`发送SIGQUIT，
3. Ctrl-Z 产生SIGTSTP
4. kill pid 则是SIGTERM(15)
5. SIGCHLD: 进程退出，向父进程发出SIGCHLD (chldhandler)
6. SIGTTIN 当后台进程读tty时，tty将发送该信号给相应的进程组，默认行为是暂停进程组中进程的执行
7. SIGCONT: `kill -SIGCONT PID`: Send a continue signal To continue a stopped process via PID
8. SIGHUP: 当tty的另一端挂掉的时候，比如ssh的session断开了，
    1. 于是sshd关闭了和ptmx关联的fd，内核将会给和该tty相关的所有进程发送SIGHUP信号，进程收到该信号后的默认行为是退出进程。
    2. see: linux-nohup.md
9. SIGTSTP: 输入CTRL+Z时，tty收到后就会发送SIGTSTP给前端进程组，其默认行为是将前端进程组放到后端，并且暂停进程组里所有进程的执行。(Terminal Stop)
10. SIGSTOP: `kill -SIGSTOP pid` cannot be ignored. SIGTSTP might be.
11. SIGKILL: cannot be ignored

其中有些信号是不可被忽略的, 但无论是否可忽略，handler 依然可以执行:
1. SIGKILL=9和SIGSTOP = 17这种是不可忽略的。这就是为什么程序卡死的时候按Ctrl-z之后再kill比按Ctrl-c好使的原因了。

# 信号的产生与处理

signal(7) 有对signal 产生条件和默认动作 的说明：

	Signal     Value     Action   Comment
	-------------------------------------------------------------------------
	SIGHUP        1       Term    Hangup detected on controlling terminal
								  or death of controlling process
	SIGINT        2       Term    Interrupt from keyboard
	SIGQUIT       3       Core    Quit from keyboard
	SIGILL        4       Core    Illegal Instruction

## signal generation, 信号的产生
一般地，信号产生的主要条件有:

1. 从终端按下特殊键时，终端驱动程序会发送信号给前台进程：ctrl-C 产生 SIGINT ，Ctrl-\ 产生SIGQUIT, Ctrl-Z 产生SIGTSTP
2. 硬件异常产生信号，由硬件检测到并通知内核： 除0 异常产生SIGFPE; 非法访问内存地址，MMU 产生SIGSEGV 信号(段错误)
3. kill(2) 函数将信号发送给进程
4. kill(1) 调用kill(2) 发送信号，默认会发送SIGTERM 终止进程信号
5. 内核检测到软件设定的条件发生时，产生信号: 如闹钟超时产生SIGALRM, 向读端关闭的管道写数据时产生SIGPIPE 信号

### 通过键盘产生
从终端按下特殊键时，终端驱动程序会发送信号给前台进程：ctrl-C 产生 SIGINT ，Ctrl-\ 产生SIGQUIT, Ctrl-Z 产生SIGTSTP

### 调用系统函数向进程发送信号
使用kill(1) 或者 kill(2)/raise(2)向进程发送信号. 比如：

	➜  test  ./a.out &
	[1] 9973
	➜  test  kill -SIGSEGV 9973; # 也可以写作kill -11 9973
	➜  test
	[1]  + 9973 segmentation fault  ./a.out

signal 库提供了很多向进程发送信号的函数：成功返回0， 错误返回-1
1. kill 向指定进程发送信号;
2. raise 向当前进程发送信号; 

	#include <signal.h>
	int kill(pid_t pid, int signo);
	int raise(int signo);

c 系统库提供了abort 函数，它向当前进程发送SIGABRT 信号（当前进程终止）, 它和exit 函数一样，总会成功，没有返回值。

	#include <stdlib.h>
	void abort(void);

### 软件产生信号
SIGPIPE 是一种由软件产生的管理信号。此外，还有alarm 函数产生的SIGALRM 信号

	#include <unistd.h>
	unsigned int alarm(unsigned int seconds);
	//The return value of alarm() is the amount of time left on the timer from a previous call to alarm().  If no alarm is currently set, the return value is 0.

它用于告诉内核seconds 秒后给当前进程发SIGALRM 信号(信号与进程是异步的)，此信号默认的动作是终止当前进程(可用来防进程超时)。 此函数返回值是0, 或者前设定时钟的剩余秒数。

例子，通过alarm() 看下进程一秒内大概能数多少个数字

	#include <stdio.h>
	#include <unistd.h>
	int main(void) {
		//1 秒后产生SIGALRM 信号
		alarm(1);
		long i=0;
		while(1) printf("%ld ", i++);
	}

## 信号的处理动作
信号的默认处理动作是:

1. Term 终止当前的进程
1. Core 终止当前的进程 并且 Core Dump(进程被终止时，用户空间的内存数据全部都会被保存到磁盘上的core 文件。事后可以用调试检查器检查core 文件以理清错误原因，这叫做Post-mortem Debug)
1. Ign 忽略
1. Cont 继续先前停止的进程

可以通过调用sigaction(2) 告诉内核 信号对应的处理动作，主要有三种:

1. 默认处理动作
2. 忽略
3. 提供自定义的处理函数(信号处理时，cpu 要从内核态切换到用户态 并执行这个自定义函数), 这种方式称为捕获(Catch) 一个信号

### 关于Core
Core 动作默认是不允许产生core 文件的， 可以通过ulimit 允许产生core 文件; 一个进程产生的core 大小取决于进程的Resource Limit(这个信息保存在PCB 中)

用ulimit 改变shell 进程的Resource Limit 为1024K, 子进程会继承这个设置：

	$ ulimit -c 1024

产生Core Dump:

	$ ./a.out
	（按Ctrl-C）
	$ ./a.out
	（按Ctrl-\）Quit (core dumped)
	$ ls -l core*
	-rw------- 1 akaedu akaedu 147456 2008-11-05 23:40 core

# 信号阻塞
信号有三个状态：
1. Signal Generation(信号产生)， 
2. 信号产生后信号就处于未决状态, Signal Pending(信号未决)， 
3. 信号阻塞, 用于保持未决状态
3. 进程正式处理信号, Signal Delivery(信号递达，信号的处理动作).

信号产生后会保持在Pending 状态，进程处理信号时可以选择阻塞信号(让信号继续保持在未决状态). 信号阻塞与信号忽略是不同的，信号忽略是信号递达(Delivery) 后的一种动作，而信号阻塞使信号继续保持在Pending 状态。

*信号在内核中的表示*
信号是存放于内核中task_struct 中进程控制块中的一个信号集: 每个信号有block 阻塞标志位，pending 标志位， handler 指针. 

信号在内核中的示意图:
![](/img/linux-c-signal-memory.png)

信号产生时，内核在进程控制块中设置该信号的未决标志(Pending)，直到信号递达(Delivery)时才清除该标志. 在上图中：
1. SIGHUP 信号未阻塞，也未产生
1. SIGINT 信号阻塞，且已产生，当信号递达时，处理动作是忽略（Pending 仍然保持）
2. SIGQUIT 信号是阻塞，但未产生，一旦信号产生它将保持在未决状态(阻塞)，它的处理动作是用户空间的函数sighandler.

如果进程解除对某个信号的阻塞之前*这种信号产生多次*怎么办？
POSIX.1 允许信号产生多次。linux 的实现是：
1. 常规信号在递达之前产生多次的话，只计一次(参考以上信号在内核中表示的示意图)；
2. 实时信号在递达之前产生多次可以依次放在一个队列里面(不在本文讨论范围)

上图中的常规信号中，每个信号的阻塞和产生标志位用相同的数据类型 sigset_t 来存储，sigset_t 称为信号集，用于表示“有效”和“无效”两种状态。其中阻塞信号集也叫当前进程的信号屏蔽字（Signal Mask）.

## 信号集操作函数
sigset_t类型对于每种信号用一个bit表示“有效”或“无效”状态，至于这个类型内部如何存储这些bit则依赖于系统实现，从使用者的角度是不必关心的，使用者只能调用以下函数来操作sigset_t变量，而不应该对它的内部数据做任何解释，比如用printf直接打印sigset_t变量是没有意义的。

	#include <signal.h>
	int sigemptyset(sigset_t *set);//初始化set 指向的信号集，使得其中所有的bit 清0, 表示该信号集不含任何有效信号。
	int sigfillset(sigset_t *set);//使set 指向的信号集中所有的位置1， 表示该信号集的有效信号支持系统所有的信号。
	int sigaddset(sigset_t *set, int signo);//在信号集中添加某有效信号
	int sigdelset(sigset_t *set, int signo);//在信号集中删除某有效信号
	//以上函数成功返回0，失败则返回-1

	int sigismember(const sigset_t *set, int signo);//判断signo 是否为set 集中的有效信号。
	//包含则返回1 不包含则返回0，出错则返回-1

> Note: 在使用sigset_t 信号集之前，一定要调用sigemptyset/sigfillset 做初始化, 使得信号集处于确定的状态

## sigprocmask
调用函数sigprocmask可以读取或更改进程的信号屏蔽字：

	#include <signal.h>
	int sigprocmask(int how, const sigset_t *set, sigset_t *oset);
	//成功返回0， 失败返回-1
		*oset
			如果oset 为非空指针，则读取当前进程的信号屏蔽字, 并用oset 传出
		*set
			如果set 为非空指针，则修改当前进程的信号屏蔽字，参数how 指示如何修改。
		如果oset 与 set 都为非空，则先将原来的信号屏蔽字备份到oset, 然后根据set与how 修改信号屏蔽字。

假设当前进程的信号屏蔽字为mask, 下表则说明了how 参数的可选值：

	SIG_BLOCK
		set包含了我们希望添加到当前信号屏蔽字的信号,相当 于mask=mask|set
	SIG_UNBLOCK
		set包含了我们希望从当前信号屏蔽字中解除阻塞的信号,相当 于mask=mask&~set
	SIG_SETMASK
		设置当前信号屏蔽字为set所指向的值,相当于mask=set

如果调用sigprocmask解除了对当前若干个未决信号的阻塞,则在sigprocmask返回前,至少将其 中一个信号递达(内核态返回用户态时，会检查并处理信号)

## sigpending
sigpending读取当前进程的未决信号集,通过set参数传出。调用成功则返回0,出错则返回-1

	#include <signal.h>
	int sigpending(sigset_t *set);

例子，阻塞SIGINT:

	#include <signal.h>
	#include <stdio.h>
	#include <unistd.h>
	void printsigset(const sigset_t *set) {
		int i;
		for (i = 1; i < 32; i++)
			if (sigismember(set, i) == 1)
				putchar('1');
			else
				putchar('0');
		puts("");
	}
	
	int main(void) {
		sigset_t s, p;
		sigemptyset(&s);
		sigaddset(&s, SIGINT);
		//阻塞s中的有效信号：即 SIGINT
		sigprocmask(SIG_BLOCK, &s, NULL);
		while (1) {
			//取出未决信号集
			sigpending(&p);
			//打印未决信号集
			printsigset(&p);
			sleep(1);
		}
		return 0;
	}

执行以上代码时，每秒钟都会打印一次未决信号集；ctrl-c 不生效的原因是SIGINT 被阻塞，阻碍用SIG_UNBLOCK 解除阻塞

	$ ./a.out 
	0000000000000000000000000000000
	0000000000000000000000000000000（这时按Ctrl-C）
	0100000000000000000000000000000
	0100000000000000000000000000000（这时按Ctrl-\）
	Quit (core dumped)

# 信号捕获

## 内核如何捕获信号
如果信号的处理动作是自定义函数，在信号递达时内核就会调用这个自定义的函数。举例如下：
1. 用户注册了SIGQUIT 信号的处理函数为sighandler
2. 当前正在执行main 函数，这里发生中断或异常切换到内核态 (比如按下CTRL-\)
3. 中断处理完毕后要返回用户态的main 之前检查到有信号SIGQUIT 递达
4. 内核决定返回用户态时执行sighandler, 而不是返回main 的上下文. sighandler 和 main 函数使用不同的堆栈空间，它们不存在调用和被调用的关系，是两个独立的控制流程。
5. sighandler 返回后自动执行sigreturn 系统调用，再次进入内核态
6. 如果没有信号递达，就再返回用户态恢复main 函数的上下文

![](/img/linux-c-signal-catch.png)

### signal 函数捕获
    signal(SIGINT, sig_handler)

signal 示例

    gcc -v  process/signal/sig-handler.c -I $SCADDRESS/include/ -L $SCADDRESS/lib/ -lapue

## sigaction
sigaction 用于读取与修改指定信号关联的处理动作。成功返回0， 失败返回-1.

	#include <signal.h>
	int sigaction(int signo, const struct sigaction *act, struct sigaction *oact);

	params:
		signo 信号
		act,oact
			act 为非空时, 则根据act 修改关联动作
			oact 为非空时， 输出原有的关联动作

sigaction 结构体：

	struct sigaction {
	   void      (*sa_handler)(int);   /* addr of signal handler, */
										   /* or SIG_IGN, or SIG_DFL */
	   sigset_t sa_mask;               /* additional signals to block */
	   int      sa_flags;              /* signal options, Figure 10.16 */

	   /* alternate handler */
	   void     (*sa_sigaction)(int, siginfo_t *, void *);
	};

sigaction 结构体中sa_handler 的含义是：
1. sa_handler 如果为常数 SIG_IGN 表示忽略信号
1. sa_handler 如果为常数 SIG_DFL 表示使用默认系统动作
1. sa_handler 如果为指针, 表示向内核注册了一个信号处理函数, 可以传一个int 参数（信号编号），这样同一样函数就可以处理多个信号了

sa_mask 的含义是, 当信号处理函数被调用时：
1. 该信号被自动加入信号屏蔽字，当信号处理函数返回时自动恢复原来的信号屏蔽字（这保证了处理某种信号时，如果该信号再次产生，它将被阻塞到处理函数结束）
2. 如果希望在处理函数调用期间，屏蔽其它信号, 则用sa_mask 字段说明额外屏蔽的信号，处理函数结束时自动恢复屏蔽关键字。

sa_flags 包含一些选项，本文将sa_flags 设置为0；sa_sigaction 是实时处理函数。本书不详细解释这两个字段。

## pause

	#include <unistd.h>
	int pause(void);

pause 使信号挂起，直到有信号递达（这类似于sleep 使进程休眠，直到有时间到达）.
1. 如果信号处理动作是终止进程，则pause 没有机会返回
1. 如果信号处理动作是忽略，则进程继续挂起, pause 不返回
1. 如果信号处理动作是捕捉，则调用信号处理函数后，pause 返回-1, errno 设置为ENTER(表示被信号中断)。所以pause 只有错误的返回值

可以用alarm 与 sleep 实现sleep:

	#include <signal.h>
	#include <stdio.h>
	#include <unistd.h>
	
	void sig_alarm(int a){ } //执行此函数时SIGALRM 信号被屏蔽, 函数结束后解除对该信号的屏蔽。然后调用sig_return 再次进入内核，再返回用户碰碰继续执行主程序
	
	unsigned int mysleep(int s){
		struct sigaction newact, oldact;
		unsigned int unslept;

		//add sigaction
		newact.sa_handler = sig_alarm;
		sigemptyset(&newact.sa_mask);
		newact.sa_flags = 0;
		sigaction(SIGALRM, &newact, &oldact);
	
		alarm(s);//s 秒之后，闹钟超时，内核发SIGALRM给这个进程。	
		pause();//也可能是非SIGALRM 信号触发pause 终止，导致unslept 时间大于0
	
		//recovery
		sigaction(SIGALRM, &oldact, NULL);

		//return
		unslept = alarm(0);
		return unslept;
	}
	int main(){
		mysleep(3);
	}

## 可重入函数 reentrant function
信号处理函数 和 主程序的控制流程是相互独立的，二者是异步的，不存在调用与被调用的关系，并且二者使用不同的堆栈空间。引入信号处理函数后，使用进程拥有多个控制流程。这会导致访问全局资源时，出现冲突。比如下图中，两函数同时操作链表时，出现混乱：

![](/img/linux-c-signal-reentrant.png)

上例中，insert 函数执行还没有返回时，就被别的控制流程再次调用，这称为重入（reentrant）.insert 访问全局链表时，可能因为重入而造成混乱，这样的函数被称为不可重入函数. 反之，如果一个函数在只访问自己的局部资源，则这样的函数就叫可重入函数（Reentrant function）

不可重入函数满足：
1. 调用了malloc 或 free, 因为malloc 是用全局链表来管理维护的堆的。
2. 调用了标准I/O 函数。因为标准I/O 函数都是以不可重入的方式使用的全局数据结构。

> SUS规定有些系统函数必须以线程安全的方式实现（暂不详述）

> 线程会讲到如何保证一个代码段以原子操作完成

## sig_atomic_t 与 volatitle 限定符
上面的例子中，main 和 sighanler 同时调用insert 函数时，导致链表错乱。根本原因时，链表的插入操作分两步完成，而非原子操作（线程节会讲解如何保证一个代码段以原子操作完成）

考虑一个问题，如果函数只有一行赋值操作，这个操作是不是原子型的呢？

	long long a;
	int main(){
		a=5;
	}

使用32位机编译后的结果是

	objdump -dS a.out 
		a=5;
	 8048352:       c7 05 50 95 04 08 05    movl   $0x5,0x8049550
	 8048359:       00 00 00 
	 804835c:       c7 05 54 95 04 08 00    movl   $0x0,0x8049554
	 8048363:       00 00 00

赋值语句被分成了两条汇编语句，因为32位的系统单条语句只能处理32位的数据。这种单条语句在32位机器中不是原子操作(main, sighandler 同是操作a 会产生错乱)，但是在64位机器上却是原子操作。

为了保证各平台中, 程序对变量的读写是原子性的，c 标准定义了一个类型sig_atomic_t, 在不同平台的c 语言库中选择不同的类型。例如在32位平台机上定义sig_atomic_t 为int 类型(也就是说变量可能是32位，也可能是64位)

即使使用sig_atomic_t ，编译器做优化时也不会考虑对多个控制流程对全局变量的读写。比如：

	sig_atomic_t a=0;
	int main(void) {
		/* register a sighandler */
		while(!a); /* wait until a changes in sighandler */
		/* do something after signal arrives */
		return 0;
	}

编译后的反汇率代码如下，当信号处理函数将a修改为1时，循环就跳出。

	/* register a sighandler */
	while(!a); /* wait until a changes in sighandler */
	 8048352:       a1 3c 95 04 08          mov    0x804953c,%eax
	 8048357:       85 c0                   test   %eax,%eax //对eax和eax做AND运算，若结果为0则跳回循环开头
	 8048359:       74 f7                   je     8048352 <main+0xe>

如果gcc 在编译过程中做的优化（默认认为a的值不可变）,编译的结果如下。 先将a 同0 比较，如果相同，就在第二句死循环了

	8048352:       83 3d 3c 95 04 08 00    cmpl   $0x0,0x804953c
	/* register a sighandler */
	while(!a); /* wait until a changes in sighandler */
	8048359:       74 fe                   je     8048359 <main+0x15>

这是因为编译器认为没有其它控制流程修改a, 误认为a 值不可变的。这不是编译器的错，sigaction, pthread, pthread_create 这些控制流程都不是c 语言的规范，不归编译器管。不过，c 语言提供了volatile 限定符，表示*这个变量可能被多个执行流程修改，优化时不能将变量的读写优化掉*.

	volatile sig_atomic_t a=0;

下列情况也是需要加sig_atomic_t:
1. 内存单元不需要写操作(只读不写)，就可以自己变化（如串口的接收寄存器）
1. 内存单元不需要读操作(只写不读)，但会被其它的机制读取（如串口的发送寄存器）

> sig_atomic_t 总是要加上volatile 限定符的。因为两者都是为了防止全局资源在多控制流程下出现冲突。

# 竞态条件(Race Condition)与sigsuspend 函数
现在为mysleep 设想这样一种时序
1. 首先为SIGALRM 设置自定义的信号处理函数
1. alarm(nsecs) 设置了nsecs 秒后进程收到 SIGALRM 信号
2. 假设此时比较倒霉，这时内核调度到其它优先级比较高的进程，而且这些进程需要执行很长的时间, 超过nsecs 秒
3. 经过nsecs 秒后, 内核向该进程发送SIGALRM, 信号处于未决状态
4. 又经过一些时间，优先级高的进程总算执行完了，内核调度到该进程. 此时检查到未决信号SIGALRM, 开始执行信号处理函数。
5. 信号处理函数结束后，再次进入内核，然后才回到主进程, 调用pause()挂起等待。
6. 因为SIGALRM 信号已经被处理了，再挂起pause 有什么用呢？？

出现这个问题的原因是设置信号函数alarm(nsecs)与设置信号作用点pause(), 二者不是原子性的，可能导致执行pause时，alarm 所设定的超时信号已经提前结束了。
这种由于时序问题而导致的错误叫作竞态条件(Race Condition).

考虑一下解决方案1：
1. 屏蔽SIGALRM信号;
1. alarm(nsecs);
1. 解除对SIGALRM信号的屏蔽;
1. pause();

这个方案还无法避免 解除信号 到 pause 过程中发生SIGALRM

方案2 呢？更不行了，解除信号在pause 之后，SIGALRM 信号永远被阻塞了:

1. 屏蔽SIGALRM信号;
1. alarm(nsecs);
1. pause();
1. 解除对SIGALRM信号的屏蔽;

如果将解除屏蔽信号 与 pause 合并为原子操作就发好了？那就是sigsuspend 函数了:
挂起时，指定要临时解除的屏蔽信号. 它的返回与pause 是一样的. 返回时，恢复原来的信号屏蔽字

	#include <signal.h>
	int sigsuspend(const sigset_t *sigmask);

考虑到Race Condition 后，重新实现mysleep :

	unsigned int mysleep(unsigned int nsecs) {
		struct sigaction    newact, oldact;
		sigset_t            newmask, oldmask, suspmask;
		unsigned int        unslept;

		/* set our handler, save previous information */
		newact.sa_handler = sig_alrm;
		sigemptyset(&newact.sa_mask);
		newact.sa_flags = 0;
		sigaction(SIGALRM, &newact, &oldact);

		/* block SIGALRM and save current signal mask */
		sigemptyset(&newmask);
		sigaddset(&newmask, SIGALRM);
		sigprocmask(SIG_BLOCK, &newmask, &oldmask);

		alarm(nsecs);

		suspmask = oldmask;
		sigdelset(&suspmask, SIGALRM);    /* make sure SIGALRM isn't blocked */
		sigsuspend(&suspmask);            /* wait for any signal to be caught */

		/* some signal has been caught,   SIGALRM is now blocked */

		unslept = alarm(0);
		sigaction(SIGALRM, &oldact, NULL);  /* reset previous action */

		/* reset signal mask, which unblocks SIGALRM */
		sigprocmask(SIG_SETMASK, &oldmask, NULL);
		return(unslept);
	}

## 关于SIGCHLD信号
我在[](/p/c-process) 进程中提及过，wait和waitpid函数清理僵尸进程.

1. 父进程阻塞等待子进程结束
2. 父进程非阻塞，定时轮询子进程状态，子进程一旦结束就收尸

其实子进程在结束时，会向父进程发送SIGCHLD 信号，父进程可以：

1. 为SIGCHLD 绑定信号处理函数，由信号处理函数调用wait 收尸
2. 由于UNIX历史原因, 父进程也可以调用sigaction 将SIGCHLD 处理动作设置为SIG_IGN, 这样子进程终止时会自动清理掉，不会产生僵尸进程，也不会通知父进程。系统默认的忽略动作和用户用sigaction 定义的忽略是没有区别的，但这一个SIG_IGN是特例。此方法对linux 可用，但不保证在所有的UNIX 上可用。

# 参考
[linux c signal]

[linux c signal]: http://akaedu.github.io/book/ch33.html
