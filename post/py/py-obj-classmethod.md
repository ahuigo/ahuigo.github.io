---
title: py-obj-classmethod
date: 2018-10-04
---
# Preface
    >>> class A(object):
    ...     def a(self):
    ...         print('a')
    ...
    ...     @staticmethod
    ...     def b():
    ...         print('b')
    ...
    ...     @classmethod
    ...     def c(cls):
    ...         print('c')
    ...
    >>> import inspect
    >>> inspect.getmembers(A, inspect.isfunction)
    >>> inspect.getmembers(A, inspect.ismethod)
    Out[1]: [('a', <function __main__.A.a>), ('b', <function __main__.A.b>)]
    Out[2]: [('c', <bound method A.c of <class '__main__.A'>>)]

    >>> inspect.getmembers(A(), inspect.ismethod)
    [('a', <bound method A.a of <__main__.A object at 0x10bd65f60>>),
    ('c', <bound method A.c of <class '__main__.A'>>)]

python3 这样更加清晰了. 

    @staticmethod 本来就是纯函数，不绑定 self/cls 
    @classmethod 是 method, 绑定 cls 
    A.a 也是函数. 
    A().a 是 method, 但是会绑定 cls, 这里的 cls=A() 
        cls 本质就是 metaclass 的实例（实例自己叫自己 self ）

# @staticmethod
@staticmethod和@classmethod都可以直接类名.方法名()来调用，

1. @staticmethod: 不需要self和 cls参数, 纯函数
2. @classmethod : 不需要self, 包装了staticmethod

# @classmethod
@classmethod make a class static method act like *object method*, except that the first arg is *class*

```
class Base(object):
    def __init__(self, val):
        print(44444444444)
        print(self)
        self.val = val

    @classmethod
    def make_obj(cls, val):
        print(222222222)
        print(cls)
        return cls(val+1)

class Derived(Base):
    def __init__(self, val):
        # In this super call, the second argument "self" is an object. <object Derived>
        # The result acts like an object of the Base class.
        print(33333333)
        print(self)
        super(Derived, self).__init__(val+2)

    @classmethod
    def make_obj(cls, val):
        print(111111111)
        print(cls)
        # In this super call, the second argument "cls" is a type. <class Derived>
        # The result acts like the Base class itself.
        return super(Derived, cls).make_obj(val)

d2 = Derived.make_obj(0) # make_obj=classmethod(make_obj)
print(d2.val)
```

Test output:

```
111111111
<class '__main__.Derived'>
222222222
<class '__main__.Derived'>
33333333
<__main__.Derived object at 0x10cc03dd8>
44444444444
<__main__.Derived object at 0x10cc03dd8>
3
```

    >>> b1 = Base(0)
    >>> b1.val
    0
    >>> b2 = Base.make_obj(0)
    >>> b2.val
    1
    >>> d1 = Derived(0)
    >>> d1.val
    2
    >>> d2 = Derived.make_obj(0) # Derived.__init__(Derived, 0)
    >>> d2.val
    3