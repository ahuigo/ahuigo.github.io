---
layout: page
title: py-func
category: blog
description: 
date: 2018-09-28
---
# Preface

函数式编程

# call func
getattr(foo, 'bar')()
locals()['bar']()
globals()['bar']()

## exec func by name

    locals()["myfunction"]()
    globals()["myfunction"]()

or 

    import foo
    getattr(foo, 'bar')()

## access var accross file
settings.py

    myList = []

Next, your subfile.py can import globals:

	import settings
	settings.myList.append('hey')


# function

## locals()
var 默认:

- outside-exist (global)
- non-exists (local)

nonlocal(python3):

    def f1():
        x = 5
        def f2():
                nonlocal x
                x+=1
        return f2

强制global:

	def func(s1,s2=None):
		global X;		#放在使用前
		print global_var
		func.count++
		local_var=4
		retrun s1,s2

	s1,s2, _ = func("-%s-" % 'Hello','-%s-' % 'Hilo' 'jack')
	print s1,s2

output:

	-Hello- -Hilojack-

exec's modfications to locals should not be attempted:

    def foo():
        exec("a=3")
        print(locals()['a']) # right
        print(a) # wrong

    def foo():
        ldict = locals()
        exec("a=3",globals(),ldict) # 绑定环境locals/globals 
        print(ldict['a'])

### locals 与闭包
内部函数outer访问 *外部函数局部作用域中变量* 的行为：就是闭包；内部函数
如果读取local 变量，那么会按照照LEGB 规则(先局部冒泡locals，再`globals()`, 再查内置) 去读取上下文中最近的同名变量;

    def outer():
        msg = 'hello world'
        def inner():
            # msg = msg + 1 这里带赋值，就是非法的: 读取赋值则UnboundLocalError: local variable 'a' referenced before assignment
            print(msg)
        return inner
    outer()()

闭包遵守
1. inner能访问outer及其祖先函数的命名空间内的变量(局部变量冒泡查找，函数参数), globals, 内置变量。
2. 调用outer已经返回了，但是它的命名空间被返回的inner对象引用，所以还不会被回收

以下global msg 会因为globals()中不存在msg 而报错

    def outer():
        msg = 'hello world'
        def inner():
            global msg # 类似于php: msg = &globals()['msg']
            print(msg)
        return inner
    outer()()

其实: `inner.__globals__ == outer.__globals__ == globals()`所有的对象都共用一个globals

#### code 对象保存闭包变量
code对象是指代码对象，表示编译成字节的的可执行Python代码，或者字节码。主要属性：

	co_name：函数的名称
	co_nlocals: 函数使用的局部变量的个数
	co_varnames: 一个包含局部变量名字的元组
	co_cellvars: 是一个元组，包含嵌套的函数所引用的局部变量的名字
	co_freevars: 是一个元组，保存使用了的外层作用域中的变量名
	co_consts： 是一个包含字节码使用的字面量的元组
	__closure__: 多个cell 对象元组，包含freevars 外层作用域变量的引用

    inspect.getmembers(f.__code__)

e.g.:

    def foo():
        a = 1
        b = 2
        c = 3
        def bar():
            return a + 1
        def bar2():
            return b + 2
        return bar
    bar = foo()
    # 外层函数
    print(foo.__code__.co_cellvars) # ('a', 'b') 因为内部嵌套的bar/bar2 占用了a/b
    print(foo.__code__.co_freevars) # 没有占用外层作用域中的变量名
    # 内层嵌套函数
    print(bar.__code__.co_cellvars) # 没有内层嵌套
    print(bar.__code__.co_freevars) # ('a') 占用外层作用域中的a

    # closure cell list，包含freevars变量引用
    print(foo.__closure__)   # None
    print(bar.__closure__)  # cell list: foo.a
    print(bar.__closure__[0].cell_contents == 1)  # True


## globals
globals 包含全局的变量

    >>> def func():
    ...     pass
    ...
    >>> globals()
    {'func': <function func at 0x10f5baf28>}

类似用类创建函数:

    class NoName(object):
        def __call__(self):
            pass

    func = NoName()

## define func annotation

    def add(x:int, y:int) -> int:
        return x + y

For example, the following annotation:

    def foo(a: 'x', b: 5 + 6, c: list) -> max(2, 9):
    
would result in an `__annotations__` mapping of

    {'a': 'x',
    'b': 11,
    'c': list,
    'return': 9}

## bind

	import functools
	nday = functools.partial(func,param1, params2...)

    from functools import partial 
    from collection import defaultdict
    arr = defaultdict(partial(defaultdict, int))
    arr['i']['j']

