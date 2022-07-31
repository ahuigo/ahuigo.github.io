---
title: asyncio
date: 2018-09-28
---
# asyncio
asyncio是基于coroutine 的，包括了:
1. 事件循环(event loop)
2. Task: 对coroutine 的封装，包含各种状态
    1. Pending Running Done Cancelled

4. Future: 将来执行或没有执行的任务的结果. task就是Future实例

## asyncio 生态
同类
1. curio： 比asyncio更轻量的协程网络库

asyncio 的生态:
1. uvloop: asyncio 的eventloop 扩展, uvloop基于libuv使用Cython编写，性能比nodejs还要高
2. sanic: 比aiohttp 轻量, sanic使用uvloop异步驱动，
2. aiohttp

## asyncio protocol
Aysncio protocol twisted-like:

    class Protocol(asyncio.Protocol):
        def connection_made(self, transport):
            self.transport = transport
        def data_received(self, data):
            self.transport.write(b'HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\nHello xxx')
            self.transport.close()
        def eof_received(self):
            if self.transport.can_write_eof():
                self.transport.write_eof()
        def connection_lost(self, exc):
            supper().connection_lost(exc)

# asyncio task 
## create task
single task: 包装的coroutine
1. 两种方式等价：
   1. `loop.create_task()`
   1. `asyncio.ensure_future()`
2. task有pending、runing、done、cancel状态
3. task 是Future的子类：isinstance(task, asyncio.Future)

e.g. create task

    import asyncio
    loop = asyncio.get_event_loop()
    async def do_some_work(x):
        print('Waiting: ', x)
    
    coroutine = do_some_work(2)
    # task = asyncio.ensure_future(coroutine)
    task = loop.create_task(coroutine)
    loop.run_until_complete(task)

## task 回调

    import asyncio
    async def func(x):
        return x+1
    def callback(future):
        print('Callback: ', future.result())
    
    loop = asyncio.get_event_loop()
    task = asyncio.ensure_future(func(1))
    task.add_done_callback(callback)

    loop.run_until_complete(task)
    print(task.result()) # future == task

## task with async/await

    async def func(x):
        await asyncio.sleep(x)
        return 'Done after {}s'.format(x)

 async/await 被用来取代yield from, yield from 可建立main 与 subgen的通道

    def gen():
        yield from subgen()
        yield from subgen()

    def subgen():
        i = 0
        while i<1:
            x = yield
            yield x+1
            i+=1
        return 100

    def main():
        g = gen()
        print(next(g))      #None
        print(g.send(1))    #2
        print(g.send(1))    #None
        print(g.send(1))    #2
        #g.throw(StopIteration) # 看似向gen()抛入异常

    main()

## task 并行
借助wait 封装

    import asyncio 
    async def func(i=2):
        print('sleep: ',i)
        await asyncio.sleep(i)
        #future.set_result('future is done')
        return i

    loop = asyncio.get_event_loop() # 默认的loop

    # asyncio.wait 封装多个tasks 为coroutine
    tasks_coroutine = asyncio.wait([
        asyncio.ensure_future(func(1)),
        asyncio.ensure_future(func(3)),
    ])

    # block for all tasks
    dones, pendings = loop.run_until_complete(tasks_coroutine) 
    for task in dones: 
        print(task.result()) # 顺序不定. pendins = set() 空集合. 除非ctrl-c中断
    #loop.close(1)

wait 会自动将 coroutine 封装为task

    tasks_coroutine = asyncio.wait([func(1), func(3)]) 

## task 中断

    import asyncio
    loop = asyncio.get_event_loop()
    async def func(i=2):
        await asyncio.sleep(i)
        return i

    try:
        loop.run_until_complete(asyncio.wait([func(1),func(20),func(33)]))
    except KeyboardInterrupt as e:
        # dones + pendings + cancels + runnings
        for task in asyncio.Task.all_tasks():
            # 有4个task: 3个func, 1个wait
            print('cancel: ',task.cancel(), task)  
    finally:
        pass #loop.close() 

利用gather 全部执行：

    print(asyncio.gather(*asyncio.Task.all_tasks()).cancel())

# asyncio loop event
    loop.run_until_complete()
    loop.stop()
    loop.run_forever() # 即使所有的任务done 也不停止, 除非loop.stop()
    loop.close()

