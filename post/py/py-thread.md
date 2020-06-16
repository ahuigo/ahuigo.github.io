---
layout: page
title: python thread 线程笔记
category: blog
description:
---
# threading
Python的标准库提供了两个模块：`_thread`和`threading`: `_thread`是低级模块，threading是高级模块，对_thread进行了封装。

绝大多数情况下，我们只需要使用threading这个高级模块。

	import time, threading
	t = threading.Thread(target=loop, name='LoopThread', args = (arg1, arg2, ..))
	# t.setDaemon(True); # 设置独立线程, 主线程不会等待子线程序而结束(子线程也会强制结束, 除非强制join()才会等待) 
                         # 默认主线程结束后，会默认等待子线程(非daemon) 结束后，主线程才退出。
	t.start()
	t.join(); 相当于wait
	threading.current_thread().name

Python的threading模块有个current_thread()函数，它永远返回当前线程的实例。

1. 主线程实例的名字默认叫`MainThread`，
1. 子线程的名字在创建时指定，我们用`LoopThread`命名子线程。
1. 名字仅仅在打印时用来显示，完全没有其他意义，如果不起名字Python就自动给线程命名为`Thread-1，Thread-2……`

## threading.Thread
启动一个线程就是把一个函数传入并创建Thread实例，然后调用start()开始执行：

	import time, threading

	def loop(*args, **kw):
		print('thread %s is running...' % threading.current_thread().name)
        print(args)
		n = 0
		while n < 5:
			n = n + 1
			print('thread %s >>> %s' % (threading.current_thread().name, n))
			time.sleep(1)
		print('thread %s ended.' % threading.current_thread().name)

	print('thread %s is running...' % threading.current_thread().name)
	t = threading.Thread(target=loop, name='LoopThread', args=[1,2,3], kwargs={'v':2})
	t.start()
    t.is_alive()
	t.join([timeout])
	print('thread %s ended.' % threading.current_thread().name)

执行结果如下：

	thread MainThread is running...
	thread LoopThread is running...
    [1,2,3]
	thread LoopThread >>> 1
	thread LoopThread >>> 2
	thread LoopThread >>> 3
	thread LoopThread >>> 4
	thread LoopThread >>> 5
	thread LoopThread ended.
	thread MainThread ended

### attr
threading.current_thread().ident
threading.current_thread().name

## 变量的线程不安全
因为有些操作的字节码 不是原子性的

    n = 1
    def foo:
        global n
        n+=1 # 不是原子的

    import dis
    dis..(foo) //多个字节码，不是原子的

## lock thread
如果线程要修改全局变量，为防collision 冲突，可以加lock
1. Rlock(),允许多重嵌套锁，
2. 而Lock()只能锁一次；

Lock:

	balance = 0
	//创建一把锁
	lock = threading.Lock()

	def run_thread(n):
		for i in range(100000):
			# 先要获取锁:
			lock.acquire()
			try:
				# 放心地改吧:
				balance +=n
				balance -=n
			finally:
				# 改完了一定要释放锁:
				lock.release()


RLock:

    from threading import RLock, Thread
    lock = Rlock()
    lock.acquire(block=True)
    lock.release()

mutex:

    if mutex.acquire(1):
        if not queue.empty():
            queue.get()
        mutex.release()

在c语言里面就是用的futex

## close thread: via thread.Event
via a threadsafe threading.Event():
1. 利用e.wait() until e.set():

    e = threading.Event()
    while not e.wait(0.5): # wait 会阻塞0.5秒
        time.sleep(1)
    print('end')

2. 利用e.is_set() until e.clear():

    e = threading.Event()
    e.set()

    def loop(running):
        while running.is_set():
            print('running')
            time.sleep(0.5)

    thread = threading.Thread(target=loop, args=(running,))
    thread.start()

    e.clear()
    thread.join()

3. close via thread attr:

    def loop():
        t = threading.currentThread()
        while getattr(t, "do_run", True):
            print ("working on %s" % arg)
            time.sleep(1)
        print("Stopping as you wish.")

    thread = threading.Thread(target=loop, args=(running,))
    thread.do_run = False

## thread isAlive
thread.start() 后为true

    thread.isAlive()

## catch thread excetion
    import threading
    import sys
    class ExcThread(threading.Thread):

        def __init__(self, target, args = None):
            self.args = args if args else []
            self.target = target
            self.exc = None
            threading.Thread.__init__(self)

        def run(self):
            try:
                self.target(*self.args)
                raise Exception('An error occured here.')
            except Exception:
                self.exc=sys.exc_info()

    def main():
        thread_obj = ExcThread(target=lambda *x:print(f'run target({x})'), args=[1,2,3])
        thread_obj.start()

        thread_obj.join()
        exc = thread_obj.exc
        if exc:
            exc_type, exc_obj, exc_trace = exc
            print(exc_type, ':',exc_obj, ":", exc_trace)

    main()


## communicate via pool.apply_async().get()
对比下 ThreadPool vs Thread

    t = threading.Thread(target=loop, name='LoopThread')
        #t.start() t.join()

e.g.

    def foo(bar, baz):
        print('hello {0}'.format(bar))
        return 'return baz:' + baz

    import multiprocessing.pool
    pool = multiprocessing.pool.ThreadPool(2)
    async_result = pool.apply_async(foo, ('world', 'foo')) # tuple of args for foo
    print(async_result.get()) # 阻塞+get