## static var

	def foo():
		foo.counter += 1
		print "Counter is %d" % foo.counter
	foo.counter = 0

or:

	def foo():
		try:
			foo.counter += 1
		except AttributeError:
			foo.counter = 1

终极(see decorator):

	def static_vars(**kwargs):
        def decorate(func):
            for k,v in kwargs.items():
                setattr(func, k, v)
            return func
        return decorate; 

	@static_vars(counter=0)
	def foo():
        print("Counter is %d" % foo.counter)
        foo.counter += 1

# args
## destruct args
    *args, **kw

    l = [*l1, *l2]
    l = l1+l2

## find def args name:

>>> func = lambda x, y: (x, y)
>>> func.__code__.co_varnames
('x', 'y')

## default args
默认参数必须指向不变对象！因为它是一个static_vars

    def add_end(L=[]):
        L.append('END')
        print(id(L))
        return L
    >>> add_end()
    123
    ['END']
    >>> add_end()
    123
    ['END', 'END']

或者每次使用时，将static vars 初始化：

    def add_end(L=None):
        if L is None: L = []

## positional args
传参时，也可以按照named args 的方式传入

	def f(a,b,c):
	    print(a,b,c) # 1 3 2

	f(**{'a':1,'c':2,'b':3})
	f(a=1,c=2,b=3) # 1 3 2

## tuple args
可变参数定义, `f(*list)`：

	def func(*tuple_args):
		s1,s2 = tuple_args

使用

	>>> nums = [1, 2, 3]
	>>> nums = (1, 2, 3)
	>>> calc(nums[0], nums[1], nums[2])
	   (nums[0], nums[1], nums[2])
	>>> calc(*nums)
	   nums

## keyword args
关键字参数`f(**dict)`,`f(key1=v1,key2=v2)`

	def person(name, age, **kw):
		print('name:', name, 'age:', age, 'other:', kw)

	>>> extra = {'city': 'Beijing', 'job': 'Engineer'}
	>>> person('Jack', 24, city=extra['city'], job=extra['job'])
	name: Jack age: 24 other: {'city': 'Beijing', 'job': 'Engineer'}

当然，上面复杂的调用可以用简化的写法：

	>>> extra = {'city': 'Beijing', 'job': 'Engineer'}
	>>> person('Jack', 24, **extra)
	name: Jack age: 24 other: {'city': 'Beijing', 'job': 'Engineer'}

## named kw args
如果要限制关键字参数的名字，就可以用命名关键字参数，例如，只接收city和job作为关键字参数。这种方式定义的函数如下：

	def person(name, age, *, city='bj', job):
		print(name, age, city, job)

`*`后面的参数被视为命名关键字参数, 传参时必须带参数名
`*`前面的参数可带可不带参数名

	>>> person('Jack', 24, job='Engineer')

也可以使用`*list`:

	def person(name, age, *list, city='bj', job):
		print(name, age, list, city, job)

## 各种参数
定义一个函数，包含上述若干种参数：

	def f1(a, b, c=0, *args, **kw):
		print('a =', a, 'b =', b, 'c =', c, 'args =', args, 'kw =', kw)
    f1(1,2,'c',arg1,arg2,arg3,k1=1,k2=2)
    f1(1,2,'c',*list,**dict)

	def f2(a, b, c=0, *, d, **kw):
		print('a =', a, 'b =', b, 'c =', c, 'd =', d, 'kw =', kw)
    f2(1,2,3,d=1,kw={1:2})

关于传参扩展：
1. `call f(*list)` 会被展开成f(item1,item2,...)
1. `call f(**kw)` 会被展开成f(k1=v1,...) ,要求k1为string, dict 则不要求key为string.
2. `def f(*list)` 只接收no-named-args
2. `def f(*list)` 只接收keyword argument

eg:

    def f2(*l,**kw):
        print(l,kw)
    > f2(0, *(1,2,3),a=1,**{'1':1,'k':3})
    (0, 1, 2, 3) {'a': 1, '1': 1, 'k': 3}


# lambda function

	func = lambda x, y: x + y
	func = (lambda x, y: x + y)
	func(1,2)

lambda 不能显式使用return :

	# error
	func = lambda x, y: return x + y

## 闭包返回函数的绑定变量
我们来看一个例子：

	def count():
		fs = []
		for i in range(1, 4):
			def f():
				 return i*i
			fs.append(f)
		return fs

	f1, f2, f3 = count()

在上面的例子中，每次循环，都创建了一个新的函数，然后，把创建的3个函数都返回了。

