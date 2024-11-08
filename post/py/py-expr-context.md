---
title: Python 的Context Managers
date: 2018-09-28
---
# Context Managers
http://arnavk.com/posts/python-context-managers/
https://docs.python.org/3/library/contextlib.html
1. Context Managers are usually used for allocation and releasing of resources(eg. `with..as`),
2. Also useful for any pair of operations that need to be performed before or after a procedure.

在with 里面`return`, 还是会执行finnally

## try-finally
In simple terms, Context Managers make writing try-finally blocks easier.

    # In Python, code with common setup and teardown:

    setup()
    try:
        do_work()
    finally:
        teardown()

    # can be translated roughly to:
    cm = ContextManager()
    obj = cm.__enter__()
    try:
        do_work(obj)    # use obj as needed (see examples below)
    finally:
        cm.__exit__()

    # this can be written more succinctly using the `with` statement:
    with ContextManager() as obj:
        do_work()

The `with` keyword should return an object that follows the *Context Manager protocol*.
1. `__enter__` should return an object that is assigned to the variable after as.
By default it is None, and is optional. A common pattern is to return self and keep the functionality required within the same class.
2. `__exit__` is called on the original Context Manager object, not the object returned by `__enter__`.
If an error is raised in `__init__` or `__enter__` then the code block is never executed and `__exit__` is not called.
3. Once the code block is entered, `__exit__` is always called, even if an exception is raised in the code block.
4. If `__exit__` returns True, the exception is suppressed.


    class CManager(object):
        def __init__(self):
            print('__init__')

        def __enter__(self):
            print('__enter__')
            return self

        def __exit__(self, type, value, traceback):
            print('__exit__:', type, value)
            return True  # Suppress this exception

        def __del__(self):
            print('__del__', self)

    def f():
        with CManager() as c:
            for j in range(3):
                yield j
            print( 'doing something with c:', c)
            raise RuntimeError()
            print ('finished doing something')
        print("end")

    for i in f():
        print(i)

    """
    # outputs:
    __init__
    __enter__
    0
    1
    2
    doing something with c: <__main__.CManager object at 
    0x10430cfb0>
    __exit__: <class 'RuntimeError'>
    end
    __del__ <__main__.CManager object at 0x10430cfb0>
    """

## Generators contextmanager(enter: next(g), exit: StopIteration)
Simple context managers can also be written using Generators and the contextmanager decorator:
Note: 因为只执行一次next, 所以只能用一个yield

    from contextlib import contextmanager
    @contextmanager
    def tag(name):
        print("<%s>" % name, end="")
        yield
        print("</%s>" % name, end="")

    with tag("h1"):
        print("main")

    output:
    <h1> foo </h1>

## context with file

	f = open("new.txt", "w")
	print(f.closed)               # whether the file is open
	f.write("Hello World!")
	f.close()
	print(f.closed)

有了CM 后，当代码进入`with .. as f` 定义的环境时，调用`f.__enter()`, 离开时，自动调用`f.__exit__()` (f.close() 的多范式)

	with open("a.txt", "w") as f:
		print(f.closed) # False
		f.write("hello world!")

	print(f.closed) # True

可以查看到f 的magic method

	> dir(f)

## with locks

    # Make a lock
    lock = threading.Lock()

    # 1. Old-way to use a lock
    lock.acquire()
    try:
        print 'Critical section 1'
        print 'Critical section 2'
    finally:
        lock.release()
    Better

    # 2. New-way to use a lock
    with lock:
        print 'Critical section 1'
        print 'Critical section 2'

# with ignored

    try:
        os.remove('somefile.tmp')
    except OSError:
        pass

Better

    from contextlib import ignored
    with ignored(OSError):
        os.remove('somefile.tmp')

To make your own ignored context manager in the meantime:

    @contextmanager
    def MyIgnored(*exceptions):
        try:
            yield
        except exceptions:
            pass

    with MyIgnored(OSError, OtherError):
        os.remove('somefile.tmp')

## eg. with redirect stdout

    # Temporarily redirect standard out to a file and then return it to normal
    with open('help.txt', 'w') as f:
        oldstdout = sys.stdout
        sys.stdout = f
        try:
            help(pow)
        finally:
            sys.stdout = oldstdout

Better

    with open('help.txt', 'w') as f:
        with redirect_stdout(f):
            help(pow)

redirect_stdout is proposed for python 3.4, bug report.

To roll your own redirect_stdout context manager

    @contextmanager
    def redirect_stdout(fileobj):
        oldstdout = sys.stdout
        sys.stdout = fileobj
        try:
            yield fieldobj
        finally:
            sys.stdout = oldstdout

实际上contextlib.redirect_stdout() 已经提供了

# with closing
Return a context manager that closes thing upon completion of the block. This is basically equivalent to:

    from contextlib import contextmanager

    @contextmanager
    def closing(thing):
        # wrapped in try/finally  to trap any exceptions raised in the calling code
        try:
            yield thing
        finally:
            thing.close()

And lets you write code like this:

    from contextlib import closing
    from urllib.request import urlopen

    with closing(urlopen('http://www.python.org')) as page:
        for line in page:
            print(line)