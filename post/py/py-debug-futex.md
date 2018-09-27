---
title: FUTEX_WAIT_PRIVATE
date: 2018-09-28
---
## FUTEX_WAIT_PRIVATE 
经常发现程序死在这里:

    sudo strace -p 2583
    futex(0x..., FUTEX_WAIT_PRIVATE, 0, NULL
Futex是一种用户态和内核态混合的同步机制。
1. 同步的进程间通过mmap共享一段内存，futex变量就位于这段共享 的内存中且操作是原子的，
2. 当进程尝试进入互斥区或者退出互斥区的时候，先去查看共享内存中的futex变量，
    3. 如果没有竞争发生，则只修改futex,而不 用再执行系统调用了。
    4. 如果futex变量告诉进程有竞争发生，则执行系统调用去完成相应的处理(wait 或者 wake up)。

futex 函数：
1. FUTEX_WAIT: 原子性的检查uaddr中计数器的值是否为val,如果是则让进程休眠，直到FUTEX_WAKE或者超时(time-out)。也就是把进程挂到uaddr相对应的等待队列上去。
2. 不加timeout参数，它会一直被阻塞，直到FUTEX_WAKE:
    int futex (int *uaddr, int op, int val, const struct timespec *timeout,int *uaddr2, int val3);

这种情况经常出现在：
1. redis 堵塞
2. queue 的 get() 是堵塞: 多个线程同时获取queue.get(), 没有获取到的线程就会被get 阻塞
    1. 可以用queue.get(timeout=2)
    1. queue.get() 前，mutex.acquire(1) 加锁+先判断 queue size
3. RLock().acquire()
    RLock().acquire(block=True)