你可能认为调用f1()，f2()和f3()结果应该是1，4，9，实际上三个函数式共享变量i：

	>>> f1()
	9
	>>> f2()
	9
	>>> f3()
	9

全部都是9！原因就在于返回的函数引用了变量i，但它并非立刻执行。等到3个函数都返回时，它们所引用的变量i已经变成了3，因此最终结果为9。

返回闭包时牢记的一点就是：返回函数*不要引用任何循环变量，或者后续会发生变化的变量*。

如果一定要引用循环变量怎么办？方法是*再创建一个函数，用该函数的参数绑定循环变量当前的值*，无论该循环变量后续如何更改，已绑定到函数参数的值不变：

	def count():
		def f(j):
			def g():
				return j*j
			return g
		fs = []
		for i in range(1, 4):
			fs.append(f(i)) # f(i)立刻被执行，因此i的当前值被传入f()
		return fs

也可以使用后面介绍的functools.partial

    functools.partial(lambda j:j*j,j)

# map reduce
http://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/0014317852443934a86aa5bb5ea47fbbd5f35282b331335000

Python内建了map-reduce/filter/all/any 实现函数式编程

## map(generator)
我们先看map。map()函数接收两个参数，一个是函数，一个是Iterable，map将传入的函数依次作用到序列的每个元素，并把结果作为新的Iterator返回。

	>>> def f(x):
	...     return x * x
	...
	>>> r = map(f, [1, 2, 3, 4, 5, 6, 7, 8, 9])
	>>> r = map(lambda x: str(x), "123")

	# map 针对一个序列
	print map(lambda x: x*2, [4, 5, 6])

	# map 针对多个序列
	print map(lambda x, y: x + y, [1, 2, 3], [4, 5, 6])

	# map 字典, 字典本身是对key 迭代
    >>> for i in map(lambda x, y: x + y, {'a':1, 'b':2}, {'c':3}): print(i)
    ...
    ac
    >>> for i in map(lambda x, y: x + y, {'a':1, 'b':2}, {'c':3, 'd':4}): print(i)
    ...
    ac
    bd

map()传入的第一个参数是f，即函数对象本身。由于结果r是一个Iterator，Iterator是惰性序列，因此通过list()函数让它把整个序列都计算出来并返回一个list。

	>>> list(map(str, [1, 2, 3, 4, 5, 6, 7, 8, 9]))
	['1', '2', '3', '4', '5', '6', '7', '8', '9']

## zip

	>>> list(zip([4, 5, 6], [5,6,7]))
	[(4, 5), (5, 6), (6, 7)]

## reduce
至少要有一个元素
If initial is present, it is placed before the items of the sequence in the calculation

    from functools import reduce
    reduce(function, sequence[, initial]) -> value
    reduce(lambda x, y: x+y, [1, 2, 3, 4, 5]) calculates
    ((((1+2)+3)+4)+5).

序列求和

	>>> from functools import reduce
	>>> reduce(add, [1, 3, 5, 7, 9])

我来利用map+reduce 实现 str2int的函数就是：

	from functools import reduce
	def char2num(s):
		return {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}[s]

	def str2int(s):
		return reduce(lambda x, y: x * 10 + y, map(char2num, s))

### reduce 实现pipeling

    def pipeline_func(fns, data):
        return reduce(lambda v, f: f(v),
                      fns,
                      data)
用法：

    pipeline_func([even_filter,
                       multiply_by_three,
                       convert_to_string], nums)

## filter
filter 返回的也是惰性Iterator

	list(filter(lambda x:x%2==0, [1,2,3]));
	>>> list(filter(lambda x:x%2==0, range(10)))
	>>> list(filter(lambda x:x%2==0, range(0,10)))
	[0, 2, 4, 6, 8]

filter empty element in list: ['',None, 'abc'] -> ['abc']

	str_list = filter(None, str_list) # fastest
	str_list = filter(bool, str_list) # fastest
	str_list = filter(len, str_list)  # a bit of slower
	str_list = filter(lambda item: item, str_list) # slower than list comprehension

例如获取100以内的奇数：

	filter(lambda n: (n%2) == 1, range(100))
	[i for i in range(100) if i%2 == 1]

### 用filter求prime素数
计算素数的一个方法是埃氏筛法， 用Python来实现这个算法，可以先构造一个从3开始的奇数序列：

	def _odd_iter():
		n = 1
		while True:
			n = n + 2
			yield n