## 阻塞loop (普通func)
用`loop.call_soon_threadsafe`往loop 添加普通函数（非coroutine）, 由于time.sleep 阻塞，执行要花3+3=6s

    from threading import Thread
    import asyncio, time
 
    def start_loop(loop):
        asyncio.set_event_loop(loop)
        print('start_loop')
        loop.run_forever()
    
    def more_work(x):
        print('More work {}'.format(x))
        time.sleep(x)
        print(f'Finished more work {x} at ',time.time() - start)
    
    start = time.time()
    new_loop = asyncio.new_event_loop()
    t = Thread(target=start_loop, args=(new_loop,))
    t.start()
    new_loop.call_soon_threadsafe(more_work, 3)
    new_loop.call_soon_threadsafe(more_work, 3)

线程本身相当于master-worker中，执行more_work 的worker

## 非阻塞loop (coroutine)
用`loop.call_soon_threadsafe`往loop 添加coroutine, 执行要花3s

    from threading import Thread
    import asyncio, time

    def start_loop(loop):
        asyncio.set_event_loop(loop)
        loop.run_forever()

    async def do_some_work(x):
        print('Waiting {}'.format(x))
        await asyncio.sleep(x)
        print(f'Finished more work {x} at ',time.time() - start)

    start = time.time()
    new_loop = asyncio.new_event_loop()
    t = Thread(target=start_loop, args=(new_loop,))
    t.start()
    print('TIME: {}'.format(time.time() - start))

    asyncio.run_coroutine_threadsafe(do_some_work(3), new_loop)
    asyncio.run_coroutine_threadsafe(do_some_work(3), new_loop)

## task 自动加入loop
新创建的task 会自动放到 loop

    import asyncio
    import time
    now = time.time
    start = now()
    async def worker(task=1):
        print('Start worker')
        await asyncio.sleep(task)
        print('Done ', task, now() - start)
    
    loop = asyncio.get_event_loop()

    asyncio.ensure_future(worker())
    asyncio.ensure_future(worker())
    loop.create_task(worker())
    try:
        loop.run_forever()
    except KeyboardInterrupt as e:
        print(asyncio.gather(*asyncio.Task.all_tasks()).cancel())
 

## 停止event loop

    new_loop = asyncio.new_event_loop()
    t = Thread(target=start_loop, args=(new_loop,))
    t.setDaemon(True)    # 设置子线程为守护线程, 不用等待
    t.start()
    try:
        while True:
            task = rcon.rpop("queue")
            if not task:
                time.sleep(1)
                continue
            asyncio.run_coroutine_threadsafe(do_some_work(int(task)), new_loop)
    except KeyboardInterrupt as e:
        print(e)
        new_loop.stop()

## create_subprocess_exec

    p = await asyncio.create_subprocess_exec('ping', '-c', '4', ip, stdout=asyncio.subprocess.PIPE)
    async for line in p.stdout:
        print(line)
    await p.wait()


# Future executor(包装多线程进程future)
coroutine 本身不能并行（parallel cpu），但是可以封装成thread/process.

就是手动封装task 太麻烦了，concurrent.futures 提供了方便的executor
1. 标准库中有两个为Future的类：concurrent.futures.Future 和 asyncio.Future。这两个Future作用相同。

Future 是抽象的Task, Task is subclass of Future, Future 也是一种特殊 Corutine

1. Future could wrap `coroutine` as task, and *store it's return value*. Important!!
    1. Future.set_result
    2. 然后执行add_done_callback()方法添加的回调函数，
2. Future instances are created by `Executor.submit()` and should not be created directly except for testing.

Future is Not thread safe!

## ThreadPoolExecutor
来一个例子 executor.map, 取数据时会block for all

    import concurrent.futures, urllib.request
    URLS = ['http://localhost?s=2','http://localhost?s=4']
    def load_url(url,timeout=60):
        with urllib.request.urlopen(url, timeout=timeout) as conn:
            print(url, 'finished!')
            return conn.read()

    import concurrent.futures
    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
       results = executor.map(load_url, URLS)
       print(list(results)) # block for all

每个io 返回的时间不一样，可以Executor.submit生成Future task, 然后实时处理 `futures.as_completed(futures)`(阻塞)

    from concurrent.futures.thread import ThreadPoolExecutor
    import concurrent.futures
    import time
    def load_url(url, timeout=1):
        time.sleep(timeout)
        msg = f"load {url} successful"
        print(msg)
        return msg + f",timeout={timeout}"

    with ThreadPoolExecutor(max_workers=2) as pool:
        urls = [('url1',4), ('url2',1)]
        futures = {pool.submit(load_url, *args): args[0] for args in urls}
        for future in concurrent.futures.as_completed(futures): # 任何一个完成都会迭代
            url=futures[future]
            print('url:', url)
            data = future.result()
            print('data:', data)

