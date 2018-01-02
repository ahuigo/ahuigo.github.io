---
layout: page
title:	linux c 线程
category: blog
description:
---
# Preface
每个进程在自己独立的地址空间运行，进程间共享数据需要通过nmap 或者 进程间通信机制。
而线程可以*一个进程的地址空间内执行多个控制流程*。有些情况下需要一个进程执行多个控制流程，比如下载软件用多个线程实现同时下载多个文件，同时用一个线程要处理用户的键盘鼠标事件.

# 同步 异步 阻塞 协程
https://www.zhihu.com/question/19732473
<Unix 网络编程>

- 同步异步: (synchronous/synchronous communication) 关注的是*调用内核* 本身的*返回消息*机制; 直接返回信息, 就同步; 以*回调的方式*返回信息就是异步
- 阻塞(blocking): 关注的是*调用者* 本身, 它在等待消息的过程中是*blocking*, 还是*unblocking* 做其它事

    同步: 有四类, 共同点是从内核copy 到用户进程都是阻塞同步的, 这是从内核层面来看的
        阻塞IO: recv/read 等待返回
        非阻塞IO: 立即返回, 但自己检查描述符
        IO multiplexing(select/poll/epoll): 同时监视多个描述符, 同一描述符IO还是阻塞的
            epoll是同步的。属于IO多路复用的一种, IO多路复用叫做事件驱动，和异步的概念比较相似
            epoll是通过中断来通知io事件的到来, 但去取数据的那一段, 也就是recvfrom 是同步
        信号驱动(SIGIO): 不用监视描述符, 信号处理函数处理, 但同一描述符IO 上阻塞的
    异步: 内核将数据copy 到用户态后(数据已经准备喽), 才触发aio或read 指定的信号处理
        Linux(AIO), Windows(IOCP), .net(BeginInvoke/Endinvoke)

## 协程
2. 进程: 独立的栈，独立的堆，进程之间调度由os kernel完成
2. 线程: 独立的栈，共享的堆，线程之间调度由os kernel完成
2. 协程: 线程内的任务，协程之间调度由用户层控制; 它是非抢占式的，导致多任务时间片不能公平分享

并行: 利用CPU的多个核进行计算; 一般多进程/多线程(除了python GIL)都能实现多核cpu 处理

不同语言中的协程:
golang 的协程本质上是epoll; 在php 中协程是单线程内自己调度


# 线程与信号处理函数
二者都实现了在一个进程内执行多个控制流程，但是信号只能等待信号到达时触发，执行完成后就结束了。
而线程则更为灵活，随时都可以触发, 而且可以长期并存，操作系统会在各线程间做调度，这类似于进程调度

# 线程共享的堆数据
同一个进程中多个线程间会共享以下数据：

- Text Segment, Data Segment
- 全局变量
- malloc 堆
- 文件描述符表
- 每种信号的处理函数(SIG_IGN, SIG_DFL或者自定义的信号处理函数)
- 当前工作目录
- 用户id 和 组id

线程间还有一些资源是独享的：

- 线程id
- 上下文：各寄存器的值，栈指针
- 栈空间
- errno 变量
- 信号屏蔽字
- 调度优先级

本文将描述由POSIX 标准定义的POSIX thread 线程，即pthread. 在linux 上pthread 函数位于libpthread 共享库，在编译时需要加上-lpthread 选项。

# show thread

	/usr/bin/pstree $PID
	ps -e -T
	top -H -p <pid>

	$ ps aux|grep php
	USER     PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
	yexue+ 19710  3.6  0.3 972184 14000 pts/1    Sl+  16:53   0:00 php b.php

	$ ps aux -T |grep php
	USER     PID  SPID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
	yexue+ 19710 19710  1.6  0.3 972184 14000 pts/1    Sl+  16:53   0:00 php b.php
	yexue+ 19710 19712  0.0  0.3 972184 14000 pts/1    Sl+  16:53   0:00 php b.php
	yexue+ 19710 19713  0.0  0.3 972184 14000 pts/1    Sl+  16:53   0:00 php b.php