最后，定义一个生成器，不断返回下一个素数：

	def primes():
		yield 2
		it = _odd_iter() # 初始序列
        def not_divisible(n):
            return lambda x: x % n > 0
		while True:
			n = next(it) # 返回序列的第一个数
			yield n
			it = filter(lambda x:x%n>0, it) # Error 闭包将保留对n的引用
			it = filter(not_divisible(n), it) # 需要再封装函数解决
			it = filter((lambda n:lambda x:x%n!=0)(n), it) # 也行
			it = filter(partial(lambda n,x:x%n!=0,n), it) # 也行

打印1000以内的素数:

	for n in primes():
		if n < 1000:
			print(n)
		else:
			break

### 双数生成器

	filter(lambda n:str(n)[::-1]==str(n), range(10,99))
    11,22,33,...

## all

    all(iterable, /)
        Return True if bool(x) is True for all values x in the iterable.

    If the iterable is empty, return True.
    >>> all(['a',(2,4),3,False])
    False

     >>>all([])
     >>> all(())
     >>> all({})
     >>> all('')
     True
     >>>any([])
     >>> any(())
     >>> any({})
     >>> any('')
     >>> any([None,None])
     False

## any

	if needle.endswith('ly') or needle.endswith('ed') or
		needle.endswith('ing') or needle.endswith('ers'):
		print('Is valid')
	else:
		print('Invalid')

改成:

	if any([needle.endswith(e) for e in ('ly', 'ed', 'ing', 'ers')]):
		print('Is valid')
	else:
		print('Invalid')

Syntax:

	any([ expression(e) for e in (....)])
	any([True, False, False]);//True
    any(x in str for x in arr)

列表解析:

	[ expression(e) for e in (....)])
	[ expression(e) for e in (....) if <condition>])


# sorted
ython内置的sorted()函数就可以对list进行排序：

	>>> sorted([36, 5, -12, 9, -21])
	[-21, -12, 5, 9, 36]

此外，sorted()函数也是一个高阶函数，它还可以接收一个key函数来实现自定义的排序，例如按绝对值大小排序：

	>>> sorted([36, 5, -12, 9, -21], key=abs)
	[5, 9, -12, -21, 36]

现忽略大小写的排序：

	>>> sorted(['bob', 'about', 'Zoo', 'Credit'], key=str.lower)
	['about', 'bob', 'Credit', 'Zoo']

要进行反向排序，不必改动key函数，可以传入第三个参数reverse=True：

	>>> sorted(['bob', 'about', 'Zoo', 'Credit'], key=str.lower, reverse=True)
	['Zoo', 'Credit', 'bob', 'about']

## 多key 排序
正的放前面，负的放后面，并且分别按绝对值从小到大

	[1, 2, 9, 10, -2, -4, -5, -12]
	lst.sort(key=lambda x: (x < 0, abs(x)))

# decorator, 装饰器
作用：
1. 为函数添加功能，特别是上下文能力
2. 为方法添加上下文能力

e.g.

    # func(MyClass)
    @func
    class MyClass(object): pass

由于函数也是一个对象，而且函数对象可以被赋值给变量，所以，通过变量也能调用该函数。

	>>> def now():
	...     print('2015-3-25')
	...
	>>> f = now
	>>> f()
	2015-3-25

函数对象有一个__name__属性，可以拿到函数的名字：

	>>> now.__name__
	'now'
	>>> f.__name__
	'now'

现在，假设我们要增强now()函数的功能，比如，在函数调用前后自动打印日志，但又不希望修改now()函数的定义，这种在代码运行期间动态增加功能的方式，称之为“装饰器”（Decorator）。

本质上，decorator就是一个返回函数的高阶函数。所以，我们要定义一个能打印日志的decorator，可以定义如下：

	def log(func):
		def wrapper(*args, **kw):
			print('call %s():' % func.__name__)
			return func(*args, **kw)
		return wrapper

我们要借助Python的@语法，把decorator置于函数的定义处：

	@log
	def now():
		print('2015-3-25')

调用now()函数，不仅会运行now()函数本身，还会在运行now()函数前打印一行日志：

	>>> now()
	call now():
	2015-3-25

如果decorator本身需要传入参数，那就需要编写一个返回decorator的高阶函数，写出来会更复杂。比如，要自定义log的文本：

	def log(text):
		def decorator(func):
			def wrapper(*args, **kw):
				print('%s %s():' % (text, func.__name__))
				return func(*args, **kw)
			return wrapper
		return decorator

这个3层嵌套的 decorator 用法如下：
1. decorator: 执行装饰器
2. wrapper: 替换func