executor 上下文结束是阻塞的

    from concurrent.futures.thread import ThreadPoolExecutor
    import time
    def load_url(url, timeout=1):
        time.sleep(timeout)
        print(f"load {url} successful, timeout={timeout}")
    with ThreadPoolExecutor(max_workers=2) as pool:
        for args in [('url1',4), ('url2',1)]:
            pool.submit(load_url, *args)
    print('All tasks has been finished')

## ProcessPoolExecutor
也支持executor.map(func,urls) 和 executor.submit(func, url, 60) + as_completed()

    import concurrent.futures, urllib.request,math
    def is_prime(n):
        mid = int(math.sqrt(n))
        flag = True
        for i in range(3, mid+1,2):
            if n%i == 0:
                flag = False
                break
        return flag

    nums = [25, 61, 29, 50, 109]

    with concurrent.futures.ProcessPoolExecutor() as executor:
        future_to_num = {executor.submit(is_prime, n ):n for n in nums}
        for future in concurrent.futures.as_completed(future_to_num):
            data = future.result()
            print(future_to_num[future],data)

也可以不用async , 用multiprocessing.

    multiprocessing.Pool(4).apply_async(func, [url, 60]).get() # get是阻塞的
    multiprocessing.Pool(4).map(math.exp,range(1,11))           # map 也是阻塞的

    multiprocessing.pool.ThreadPool(4).apply_async(func, [url, 60]).get() # get是阻塞的
    multiprocessing.pool.ThreadPool(4).map(math.exp,range(1,11))

### Future.executor.map(包装多线程进程)
map是有序的： [ProcessPoolExecutor](/demo/py-demo/async/future-processpool-map.py)
as_completed 以及dict是无序的

    with concurrent.futures.ProcessPoolExecutor() as executor:
        for x in zip(nums, executor.map(is_prime, nums)):
            print(x)

## Future Task Method

    future.cancel()
    future.cancelled() bool
    future.running() bool
    future.done() bool
    future.result(timeout=None)

# 其他
## shell

    await asyncio.create_subprocess_exec('ping', '-c', '4', ip, stdout=asyncio.subprocess.PIPE)

# curio
比asyncio更轻量的协程网络库

curio的作者是David Beazley，下面是使用curio创建tcp server的例子，据说这是dabeaz理想中的一个异步服务器的样子：

    ```
    from curio import run, spawn
    from curio.socket import *

    async def echo_server(address):
        sock = socket(AF_INET, SOCK_STREAM)
        sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
        sock.bind(address)
        sock.listen(5)
        print('Server listening at', address)
        async with sock:
            while True:
                client, addr = await sock.accept()
                await spawn(echo_client, client, addr)

    async def echo_client(client, addr):
        print('Connection from', addr)
        async with client:
            while True:
                data = await client.recv(100000)
                if not data:
                    break
                await client.sendall(data)
        print('Connection closed')

    if __name__ == '__main__':
        run(echo_server, ('',25000))
    ```

无论是asyncio还是curio，或者是其他异步协程库，在背后往往都会借助于IO的事件循环来实现异步，下面用几十行代码来展示一个简陋的基于事件驱动的echo服务器：
[/demo](/demo/py/socket-selector-echo.py)
验证一下：

    # terminal 1,
    $ nc localhost 8081
    hello world
    hello world

    # terminal 2
    $ nc localhost 8081
    hello world
    hello world

# uvloop with asyncio
基于libuv 的asyncio event-loop 实现

    import asyncio,uvloop
    loop = uvloop.new_event_loop()
    asyncio.set_event_loop(loop)

## sanic
Sanic使用了uvloop作为asyncio的事件循环，uvloop由Cython编写，它的出现让asyncio更快.
比 nodejs、gevent 和其他Python异步框架要快两倍

    from sanic import Sanic
    from sanic.response import json
    app = Sanic()

    @app.route('/<user>')
    async def test(request, user):
        return json({'hello': user})

    app.run(host='0.0.0.0', port=8000)

route 可参考：https://www.jianshu.com/p/80f4fc313837

    @app.route('/number/<number_arg:number>')
    @app.route('/folder/<folder_id:[A-z0-9]{0,4}>')

    app.add_route(handler2, '/folder2/<name>')
    app.add_route(personal_handler2, '/personal2/<name:[A-z]>', methods=['GET'])

看看 《Sanic 的若干吐槽》，感觉Sanic 不像flask 而是像koa
https://manjusaka.itscoder.com/2018/02/23/why-i-dont-recommend-sanic/


# 参考
- Python黑魔法 --- 异步IO（ asyncio） 协程 http://python.jobbole.com/87310/
