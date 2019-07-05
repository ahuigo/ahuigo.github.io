---
title: py-debug-log
date: 2018-09-28
---
# Preface
- logging
https://docs.python.org/3.4/howto/logging.html

## example

    import logging
    import sys
    formatmsg='%(asctime)s:%(levelname)s:%(filename)s:%(lineno)s:%(message)s'
    logging.basicConfig(format=formatmsg, filename='mvp.log', level=logging.DEBUG)

    # logger and stramHanler
    logger = logging.getLogger('mvp')
    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(logging.DEBUG)
    ch.setFormatter(logging.Formatter(formatmsg))
    logger.addHandler(ch)

    logger.debug('error message')
    logger.debug({'err':'error message'})


## autolog: excepthook

    import sys
    >>> def foo(exctype, value, tb):
    ...     print('My Error Information')
    ...     print('Type:', exctype)
    ...     print('Value:', value)
    ...     print('Traceback:', tb)
    ...
    >>> sys.excepthook = foo

## log with exc_info

    try:
        result = json.loads(s, strict=False)
    except (TypeError, ValueError):
        logger.debug('Can not decode response as JSON', exc_info=True)

## Logging to a single file from multiple processes
1. logging is thread-safe(这个可能要感谢GIL)
2. logging to a single file from multiple processes is not supported
    1. 不过如果是posix 兼容的系统，append < buf_size就是atomic, linux下应该是: 4096bytes

方案：
1. 独立的单进程socketHandler写log
2. 加锁, 甚至文件锁

### log lock
Python的logging模块是线程安全的，
1. 因为logging模块在输出日志时，都要获取一把锁，而这把锁是一把可重入锁，
2. 对于不同的线程，在打日志前都要等待这把锁变为可用状态，才能持有这把锁并执行提交逻辑

https://zhuanlan.zhihu.com/p/36310626?group_id=974774296987615232

# logging
logging，和assert比，logging不会抛出错误，而是可以输出到文件：

## log level
1. `debug，info，warning，error, fatal/critical`等几个级别重要性依次增加，
1. default level: *WARNING*

除了根logging.root, 不同的应用/子应用可以设定自己的logger, 进而分别设定不同filename

    >>> logging.root
    <RootLogger root (WARNING)>
    >>> wb = logging.getLogger('weibo')
    <Logger weibo (WARNING)>
    >>> wb = logging.getLogger('weibo.sub1')
    <Logger weibo.sub1 (WARNING)>
    >>> logging.getLogger('root')
    <Logger root (WARNING)> # 不是根root


### set level
logging.basicConfig(level=logging.DEBUG)
logger.setLevel()

>Note: basicConfig 第二次不再生效

## log file
    import logging
    logging.basicConfig(filename='example.log',level=logging.DEBUG)
    logging.debug('This message should go to the log file')
    logging.info('So should this{}', 'arg1')
    logging.warning('And this, too')

    $ cat example.log
    DEBUG:root:This message should go to the log file

If not remember messages from elarlier runs, use `filemode='w'`:

    logging.basicConfig(filename='example.log', filemode='w', level=logging.DEBUG)

logging file path(default by current path):

    logging.getLoggerClass().root.handlers[0].baseFilename
    logger.handlers[0].baseFilename

## format message

    logging.basicConfig(format='%(asctime)s:%(levelname)s:%(filename)s:%(lineno)s:%(message)s',  level=logging.DEBUG)
    logging.basicConfig(format='%(asctime)s:%(levelname)s:%(filename)s:%(lineno)s:%(message)s', filename='mvp.log', level=logging.DEBUG)
    INFO:a.py:1:So should this