# 内核线程、轻量级进程、用户线程
http://www.cnitblog.com/tarius.wu/articles/2277.html

- 内核线程: 内核实现线程则会导致线程上下文切换的开销跟进程一样大
- 用户线程: 对引起阻塞的系统调用的调用会立即阻塞该线程所属的整个进程
- LWP: 折衷的方法是轻量级进程（Lightweight）
	轻量级线程(LWP)是一种由内核支持的用户线程。

## 线程和协程的区别：
> http://www.cnblogs.com/shenguanpu/archive/2013/05/05/3060616.html

用户态的轻量级的线程

一旦创建完线程，你就无法决定他什么时候获得时间片，什么时候让出时间片了，你把它交给了内核。
而协程编写者可以有一是可控的切换时机，二是很小的切换代价。从操作系统有没有调度权上看，协程就是因为不需要进行内核态的切换，所以会使用它，会有这么个东西。

# thread control, 线程控制

## 创建线程

	#include <pthread.h>
	int pthread_create(pthread_t *restrict thread,
		const pthread_attr_t *restrict attr,
		void *(*start_routine)(void*),
		void *restrict arg);

*返回*
成功返回0，失败返回-1 。和通常的c 库函数不同，pthread 函数都是通过返回值返回errno, 虽然每个线程提供也有一个errno, 但这只是出于兼容性的考虑, pthread 不使用它. 所以不能在线程中使用perror(3) 打印错误信息，可以先用strerror(3)把错误码转换成错误信息再打印。

*attr 参数*
这个参数用于设定线程属性，本文不具体讨论，直接置为NULL

*新的线程*

- 在一个线程中调用pthread_create 创建新的线程后，当前线程从pthread_create 返回后就继续向下执行。新的线程所执行的代码由start_routine 给出，这个函数的参数由arg 指定. start_routine 返回值为void *, start_routine 返回时这个线程就退出了
- 其它线程可以调用pthread_join 得到start_routine 的返回值，类似于父进程通过wait 得到子进程的状态。
- 新创建线程的id 被填写到thread 指向的内存单元。它不像进程id 一样是一个正整数，可以通过getpid 获得当前进程的id. 线程id 的类型是pthread_t, 它只在当前进程中是唯一的，而且它的具体数据类型在不同的系统有不同的实现，可能是一个整数，也可能是一个结构体，也可能是一个地址，所以不能直接通过printf 打印thread, 而应该使用 pthread_self(3) 获取当前线程的id


	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include <pthread.h>
	#include <unistd.h>

	pthread_t ntid;

	void printids(const char *s) {
		pid_t      pid;
		pthread_t  tid;

		pid = getpid();
		tid = pthread_self();
		printf("%s pid %u tid %u (0x%x)\n", s, (unsigned int)pid,
		       (unsigned int)tid, (unsigned int)tid);
	}

	void *thr_fn(void *arg) {
		printids(arg);
		return NULL;
	}

	int main(void) {
		int err;

		err = pthread_create(&ntid, NULL, thr_fn, "new thread: ");
		if (err != 0) {
			fprintf(stderr, "can't create thread: %s\n", strerror(err));
			exit(1);
		}
		printids("main thread:");
		sleep(1);

		return 0;
	}

以上创建线程示例的执行结果类似：

	$ gcc main.c -lpthread
	$ ./a.out
	main thread: pid 5065 tid 1907036944 (0x71ab1310) 5911000
	new thread:  pid 5065 tid 93392896 (0x5911000) 5911000

*exit 与 _exit*

任意一个线程调用了exit 或者 _exit 则整个进程的所有线程都终止，由于main 函数执行return 也会调用exit. 为了让main 退出前，保证线程已经执行结束，加了一个延时sleep(1). 这只是权宜之计，这依然不能保证1s 之内内核会调度执行main 创建的线程. 下面给出三种终止线程的方法

	exit(main(argc, argv));