e.g.

	#now = log('excute')(now) # return wrapper
	@log('execute')
	def now():
		print('2015-3-25')
	print(now.__name__)

    # output:
    execute now():
    2015-3-25
    wrapper

## __name__
经过decorator装饰之后的函数，从外面看，它们的__name__已经从原来的'now'变成了'wrapper'：

	>>> now.__name__
	'wrapper'

因为返回的那个wrapper()函数名字就是'wrapper'，所以，需要把原始函数的`__name__`等属性复制到wrapper()函数中，否则，有些依赖函数签名的代码执行就会出错。

不需要编写`wrapper.__name__ = func.__name__`这样的代码，Python内置的`functools.wraps`就是干这个事的，所以，一个完整的decorator的写法如下：

	import functools

	def log(func):
		@functools.wraps(func)
		def wrapper(*args, **kw):
			print('call %s():' % func.__name__)
			return func(*args, **kw)
		return wrapper
        # reuturn functools.wraps(func)(wrapper)

或者针对带参数的decorator：

	import functools

	def log(text):
		def decorator(func):
			@functools.wraps(func)
			def wrapper(*args, **kw):
				print('%s %s():' % (text, func.__name__))
				return func(*args, **kw)
			return wrapper
		return decorator

## functools.wraps
为了使得装饰器返回的对象属性跟原对象，此对象有些属性如`__name__`, 它能用于把被调用函数的`__module__，__name__，__qualname__，__doc__，__annotations__`赋值给装饰器返回的函数对象。

	functools.wraps(func)(wrapper)

## singleton
适用于function, method

    from functools import wraps
    def singleton(cls):
        _instance = {}
        @wraps(cls)
        def _singleton(*args, **kwargs):
            if cls not in _instance:
                ck = str(cls)+str(args)+str(kwargs)
                _instance[ck] = cls(*args, **kwargs)
            return _instance[ck]
        return _singleton

    def file_cache(key, expire, verify_empty=True, options={}, nkey=0):
        def decorator(cls):
            @wraps(cls)
            def wrapper(*args, **kwargs):
                fkey = key
                for k in args[1:1+nkey]:
                    fkey += '.'+k
                if Args.refresh:
                    ok = False
                else:
                    ok, value = file_db(fkey, expire=expire, **options)
                if not ok:
                    value = cls(*args, **kwargs)
                    if not verify_empty or value:
                        file_db(fkey, value, **options)
                return value
            return wrapper
        return decorator

## multi decorator
倒序

    @log2
    @log1
    def func:
        pass
    func=log2(log1(func))

## class decorator
除了函数版装饰器，还有类装饰器(就当函数来使用就行)

    class make_bold(object):
        def __init__(self, func):
            print('Initialize')
            self.func = func

        def __call__(self, *args, **kwargs):
            print('Call')
            return '<b>{}</b>'.format(self.func())

run

    >>> @make_bold
    ... def get_content():
    ...     return 'hello world'
    ...
    Initialize
    >>> get_content()
    Call
    '<b>hello world</b>'

相当于:

    >>> get_content = make_bold(get_content)
    Initialize

## 内置装饰器
@staticmethod、@classmethod、@property

# partial function,偏函数
用于定制函数, 支持`partial(func, *list, **kw)`

	def int2(x, base=2):
		return int(x, base)

functools.partial就是帮助我们创建一个偏函数的，不需要我们自己定义int2()，可以直接使用下面的代码创建一个新的函数int2：

	>>> import functools
	>>> int2 = functools.partial(int, base=2)
	>>> int2('1000000')
	64
	>>> int2('1010101')
	85

最后，创建偏函数时，实际上可以接收函数对象、*args和**kw这3个参数，当传入：

	max2 = functools.partial(max, 10)

实际上会把10作为*args的一部分自动加到左边，也就是：

	max2(5, 6, 7)

相当于：

	args = (10, 5, 6, 7)
	max(*args)

# atexit
    import atexit
    atexit.register(func)

atexit 用于退出前执行finally func. 以下情况除外：
1. 未处理的信号
2. 调用`os._exit()`
3. python 内部错误

# lru_cache
函数名+args为缓存的键值,只缓存最近使用的maxsize 条

    @functools.lru_cache(maxsize=None) # default maxsize=128
    def fib(n):
        if n < 2:
            return n
        return fib(n-1) + fib(n-2)

    >>> [fib(n) for n in range(16)]
    [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610]

    >>> fib.cache_info()
    CacheInfo(hits=28, misses=16, maxsize=None, currsize=16)

说明

    @functools.lru_cache(maxsize=None, typed=False)
    typed：若为 True，则不同参数类型的调用将分别缓存。