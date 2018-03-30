# Preface
参考：https://zhuanlan.zhihu.com/p/30056870
# CGI
原始的CGI 程序只是单纯的多进程fork 模式[/demo/py/socket-cgi.py]
这非常慢！！

# FastCGI
FastCGI则是预先启动多个cgi进程守候，不会重复fork, cgi处理完 等待下一个任务
- 与FastCGI不同，apache 搞了一套mod_python, 使得cpython 可以内嵌进去
- 后来PEP 333中定义了[WSGI](/p/py/py-server-framework.md)(Web Server Gateway Interface)，成为沿用至今的Python web开发的标准协议(server与app之间的约定)
    1. 绝大部分框架都遵守WSGI: 自带的wsgi, 以及flask/django/gunicorn
    2. 以gunicorn 为例: 一个著名的wsgi http服务器，它采用pre-fork模型来处理和转发请求给worker, 支持基本的SyncWorker(多个request要排队), 以及同时处理多个request的: ThreadWorker/AsyncWorker/GeventWorker/TornadoWorker...

## master-worker 模型
master-worker 就是producer-consumer:
1. 使用thread实现的话，如果修改公共变量, 还需要加threading.Lock().acquire/release
2. 使用concurrent.futures 提供更简单的ThreadPoolExecutor/ProcessPool API

伪代码：

    producer            consumer
    msgs = Queue()
    msgs.append(msg)
    condition.notify()    
                        msgs.pop(0)
    ...                 ...

### futures的多线程多进程
see [/p/py/async-asyncio](/p/py/py-async-asyncio)

### IO multiplexing
多线程多进程占用资源有点大，为解决C10K问题，就需要IO multiplexing节省资源.
同步与异步见[linux-process](/p/linux-process.md)

#### 水平触发与边缘触发
1. 水平触发：如果文件描述符可以非阻塞地进行IO调用，此时认为他已经就绪
2. 边缘触发：如果文件描述符自上次来的时候有了新的IO活动(新的输入)，触发通知

#### epool
基于事件驱动的(像epool) 衍生了大量的框架：
Tornado:
```
import tornado.ioloop, tornado.web
class MainHander(tornado.web.RequestHandler):
    def get(self):
        self.write('hello,ahui')
app = tornado.web.Application([r'/', MainHander])
app.listen(8888)
tornado.ioloop.IOLoop.current().start()
```
event-based library:
1. libevent, libev, libuv,greenlet等: 这些库用于实现协程等
    1. eventlet(python2 时协程库)
    2. gevent(eventlet 增强版)
        0. 基于greenlet和libevent: 它用到Greenlet提供的，封装了libevent事件循环的高层同步API
        1. inspired by eventlet, more consistent API, simpler implementation and better performance
        2. 其实用go 比gevent 牛逼多了
    3. asyncio 是python3 提供的官方协程库
2. Stackless Python: cpython 另一个实现，抛弃了cpython中的堆栈，用微线程"tasklet"取代，tasklet之间通过channel交换数据
2. Greenlet: 保留cpython 作为c extension，基于stackless实现, 通过switch将一个greenlet的控制权交给另一个greenlet ![greenlet-demo-sample](https://pic3.zhimg.com/v2-9c51c194e68ceeb897ab850c0cdc9d4e_b.jpg)
4. coroutine: 人性化，优雅，内存小

#### coroutine
1. 基于gevent的协程库 以及monkey patching[coroutine-gevent](/demo/py/coroutine-gevent.py)

# 代码自动加载
- Django的开发环境在Debug模式下就可以做到自动重新加载
- 利用reload 加载，但不是所有模块都能被重新载入, 且只适合于无副作用的模块
- 监控代码改动，一旦有改动，就自动重启服务器，适合debug模式开发:
    1. watchdog: `$ ./pymonitor.py app.py`[demo](p3-app/day-13)
        1. 利用watchdog接收文件变化的通知，如果是.py文件，就自动重启wsgiapp.py进程。
        2. 利用Python自带的subprocess实现进程的启动和终止，并把输入输出重定向到当前进程的输入输出中：
        4.  watchdog只能处理后端的, 介绍以下两个神器
            1. LiveReload：改动php, html，css，js都能重刷chrome
            2. selenium: 一般用于 Web UI自动化测试
            3. 还有mechanize这种自动控制多个浏览器做事的库，利用浏览器引擎等。
            2. LiveStyle：css双向绑定，在chrome改动css，代码自动更新；或者在代码改动css，chrome自动更新
    2. pip3 install gunicorn: gunicorn 本身就遵守wsgi的web server. 可搭配请求转给worker: flask/django，也可单独使用
    gunicorn --reload -b 127.0.0.1:8800 -k aiohttp.worker.GunicornWebWorker -w 1 -t 60 --reload app:app

# nginx+gunicorn

## gunicorn

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

    $ gunicorn rocket:app -p rocket.pid -b 0.0.0.0:8000 -D
    $ gunicorn --pythonpath . rocket:app -p rocket.pid -b 0.0.0.0:8000 -D
    $ PYTHONPATH=. gunicorn rocket:app -p rocket.pid -b 0.0.0.0:8000 -D
    $ cat rocket.pid
    63101
    $ kill -cat rocket.pid

### log
将启动时的python grammar error, exception 都记录到app.gun.log

    gunicorn app:app  --log-file app.gun.log

app log:

    app.logger.setHandler(logging.FileHandler('app.log'))

## nginx反向

    location / {
                proxy_pass http://127.0.0.1:8000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }