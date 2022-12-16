---
layout: page
title: py-obj
category: blog
description: 
date: 2018-10-04
---
# Preface

pythone 一切皆对象: var, class, metaclass

## id

	id(any object)

# Class expression
class property without assigned

    a=1
    class A():
        a
        print(1)

这里A内部的`a`和`print(1)` 只是表达式

# Class and Object

    class MyStuff(object):
        name = 'hilo'
        age = 1
        print(name); # hilo
    
        def __init__(self):
            self.tangerine = "And now a thousand years between"
            self.age =2
    
        def apple(self):
            print("I AM CLASSY APPLES!")
    
    obj = MyStuff();
    print(MyStuff.name); # hilo
    print(obj.name);     # hilo
    print(MyStuff.age); # 1
    print(obj.age);     # 2

## 单例
via metaclass/decorator/`__new__`:

    class Singleton(type):
        _instances = {}
        def __call__(cls, *args, **kwargs):
            if cls not in cls._instances:
                cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)
            return cls._instances[cls]
    
    class BaseClass(metaclass=Singleton):
        pass

## attr scope for extend

    class A:
         l=[]
         v=1
    a=A()
    a.l.append(1)
    a.l==A.l # True
    a.l=[2]
    a.l==A.l # False

    a.v==A.v # True
    a.v=2
    a.v==A.v # False

## bound method

    class A: pass
    a=A()
    def bar(self): 
        print('bar')
    a.bar=bar.__get__(a)

参考py-maigc get

## static value for object
> `obj.__class__ === type(obj). type(self) === self.__class === __class__`
static value 在不同的对象/类里, 是隔离的

    class f(object):
        i=1
        def p(self):
            print(__class__.i)

    class f1(f):
        def p(self):
            __class__.i+=1
            print(__class__.i)

    class f2(f):
        def p(self):
            __class__.i+=1
            print(__class__.i)
    f1().p();#2
    f1().p();#3
    f2().p();#2
    print(f.i);#1

### static var in class

    def Foo(object):
        i=1
    def Bar(Foo):
        pass
    print(Foo.i); # 1
    print(Bar.i); # 1 via MRO
    print(Bar().i); # 1 via MRO

## Inheritance

	class Parent(object):

		def altered(self):
			print "PARENT altered()"

	class Child(Parent):

		def altered(self):
			print "CHILD, BEFORE PARENT altered()"
			super().altered();# or super(Child, self)

	Child().altered()

super inherits init

	class Child(Parent):
		def __init__(self, stuff):
			self.stuff = stuff
			super().__init__()

# attribute
方法也是属性

- __dict__:
    1. 'local' set of attributes on that instance;
    2. not contain every attribute available on the instance,
    3. some object like `[]` has no `__dict__ attribute`
- dir(var): search inheritance tree(instance/class/superclasses), include every attribute like `__slots__`

## __dict__ 属性的dict
属性分为：

1. 类属性(class attribute)
1. 对象属性(object attribute)。
2. 这些属性保存于`__dict__`, 各自独立保存: 子类与父类独立; 类与对象独立


	class bird(object):
		feather = True

	class chicken(bird):
		fly = False
		def __init__(self, age):
			self.age = age

	summer = chicken(2)

	print(bird.__dict__.keys())
	print(chicken.__dict__.keys())
	print(summer.__dict__.keys())

output:

    dict_keys(['__dict__', '__module__', '__weakref__', '__doc__', 'feather'])
    dict_keys(['fly', '__module__', '__init__', '__doc__'])
    dict_keys(['age'])

属性访问时，是层层遍历的: `summer|chicken|bird|object`, 所以:

	>>> print(summer.age)
	2
	>>> print(summer.fly)
	False
	>>> print(summer.feather)
	True
	>>> print(chicken.fly)
	False
	>>> print(chicken.feather)
	True

### 实例中的dict
https://stackoverflow.com/questions/14361256/whats-the-biggest-difference-between-dir-and-dict-in-python

    >>> class Foo(object):
    ...     bar = 'spam'

类有自己的`__dict__`, 实例也有自己的`__dict__`, 访问`Foo().bar` 时会遍历到原类的属性

    >>> Foo.__dict__.items()
    [('__dict__', <attribute '__dict__' of 'Foo' objects>), ('__weakref__',....
    >>> Foo().__dict__
    {}
    >>> Foo().bar
    'spam'

1. The `dir()` method uses *both* these `__dict__` attributes, to create
2. a complete list of available attributes on the *instance, the class, and on all ancestors* of the class.

Note how the instance __dict__ is left empty. Attribute lookup on Python objects follows the hierarchy of objects from instance to type to parent classes to search for attributes.

    Foo.ham = 'eggs'
    # equal to
    Foo.__dict__['ham'] = 'eggs'

## vars: return dict
Return the `__dict__` attribute  for a module, class, instance, or *locals()*

	vars([object])
        object.__dict__

## hasattr

	>>> hasattr(obj, 'y') # 有属性'y'吗？
	True
	>>> getattr(obj, 'y') # 获取属性'y'
	19
	>>> getattr(obj, 'y', 'default')

	 if hasattr(fp, 'read'):
        return readData(fp)

## __getattr__, __setattr__
`obj.attr` 是attr
`obj['key']` 是item

当访问不存在的attr 时触发`__getattr__`

	def __getattr__(self, attr):
		if attr=='score':
			return 99
		raise AttributeError('\'Student\' object has no attribute \'%s\'' % attr)

### default method handler with getattr
```
class C2:
    def __getattr__(self,name):
        def handlerFunction(*args,**kwargs):
            print name,args,kwargs
        return handlerFunction
C2().func(1,2,3)
```

## __getitem__, __setitem__
for dict

## __call__
与php `__invoke()`一样，它是将对象变函数

	class Student(object):
		def __init__(self, name):
			self.name = name

		def __call__(self):
			print('My name is %s.' % self.name)

调用方式如下：

	>>> s = Student('Michael')
	>>> s() # self参数不要传入
	My name is Michael.

能被调用的对象就是一个Callable对象

	>>> callable(Student())
	True
	>>> callable(max)
	True

## 实例与类属性

	>>> class Student(object):
	...     name = 'Student'
	...
	>>> s = Student() # 创建实例s
	>>> print(s.name) # 打印name属性，因为实例并没有name属性，所以会继续查找class的name属性
	Student
	>>> print(Student.name) # 打印类的name属性
	Student

## 给实例绑定方法属性

	>>> def set_age(self, age): # 定义一个函数作为实例方法
	...     self.age = age
	...
	>>> from types import MethodType
	>>> s.set_age = MethodType(set_age, s) # 将方法set_age绑定到实例s
	>>> s.set_age(25) # 调用实例方法
	>>> s.age # 测试结果
	25

为了给所有实例都绑定方法，可以给class绑定方法(Inheritance)：

	>>> def set_score(self, score):
	...     self.score = score
	...
	>>> Student.set_score = MethodType(set_score, Student)

## 使用__slots__ 限制添加属性
如果我们想要限制实例的属性怎么办？

	class Student(object):
		__slots__ = ('name', 'age') # 用tuple定义允许绑定的属性名称

然后，我们试试：

	>>> s = Student() # 创建新的实例
	>>> s.age = 25 # 绑定属性'age'
	>>> s.score = 99 # 绑定属性'score'
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	AttributeError: 'Student' object has no attribute 'score'
    >>> Student.score = 99 # slots 只限制实例，不限制本类

由于'score'没有被放到__slots__中，所以不能绑定score属性，试图绑定score将得到AttributeError的错误。

1. 对obj 的限制其实是查找的: super().__slots__, 自身的__slots__加上父类的__slots__
3. 使用__slots__要注意，如果`obj.__class__没有slots` 则不查找slots
4. 如果`hasattr(obj, '__slots__')`, 则不存在`__dict__`, 但是`obj.__class__.__dict__`还是存在的

> object.__slots__ == ()

## @property 属性
Python内置的`@property`装饰器就是负责把一个方法变成属性调用的`Student().score=1`：

1. 使用@property 后，Student().score()就被禁止了

	class Student(object):

		@property
		def score(self):
			return self._score

		@score.setter
		def score(self, value):
			if not isinstance(value, int):
				raise ValueError('score must be an integer!')
			if value < 0 or value > 100:
				raise ValueError('score must between 0 ~ 100!')
			self._score = value

1. @property的实现比较复杂，我们先考察如何使用。把一个getter方法变成属性，只需要加上@property就可以了，
2. 此时，@property本身又创建了另一个装饰器@score.setter，可用它把一个setter方法变成属性赋值.

## __str__
相当于js 的toString

	>>> class Student(object):
	...     def __init__(self, name):
	...         self.name = name
	...     def __str__(self):
	...         return 'Student object (name: %s)' % self.name
	...
	>>> print(Student('Michael'))
	Student object (name: Michael)

`__str__()`返回用户看到的字符串(`print(obj)`)，
`__repr__()`返回程序开发者看到的字符串，也就是说，__repr__()是为调试服务的: 直接输入`Student()`。

			__repr__ = __str__
            # 或者
	...     def __repr__(self):
	...         return 'prompt in shell'

# item

## __iter__
如果一个类想被用于for ... in循环，类似list或tuple那样，就必须:
1. 实现一个`__iter__()`方法，该方法返回一个迭代对象，
2. 然后，Python的for循环就会不断调用该迭代对象的`__next__()`方法拿到循环的下一个值，直到遇到StopIteration错误时退出循环。

我们以斐波那契数列为例，写一个Fib类，可以作用于for循环：

	class Fib(object):
		def __init__(self):
			self.a, self.b = 0, 1 # 初始化两个计数器a，b

		def __iter__(self):
			return self # 实例本身就是迭代对象，故返回自己

		def __next__(self):
			self.a, self.b = self.b, self.a + self.b # 计算下一个值
			if self.a > 100000: # 退出循环的条件
				raise StopIteration();
			return self.a # 返回下一个值

## __getitem__
Fib实例虽然能作用于for循环，看起来和list有点像，但是，把它当成list来使用还是不行，比如，取第5个元素：

	>>> Fib()[5]
	Traceback (most recent call last):
	  File "<stdin>", line 1, in <module>
	TypeError: 'Fib' object does not support indexing

要表现得像list那样按照下标取出元素，需要实现__getitem__()方法：

	class Fib(object):
		def __getitem__(self, n):
			a, b = 1, 1
			for x in range(n):
				a, b = b, a + b
			return a

现在，就可以按下标访问数列的任意一项了：

	>>> f = Fib()
	>>> f[0]
	1

但是list有个神奇的切片方法：

	>>> list(range(100))[5:10]
	[5, 6, 7, 8, 9]

对于Fib却报错。原因是`__getitem__()`传入的参数可能是一个int，也可能是一个切片对象slice，所以要做判断：

	class Fib(object):
		def __getitem__(self, n):
			if isinstance(n, int): # n是索引
				a, b = 1, 1
				for x in range(n):
					a, b = b, a + b
				return a
			if isinstance(n, slice): # n是切片
				start = n.start
				stop = n.stop
				step = n.step
				if start is None:
					start = 0
				a, b = 1, 1
				L = []
				for x in range(stop):
					if x >= start:
                        # if (x-start)%step == 0:
						L.append(a)
					a, b = b, a + b
				return L

> 与之对应的是__setitem__()方法，把对象视作list或dict来对集合赋值。最后，还有一个__delitem__()方法，用于删除某个元素。

# Multi paradigm，多范式
操作符其实是对象的方法,

	'abc' + 'xyz'
	'abc'.__add__('xyz')

	(1.8).__mul__(2.0)
	True.__or__(False)

Python的多范式依赖于Python对象中的特殊方法(special method, magic method):. Use `dir(1)` to list all magic method:

	> dir(1)
	 `__add__` `__init__`

内置函数也是映射magic method:

	len([1,2,3])
	[1,2,3].__len__()

list index

	li[3]
	li.__getitem__(3)

	li[3] = 0
	li.__setitem__(3, 0)
	{'a':1, 'b':2}.__delitem__('a')

function object

	class SampleMore(object):
        def __call__(self, a):
            return a + 5

	add = SampleMore()     # A function object
	print(add(2))          # Call function
	print(add.__call__(2))          # Call function

# MixIn(Mix Inheritance, Multi Inheritance)
比如，编写一个多进程模式的TCP服务，定义如下：

    class MyTCPServer(TCPServer, ForkingMixIn):
        pass

编写一个多线程模式的UDP服务，定义如下：

    class MyUDPServer(UDPServer, ThreadingMixIn):
        pass
