---
title: Queue
date: 2018-10-04
---
# Queue
其实管道也是一种queue, queue 是进程-线程安全的

	from multiprocessing import Process, Queue
	q = Queue()
	q.put(any_type_value)
	q.get(True)	 # io阻塞
	q.get(False) # io非阻塞
	q.get(timeout=2) # io阻塞
	time.sleep(random.random())

    q.qsize()
    q.empty()
    q.full()


## mutex
threading要记得加锁

    if mutex.acquire(1):
        if not queue.empty():
            queue.get()
        mutex.release()

## asyncio

    queue = asyncio.Queue()

method:

    coroutine get()
        Remove and return an item from the queue.
        If queue is empty, wait until an item is available.

    get_nowait()
        Remove and return an item from the queue.

clear queue if queue if full

    async def f():
        if queue.qsize() > 3:
            while queue.qsize() > 1:
                try:
                    queue.get_nowait()
                except:
                    pass