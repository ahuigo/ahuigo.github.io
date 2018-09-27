---
title: asyncio
date: 2018-09-28
---
# asyncio
asyncio是基于coroutine 的，包括了:
1. 具有特定系统实现的事件循环(event loop)
2. 数据通讯和协议抽象(类似Twisted中的部分)
3. TCP/UDP/SSL, 子进程线程管道(ThreadPoolExecutor)，延迟调用和其他
4. Future类:包装coroutine; ensure_future: set_result() , .result()
5. 同步支持

## asyncio 生态
同类
1. curio： 比asyncio更轻量的协程网络库

asyncio 的生态:
1. sanic: 比aiohttp 轻量, sanic使用uvloop异步驱动，uvloop基于libuv使用Cython编写，性能比nodejs还要高
2. aiohttp
3. uvloop: asyncio 的eventloop 扩展

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


## result
### get coroutine result

    async def func():
        return 1
    result = loop.run_until_complete(func()) # 1

### get coroutine result from asyncio.wait
    ```
    async def func():
        return 1

    tasks = asyncio.wait([func(), func()])
    tasks_finished, sets = loop.run_until_complete(tasks) # 不支持直接传run_until_complete([corotine_list])
    for task in tasks_finished: print(task.result()) # 顺序不定
    ```

### asyncio.gather() to collect multiple results:

    import asyncio
    async def func():
        return 'saad'

    loop = asyncio.get_event_loop()
    tasks = func_normal(), func_infinite()
    a, b = loop.run_until_complete(asyncio.gather([func(),func()]))
    print("func()={a}, func()={b}".format(**vars()))
    loop.close()

### Future.set_result
asyncio future.set_result() and result():

    import asyncio
    async def slow_operation(future):
        aswait asyncio.sleep(1)
        future.set_result('future is done')

    loop asyncio.get_event_loop()
    future = asyncio.Future()
    asyncio.ensure_future(slow_operation(future))
    loop.run_until_complete(future)
    print(future.result())
    loop.close()

## create_subprocess_exec

    p = await asyncio.create_subprocess_exec('ping', '-c', '4', ip, stdout=asyncio.subprocess.PIPE)
    async for line in p.stdout:
        print(line)
    await p.wait()

## Future
> http://blog.gusibi.com/post/python-concurrency-with-futures/
Future 是 concurrent.futures 模块和 asyncio 包的重要组件。从Python3.4起，标准库中有两个为Future的类：concurrent.futures.Future 和 asyncio.Future。这两个Future作用相同。

Future 是抽象的Task, Task is subclass of Future, Future 也是一种Awaitable

1. Encapsulates(包括) the asynchronous execution of a callable.
2. Future instances are created by `Executor.submit()` and should not be created directly except for testing.
3. Future could wrap `coroutine` as task, and *store it's return value*
4. Future.set_result,result()

Future is Not thread safe!

### Future.executor.submit(包装多线程进程future)
#### ThreadPoolExecutor.submit
普通的函数包装成future, 类似这样:

    async def wait_thread(load_url):
        return ThreadPool(processes=1).apply_async(load_url, args).get()

来一个ThreadPool的例子
e.g. `[ThreadPoolExecutor.submit list], concurrent.futures.as_completed(futures)`

    import concurrent.futures, urllib.request
    URLS = ['http://baidu.com','https://qq.cn']
    def load_url(url,timeout):
        with urllib.request.urlopen(url, timeout=timeout) as conn:
            return conn.read()

    with concurrent.futures.ThreadPoolExecutor(max_workers=5) as executor:
        future_to_url = {executor.submit(load_url, url, 60): url for url in URLS}
        for future in concurrent.futures.as_completed(future_to_url):
            url=future_to_url[future]
            data = future.result()

#### ProcessPoolExecutor.submit

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

不用async , 用multiprocessing 也可以做到的(只不过asyncio更优雅)

    multiprocessing.Pool(4).apply_async(func, args).get() # get是阻塞的

### Future.executor.map(包装多线程进程)
map是有序的： [ProcessPoolExecutor](/demo/py/future-processpool-map.py)
as_completed 以及dict是无序的

    with concurrent.futures.ProcessPoolExecutor() as executor:
        for x in zip(nums, executor.map(is_prime, nums)):
            print(x)

### Future Objects Method
Future instances are created by future = asyncio.Future()

    future.cancel()
    Attempt to cancel the call. If the call is currently being executed then it cannot be cancelled and the method will return False,

    future.cancelled()
    Return True if the call was successfully cancelled.

    future.running()
    Return True if the call is currently being executed and cannot be cancelled.

    future.done()
    Return True if the call was successfully cancelled or finished running.

    future.result(timeout=None)
    Return the value returned by the call. If the call hasn’t yet completed then this method will wait up to timeout seconds.

    asyncio.sleep(delay, result=None, *, loop=None)

## Delayed calls
> asyncio.sleep is based on eventloop.call_later

The event loop has its own *internal clock* for computing timeouts. Which will generally be a different clock than `time.time()`.

    AbstractEventLoop.call_later(delay, callback, *args)
    AbstractEventLoop.call_at(when, callback, *args)
    AbstractEventLoop.time()
        Return the current time, as a float value, according to the event loop’s internal clock.

# uvloop
基于libuv 的asyncio event-loop 实现

    import asyncio,uvloop
    loop = uvloop.new_event_loop()
    asyncio.set_event_loop(loop)

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

# sanic
基于uvloop, python3.5+的类flask的高性能web框架

    from sanic import Sanic
    from sanic.response import json
    app = Sanic()

    @app.route('/')
    async def test(request):
        return json({'hello': 'ahui'})

    app.run(host='0.0.0.0', port=8000)