exit也是libc中的函数，它首先做一些清理工作，然后调用 _exit系统调用终止进程，main函数的返回值最终被传给_exit系统调用，成为进程的退出状态.
参考[](/p/linux-c-compile)

## 终止线程
线程终止有三个办法：

1. 线程函数用return 返回（这不适用于main, main 函数return 的话，相当于调用exit，所有的线程都终止）
3. 线程调用pthread_exit 终止自己
2. 线程用pthread_cancel 终止同一个进程中的另外一个线程. 它分为同步和异步两种情况，比较复杂，不作讨论

> 通过return 或者 pthread_exit 返回的返回值，必须是全局的 或者malloc 分配的，不能是线程函数栈上的。因为线程返回值后，线程就退出了

### pthread_exit & pthread_join

	#include <pthread.h>
	void pthread_exit(void *value_ptr);

void *value_ptr 和线程函数返回值一样的用法，其它线程可以调用pthread_join 获得这个指针

	#include <pthread.h>
	int pthread_join(pthread_t thread, void **value_ptr);
	//成功返回0 失败返回错误号

调用pthread_join 时，线程将挂起等待，直到id 为thread 的线程执行终止。thread 以不同的方法终止，pthread_join 会得到不同类型的值：

1. 如果thread 线程通过return 返回, value_ptr 指向的单元里存放的是thread 返回的值
1. 如果thread 线程通过pthread_exit返回, value_ptr 指向的单元里存放的是pthread_exit 返回的值
1. 如果thread 线程被pthread_cancel 异常终止, value_ptr 指向的单元里存放的是常数PTHREAD_CANCELED

如果不需要得到线程返回值，可以给value_ptr 传NULL

	#include <stdio.h>
	#include <stdlib.h>
	#include <pthread.h>
	#include <unistd.h>

	void *thr_fn1(void *arg) {
		printf("thread 1 returning\n");
		return (void *)1;
	}

	void *thr_fn2(void *arg) {
		printf("thread 2 exiting\n");
		pthread_exit((void *)2);
	}

	void *thr_fn3(void *arg) {
		while(1) {
			printf("thread 3 writing\n");
			sleep(1);
		}
	}

	int main(void) {
		pthread_t   tid;
		void        *tret;

		pthread_create(&tid, NULL, thr_fn1, NULL);
		pthread_join(tid, &tret);
		printf("thread 1 exit code %d\n", (int)tret);

		pthread_create(&tid, NULL, thr_fn2, NULL);
		pthread_join(tid, &tret);
		printf("thread 2 exit code %d\n", (int)tret);

		pthread_create(&tid, NULL, thr_fn3, NULL);
		sleep(3);
		pthread_cancel(tid);
		pthread_join(tid, &tret);
		printf("thread 3 exit code %d\n", (int)tret);

		return 0;
	}

运行结果如下, 可以在pthread.h 中找到：#define PTHREAD_CANCELED ((void *) -1)

	$ gcc a.c ;./a.out
	thread 1 returning
	thread 1 exit code 1
	thread 2 exiting
	thread 2 exit code 2
	thread 3 writing
	thread 3 writing
	thread 3 writing
	thread 3 exit code 1

默认地，线程终止后的状态资源会保持到pthread_join 获取它。此外，还可以将线程设置为detach 状态，这样线程终止后，其所占用资源会被立即回收.

不能对一个已经处理detach 状态的线程使用pthread_join, 否则调用会返回EINVAL. 对一个尚未detach 的线程调用pthread_join 或者 pthread_detach 都可以将线程置为detach 状态.

	#include <pthread.h>
	int pthread_detach(pthread_t tid);
	//成功返回0 失败返回错误号

# 线程同步

