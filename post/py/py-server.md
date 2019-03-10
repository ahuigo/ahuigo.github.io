---
title: py-server
date: 2018-10-04
---
# Preface
参考：https://zhuanlan.zhihu.com/p/30056870

## CGI
原始的CGI 程序只是单纯的多进程fork 模式[/demo/py/socket-cgi.py]
这非常慢！！

## FastCGI
1. FastCGI则是预先启动多个cgi进程守候，不会重复fork, cgi处理完 等待下一个任务
2. slave process 存在惊群问题：就是多个slave 同时listen 同一fd, 所以listen 要[加锁]`FCGI_LOCK(req->listen_socket);`

## nginx 惊群
> https://zhu327.github.io/2018/08/29/gunicorn%E4%B8%8Euwsgi%E4%B9%8B%E6%88%91%E8%A7%81/
Linux 2.6内核更新以后多个进程accept只有一个进程会被唤醒, 但是如果使用epoll还是会产生惊群现象.

Nginx为了解决epoll惊群问题, 使用进程间互斥锁, 只有拿到锁的进程才能把listen fd加入到epoll中, 在accept完成后再释放锁.

但是在高并发情况下, 获取锁的开销也会影响性能, 一般会建议把锁配置关掉. 直到Nginx 1.9.1更新支持了socket的SO_REUSEPORT选项, 惊群问题才算解决, listen socket fd不再是在master进程中创建, 而是每个worker进程创建一个通过`SO_REUSEPORT` 选项来复用端口, 内核会`自行选择一个fd来唤醒`, 并且有负载均衡算法.

## WSGI and uwsgi
> 更多：https://zhu327.github.io/2018/08/29/gunicorn%E4%B8%8Euwsgi%E4%B9%8B%E6%88%91%E8%A7%81/

后来PEP 333中定义了[WSGI](/p/py/py-server-framework.md)(Web Server Gateway Interface)，成为沿用至今的Python web开发的标准协议(server与app之间的约定)
1. 绝大部分app框架都遵守WSGI: 自带的wsgi, 以及flask/django
3. gunicorn: WSGI 协议，并发性不好，不支持http1.1. 还有玩具：wsgiref/Werkezug
    1. 以gunicorn 它采用pre-fork模型来处理和转发请求给worker,
    2. 支持基本的SyncWorker(多个request要排队), 以及同时处理多个request的: ThreadWorker/AsyncWorker/GeventWorker/TornadoWorker...
2. uWSGI是一个Web服务器: Master+Worker 配合 gevent 携程支持高并发(uWSGI c语言写的)
    1. 自创了uwsgi协议,每个packet 前4字节是传输信息类型：实现了WSGI协议、uwsgi协议、http协议等

bench: http://klen.github.io/py-frameworks-bench/

# python 架构演进
作者谈到了4个阶段：https://zhu327.github.io/2018/07/19/python%E5%90%8E%E7%AB%AF%E6%9E%B6%E6%9E%84%E6%BC%94%E8%BF%9B/
1. 传统：
   1. gunicorn+ uWSGI() 配合 gevent 携程支持高并)
   2. Redis连接数过多 使用redis-py自带的连接池来实现连接复用
    3. MySQL连接数过多 使用djorm-ext-pool连接池复用连接
    4. RabbitMQ 将导步任务给Celery（配置gevent支持并发任务）
2. 服务拆分：
   1. 每一个服务都有一个完整的认证过程, 认证又依赖于用户中心的数据库, 修改认证时需要重新发布多个服务
2. 微服务架构
   1. 接入层: 引入了基于OpenResty的`Kong API Gateway`, 定制实现了认证, 限流等插件. 
   2. 发布新的服务时: 发布脚本中调用`Kong admin api`注册服务地址到Kong, 并加载api需要使用插件
   3. 相互调用问题: 维护了一个基于`gevent+msgpack`的RPC服务框架`doge`, 借助于`etcd做服务治理`
3. 新：解耦数据层
   1. 接入层Kong + 服务层Doge + 数据层etcd

# 并发模型
### futures的多线程多进程
see [/p/py/async-asyncio](/p/py/py-async-asyncio)

### IO multiplexing(single cpu)
多线程多进程占用资源有点大，为解决C10K问题，就需要IO multiplexing节省资源.
同步与异步见[linux-process](/p/linux-process.md)

