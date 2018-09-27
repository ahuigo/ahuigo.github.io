---
layout: page
title: py-async
category: blog
description: 
date: 2018-09-28
---
# Preface
本文参考:
1. Python黑魔法 --- 异步IO（ asyncio） 协程
http://www.jianshu.com/p/b5e347b3a17c
2. Python Async/Await入门指南 
https://zhuanlan.zhihu.com/p/27258289

# 语法
带`async for p` 或者`await` 只能放到 async 函数，可以是`coroutine or async_gnerator`:
1. async_generator 不支持:`return`

    ```
    def function(): return 1
    def generator(): yield 1

    # 在3.5过后，我们可以使用async修饰将普通函数和生成器函数包装成异步函数和异步生成器。
    async def async_function(): return 1
    async def async_generator(): yield 1

    import types
    print(type(function) is types.FunctionType)
    print(type(generator()) is types.GeneratorType)
    print(type(async_function()) is types.CoroutineType)
    print(type(async_generator()) is types.AsyncGeneratorType)

    import inspect
    inspect.iscoroutine(async_function)
    inspect.isgenerator

    import asyncio
    asyncio.iscoroutine(someFunc)
    asyncio.iscoroutinefunction(someFunc)
    ```

## generator 生成器
传统的生产者-消费者模型是一个线程写消息，一个线程取消息，通过锁机制控制队列和等待，但一不小心就可能死锁。

如果改用协程，生产者生产消息后，直接通过yield跳转到消费者开始执行，待消费者执行完毕后，切换回生产者继续生产，效率极高：

	def consumer():
		r = 'init'
		while True:
			n = yield r
			if not n:
				return
			print('[CONSUMER] Consuming %s...' % n)
			r = '200 OK'

	def produce(c):
		print(c.send(None));# init, 等价于next(c), 返回第一个yield r， 并停止; 下一次send 是发送给 `n=`
		n = 0
		while n < 5:
			n = n + 1
			print('[PRODUCER] Producing %s...' % n)
			r = c.send(n)
			print('[PRODUCER] Consumer return: %s' % r)
		c.close()

	c = consumer()
	produce(c)

执行结果：

	[PRODUCER] Producing 1...
	[CONSUMER] Consuming 1...
	[PRODUCER] Consumer return: 200 OK
	[PRODUCER] Producing 2...
	[CONSUMER] Consuming 2...
	[PRODUCER] Consumer return: 200 OK
	....

注意到consumer函数是一个generator.

整个流程无锁，由一个线程执行，produce和consumer协作完成任务，所以称为“协程”，而非线程的抢占式多任务。

### yield from(>=3.3)
yield from(不是await )可以将generator 串联：

    def gen_234():
        yield 2
        yield 3
        yield 4

    def main():
        yield 1
        yield from gen_234()
        yield 5

    for element in main():
        print(element)  # 1,2,3,4,5

## async await 
asyncio 提供了默认的eventloop
1. async 是用来将`函数`转换为`协程`的语法api
1. yield from 等待的是一个生成器对象，
2. await 接收的是定义了`__await__`方法的 awaitable 对象。


    import asyncio
    import aiohttp

    async def fetch_page(session, url):
        response = yield from session.get(url)
        if response.status == 200:
            text = await response.text()
            print(text)
    loop = asyncio.get_event_loop()

    session = aiohttp.ClientSession(loop=loop)

    tasks = [
        asyncio.ensure_future(
            fetch_page(session, "http://bigsec.com/products/redq/")
        ),
        asyncio.ensure_future(
            fetch_page(session, "http://bigsec.com/products/warden/")
        )
    ]

    loop.run_until_complete(asyncio.wait(tasks))
    session.close()
    loop.close()

执行细节:

1. 首先实例化一个 eventloop，并将其传递给 aiohttp.ClientSession 使用，这样 session 就不用创建自己的事件循环。
2. eventloop 调度的是future 包装的task:
    1. 当代码运行到 yield from session.get(url)处，fetch_page 协程被挂起
    2. 隐式的将一个 Future 对象传递给事件循环
        1. session.get() 内部也是协程
        2. 只有当 session.get() 完成后，该任务才算完成。恢复其工作状态。