## 互斥锁
与信号处理函数一样，线程在访问全局资源时也会遇到非原子操作导致的冲突(可重入问题). 比如两个线程要对同一个寄存器加1， 并行访问时可能会导致只加了一次.
![thread parallel](/img/linux-c-thread-parallel-conflict.png)

不可重入操作的特点时，输出不仅依赖于输入，还依赖于状态, 比如加1 依赖于状态，这个状态是寄存器原值. 访问状态和修改状态不是原子操作的话，就会导致并发冲突。

上图显示的并发冲突，在单次操作时，很难重现。如果加入printf, 它用调用write 使线程执行进入内核, 此时内核很容易调度别的线程. 如果再循环5000次，就会出现大量的并发冲突，导致最后得到的值少于10000. 比如：

	#include <stdio.h>
	#include <stdlib.h>
	#include <pthread.h>
	#include <unistd.h>

	int n = 0;
	void *thr_fn1(void *arg) {
		printf("n:%d\n", ++n);
		return (void *)1;
	}

	int main(void) {
		pthread_t   tid1, tid2;

		for(int i=0; i< 5*1e3; i++){
			pthread_create(&tid1, NULL, thr_fn1, NULL);
			pthread_create(&tid2, NULL, thr_fn1, NULL);
			pthread_join(tid1, NULL);
			pthread_join(tid2, NULL);
		}
		return 0;
	}

为了避免产生并发冲突, 线程引入了互斥锁(Mutex, Mutual Exclusion Lock ), 获得锁的线程在执行时，就不会被打断了，通过互斥锁实现了原子操作。

### 生成锁
Mutex用pthread_mutex_t类型的变量表示，可以这样初始化和销毁：

	#include <pthread.h>
	int pthread_mutex_destroy(pthread_mutex_t *mutex);
	int pthread_mutex_init(pthread_mutex_t *restrict mutex,
		   const pthread_mutexattr_t *restrict attr);
	pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

成功返回0， 失败返回错误号

pthread_mutex_init 对Mutex 做初始化，参数attr 用于设定Mutex 属性。如果用PTHREAD_MUTEX_INITIALIZER 初始化全局或者静态Mutex, 那它相当于用pthread_mutex_init 初始化时attr 为NULL

### 加锁与释锁

	#include <pthread.h>
	int pthread_mutex_lock(pthread_mutex_t *mutex);
	int pthread_mutex_trylock(pthread_mutex_t *mutex);
	int pthread_mutex_unlock(pthread_mutex_t *mutex);
	//成功返回0，失败返回错误号

一个线程调用pthread_mutex_lock 时，如果锁被其它线程占用，它将被挂起等待，直到另外一个线程调用pthread_mutex_unlock 释放Mutex, 当前线程被唤醒后试图重新加锁。只有加锁成功，当前线程才能继续执行。

如果不想线程加锁时被挂起等待，可以用`pthread_mutex_trylock`

使用Mutex锁 避免线程并发冲突:

	#include <stdio.h>
	#include <stdlib.h>
	#include <pthread.h>
	#include <unistd.h>

	int n = 0;
	void *thr_fn1(void *arg) {
		static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
		//lock
		pthread_mutex_lock(&mutex);

		for(int i=0; i< 2*1e4; i++){
			printf("n:%d\n", ++n);
		}

		//unlock
		pthread_mutex_unlock(&mutex);
		return (void *)1;
	}

	int main(void) {
		pthread_t   tid1, tid2;
		pthread_create(&tid1, NULL, thr_fn1, NULL);
		pthread_create(&tid2, NULL, thr_fn1, NULL);
		pthread_join(tid1, NULL);
		pthread_join(tid2, NULL);
		return 0;
	}

### Mutex 锁的原理
假设Mutex 锁为1 时表示锁空闲，为0 表示锁占用。那么lock / unlock 的实现伪码如下：

	lock:
		if(mutex > 0){
			mutex = 0;
			return 0;
		}else{
			//suspend;
			goto lock;
		}
	unlock:
		mutex = 1;
		唤醒其它因等待Mutex 而挂起的线程；
		return 0;

