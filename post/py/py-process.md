---
layout: page
title: py-process
category: blog
description: 
date: 2018-10-04
---
# Preface
- sh: sh之于subprocess， 相当于requests 对于urllib2
	1. sh.ls("-l", "/tmp", color="never")
	2. sh.ifconfig("en0")
	3. sh.fileset()

# fork
Cover these functions:
- os.fork()
- os.getpid()

Example

	import os

	print('Process (%s) start...' % os.getpid())
	# Only works on Unix/Linux/Mac:
	pid = os.fork()
	if pid == 0:
		print('I am child process (%s) and my parent is %s.' % (os.getpid(), os.getppid()))
	else:
		print('I (%s) just created a child process (%s).' % (os.getpid(), pid))

## fork api:
```
p = Process(target=run_proc, args=('test',))
	p.start() .join() .terminate()
	p.exitcode = 0
multiprocessing.Pool(4).apply_async(func_task, args).get() # 直接调用get()会阻塞，不需要pool.join()
    pool = Pool(4)
	pool.close() pool.join()

```
thread 类似
```
t = threading.Thread(target=loop, name='LoopThread')
	t.start() t.join()

async_result = multiprocessing.pool.ThreadPool(processes=1).apply_async(foo, ('world', 'foo')) # tuple of args for foo
	print(async_result.get()) # 阻塞
	pool.close() .join() # 等待所有线程结束
```


# multiprocessing.Process(func)跨平台
fork 与子程序func 是分离的, 父进程同步子进程比较麻烦
multiprocessing.Process(func) 则可以直接传func:

1. child = multiprocessing.Process(target=func, args=())
2. child.start()
2. child.join() 等待子进程结束后再继续往下运行，通常用于进程间的同步
4. child.terminate() 或者直接结束
4. child.exitcode 正常是0

	from multiprocessing import Process
	import os

	# 子进程要执行的代码
	def run_proc(name):
		print('Run child process %s (%s)...' % (name, os.getpid()))

	if __name__=='__main__':
		print('Parent process %s.' % os.getpid())
		p = Process(target=run_proc, args=('test',))
		print('Child process will start.')
		p.start()
		p.join()
		print('Child process end.')

结果

	Parent process 928.
	Process will start.
	Run child process test (929)...
	Process end.

## daemon

    import time
    import multiprocessing
    def f():
        time.sleep(1)
        print('sleep end')
    p = multiprocessing.Process(target=f)
    p.daemon=True
    p.start()
    print('Daemon will not wait children, in case of p.join()...')

daemonic processes are not allowed to have children!

    import time
    import multiprocessing
    def f():
        p = multiprocessing.Process(target=lambda:1)
        p.start()
        time.sleep(1)
    p = multiprocessing.Process(target=f)
    # daemon (no wait)
    p.daemon=True
    p.start()
    print('start...')
    p.join()

# Pool

##  NoDaemon
    import multiprocessing
    import multiprocessing.pool
    class NoDaemonProcess(multiprocessing.Process):
        def _get_daemon(self):
            return False
        def _set_daemon(self, value):
            pass
        daemon = property(_get_daemon, _set_daemon)

    # We sub-class multiprocessing.pool.Pool instead of multiprocessing.Pool
    # because the latter is only a wrapper function, not a proper class.
    class MyPool(multiprocessing.pool.Pool):
        Process = NoDaemonProcess

## Pool().apply_async()
如果要启动大量的子进程，可以用进程池的方式批量创建子进程：
1. multiprocessing.Pool(4) 比fork 简单
2. multiprocessing.pool.ThreadPool(2) 也是

e.g.
1. p = multiprocessing.Pool(4)
2. for i in range(5): res = p.apply_async(func, args=(i,))
2. p.join() 等待子进程结束后再继续往下运行，通常用于进程间的同步
3. 或者用res.get() 阻塞获取返回值

e.g.

    from multiprocessing import Pool
    import os, time, random

    def long_time_task(name):
        print('Run task %s (%s)...' % (name, os.getpid()))
        start = time.time()
        time.sleep(random.random() * 3)
        end = time.time()
        print('Task %s runs %0.2f seconds.' % (name, (end - start)))

    if __name__=='__main__':
        print('Parent process %s.' % os.getpid())
        p = Pool(4)
        for i in range(5):
            p.apply_async(long_time_task, args=(i,)) # 加5个任务
        time.sleep(3)
        print('Waiting for all subprocesses done...')
        p.close() # Tells the pool not to accept any new job. Once all the tasks have been completed the worker processes will exit
        p.join() # Wait for the worker processes to exit. One must call close() before using join().
        print('All subprocesses done.')

