---
title: asyncio
date: 2018-09-28
---
# asyncio
asyncio是基于coroutine 的，包括了:
1. 事件循环(event loop):
   1. 全局有一个event loop: 所以可以在全局使用 await task
2. Task: 对coroutine 的封装，包含各种状态
    1. Pending Running Done Cancelled

3. Future: 将来执行或没有执行的任务的结果. task就是Future实例

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
注意：由于协程是单线程的，只有像corountine=asyncio.sleep(1) 交出执行权才能实现异步。

## task 的创建
task包装的是coroutine, 是Future的子类
1. 创建task：
   1. python>=3.7:`task = asyncio.create_task(coroutine)`
   1. python<=3.6: `asyncio.ensure_future()`
2. task有pending、runing、done、cancel状态
3. task 是Future的子类：isinstance(task, asyncio.Future)

### 创建coroutine
执行环境event loop：
1. 只能在async 内调用await, 它是异步的阻塞的
2. 只能在event loop 中执行coroutine:　可使用`asyncio.run`代替以前的`asyncio.get_event_loop()` 创建event_loop 环境

没有await coroutine 就不会执行, await会阻塞

    import asyncio
    async def fn():
        print("2. task start...")
        await asyncio.sleep(1)
        print("3. task end")
    async def main():
        co = fn()
        print("1. main pepare")
        await co
        print("4. main end")

    asyncio.run(main()) # blocking call

Note： ipython 本身就是event_loop，支持命令行写await：

    全局await coroutine (不await 不执行)
    全局await task

### 创建task：异步执行task 不返回(创建task)
> 只能在event_loop 内，调用: create_task

asyncio.create_task(coroutine) 会创建一个 Task 对象，这个 Task 对象是 Future 类的一个子类。
(一旦创建task，　就会马上执行)

    import asyncio
    async def func(i=2):
        await asyncio.sleep(i)
        print(f'func{i} done')
        return i

    async def main():
        coroutines = [func(1),func(2),func(3)]
        # 1. 只要创建就马上执行
        tasks = [asyncio.create_task(coroutine) for coroutine in coroutines]
        # 2. 等task执行结束, 不用await
        print("1. wait tasks(不等待的话，tasks 会中断退出)")
        await asyncio.sleep(4) 
    asyncio.run(main())

## await task 回调返回(创建task)
create_task 会将coroutine 包装成task：　task可以被await ，也可以关联回调

    import asyncio

    async def func(x):
        return x+1
    def callback(future):
        print('Callback: ', future.result())

    async def main():
        # 异步任务，关联 callback 处理返回
        task = asyncio.create_task(func(1))
        task.add_done_callback(callback)

        # main 本身是async 任务，只能在异步任务内await 等其它任务执行
        await task
        print(task.result())

    asyncio.run(main())

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
借助wait 封装, asyncio.wait 只能接收tasks 不接收coroutines 

    import asyncio 

    async def func(i=2):
        print('sleep: ',i)
        await asyncio.sleep(i)
        return i

    async def main():
        tasks = [asyncio.create_task(func(1)), asyncio.create_task(func(3))]  # Convert coroutines to tasks
        done, pending = await asyncio.wait(tasks)
        # await asyncio.gather(*tasks)
        for task in done:
            print(task.result())

    asyncio.run(main())

利用gather 合并tasks

    await asyncio.gather(*tasks)

## task 中断

    import asyncio
    async def func(i=2):
        try:
            await asyncio.sleep(i)
        except asyncio.CancelledError:
            print(f'func{i} was cancelled')
        print(f'func{i} done')
        return i

    async def main():
        coroutines = [func(1),func(2),func(3)]
        tasks = [asyncio.create_task(coroutine) for coroutine in coroutines]

        await asyncio.sleep(2)
        for task in tasks:
            print('cancel: ',task.cancel(), task)  

    asyncio.run(main())

利用gather 合并tasks

    print(asyncio.gather(*tasks).cancel())

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

### pool 上下文是阻塞的
executor 上下文结束是阻塞的(会等所有任务完成):

    from concurrent.futures.thread import ThreadPoolExecutor
    import time
    def load_url(url, timeout=1):
        time.sleep(timeout)
        print(f"load {url} successful, timeout={timeout}")
    with ThreadPoolExecutor(max_workers=2) as pool:
        for args in [('url1',4), ('url2',1)]:
            pool.submit(load_url, *args)
    print('All tasks has been finished')

### task exception
默认task 的exception不会被显示，我们可以手动捕获显示异常：

    with ThreadPoolExecutor() as executor:
        # execute our task
        future = executor.submit(work)
        # get the result from the task
        try:
            result = future.result()
        except Exception:
            print('Unable to get the result')

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