可以看到，unlock 只有一个操作，可汇编码为单条指令，它是原子性的(单个cpu 时钟内，就能执行一条完成的汇编命令)
但是lock，包含两个操作：一个是对mutex 的状态判断，一个是对mutex 状态设置。这两个操作, 有因果关系，必须合并为一个原子操作才能避免多个线程同时加锁成功。
其实，大多数汇编指令都提供了swap 或者 exchange 指令，这个指令就可以实现将:状态判断和状态设置 合并为一个原子操作。以x86 的xchg 实现lock 和 unlock:

	lock:
		movb $0, %al;
		xchgb %a1, mutex;//如果mutex 为0（被占用状态）那么交换后al 得到的是占用状态，原锁mutex 值不变（继续被占用）。
		if(al > 0){
			return 0;
		}else{
			//suspend;
			goto lock;
		}
	unlock:
		movb $1, mutex;
		唤醒其它因等待Mutex 而挂起的线程；
		return 0;

### Dead Lock 死锁
死锁有以下典型的情况：
1. 带锁线程的自己调用自己，如果线程自己调用自己就会因等待自己的锁释放而无限等待。这和递归不一样，递归是串行调用自己，根本不要锁机制。
2. 两个带锁线程AB 间的相互调用：如果线程A 获得锁lock1, 线程B 获得锁lock2. 此时线程A想获得lock2, 需要等待线程B 释放lock2, 但是线程B 又想获得锁lock1 B又等待A. 相当于AB 相互调用，相互等待对方释放锁。其实也相当于A 通过B 间接调用自己。经典的死锁问题: 5个哲学家就餐问题，就属于此类范畴(每位哲学都要等待右边的叉子释放)

有几个方法避免发生死锁：
1. 方法一是按顺序加lock1, lock2,lock3 加锁lock3 之前，必须先加lock2, 加lock2 前，必须先加lock1. 释放lock 时必须按倒序来
2. 如果确定锁的顺序比较困难，则尽量用pthread_mutex_trylock 代替 pthread_mutex_lock 以避免死锁。
3. 用串行代替并行

## Condition Variable
线程间的同步还有一个情况：
1. 进程A 需要等待一个条件成立，才执行，当条件不成立时就阻塞等待
2. 进程B 需要设置条件，当条件成立时，唤醒进程A

在pthread 库中通过条件变量(Condition Variable) 来阻塞等待一个条件，或者唤醒等待这个条件的线程。
Condition Variable 用pthread_cond_t 类型表示:

	#include <pthread.h>
	int pthread_cond_destroy(pthread_cond_t *cond);
	int pthread_cond_init(pthread_cond_t *restrict cond,
		   const pthread_condattr_t *restrict attr);
	pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
	//成功返回0，失败返回错误码

Condition Variable 与Mutex 有类似的初始化函数pthread_cond_init, 当attr 为NULL 就相当于PTHREAD_COND_INITIALIZER.

Condition Variable 的操作函数有：

	#include <pthread.h>
	int pthread_cond_timedwait(pthread_cond_t *restrict cond,
		   pthread_mutex_t *restrict mutex,
		   const struct timespec *restrict abstime);
	int pthread_cond_wait(pthread_cond_t *restrict cond,
		   pthread_mutex_t *restrict mutex);
	int pthread_cond_broadcast(pthread_cond_t *cond);
	int pthread_cond_signal(pthread_cond_t *cond);

Condtion Variable 总是搭配Mutex 使用。

> 超时条件变量的作用是为了防止某个线程因为异常终止，没有及时释放锁，超时会导致锁因为超时而释放

### 用条件阻塞线程
一个线程可以通过调用pthread_cond_wait 在一个Condition Variable 阻塞等待，这个函数会三步操作：
1. 释放mutex
2. 阻塞等待
3. 当被唤醒时，重新获得Mutex 并返回

