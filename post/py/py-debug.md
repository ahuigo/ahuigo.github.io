---
layout: page
title: py-debug
category: blog
description: 
date: 2018-09-28
---
# Preface
1. exception
2. 调试包括print, assert, 
3. 使用logging/sentry/q(强烈推荐)
4. pdb/ipdb
3. perf 性能
1. 抛异常。在想要的位置异常，比如Flask的DEBUG的模式下，werkzeug里面的DebuggedApplication: 会把Web页面渲染成一个可调试和可执行的环境，直接到上面调试

## sys 调用栈
getframe(0) 是`debug_info`本身，getframe(1) 是caller

    import sys
    def debug_info():
        return {
            'file':sys._getframe().f_code.co_filename,
            'fileno':sys._getframe().f_lineno,
            'funcname':sys._getframe(0).f_code.co_name,
            'caller':sys._getframe(1).f_code.co_name,
        }

## interactive
    import sys
    def foo(exctype, value, traceback):
        print('My Error Information')
        print('Type:', exctype)
        print('Value:', value)
        print('Traceback:', traceback)
        print('tb_frame', traceback.tb_frame)
        import code
        code.interact(local=locals())

    sys.excepthook = foo

## For More
Python 代码调试技巧: \
    https://www.ibm.com/developerworks/cn/linux/l-cn-pythondebugger/

# 异常
## 异常信息处理
### 异常的callstack
callstack 要利用到traceback

    except:
        import traceback
        print('异常的call stack:', traceback.format_exc()) 


### 异常信息叠加
可以把异常信息放到第二个参数

    try:
        raise Exception("msg1")
    except Exception as err:
        raise Exception("get upload url failed", err.args)
        reise e

## Exception对象

    e = Exception(obj1, obj2)
    e.args # (obj1,obj2)
    str(e)

### custom exception

    class CustomE(Exception):
        def __init__(self, message, errors):
            super().__init__(message, "argv2")
            self.errors = errors
    try:
        raise CustomE("msg", ["errors"])
    except Exception as e:
        print(e.args, e.errors, str(e))
        a = e

    
## global exception

    import sys
    def my_except_hook(exctype, value, traceback):
        if exctype == KeyboardInterrupt:
            print("KeyboardInterrupt...")
        print('Value:', value)
        print('tb_frame', traceback.tb_frame)
        sys.__excepthook__(exctype, value, traceback)
    sys.excepthook = my_except_hook

## decorator exception
    def user_exception(func):
        def func_wrapper(*args, **kwargs):
            try:
                return func(*args, **kwargs)
            except Exception as e:
                print(e)
                return None 
        return func_wrapper

## try catch finnaly else

	try:
		do sth.
    except ZeroDivisionError as e:
        print(e)
	except ValueError:
		raise
		raise ValueError('sth error!')
    except (RuntimeError, TypeError, NameError) as e:
        print("Unexpected error:", e)
        pass
	else:
		return None
	finally:
		do sth.

## exception type

    BaseException
     +-- SystemExit
     +-- KeyboardInterrupt
     +-- GeneratorExit
     +-- Exception
          +-- StopIteration

### SystemExit
exit(n), quit(n), sys.exit(n)都是一个东西: SystemExit(n); 
不影响 不影响finnaly 或者 catch BaseException; 

    1. SystemExit is raised by the `sys.exit()` function. 
    2. not accidentally caught by code that *catches Exception*.
    5. 不影响finnaly 或者 except BaseException
    3. When it is not handled, the Python *interpreter exits; no stack traceback* is printed. 

而`os._exit(n)` 直接调用C `_exit(n)` 直接中断！
1. The constructor accepts the same optional argument passed to sys.exit(). 
    1. If an integer,passed to C’s exit() function;
    2. if it is None, the exit status is zero;
    3. if it has another type (such as a string), the object’s value is printed and the exit status is one.

### debug mode

    PYTHONASYNCIODEBUG=1 python3 a.py

### logging.exception

	import logging

    try:
    	10 / 0
    except Exception as e:
        logging.exception(e)

通过配置，logging还可以把错误记录到日志文件里，方便事后排查。


	logging.basicConfig(filename='example.log',level=logging.DEBUG)
	logging.basicConfig(filename=logname,
                            filemode='a',
                            format='%(asctime)s,%(msecs)d %(name)s %(levelname)s %(message)s',
                            datefmt='%H:%M:%S',
                            level=logging.DEBUG)

logging file path(default by current path):

	logging.getLoggerClass().root.handlers[0].baseFilename


# 调试
调试包括print, assert, logging, pdb,ipdb,...

## assert 断言

	def foo(n):
		assert n != 0, 'n is zero!'
		return 10 / n

	foo(0)

如果断言失败，assert语句本身就会抛出AssertionError：

	AssertionError: n is zero!

Python解释器时可以用-O参数来关闭assert：

	$ python3 -O test.py

## gdb

    $ gdb python3 <pid>
    > bt
    > info threads


好像失效了: If you have Python extensions installed, you can enter:
https://wiki.python.org/moin/DebuggingWithGdb
On linux, you can attach gdb to the process and get a python stack trace with some gdb macros. Put http://svn.python.org/projects/python/trunk/Misc/gdbinit in ~/.gdbinit, then

    (gdb) py-bt
    (gdb) py-list
    (gdb) pystack

## pdb
py/py-debug-pdb.md

## signal(when exec)
https://stackoverflow.com/questions/132058/showing-the-stack-trace-from-a-running-python-application

    import code, traceback, signal

    def debug(sig, frame):
        """Interrupt running process, and provide a python prompt for
        interactive debugging."""
        d={'_frame':frame}         # Allow access to frame object.
        d.update(frame.f_globals)  # Unless shadowed by global
        d.update(frame.f_locals)

        i = code.InteractiveConsole(d)
        message  = "Signal received : entering python shell.\nTraceback:\n"
        message += ''.join(traceback.format_stack(frame))
        i.interact(message)

    def listen():
        signal.signal(signal.SIGUSR1, debug)  # Register handler

To use, just call the listen() function at some point when your program starts up, and let it run. At any point, send the process a SIGUSR1 signal, using kill, or in python:

    os.kill(pid, signal.SIGUSR1)

This will cause the program to break to a python console at the point it is currently at, 
1. showing you the stack trace, and letting you manipulate the variables. 
2. Use control-d (EOF) to continue running (though note that you will probably interrupt any I/O etc at the point you signal, so it isn't fully non-intrusive.