Note: 可以使用r.get() 获得返回(阻塞)

    from multiprocessing import Pool
    import os, time, random

    def long_time_task(name):
        time.sleep(3)
        return '%s' %name

    p = Pool(4)
    rr = []
    for i in range(5):
        r = p.apply_async(long_time_task, args=(i,)) # 加5个任务
        rr.append(r)
    for r in rr: print(r.get())

执行结果如下：

    Parent process 78869.
    Run task 0 (78870)...
    Run task 1 (78871)...
    Run task 2 (78872)...
    Run task 3 (78873)...
    Task 2 runs 0.47 seconds.
    Run task 4 (78872)...
    Task 4 runs 0.19 seconds.
    Task 3 runs 1.74 seconds.
    Task 1 runs 2.24 seconds.
    Task 0 runs 2.99 seconds.
    Waiting for all subprocesses done...
    All subprocesses done.

请注意输出的结果，task 0，1，2，3是立刻执行的，而task 4要等待前面某个task完成后才执行，这是因为Pool的默认大小在我的电脑上是4，因此，最多同时执行4个进程。这是Pool有意设计的限制，并不是操作系统的限制。如果改成：

	p = Pool(5)
	# 就可以同时跑5个进程。

由于Pool的默认大小是CPU的核数，如果你不幸拥有8核CPU，你要提交至少9个子进程才能看到上面的等待效果。

## map
map 并行处理10 个任务

    import multiprocessing
    import math
    multiprocessing.Pool(processes=4).map(math.exp,range(1,11)) #type list
    multiprocessing.Pool(4).map(math.exp,range(1,11), chunksize=2) 一组chunksize 传入一个进程
    [2.718281828459045, 7.38905609893065, 20.085536923187668, ...]

