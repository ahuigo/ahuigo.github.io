---
title: py-debug-log-inspect
date: 2018-09-28
---
# Preface
1. traceback
2. inspect.getsource(func)

# traceback(exception+stack)
    ```
    import sys
    import traceback

    try:
        asdf
    except NameError:
        exc_type, exc_value, exc_traceback = sys.exc_info()
        lines = traceback.format_exception(exc_type, exc_value, exc_traceback)
        print ''.join('!! ' + line for line in lines)  # Log it or whatever here
    ```

This displays:

    ```
    !! Traceback (most recent call last):
    !!   File "<stdin>", line 2, in <module>
    !! NameError: name 'asdf' is not defined
    ```

## print_stack
stack example 2: print_stack(), format_stack()

	import traceback
	traceback.print_stack([file=sys.stderr]);
	#or
    stack_str = ''.join(traceback.format_stack())

## sys.exc_info

    traceback.format_exc()
    traceback.print_exc()
    err = sys.exc_info()[1]

# inspect

    print(__file__)
    print(module.__file__)
    print(sys.argv[0])
    print(func.__class__) # "<class 'function'>"
    print(cls.__class__) # "<class 'type'>"

## inspect path
current file + fileno:

    __file__
    sys._getframe().f_lineno

parent file + fileno:

## class defined path

    import inspect
    inspect.getfile(C.__class__)
    inspect.getfile(C.__class__.__module__)

## inspect frame

    import inspect

    def PrintFrame(*args):
      callerframerecord = inspect.stack()[1]    # 0 represents this line
                                                # 1 represents line at caller
      frame = callerframerecord[0]
      info = inspect.getframeinfo(frame)
      print(f'{info.filename}:{info.lineno}:{info.function}', args)

    def Main():
      PrintFrame()                              # for this line

包装一下

    def debug_print(*args, mode=None):
      callerframerecord = inspect.stack()[1]    
      frame = callerframerecord[0]
      info = inspect.getframeinfo(frame)

      color_red = f"\033[91m"
      color_end = f"\033[0m"
      print(f'{color_red}{info.filename}:{info.lineno}:{info.function}{color_end}', args)

## inspect source code

    file_name = inspect.getfile(func_foo)
    line_number = inspect.getsourcelines(func_foo)[1]

## inspect class

    import inspect
    inspect.getfile(moudle) #a module, class, method, function, traceback, frame, or code object

### code object
The difference between a code object and a function object is that:
1. the function object contains an explicit reference to the function’s globals (the module in which it was defined),
2. while a code object contains no context;

One way to create a code object is to use compile built-in function:

    >>> compile('sum([1, 2, 3])', '', 'single')
    <code object <module> at 0x19ad730, file "", line 1>
    >>> exec compile('sum([1, 2, 3])', '', 'single')
    6
    >>> compile('print "Hello world"', '', 'exec')
    <code object <module> at 0x19add30, file "", line 1>
    >>> exec compile('print "Hello world"', '', 'exec')
    Hello world

also, functions have the function attribute `__code__` ,while class has no `__code__`

    >>> def f(s): print s
    >>> f.__code__
    <code object f at 0x19aa1b0, file "<stdin>", line 1>

## frame

    # via sys
    sys._getframe() #current frame:
    sys._getframe(1) #caller frame:

    # via inspect.currentframe()
    inspect.currentframe() # current frame

    # via inspect.stack()
    inspect.stack()[0][0]   # current frame
    inspect.stack()[1][0]   # caller frame
    inspect.stack()[0][0].f_back   # caller frame

stack struct:

    inspect.stack()[1][0]   # frame
    inspect.stack()[1][1]   # frame filename
    inspect.stack()[1][2]   # frame fileno
    inspect.stack()[1][3]   # frame name(func/class/...)
    inspect.stack()[1][4]   # frame code

### frame info
eg:

    frame = inspect.currentframe()

    frame.f_code.co_filename    # filename
    frame.f_lineno          # lineno
        frame.f_back.f_lineno   # caller lineno
    frame.f_code.co_name          # frame name(func name)
    frame.f_locals          # locals for frame

    gen.gi_frame.f_lasti # 生成器当前的执行位置(字节码)
    >>> gen.gi_frame.f_lasti
    3
    >>> len(gen.gi_code.co_code) # 编译好的py代码
    56

simple get filename: `__file__` or `sys.argv[0]`

via `getframeinfo(frame)`获取结构化:

      info = inspect.getframeinfo(frame)
      print info.filename                       # Test.py
      print info.function                       # Main
      print info.lineno                         # 13

## inspect caller and current(important)
caller:

    sys._getframe(1).f_code.co_name
    inspect.stack()[1][3]

### current function
current function name:

    import inspect
    def current_fn_name():
        print(inspect.stack()[0][0].f_code.co_name)
        print(inspect.stack()[0][3])
        print(inspect.currentframe().f_code.co_name)
        print(sys._getframe().f_code.co_name)
    
current function:

    def self_func():
        from inspect import currentframe, getframeinfo
        cframe = currentframe()
        callerFrame = cframe.f_back
        func_name = getframeinfo(callerFrame)[2]
        callerFrame = callerFrame.f_back
        func = callerFrame.f_locals.get( # type: ignore
                func_name, callerFrame.f_globals.get( func_name) # type: ignore
        )
        return func

## inspect function args
    print(inspect.getargspec(func)[0])
    print(inspect.getargspec(func).args)