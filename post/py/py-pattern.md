---
title: python-pattern
date: 2018-10-04
---
# python-pattern
https://github.com/ahuigo/python-patterns

# singleton
http://stackoverflow.com/questions/6760685/creating-a-singleton-in-python
http://www.cnblogs.com/ifantastic/p/3175735.html
http://py.windrunner.info/design-patterns/singleton.html

https://docs.python.org/3/reference/datamodel.html#object.__new__

## via decorator

    def singleton(cls):
        instance = cls()
        instance.__call__ = lambda: instance
        return instance

Sample use

    @singleton
    class Highlander:
        x = 100
        # Of course you can have any attributes or methods you like.


    highlander = Highlander()
    another_highlander = Highlander()
    assert id(highlander) == id(another_highlander)

如果你希望只在需要的时候创建类的实例对象也有别的方法：

    def singleton(cls, *args, **kw):
        instances = {}
        def _singleton():
            if cls not in instances:
                instances[cls] = cls(*args, **kw)
            return instances[cls]
        return _singleton

    @singleton
    class MyClass(object):
        a = 1
        def __init__(self, x=0):
            self.x = x

    one = MyClass()
    two = MyClass()

    assert id(one) == id(two)

## via baseclass.new
via __dict__

    class Singleton(object):
        def __new__(cls, *args, **kwds):
            it = cls.__dict__.get("__it__")
            if it is not None:
                return it
            cls.__it__ = it = object.__new__(cls)
            it.init(*args, **kwds)
            return it
    class MySingleton(Singleton):
        def init(self):
            print("calling single init")
        def __init__(self):
            print("calling __init")

    x = MySingleton()
    y = MySingleton()

via property:

    class Singleton(object):
        _instance = None
        print(_instance); # static, excute when defined as decorate
        def __new__(cls, *args, **kwargs):
            if not isinstance(cls._instance, cls):
                cls._instance = object.__new__(cls)
            return cls._instance

    class MyClass(Singleton ):
        pass

    x=MyClass(1)
    y=MyClass(2)

## via metaclass.call

    class Singleton(type):
        def __init__(cls, name, bases, dict):
            super(Singleton, cls).__init__(name, bases, dict)
            cls._instance = None
        def __call__(cls, *args, **kw):
            if cls._instance is None:
                cls._instance = super(Singleton, cls).__call__(*args, **kw)
            return cls._instance

    class MyClass(object, metaclass=Singleton):
        pass

    one = MyClass()
    two = MyClass()
    print(id(one))
    print(id(two))