3. 所有任务才能结束，然后关闭 session 与 loop，释放连接资源。

summary: 
1. async/await 是协程api, 使用者目前并不能脱离 asyncio/curio 使用 async/await 编写协程代码
2. 协程基于eventloop 的调度

## future task loop
https://segmentfault.com/a/1190000012291369#articleHeader11

![](https://sfault-image.b0.upaiyun.com/385/432/3854323182-5a26464766e62_articlex)
当你写协程代码时，必须先去理解协程、生成器的区别，future 对象与 task 对象的职能，loop 的作用( 还不如学习golang)

### 4.3. 另一个Future

Python 里另一个 Future 对象是 concurrent.futures.Future，与 asyncio.Future 互不兼容，但容易产生混淆。concurrent.futures 是线程级的 Future 对象，当使用 concurrent.futures.Executor 进行多线程编程时用于在不同的 thread 之间传递结果。

## coroutine
- yield(generator): 中断返回; 不关心yield func() 内部有无yield
- await(coroutine+return): 等待过程+反复中断/挂起自身的协程，并等待另一个协程完成直到返回结果), 直到StopIteration; 关心内部的wait;
 	1. 可以合并多个coroutine/generator: `generator=asyncio.wait(generator/coroutine_list/generator_list)`
 	1. 执行coroutine 有几个方法：
		1. async 里面：
			1. await coroutine_func()
			2. result = [await fun() for fun in funcs if await coroutine_func()]
		1. 正文：coroutine.send(None) 同时结合try-send-catch
		2. 正文: event_loop.run_until_complete: `asyncio.get_event_loop().run_until_complete(coroutine_or_Awaitable/future(a special Awaitable))`

coroutine 的使用方式:

    async def async_function(): return 1

    try:
        async_function().send(None)
    except StopIteration as e:
        print(e.value)

### await 代替 StopIteration
    async def async_function():
        return 1

    async def await_coroutine():
        result = await async_function()
        print(result)
        return result

    def run(coroutine):
        try:
            coroutine.send(None)
        except StopIteration as e:
            return e.value

    a=run(await_coroutine())
    b=run(async_function())
    print(a,b) # 1,1

注意：await后面的对象需要是一个Awaitable(一个类实现了`__await__`方法)，generator/async_generator 都是没有这个的

    class Awaitable(metaclass=ABCMeta):
        __slots__ = ()

        @abstractmethod
        def __await__(self):
            yield

        @classmethod
        def __subclasshook__(cls, C):
            if cls is Awaitable:
                return _check_methods(C, "__await__")
            return NotImplemented

Coroutine类也继承了Awaitable，而且实现了send，throw和close方法。所以await一个调用异步函数返回的协程对象是合法的。

    class Coroutine(Awaitable):
        __slots__ = ()

        @abstractmethod
        def send(self, value):
            ...

        @abstractmethod
        def throw(self, typ, val=None, tb=None):
            ...

        def close(self):
            ...

        @classmethod
        def __subclasshook__(cls, C):
            if cls is Coroutine:
                return _check_methods(C, '__await__', 'send', 'throw', 'close')
            return NotImplemented

### asyncio.await: merge multiple Coroutine

    import asyncio
    async def async_func(sleep=.2):
        for i in range(4):
            x=await asyncio.sleep(sleep)
            r = "sleep%r %r: loop=%d, " % (sleep,x, i, )
            print(r)

    loop = asyncio.get_event_loop()
    res = loop.run_until_complete(async_func(0.1))
    # res = loop.run_until_complete(asyncio.wait([async_func(0.1), async_func(.3)]))

    loop.close()

### define coroutine
#### method coroutine
函数之外，类实例的普通方法也能用async语法修饰：

    import asyncio

    class ThreeTwoOne:
        async def begin(self):
            print(3)
            await asyncio.sleep(1)
            print(2)
            await asyncio.sleep(1)
            print(1)        
            await asyncio.sleep(1)
            return

    class ThreeTwoOne:
        @classmethod
        async def begin(cls):
            print(3)
            await asyncio.sleep(1)
            print(2)
            await asyncio.sleep(1)
            print(1)        
            await asyncio.sleep(1)
            return

    async def game():
        await ThreeTwoOne.begin()
        print('start')