pthread_cond_timedwait 还有一个用于设定超时的参数abstime, 如果abstime 所指定的时刻仍然没有别的线程来唤醒当前的线程，就返回ETIMEOUT.

### 用条件唤醒线程
一个线程可以调用pthread_cond_signal 唤醒在某个条件上等待的另一个线程，也可以用pthread_cond_broadcast 唤醒在这个条件上等待的所有线程。
Note: 调用pthread_cond_signal 唤醒条件cond 上的线程时，内核会选择cond 上等待的某个线程，并将这个线程调度到执行队列. 这个唤醒对后来加入到cond 并挂起等待的线程是无效的.

下面的代码演示了一个生产者消费者的例子，生产者生产一个结构体串在链表的表头上，消费者从表头取走结体体:

	#include <stdlib.h>
	#include <pthread.h>
	#include <stdio.h>

	struct msg {
		struct msg *next;
		int num;
	};

	struct msg *head;
	pthread_cond_t has_product = PTHREAD_COND_INITIALIZER;
	pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;

	void *consumer(void *p) {
		struct msg *mp;

		for (;;) {
			pthread_mutex_lock(&lock);
			while (head == NULL)
				pthread_cond_wait(&has_product, &lock);
			mp = head;
			head = mp->next;
			pthread_mutex_unlock(&lock);
			printf("Consume %d\n", mp->num);
			free(mp);
			sleep(rand() % 5);
		}
	}

	void *producer(void *p) {
		struct msg *mp;
		for (;;) {
			mp = malloc(sizeof(struct msg));
			mp->num = rand() % 1000 + 1;
			printf("Produce %d\n", mp->num);
			pthread_mutex_lock(&lock);
			mp->next = head;
			head = mp;
			pthread_mutex_unlock(&lock);
			pthread_cond_signal(&has_product);
			sleep(rand() % 5);
		}
	}

	int main(int argc, char *argv[]) {
		pthread_t pid, cid;

		srand(time(NULL));
		pthread_create(&pid, NULL, producer, NULL);
		pthread_create(&cid, NULL, consumer, NULL);
		pthread_join(pid, NULL);
		pthread_join(cid, NULL);
		return 0;
	}

输出为:

	$ ./a.out
	Produce 433
	Produce 865
	Consume 865
	Produce 285
	Consume 285

### 为什么Condition Variable 要这么设计？
先回到最初的问题，如果我们想实现一个原子操作，我们会直接用mutex 锁

	mutex_lock
		Operation
	mutex_unlock

mutex 锁会使线程阻塞等待，当有大量线程进程阻塞时，会加重内核调度负担。所以，可以考虑将这些阻塞的线程或进程 放到睡眠的状态，等到有锁时，才被唤醒。这个锁就成为了唤醒的条件。

	cond_wait(sleep):
		kernel:
			cond_lock
				将线程加入到睡眠队列// 这个操作可能会和唤醒操作 出现并发冲突，所以要加cond_lock
			cond_unlock
		user(进程唤醒后):
			mutex_lock

	cond_signal(wake up):
		kernel:
			cond_lock
				唤醒某一个睡眠线程，并加入到执行队列
			cond_unlock

	code(线程并唤醒，且获得mutex_lock 后):
			Operation
		mutex_unlock

我们可以看到cond_wait 与 cond_signal 使用了两把锁，为了节省锁资源，实际实现时将mutex_lock 与 cond_lock 合为一把lock(牺牲了Operation 与 唤醒休眠线程 的并发性)

	cond_wait(sleep):
		kernel:
			lock
				将线程加入到睡眠队列
			unlock
		user(进程唤醒后):
			lock

	cond_signal(wake up):
		kernel:
			lock
				唤醒某一个睡眠线程，并加入到执行队列
			unlock

	code(线程并唤醒，且获得lock 后):
			Operation
		unlock

