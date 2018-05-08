---
layout: page
title:
category: blog
description:
---
# Preface
1. exception
2. 调试包括print, assert, 
3. 使用logging/sentry/q(强烈推荐)
4. pdb/ipdb
3. perf 性能
1. 抛异常。在想要的位置异常，比如Flask的DEBUG的模式下，werkzeug里面的DebuggedApplication: 会把Web页面渲染成一个可调试和可执行的环境，直接到上面调试

2.
```
import sys
def debug_info():
    return {
        'file':sys._getframe().f_code.co_filename,
        'fileno':sys._getframe().f_lineno,
        'funcname':sys._getframe(0).f_code.co_name  ,
        'caller':sys._getframe(1).f_code.co_name　,
    }
```

## For More
Python 代码调试技巧: \
    https://www.ibm.com/developerworks/cn/linux/l-cn-pythondebugger/

# 异常

## exception

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

## raise异常
可以在except语句块后面加一个else，当没有错误发生时，会自动执行else语句：
```
class FooError(ValueError):
    pass
try:
	print('try...')
	r = 10 / int('2')
	print('result:', r)
except ValueError as e:
	print('ValueError:', e)
except ZeroDivisionError as e:
	print('ZeroDivisionError:', e)
except:
	print('no error!')
    raise FooError('invalid value:')
finally:
	print('finally...')
print('END')
```
More: raise语句如果不带参数，就会把当前错误原样抛出

### e

    raise Exception(*args)
    e.args

### 记录异常错误

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

### 抛出异常

	raise TypeError('invalid value: %s' % s)
	# 或
	except ValueError as e:
        print('ValueError!')
        raise

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

    (gdb) py-bt
    (gdb) py-list
    (gdb) pystack

## pdb
py/py-debug-pdb.md
