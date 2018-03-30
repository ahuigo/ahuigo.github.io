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

# inspect

    print(__file__)
    print(module.__file__)
    print(sys.argv[0])
    print(func.__class__) # "<class 'function'>"
    print(cls.__class__) # "<class 'type'>"

## class defined path

    import inspect
    inspect.getfile(C.__class__)
    inspect.getfile(C.__class__.__module__)

## inspect frame

    import inspect

    def PrintFrame():
      callerframerecord = inspect.stack()[1]    # 0 represents this line
                                                # 1 represents line at caller
      frame = callerframerecord[0]
      info = inspect.getframeinfo(frame)
      print info.filename                       # __FILE__     -> Test.py
      print info.function                       # __FUNCTION__ -> Main
      print info.lineno                         # __LINE__     -> 13

    def Main():
      PrintFrame()                              # for this line

## inspect source code

    inspect.getsourcelines(foo)

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
    frame.f_code.co_name          # frame name
    frame.f_locals          # locals for frame

    gen.gi_frame.f_lasti # 生成器当前的执行位置(字节码)
    >>> gen.gi_frame.f_lasti
    3
    >>> len(gen.gi_code.co_code) # 编译好的py代码
    56

simple get filename: `__file__` or `sys.argv[0]`

via `getframeinfo(frame)`:

      info = inspect.getframeinfo(frame)
      print info.filename                       # Test.py
      print info.function                       # Main
      print info.lineno                         # 13

## inspect caller and current
caller:

    sys._getframe(1).f_code.co_name
    inspect.stack()[1][3]

current function:

    def what_is_my_name():
        print(inspect.stack()[0][0].f_code.co_name)
        print(inspect.stack()[0][3])
        print(inspect.currentframe().f_code.co_name)
        print(sys._getframe().f_code.co_name)

## inspect function args
    print(inspect.getargspec(func)[0])
    print(inspect.getargspec(func).args)