#### async with: aenter and aexit
根据PEP 492中，async也可以应用到上下文管理器中，`__aenter__和__aexit__`需要返回一个Awaitable：

    class GameContext:
        async def __aenter__(self):
            print('game loading...')
            await asyncio.sleep(1)

        async def __aexit__(self, exc_type, exc, tb):
            print('game exit...')
            await asyncio.sleep(1)

    async def game():
        async with GameContext():
            print('game start...')
            await asyncio.sleep(2)

Note: GameContext 这里是coroutine, aenter/aexit 则是coroutine

#### asynccontextmanager
在3.7版本，contextlib中会新增一个asynccontextmanager装饰器来包装一个实现异步协议的上下文管理器：

    from contextlib import asynccontextmanager

    @asynccontextmanager
    async def get_connection():
        conn = await acquire_db_connection()
        try:
            yield
        finally:
            await release_db_connection(conn)

Note: get_connection 本身是async generator, conn/release 则是coroutine

#### async with context call

    from time import time

    class GameContext:
        async def __aenter__(self):
            self._started = time()
            print('game loading...')
            await asyncio.sleep(1)
            return self

        async def __aexit__(self, exc_type, exc, tb):
            print('game exit...')
            await asyncio.sleep(1)

        async def start(self):
            print('start time: ...', time()-self._started)
        async def __call__(self, *args, **kws):
            if args[0] == 'time':
                return time() - self._started

    async def game():
        async with GameContext() as ctx:
            print('game start...')
            await ctx.start()
            await asyncio.sleep(2)
            print('game time: ', await ctx('time'))

    import asyncio
    loop = asyncio.get_event_loop()
    res = loop.run_until_complete(game())
    loop.close()

# async for
满足这个协议, 比如: async generator; asyncio.streams.StreamReader

    @coroutine
    def __aiter__(self):
        return self

    @coroutine
    def __anext__(self):

来个例子：

    p = await asyncio.create_subprocess_exec('ping', '-c', '4', ip, stdout=asyncio.subprocess.PIPE)
    async for line in p.stdout:
        print(line)
    await p.wait()

## async generator
`>=python 3.6`: async generator 必须由coroutine 调用: `async for p in async_generator`, 它没有`send()`方法(所以也不支持`next()`)

### 执行async_generator
使用：
1. in coroutine/async generator：
	1. `async for p in async_generator(10): pass`
	1. `[p async for p in async_generator(10)], (p async for p in count(10))`
	1. async generator 不能使用`await async_generator`, 因为一般async_generator都没有实现`__await__`, await 的作用是：检查是否完成了任务

`async for p` 需要放到coroutine或者async_generator环境中

    import asyncio
    async def count(num=5):
        for i in range(num):
            await asyncio.sleep(0.1)
            yield i

    async def li():
        bucket = [p async for p in count(10)] # list: 1,2,3,...
        bucket = (p async for p in count(10)) # async_generator
        print(type(bucket))

    loop = asyncio.get_event_loop()
    res = loop.run_until_complete(li())
    loop.close()

类似的还有coroutine await

    result = [await fun() for fun in funcs if await condition()]

再来个复杂点的:

    async def li():
        bucket = [p async for p in count(10)] # list: 1,2,3,...
        bucket = (p async for p in count(10)) # async_generator
        print(type(bucket))
        print(id(bucket))
        yield bucket

    async def l():
        async for x in li():
            async for p in x:
                print(p)
                print(type(p))
                print(id(p))

#### async generator example for take tomatoes

    import random
    class Potato:
        @classmethod
        def make(cls, num, *args, **kws):
            potatos = []
            for i in range(num):
                potatos.append(cls.__new__(cls, *args, **kws))
            return potatos

    all_potatos = Potato.make(5)

    async def ask_for_potato():
        await asyncio.sleep(random.random()*2)
        all_potatos.extend(Potato.make(random.randint(1, 10)))


    async def take_potatos(num):
        count = 0
        while True:
            if len(all_potatos) == 0:
                await ask_for_potato()
            potato = all_potatos.pop()
            yield potato
            count += 1
            if count == num:
                break

    async def buy_potatos():
        bucket = []
        async for p in take_potatos(10):
            bucket.append(p)
            print(f'Got potato {id(p)}...')

    import asyncio
    loop = asyncio.get_event_loop()
    res = loop.run_until_complete(buy_potatos())
    # res = loop.run_until_complete(asyncio.wait[buy_potatos(), take_tomatoes()])
    loop.close()