其实，实际实现的cond_wait 会考虑到，解锁与释锁的对称性；以及绝大多数情况下，线程被唤醒到lock 再到执行线程时，有些条件不满足了，线程必须重新休眠。比如, 以上例子中的，线程被唤醒并且加锁成功时，发现head 还是为空，必須重新休眠：

	while (head == NULL)
			pthread_cond_wait(&has_product, &lock);

所以, con_wait 只有一个unlock 和 lock:

	cond_wait(sleep):
		kernel:
				将线程加入到睡眠队列
			unlock
		user(进程唤醒后):
			lock

这样就方便了

## Semaphore 信号量
Mutex 表示一种可用资源，1表示可用，0表示不可用（资源被别的线程给占用）
信号量（Semaphore）和Mutex 类似， 表示可用资源的数量，和Mutex 不同的是这个数量可以大于1
本文将介绍POSIX Semaphore 库函数，详见sem_overview(7), 这种信号量不仅可以用于同一进程中线程间同步，也可以用于多个进程间同步。

	#include <semaphore.h>
	int sem_init(sem_t *sem, int pshared, unsigned int value);
	int sem_destroy(sem_t * sem);
	int sem_wait(sem_t *sem);
	int sem_trywait(sem_t *sem);
	int sem_post(sem_t * sem);

semaphore 变量类型为sem_t, sem_init 初始化一个semaphore 变量，value 是可用资源数量，pshared 为0表示信号量用于同一进程中线程间同时（本节只介绍这种情况）。sem_destroy 用于释放与semaphore 相关的资源。

sem_wait 可以获得资源，使得semaphore 减1，如果semaphore 已经为0，则挂起等待，而sem_trywait 则不会挂起等待。而sem_post 可以释放资源，傅semaphore 加1，同时唤醒挂起等待的线程。

> Mac OSX 已经不再使用sem_init 等Unnamed semaphores函数了，
To use named semaphores instead of unnamed semaphores, use sem_open instead of sem_init, and use sem_close and sem_unlink instead of sem_destroy.
http://stackoverflow.com/questions/1413785/sem-init-on-os-x

上一节生产者消费者的例子是基于链表的，空间是动态分配的。现在基于固定大小的环形队列重写这个程序：

	#include <stdlib.h>
	#include <pthread.h>
	#include <stdio.h>
	#include <semaphore.h>

	#define NUM 50
	int queue[NUM];
	sem_t blank_number, product_number;

	void *producer(void *arg) {
		int p = 0;
		while (1) {
			sem_wait(&blank_number);
			queue[p] = rand() % 1000 + 1;
			printf("Produce %d\n", queue[p]);
			sem_post(&product_number);
			p = (p+1)%NUM;
			sleep(rand()%5);
		}
	}

	void *consumer(void *arg) {
		int c = 0;
		while (1) {
			sem_wait(&product_number);
			printf("Consume %d\n", queue[c]);
			queue[c] = 0;
			sem_post(&blank_number);
			c = (c+1)%NUM;
			sleep(rand()%5);
		}
	}

	int main(int argc, char *argv[]) {
		pthread_t pid, cid;

		sem_init(&blank_number, 0, NUM);
		sem_init(&product_number, 0, 0);
		pthread_create(&pid, NULL, producer, NULL);
		pthread_create(&cid, NULL, consumer, NULL);
		pthread_join(pid, NULL);
		pthread_join(cid, NULL);
		sem_destroy(&blank_number);
		sem_destroy(&product_number);
		return 0;
	}

对于mac osx 来说，应该使用named semaphore:

	sem_t *blank_number;
	blank_number = sem_open("blank_number",O_CREAT| O_EXCL, S_IRWXU, NUM);
	if(blank_number == SEM_FAILED){
		perror("open blank_number");
		return 1;
	}
	sem_close(blank_number);