### chunksize

   chunksize=1
     The portion of the input data to hand to each worker.  This
     can be used to tune performance during the mapping phase.
   """
   multiprocessing.Pool(4).map(map_func, iterable_inputs, chunksize=chunksize)

# 进程间通信
Process之间肯定是需要通信的，操作系统提供了很多机制来实现进程间的通信。Python的multiprocessing模块包装了底层的机制，提供了Queue、Pipes等多种方式来交换数据。

## queue
其实管道也是一种queue, queue 是线程安全的

	from multiprocessing import Process, Queue
	q = Queue()
	q.put(value)
	q.get(True)	 # io阻塞
	q.get(False) # io非阻塞
	time.sleep(random.random())

### queue example 0
```
from multiprocessing import Process, Queue
def multiply(a,b,que): que.put(a*b)

queue1 = Queue() #create a queue object
p = Process(target= multiply, args= (5,4,queue1)) #we're setting 3rd argument to queue1
p.start()
print(queue1.get()) #and we're getting return value: 20
p.join()
print("ok.")
```
### queue example
我们以Queue为例，在父进程中创建两个子进程，一个往Queue里写数据，一个从Queue里读数据：

	from multiprocessing import Process, Queue
	import os, time, random

	# 写数据进程执行的代码:
	def write(q):
	    print('Process to write: %s' % os.getpid())
	    for value in ['A', 'B', 'C']:
	        print('Put %s to queue...' % value)
	        q.put(value)
	        time.sleep(random.random())

	# 读数据进程执行的代码:
	def read(q):
	    print('Process to read: %s' % os.getpid())
	    while True:
	        value = q.get(True)
	        print('Get %s from queue.' % value)

	if __name__=='__main__':
	    # 父进程创建Queue，并传给各个子进程：
	    q = Queue()
	    pw = Process(target=write, args=(q,))
	    pr = Process(target=read, args=(q,))
	    # 启动子进程pw，写入:
	    pw.start()
	    # 启动子进程pr，读取:
	    pr.start()
	    # 等待pw结束:
	    pw.join()
	    # pr进程里是死循环，无法等待其结束，只能强行终止:
	    pr.terminate()

运行结果如下：

	Process to write: 50563
	Put A to queue...
	Process to read: 50564
	Get A from queue.
	Put B to queue...
	Get B from queue.
	Put C to queue...
	Get C from queue.

在Unix/Linux下，multiprocessing模块封装了fork()调用，使我们不需要关注fork()的细节。由于Windows没有fork调用，因此，multiprocessing需要“模拟”出fork的效果，父进程所有Python对象都必须通过pickle序列化再传到子进程去，所有，如果multiprocessing在Windows下调用失败了，要先考虑是不是pickle失败了。

# distribute process, 分布式进程
Process可以分布到多台机器上，而Thread最多只能分布到同一台机器的多个CPU上。

Python的`multiprocessing模块`不但支持多进程，其中`managers子模块`还支持把多进程分布到多台机器上。 由于managers模块封装很好，不必了解网络通信的细节

	from multiprocessing.managers import BaseManager

举个例子：
我们先看服务进程，服务进程负责启动Queue，把Queue注册到网络上，然后往Queue里面写入任务：

	# task_master.py

	import random, time, queue
	from multiprocessing.managers import BaseManager

	# 发送任务的队列:
	task_queue = queue.Queue()
	# 接收结果的队列:
	result_queue = queue.Queue()

	# 从BaseManager继承的QueueManager:
	class QueueManager(BaseManager):
	    pass

	# 把两个Queue都注册到网络上, callable参数关联了Queue对象:
	QueueManager.register('get_task_queue', callable=lambda: task_queue)
	QueueManager.register('get_result_queue', callable=lambda: result_queue)
	# 绑定端口5000, 设置验证码'abc':
	manager = QueueManager(address=('', 5000), authkey=b'abc')
	# 启动Queue:
	manager.start()
	# 获得通过网络访问的Queue对象:
	task = manager.get_task_queue()
	result = manager.get_result_queue()
	# 放几个任务进去:
	for i in range(10):
	    n = random.randint(0, 10000)
	    print('Put task %d...' % n)
	    task.put(n)
	# 从result队列读取结果:
	print('Try get results...')
	for i in range(10):
	    r = result.get(timeout=10)
	    print('Result: %s' % r)
	# 关闭:
	manager.shutdown()
	print('master exit.')

请注意，当我们在一台机器上写多进程程序时，创建的Queue可以直接拿来用，但是，在分布式多进程环境下，添加任务到Queue不可以直接对原始的task_queue进行操作，那样就绕过了QueueManager的封装，必须通过manager.get_task_queue()获得的Queue接口添加。

然后，在另一台机器上启动任务进程（本机上启动也可以）：

	# task_worker.py

	import time, sys, queue
	from multiprocessing.managers import BaseManager

	# 创建类似的QueueManager:
	class QueueManager(BaseManager):
	    pass

	# 由于这个QueueManager只从网络上获取Queue，所以注册时只提供名字:
	QueueManager.register('get_task_queue')
	QueueManager.register('get_result_queue')

	# 连接到服务器，也就是运行task_master.py的机器:
	server_addr = '127.0.0.1'
	print('Connect to server %s...' % server_addr)
	# 端口和验证码注意保持与task_master.py设置的完全一致:
	m = QueueManager(address=(server_addr, 5000), authkey=b'abc')
	# 从网络连接:
	m.connect()
	# 获取Queue的对象:
	task = m.get_task_queue()
	result = m.get_result_queue()
	# 从task队列取任务,并把结果写入result队列:
	for i in range(10):
	    try:
	        n = task.get(timeout=1)
	        print('run task %d * %d...' % (n, n))
	        r = '%d * %d = %d' % (n, n, n*n)
	        time.sleep(1)
	        result.put(r)
	    except Queue.Empty:
	        print('task queue is empty.')
	# 处理结束:
	print('worker exit.')

任务进程要通过网络连接到服务进程，所以要指定服务进程的IP。

现在，可以试试分布式进程的工作效果了。先启动task_master.py服务进程：

	$ python3 task_master.py
	Put task 3411...
	Put task 1605...
	Put task 1398...
	Put task 4729...
	Put task 5300...
	Put task 7471...
	Put task 68...
	Put task 4219...
	Put task 339...
	Put task 7866...
	Try get results...

task_master.py进程发送完任务后，开始等待result队列的结果。现在启动task_worker.py进程：

	$ python3 task_worker.py
	Connect to server 127.0.0.1...
	run task 3411 * 3411...
	run task 1605 * 1605...
	run task 1398 * 1398...
	run task 4729 * 4729...
	run task 5300 * 5300...
	run task 7471 * 7471...
	run task 68 * 68...
	run task 4219 * 4219...
	run task 339 * 339...
	run task 7866 * 7866...
	worker exit.

task_worker.py进程结束，在task_master.py进程中会继续打印出结果：

	Result: 3411 * 3411 = 11634921
	Result: 1605 * 1605 = 2576025
	Result: 1398 * 1398 = 1954404
	Result: 4729 * 4729 = 22363441
	Result: 5300 * 5300 = 28090000
	Result: 7471 * 7471 = 55815841
	Result: 68 * 68 = 4624
	Result: 4219 * 4219 = 17799961
	Result: 339 * 339 = 114921
	Result: 7866 * 7866 = 61873956

这个简单的Master/Worker模型有什么用？其实这就是一个简单但真正的分布式计算，把代码稍加改造，启动多个worker，就可以把任务分布到几台甚至几十台机器上，比如把计算n*n的代码换成发送邮件，就实现了邮件队列的异步发送。

Queue对象存储在哪？注意到task_worker.py中根本没有创建Queue的代码，所以，Queue对象存储在task_master.py进程中