#### async generator 需要实现aiter, anext
AsyncGenerator的定义，它需要实现__aiter__和__anext__两个核心方法，以及asend，athrow，aclose方法。

    class AsyncGenerator(AsyncIterator):
        __slots__ = ()

        async def __anext__(self):
            ...

        @abstractmethod
        async def asend(self, value):
            ...

        @abstractmethod
        async def athrow(self, typ, val=None, tb=None):
            ...

        async def aclose(self):
            ...

        @classmethod
        def __subclasshook__(cls, C):
            if cls is AsyncGenerator:
                return _check_methods(C, '__aiter__', '__anext__',
                                    'asend', 'athrow', 'aclose')
            return NotImplemented

# future
是一个特殊的coroutine(Awaitable),
下面观察一个asyncio中Future的例子：

    import asyncio

    future = asyncio.Future()

    async def coro1():
        await asyncio.sleep(1)
        future.set_result('data')

    async def coro2():
        print(await future)

    loop = asyncio.get_event_loop()
    loop.run_until_complete(asyncio.wait([
        coro1(),
        coro2()
    ]))
    loop.close()

两个协程在在事件循环中，协程coro1在执行第一句后挂起自身切到asyncio.sleep，而协程coro2一直等待future的结果，让出事件循环，计时器结束后coro1执行了第二句设置了future的值，被挂起的coro2恢复执行，打印出future的结果'data'。

future可以被await证明了future对象是一个Awaitable，进入Future类的源码可以看到有一段代码显示了future实现了__await__协议：

    class Future:
        ...
        def __iter__(self):
            if not self.done():
                self._asyncio_future_blocking = True
                yield self  # This tells Task to wait for completion.
            assert self.done(), "yield from wasn't used with future"
            return self.result()  # May raise too.

        if compat.PY35:
            __await__ = __iter__ # make compatible with 'await' expression

当执行await future这行代码时，future中的这段代码就会被执行，首先future检查它自身是否已经完成，如果没有完成，挂起自身，告知当前的Task（任务）等待future完成。

当future执行set_result方法时，会触发以下的代码，设置结果，标记future已经完成：

    def set_result(self, result):
        ...
        if self._state != _PENDING:
            raise InvalidStateError('{}: {!r}'.format(self._state, self))
        self._result = result
        self._state = _FINISHED
        self._schedule_callbacks()

最后future会调度自身的回调函数，触发`Task._step()` 告知Task驱动future从之前挂起的点恢复执行，不难看出，future会执行下面的代码：

    ```
    class Future:
        ...
        def __iter__(self):
            ...
            assert self.done(), "yield from wasn't used with future"
            return self.result()  # May raise too.
    ```
最终返回结果给调用方。

前面讲了那么多关于asyncio的例子，那么除了asyncio，就没有其他协程库了吗？

1. 你可以理解为，asyncio是使用async/await语法开发的协程库，而不是有asyncio才能用async/await，
2. 除了asyncio之外，curio和trio是更加轻量级的替代物，而且也更容易使用。

## asyncio
参考[/p/py/py-server.py]

使用async修饰的函数调用时会返回一个协程对象，await只能放在async修饰的函数里面使用:
1. await后面必须要跟着一个协程对象或Awaitable. 通过`__wait__`确认是否继续暂停等待
2. await的目的是等待协程控制流的返回，
3. 而实现暂停并挂起函数的操作是yield, yield 不可出现在coroutine中，而要放到Future中

### asyncio example

    import asyncio
    import contextlib

    async def ping(ip):
        p = await asyncio.create_subprocess_exec('ping', '-c', '4', ip, stdout=asyncio.subprocess.PIPE)
        async for line in p.stdout:
            print(line)
        await p.wait()


    async def main():
        await asyncio.wait([
            ping('8.8.8.8'),
            ping('8.8.4.4'),
        ])


    if __name__ == '__main__':
        with contextlib.closing(asyncio.get_event_loop()) as main_loop:
            main_loop.run_until_complete(main())