# 多核CPU
打开Mac OS X的Activity Monitor，或者Windows的Task Manager，都可以监控某个进程的CPU使用率。
我们可以监控到一个死循环线程会100%占用一个CPU。

如果有两个死循环线程，在多核CPU中，可以监控到会占用200%的CPU，也就是占用两个CPU核心。
要想把N核CPU的核心全部跑满，就必须启动N个死循环线程。

试试用Python写个死循环：

    import threading, multiprocessing
    def loop():
        x = 0
        while True:
            x = x ^ 1
    for i in range(multiprocessing.cpu_count()):
        t = threading.Thread(target=loop)
        t.start()

启动与CPU核心数量相同的N个线程，在4核CPU上可以监控到CPU占用率仅有102%，也就是仅使用了一核。
但是用C、C++或Java来改写相同的死循环，直接可以把全部核心跑满，4核就跑到400%，8核就跑到800%，为什么Python不行呢？

因为:
1. Python的线程虽然是真正的线程，但解释器执行代码时，有一个GIL锁：`Global Interpreter Lock`，任何Python线程执行前，必须先获得GIL锁，
2. 然后，每执行100条字节码，解释器就自动释放GIL锁，让别的线程有机会执行。

这个GIL全局锁实际上把所有线程的执行代码都给上了锁，所以，多线程在Python中只能交替执行，即使100个线程跑在100核CPU上，也只能用到1个核。

1. 当线程运行在不同的内核中时，两个或更多的处理器要更新同一个对象便产生了竞争机制，特别在Python垃圾回收处理机制中。
2. 合理的解决方案就是给每个对象上锁
3. 锁的粒度越小, 实现起来越复杂, 而且可能还会因为锁而降低性能. 所以就加了全局大锁(GIL)

Note, GIL 与LOCK
1. 虽然 python线程是串行的(GIL), 但是它不是appliction 级的锁定, 所以还是需要加锁lock
2. 一个进程可以占用多个CPU，但是一个线程可能只会占用一个CPU。
3. 进程是资源分配的最小单位，线程是CPU调度的最小单位；

## CPython
GIL是Python解释器设计的历史遗留问题，通常我们用的解释器是官方实现的CPython，要真正利用多核，除非重写一个不带GIL的解释器。

所以，在Python中 如果一定要通过多线程利用多核

1. 那只能通过C扩展来实现，不过这样就失去了Python简单易用的特点。
2. 不过，也不用过于担心，Python虽然不能利用多线程实现多核任务，但可以通过多进程实现多核任务。多个Python进程有各自独立的GIL锁，互不影响

# sleep
sleep 线程级的，只会停止当前线程: 在waiter sleep时，worken继续工作

    class worker(Thread):
        def run(self):
            for x in xrange(0,11):
                print x
                time.sleep(1)

    class waiter(Thread):
        def run(self):
            for x in xrange(100,103):
                print x
                time.sleep(5)

    def run():
        worker().start()
        waiter().start()


# share variable
1. 通过thread attr:
    t = Thread(...)
    t.a = 2;
    threading.current_thread().a
2. 通过dict[thread_key]
3. 通过queue


## ThreadLocal
线程也有属于自己的子全局变量，否则:
每个函数一层一层调用都这么传参数？太麻烦了!

	def thread_student(name):
		std = Student(name)
		# std是局部变量，但是每个函数都要用它，因此必须传进去：
		do_task_1(std)
		do_task_2(std)

	def do_task_1(std):
		do_subtask_1(std)
		do_subtask_2(std)


由于`dict[key]=value`是线程安全的, 可用一个全局dict存放所有的Student对象，然后以thread自身作为key获得线程对应的Student对象如何？

	global_dict = {}

	def std_thread(name):
		std = Student(name)
		# 把std放到全局变量global_dict中：
		global_dict[threading.current_thread()] = std
		do_task_1()
		do_task_2()

	def do_task_1():
		# 不传入std，而是根据当前线程查找：
		std = global_dict[threading.current_thread()]

它最大的优点是消除了std对象在每层函数中的传递问题，但是，每个函数获取std的代码有点丑

有没有更简单的方式？
ThreadLocal应运而生，不用查找dict，ThreadLocal帮你自动做这件事：

	import threading

	# 创建全局ThreadLocal对象:
	local_school = threading.local()

	def process_student():
	    # 获取当前线程关联的student:
	    std = local_school.student
	    print('Hello, %s (in %s)' % (std, threading.current_thread().name))

	def process_thread(name):
	    # 绑定ThreadLocal的student: local_school[thread_key].student
	    local_school.student = name
	    process_student()

	t1 = threading.Thread(target= process_thread, args=('Alice',), name='Thread-A')
	t2 = threading.Thread(target= process_thread, args=('Bob',), name='Thread-B')
	t1.start()
	t2.start()
	t1.join()
	t2.join()

执行结果：

	Hello, Alice (in Thread-A)
	Hello, Bob (in Thread-B)

ThreadLocal最常用的地方:

0. 线程范围内的全局变量
1. 就是为每个线程绑定一个数据库连接，HTTP请求，用户身份信息等，这样一个线程的所有调用到的处理函数都可以非常方便地访问这些资源。

## communicate via Queue
Queue  is thread safe

    import queue
    q=queue.Queue()

## signal for thread
signal.pthread_kill(thread_id, signum)