当semaphore 用于线程间同步(pshared=0)时, semaphore 完全可以用 `Condition Variable` 来实现。

	#include <stdlib.h>
	#include <pthread.h>
	#include <stdio.h>
	#include <unistd.h>
	#include <semaphore.h>

	#define NUM 50
	int queue[NUM];
	/**
	 * sem_t_def
	 */
	struct sem_t_def {
	    int count ;
	    pthread_mutex_t count_lock;// = PTHREAD_MUTEX_INITIALIZER;

	    pthread_cond_t cond;
	    pthread_mutex_t cond_lock;//= PTHREAD_MUTEX_INITIALIZER;
	} blank_number, product_number;

	void sem_init_def(struct sem_t_def * sem, int count){
	    sem->count = count;
		pthread_mutex_init(&sem->count_lock, NULL);

		pthread_cond_init(&sem->cond, NULL);
		pthread_mutex_init(&sem->cond_lock, NULL);
	}
	void sem_destroy_def(struct sem_t_def * sem){
	}

	int sem_wait_def(struct sem_t_def * sem){
		dec_count:
			pthread_mutex_lock(&sem->count_lock);
			int count = sem->count;
			if(sem->count > 0){
				sem->count--;
			}
			pthread_mutex_unlock(&sem->count_lock);

		//有资源，就执行
	    if(count>0){
	        return 0;
		//没有资源，就休眠
	    }else{
	        pthread_mutex_lock(&sem->cond_lock);//用count_lock 也可以, 但是降低了并发性: 它会使得别的线程在操作sem->count 或者 sem->cond 时导致对方线程挂起, 因为它们是用的同一把锁lock
	        pthread_cond_wait(&sem->cond, &sem->cond_lock);
	        pthread_mutex_unlock(&sem->cond_lock);
			goto dec_count;
	        return 0;
	    }
	}
	void sem_post_def(struct sem_t_def * sem){
	    pthread_mutex_lock(&sem->count_lock);
	    sem->count++;
	    pthread_mutex_unlock(&sem->count_lock);
	    pthread_cond_signal(&sem->cond);
	}
	void *producer(void *arg) {
	    int p = 0;
	    while (1) {
	        sem_wait_def(&blank_number);
	        queue[p] = rand() % 1000 + 1;
	        printf("Produce queue[%d]:%d\n", p, queue[p]);
	        sem_post_def(&product_number);
	        p = (p+1)%NUM;
	        sleep(rand()%5);
	    }
	}

	void *consumer(void *arg) {
	    int c = 0;
	    while (1) {
	        sem_wait_def(&product_number);
	        printf("Consume queue[%d]:%d\n", c, queue[c]);
	        queue[c] = 0;
	        sem_post_def(&blank_number);
	        c = (c+1)%NUM;
	        sleep(rand()%5);
	    }
	}
	int main() {
	    pthread_t pid, cid;
	    sem_init_def(&blank_number,  NUM);//空闲队列资源数量
	    sem_init_def(&product_number,  0);//生产队列资源数量
	    pthread_create(&pid, NULL, producer, NULL);
	    pthread_create(&cid, NULL, consumer, NULL);
	    pthread_join(pid, NULL);
	    pthread_join(cid, NULL);
	    sem_destroy_def(&blank_number);
	    sem_destroy_def(&product_number);
	    return 0;
	}

## 其它线程间同步机制

### Reader-Writer Lock
如果共享数据是只读的，那么不会出现并发冲突。只有当一个线程可以写数据时，才需要考虑线程同步问题。由此引发了
- 读者写者锁（Reader-Writer Lock）, Reader 之间并不互斥，而Writer 是独占的(exclusive), 在write 时，Reader-Writer 都不可以访问数据。可见Reader-Writer 锁比Mutex 锁并发效率更高。

### 避免挂起某个线程
用挂起等待线程 来解决 并发冲突不是一个最好的方法。在某些情况下解决并发冲突可以避免 挂起某个线程，比如Linux 内核的Seqlock, RCU(read-copy-update) 机制

# 参考
- [linux 线程]

[linux 线程]: http://akaedu.github.io/book/ch35.html