[For more logrecord-attributes ](https://docs.python.org/3.4/library/logging.html#logrecord-attributes):

    %(asctime)s	Human-readable time:
    %(created)f time.time():
    %(filename)s %(lineno)d
    %(funcName)s

    %(thread)d
    %(threadName)s
    %(process)d

    %(pathname)s
    %(module)s

### format date
The default format for date/time display (shown above) is ISO8601.

    2003-07-08 16:49:45,896

define datefmt(see shell date):

    logging.basicConfig(format='%(asctime)s', datefmt='%Y/%m/%d %I:%M:%S %p')
    2010/12/12 11:46:36 PM

### level msg
    logger.error("Error while finding A from DB. a : {} and b : {}", a,b);

	logging.basicConfig(level=logging.INFO)
    logging.log(level, msg, *args, **kwargs)
    logging.fatal(msg, *args, **kwargs) CRITICAL
    logging.error(msg, *args, **kwargs) .exception()
    logging.warning(msg, *args, **kwargs)
    logging.info(msg, *args, **kwargs)
    logging.debug(msg, *args, **kwargs)
    logger.info/debug/...

# Advanced logging
## loggging components:
Log *event information* is passed between loggers, handlers, filters and formatters in a *LogRecord instance*.
1. Loggers expose the interface that application code directly uses.
2. Handlers send the log records (created by loggers) to the appropriate destination.
2. Filters provide a finer grained facility for determining which log records to output.
4. Formatters specify the layout of log records in the final output.

## loggers
loggers have threefold job
1. First, log messages at runtime.
2. Second, determine which messages to act upon based upon severity (the default filtering facility) or *filter* objects.
3. Third, logger objects pass along relevant log messages *to all interested log handlers*.

### loggers method
logger 不支持setFormatter, 那个是handler 支持的。只支持以下
- Logger.setLevel()
- logger.addHandler:
    Logger.addHandler() and Logger.removeHandler()
    logger.handlers[0].baseFilename
- addFilter()
    Logger.addFilter() and Logger.removeFilter()


logger send msg:
1. logger.error()/critical()
2. Logger.exception()  
    1. called *only in exception*
    2. like error(), except *dumps a stack trace along with it*
        `logger.exception(msg, _args)`，它等价于 `logger.error(msg, exc_info=True, _args)`
3. Logger.log() takes a log level as an explicit argument.

### loggers name and inheritante
1. loggers with names of `foo.bar, foo.bar.baz, and foo.bam` are all children of `foo`. 继承的东西包括
    1. level
    2. 不继承formatter
2. all loggers inheritante `root`! 
3. rootLogger 会创建handler: stderr (NOTSET)
    1. 调用logging.error,info,...,etc
    2. 调用logging.basicConfig时

Child loggers *propagate* messages up to *ancestor* loggers:
turn off propagate:

    logger.propagate=False

### loggers level
effective level is used to decide  whether to process an event, which is *inheritance* parental level.
getLogger 是单态的

    ```python
    >> b=logging.getLogger('b')
    <Logger b (WARNING)>
    >>> b.setLevel(20)
    >>> c=logging.getLogger('b.c')
    <Logger b.c (INFO)>
    ```

### loggers curd

#### create loggers
The root of the hierarchy of loggers is called the root logger.

    >>> import logging
    >>> logging.root.handlers[:]
    []
    >>> logging.error('1')
    ERROR:root:1
    >>> logging.root.handlers[:]
    [<StreamHandler <stderr> (NOTSET)>]

creat a new logger explicitly:

    >>> logging.Logger.manager.loggerDict
    {}
    >>> logging.getLogger(__name__) # return root logger if without args
    <Logger __main__ (WARNING)>
    >>> logging.Logger.manager.loggerDict
    {'__main__': <Logger __main__ (WARNING)>}


#### remove logger's handler

```
    for hander in logger.handlers[:]:
        logger.removeHandler(handler)
```

#### root logger
for `logging/__init__.py`, you'll see that basicConfig() *sets the handlers on the root logger* object *by calling addHandler()*.

    import logging
    for handler in logging.root.handlers[:]: # copy loop, dict用dict.items(), 不可用dict.keys()
        logging.root.removeHandler(handler)

The root logger is used by the functions `loggging.debug()/ info()/...`, which just call the same-named method of the root logger

    logging.info(msg):
        logging.root.info(msg)

## handler
One logger's default handler:
1. for root logger: [<StreamHandler <stderr> (NOTSET)>]
2. for other logger: ineritante parent loggers


### handlers category
see: https://docs.python.org/3.6/howto/logging.html#useful-handlers
1. file: logging.FileHandler(filename)
1. BaseRotatingFileHandler:
    1. RotatingFileHandler = logging.handlers.RotatingFileHandler( LOG_FILENAME, maxBytes=10**8, backupCount=5)
    2. TimedRotatingFileHandler
3. SysLogHandler
4. QueueHandler
5. SocketHandler:
6. StreamHandler: logging.StreamHandler(stream=sys.stderr) # open(filename)
7. null: logging.NullHandler()
8. flask 的smtpHandler

example add stdout:

    root = logging.getLogger('mblog')
    root.setLevel(logging.DEBUG)
    ch = logging.StreamHandler(sys.stdout)
    ch.setLevel(logging.DEBUG)
    ch.setFormatter(logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
    root.addHandler(ch)

### handlers method
like logger:
1. handler.setLevel() method, just as in logger objects
2. handler.addFilter() like logger
2. handler.setFormatter() (not logger)

#### hander destinations
1. writing log messages to:  files, HTTP GET/POST locations, email via SMTP, generic sockets, queues, or OS-specific logging mechanisms such as syslog or the Windows NT event log.
3. The default destination is `std.stderr`, if no handler

### hander msg
default msg format:
1. '%(message)s' 继承自parental loggers

## filter
几乎不用
instances of Filter can be added to both Logger and Handler instances

## Formatters
```
logging.Formatter.__init__(fmt=None, datefmt=None, style=’%’)
```
1. The default fmt is raw msg.
2. if no datefmt, default datefmt ISO8601:
```
%Y-%m-%d %H:%M:%S
```
3.  The style is one of %, ‘{‘ or ‘$’. default ‘%’
    1. the style is ‘%’, ` %(<dictionary key>)s` styled `LogRecord attributes`
    2. ‘{‘: `str.format()` (using keyword arguments)
    3. ‘$’: `string.Template.substitute()`

## configuring logging
Configure in three ways:
1. with code
2. with  fileConfig()
3. with  dictConfig()

Note:
> fileConfig()/dictConfig function takes a default parameter, disable_existing_loggers=True

configure code  example:

    import logging

    # create logger
    logger = logging.getLogger('simple_example')
    logger.setLevel(logging.DEBUG)

    # create console handler and set level to debug
    ch = logging.StreamHandler()
    ch.setLevel(logging.DEBUG)

    # create formatter
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')

    # add formatter to ch
    ch.setFormatter(formatter)

    # add ch to logger
    logger.addHandler(ch)

    # 'application' code
    logger.error('error message')

### config log with dictConfig()
in YAML format for the new dictionary-based approach:

    version: 1
    formatters:
    simple:
        format: 'simple:%(name)s - %(levelname)s - %(message)s'
    handlers:
    console:
        class: logging.StreamHandler
        level: DEBUG
        formatter: simple
        stream: ext://sys.stdout
    file:
        class : logging.handlers.RotatingFileHandler
        formatter: simple
        filename: logconfig.log
        maxBytes: 10240
        backupCount: 3
    loggers:
    simpleExample:
        level: DEBUG
        handlers: [console]
        propagate: yes
    simpleExample.a:
        level: DEBUG
        handlers: [console]
        propagate: yes
    root:
    level: DEBUG
    handlers: [console]

code:

    import logging, yaml
    import logging.config
    import logging.handlers
    logging.config.dictConfig(yaml.load(open('a.yaml')))
    s=logging.getLogger('simpleExample.a')
    s.error('abc')

测试下chrilden loggers inheritance: Output:
1. 依次是simpleExample.a, simpleExample, root产生的三个
2. 产生一个: simpleExample.a(propagate=no)
3. 产生两个: simpleExample.a(propagate=yes), simpleExample(propagate=no)
```
2017-10-05 18:04:28,658 - simpleExample.a - ERROR - abc
2017-10-05 18:04:28,658 - simpleExample.a - ERROR - abc
2017-10-05 18:04:28,658 - simpleExample.a - ERROR - abc
```
如果用`handlers:[console,file]`, 则两个都会执行

### config log with fileConfig:
```
confstr='''
[loggers]
keys=root,simpleExample

[handlers]
keys=consoleHandler

[formatters]
keys=simpleFormatter

[logger_root]
level=DEBUG
handlers=consoleHandler

[logger_simpleExample]
level=DEBUG
handlers=consoleHandler
qualname=simpleExample
propagate=0

[handler_consoleHandler]
class=StreamHandler
level=DEBUG
formatter=simpleFormatter
args=(sys.stdout,)

[formatter_simpleFormatter]
format=%(asctime)s - %(name)s - %(levelname)s - %(message)s
datefmt=
'''
with open('logging.conf', 'w') as f:
    f.write(confstr)

import logging
import logging.config
logging.config.fileConfig('logging.conf')

# create logger
logger = logging.getLogger('simpleExample')

# 'application' code
logger.critical('critical message')
```

#### classname in fileconf
The class names referenced in config files need to be:
1. either relative to the logging module: WatchedFileHandler (logging.handers.WatchedFileHandler)
2. or absolute values: mypackage.mymodule.MyHandler


## log flow
The flow of log event information in loggers and handlers is illustrated in the following diagram
![python-log-flow](/py/py-log-flow.png)