#### 水平触发与边缘触发
1. 水平触发：如果文件描述符可以非阻塞地进行IO调用，此时认为他已经就绪
2. 边缘触发：如果文件描述符自上次来的时候有了新的IO活动(新的输入)，触发通知

#### epool vs coroutine
直接操作epoll去构造维护事件的循环，从底层到高层的业务逻辑需要层层回调，造成callback hell，并且可读性较差。所以:
1. 这个繁琐的注册回调与回调的过程得以封装，并抽象成EventLoop。
2. EventLoop屏蔽了进行epoll系统调用的具体操作。
3. 对于用户来说，将不同的I/O状态考量为事件的触发，只需关注更高层次下不同事件的回调行为。诸如libev, libevent之类的使用C编写的高性能异步事件库已经取代这部分琐碎的工作。

基于事件驱动的(像epool) 衍生了大量的框架, 比如

    1.tornado: tornado框架自己实现的IOLOOP;
    2.picoev: meinheld(greenlet+picoev)使用的网络库，小巧轻量，相较于libevent在数据结构和事件检测模型上做了改进，所以速度更快
    3.uvloop: uvloop是个高性能的异步非阻塞框架，比Asyncio更加快速. uvloop继承自libuv使用Cython编写，性能比nodejs还要高
    4. libevent, libev, libuv,greenlet等: 这些库基于协程等
        1.libevent/libev: Gevent(greenlet+前期libevent，后期libev)使用的网络库，广泛应用;
        1. eventlet(python2 时协程库)
        2. gevent(eventlet 增强版)
            1. 基于greenlet和libevent: 它用到Greenlet提供的，封装了libevent事件循环的高层同步API
            2. inspired by eventlet, more consistent API, simpler implementation and better performance
            3. 其实用go 比gevent 牛逼多了
        3. asyncio 是python3 提供的官方协程库
    5. Stackless Python: cpython 另一个实现，抛弃了cpython中的堆栈，用微线程"tasklet"取代，tasklet之间通过channel交换数据
    6. Greenlet: 保留cpython 作为c extension，基于stackless实现, 通过switch将一个greenlet的控制权交给另一个greenlet ![greenlet-demo-sample](https://pic3.zhimg.com/v2-9c51c194e68ceeb897ab850c0cdc9d4e_b.jpg)

EventLoop处理事件触发时的回调比较麻烦: 有了协程(gevent/asyncio/curio 人性化，优雅，内存小)

1. golang 的 goroutine，luajit 的 coroutine，Python 的 gevent,erlang 的 process，scala 的 actor 等。
1. 基于gevent的协程库 以及monkey patching[coroutine-gevent](/demo/py/coroutine-gevent.py)

# 代码自动加载
- Django的开发环境在Debug模式下就可以做到自动重新加载
- 利用reload 加载，但不是所有模块都能被重新载入, 且只适合于无副作用的模块
- 监控代码改动，一旦有改动，就自动重启服务器，适合debug模式开发:
    1. watchdog: 
    2. 其他: watchdog只能处理后端的, 介绍以下两个神器
        1. LiveReload：改动php, html，css，js都能重刷chrome
        2. selenium: 一般用于 Web UI自动化测试
        3. 还有mechanize这种自动控制多个浏览器做事的库，利用浏览器引擎等。
        4. LiveStyle：css双向绑定，在chrome改动css，代码自动更新；或者在代码改动css，chrome自动更新
    3. pip3 install gunicorn: gunicorn 本身就遵守wsgi的web server. 可搭配请求转给worker: flask/django，也可单独使用

## watchdog
用watchdog 提供的watchmedo

    $ pip install watchdog -U
    $ watchmedo shell-command --patterns="*.py;*.html;*.css;*.js" --recursive --command='kill -HUP `cat app.pid`' . &

还有

    from watchdog.observers import Observer
    from watchdog.events import FileSystemEventHandler

    observer = Observer()
    observer.schedule(MyFileSystemEventHander(restart_process), path, recursive=True)
    observer.start()
    log('Watching directory %s...' % path)
    start_process()
    try:
        while True:
            time.sleep(0.5)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()

# greenlet
gevent 是基于greenlet， greenlet封装了libevent+yield 的事件循环高层同步API, 所以它是基于生成器的

    >>> from greenlet import greenlet
    >>> def foo1():
    ...   print "foo1.1"
    ...   gr2.switch()
    ...   print "foo1.2"
    ... 
    >>> def foo2():
    ...   print "foo2.1"
    ...   gr1.switch()
    ...   print "foo2.2"
    ... 
    >>> gr1 = greenlet(foo1)
    >>> gr2 = greenlet(foo2)
    >>> gr1.switch()
    foo1.1
    foo2.1
    foo1.2

# nginx+gunicorn

## gunicorn
比起uWSGI来说，Gunicorn对于“协程”也就是Gevent的支持会更好更完美。

    --log-level "debug" 
    PYTHONUNBUFFERED=TRUE
    -R, --enable-stdio-inheritance

rocket.py:

    from flask import Flask
    app = Flask(__name__)

    @app.route('/')
    def index():
        return "Hello World!"

    if __name__ == '__main__':
        app.run('0.0.0.0', 80, debug=True)

run:

    $ gunicorn rocket:app -w 8 -p rocket.pid -b 0.0.0.0:8000 -D
    $ gunicorn --pythonpath . rocket:app -p rocket.pid -b 0.0.0.0:8000 -D
    $ PYTHONPATH=. gunicorn rocket:app -p rocket.pid -b 0.0.0.0:8000 -D
    $ kill -9 `cat rocket.pid`

### -k,--worker-class
指定异步模式

    sync
    eventlet 
    gevent 
    tornado
    gthread
    aiohttp.worker.GunicornWebWorker (asyncio)

e.g.

    gunicorn --reload -b 127.0.0.1:8800 -k aiohttp.worker.GunicornWebWorker -w 1 -t 60 --reload app:app
    nohup gunicorn -k gevent dmonitor.wsgi:application -b 0.0.0.0:8009 -w 4 &

worker 官方推荐(如果阻塞多，可以再增加)

    worker_num = (2 x $num_cores) + 1

### log
将启动时的python grammar error, exception 都记录到app.gun.log

    gunicorn app:app  --log-file app.gun.log
    nohup gunicorn app --capture-output &
    nohup gunicorn app --capture-output --log-file app.gun.log --log-level=debug

app log:

    app.logger.setHandler(logging.FileHandler('app.log'))

debug log:

    --log-level=debug

### gevent
http://xiaorui.cc/2017/02/16/%E6%B7%B1%E5%85%A5%E7%90%86%E8%A7%A3uwsgi%E5%92%8Cgunicorn%E7%BD%91%E7%BB%9C%E6%A8%A1%E5%9E%8B%E4%B8%8A/

gunicorn 默认使用同步阻塞的网络模型(-k sync)，改用高并发的：gevent(epoll 监听模型)或meinheld 等worker class

    gunicorn -k gevent app:app
        -k aiohttp.worker.GunicornWebWorker

gevent 是协程+异步IO的库(epoll)
1. gevent 的采用的epoll 监听模型，flask 本身是单进程单线程的，gevent通过epoll 实现对多事件的监听
2. 每个连接由gevent的一个协程处理：从accept、parse http protocol、response 都是在一个gevent协程里面专属app=Flask('')处理
3. gevent 要求业务是非阻塞型的: `while True: checkFd then yield`, 或者 兼容gevent的patch
    4. time.sleep() 支持gevent patch
        from gevent import monkey
        monkey.patch_all()

### conf

    $ gunicorn -c gun.conf app:app
    import os
    bind = '127.0.0.1:5000'
    workers = 4
    backlog = 2048
    worker_class = "sync"
    debug = True
    proc_name = 'gunicorn.proc'
    pidfile = '/tmp/gunicorn.pid'
    logfile = '/var/log/gunicorn/debug.log'
    loglevel = 'debug'

### pstree
    pstree -alp
    ├─gunicorn,27763 /usr/bin/gunicorn cli.sub:app --reload -t 7200 -D
    │   └─gunicorn,27768 /usr/bin/gunicorn cli.sub:app --reload -t 7200 -D
    │       ├─{gunicorn},27786 <thread>
    │       └─{gunicorn},27787 <thread>

### profiler
/demo/py-demo/wsgi_profiler.py
