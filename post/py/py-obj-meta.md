---
title: metaclass
date: 2018-10-04
---
# metaclass
通过元类，我们可以实例元类 创建类

## issue
python 解析class 时，会对参数(包括obj)做预处理。预处理的参数不再接受修改

    i = 1
    class A():
        print(i)

    i = 2
    A()

    l = [1]
    class A():
        print(l)

    l.append(2)
    A()

## 老式的类工厂创建类
```
def class_with_method(func):
    class klass: pass
    setattr(klass, func.__name__, func)
    return klass

def say_foo(self): print('foo')

Foo = class_with_method(say_foo)
foo = Foo()
foo.say_foo()
```

## metaclass.new 初识
我们先看一个简单的例子，这个metaclass可以给我们自定义的MyList增加一个add方法：
1. 我们通过type 定义一个类，也可以通过metaclass 修改一个类
2. class可以创建instance:
    1. define:`class new_cls: ...`:
       1. `new_cls=type('Hello', (object,), dict(hello=fn));`
    2. `ins=new_cls(*args)`实际会调用:
       2. `ins.__init__(*args)# 隐含new_cls.__init__(ins,*args)`
    3. `ins(*args)`实际会调用:
        1. `ins.__call__(*args)# 隐含new_cls.__call__(ins,*args)`
2. metaclass可以修改 class(这一步在执行完static define后):
    1. `new_cls=metaclass(name, bases, attrs)`实际会调用(define 阶段):
        1. `new_cls=metaclass.__new__(metaclass, name, bases, attrs);# static method`
            1. `new_cls=(super() or type).__new__(metaclass, name, bases, attrs);`
        1. `new_cls.__init__(name, bases, attrs); # metaclass.__init__(new_cls,...)`
    2. `ins=new_cls(*args)`实际会调用:
        1. 调用 `metaclass.__call__(new_cls,*args)`: meta.call:内部会调用ins=new_cls.new和new_cls.init
            1. 里面的`super().__call__(*args)`, 实际调用的static method 相当于: `type.__call(new_cls, *args)`
                2. `ins=new_cls.__new__(new_cls)`
                3. `new_cls.__init__(ins)`
        2. 注意: `ins(*args)`才会调用`ins=new_cls.__call__(ins, *args)`

```python
class ListMetaclass(type):
    def __new__(cls, name, bases, attrs):
        print('1.2 define: ListMetaclass.__new__(meta_cls,name,bases,attrs)\t');
        attrs['add'] = lambda self, value: self.append(value)
        new_cls = type.__new__(cls, name, bases, attrs)
        print('1.3 define: new_cls=type.new()')
        return new_cls;
    def __init__(new_cls, name, bases, attrs):
        print('1.4 define:Metaclass.__init__(new_cls, name,bases, attrs)', bases)
    def __call__(new_cls, *args):
        print('2.1 MyList():ins=Metaclass.__call__(new_cls)')
        print(new_cls.__class__.__mro__) # ListMetaclass, type, object
        ins = super().__call__(*args)
        print('2.4 MyList():ins=Metaclass.__call__ return', ins)
        return ins

print('1. start define MyList')
class MyList(list, metaclass=ListMetaclass):
    print('1.1 define MyList static')
    a=1
    def bar(self):
        print('test');
    def __new__(new_cls, *args):
        print('2.2 MyList(): ins = MyList.__new__(MyList): ')
        return super().__new__(new_cls, *args)
    def __init__(self, *args):
        print('2.3 MyList(): MyList.__init__(ins, *args)')
        super().__init__(*args) # list.__init__(l, [2,3,4])
    def __call__(*args):
        print('3.1 L(*args)=== MyList._call_(L, *args)')
        print(args) 

print('2. start instance MyList  :')
L=MyList([2,3,4])
L.add(1)
print(MyList.__class__) # <class '__main__.ListMetaclass'>
print(MyList.__mro__) # (<class '__main__.MyList'>, <class 'list'>, <class 'object'>)

L('3.1')
print('END: Print MyList :', L)
```
output:
```
1. start define MyList
1.1 define MyList static
1.2 define: ListMetaclass.__new__(cls,name,bases,attrs)
1.3 define: new_cls=type.new()
1.4 define:Metaclass.__init__(new_cls, name,bases, attrs) (<class 'list'>,)
2. start instance MyList()  :
2.1 MyList():ins=Metaclass.__call__(new_cls)
(<class '__main__.ListMetaclass'>, <class 'type'>, <class 'object'>)
2.2 MyList(): ins = MyList.__new__(MyList):
2.3 MyList(): MyList.__init__(ins, *args)
2.4 MyList():ins=Metaclass.__call__ return [2, 3, 4]
<class '__main__.ListMetaclass'>
(<class '__main__.MyList'>, <class 'list'>, <class 'object'>)
END: Print MyList : [2, 3, 4, 1]
```

本例子最关键的是通过type.new 实例化一个`MyList=ListMetaclass(name,bases,attrs)`:
1. `MyList = ListMetaclass.__new__(ListMetaclass, name, bases, attrs)`
1. `MyList = type.__new__(ListMetaclass, name, bases, attrs)`

ListMetaclass 的继承了type, 我们也可以看到MyList实例化关系：

    > print(MyList.__class__)
    <class '__main__.ListMetaclass'>
    > print(MyList.__mro__)
    (<class '__main__.MyList'>, <class 'list'>, <class 'object'>)

### 使用metaclass 动态创建ORM 字段属性
demo: /demo/py/metaclass_orm.py

### metaclass inheritance
#### metaclass 可以被subclass(mro继承)
When you do:
```
class Foo(Bar):
  pass
```
Python does the following:

1. Is there a __metaclass__ attribute in Foo? If yes, use it
2. If Python can't find __metaclass__, it will look for a __metaclass__ at *the MODULE level*, (but only for classes that don't inherit anything, basically old-style classes).
3. Then if it can't find any __metaclass__ at all, it will use *the Bar's  own metaclass* (which might be the default type) to create the class object.

#### metaclass 实例的实例不可以访问到meta的属性
ins可以访问到super(ins)==ins.class.mro 的属性, eg.
1. suer(A).mro = (M_A, type, object)，
1. suer(B).mro = (A, type, object)，

下面的例子中：
1. A.new(A,'B'..) 不会执行 M_A.new(A,'B'..) #
2. 而是执行继承类中的type.new(A, 'B', ...) # super(A)是type，则不是M_A

```
class M_A(type):
    a=1
    def __new__(cls, *args, **kw):
        print(cls, args, kw) # <class '__main__.M_A'> ('A', (<class 'type'>,), {'__module__': '__main__', '__qualname__': 'A'}) {}
        return super().__new__(cls, *args, **kw)

class A(type, metaclass = M_A):
    pass
class B(object, metaclass=A): pass
A.a # 1
B.a # meta实例的实例不可以访问到meta的属性
```

## new
https://docs.python.org/3/reference/datamodel.html#object.__new__

总结下`obj = Foo(*args)`, 相当于
1. `obj=Foo.__new__(Foo, *args)` # type(..)本质上是type.__new__(type, ...)
2. `Foo.__init__(obj, *args) <- obj.__init__(*args)`

### new 的本质是添加属性并实例化
1. `float.__new__(inch, 2)`将float 修改并替换成 *inch 实例*: 在inch 中添加float属性 并实例化
2. `object.__new__(Stranger, *args, **kw)`替换成 *Stranger 实例*: 在Stranger 中添加object空属性， 相当于改名，并实例化
2. 与`type.__new__(metaclass, 'xx', bases,attrs)` 不同的是, 它修改并替换成 *xx类*: 在metaclass 中添加新属性, 并实例化

```
# inch must be a subtype of float
class inch(float): pass
i = float.__new__(inch, 2*0.0254)
```

#### metaclass属性可以被new_cls 使用
本质上是class 可以使用metaclass 的属性
```
>>> class Nobility(type): attributes = 'Power', 'Wealth', 'Beauty'
>>> d=Nobility.__new__(Nobility, 'D', (object,), {})
>>> d=type.__new__(Nobility, 'D', (object,), {}) # 实际调用
>>> d.attributes
('Power', 'Wealth', 'Beauty')
```

### e.g. inch:new(float)
```
class inch(float):
    def __new__(cls, arg=0.0):
        print(cls)  # <class '__main__.inch'>
        obj = float.__new__(cls, arg*0.0254); #inch is subtype of float
        print(type(obj), obj) # <class 'inch'> 0.0508
        return obj  # inch.__mro__: float, object
    def __init__(self, a):
        print('init:', a); # init: 2(传的是2，实际self是0.0508, )

i=inch(2)
print(i) # 0.0508
```

new 将Foo替换成Stranger 实例:
```
    class Foo(object):
        def __init__(self, *args, **kwargs):
            print('Foo init')
        def __new__(cls, *args, **kwargs):
            print(cls)
            obj=object.__new__(Stranger, *args, **kwargs);
            # obj.init(*args, **kwargs)
            print(type(obj))
            return obj
    class Stranger(object):
        def __init__(self, *args, **kwargs):
            print('Stranger init')
    foo = Foo()
    print(type(foo))    # Stranger
    print(type(foo).__mro__) # Stranger, object
```
## metaclass conflict
metaclass conflict: the metaclass of a derived class must be a (non-strict) subclass of the metaclasses of all its bases

### What type can create a class?
type, or anything that subclasses!

To illustrate, M_A must be subtype of metaclass of `type = (A's base object).__class__`
```
class M_A(object): pass
class A(object, metaclass = M_A): pass
```
原因是:
1. The "derived class" is A.
2. The "metaclass of a derived class" A is M_A.
3. `A's base` class is `object`, therefore *"the metaclasses of all its bases"* is *type* - because type is object's metaclass.

correct metaclass base to type:
```
class M_A(type): pass
class A(object, metaclass = M_A): pass
```
内部会执行:
```
>>> class A(object): pass
>>> class M_A(type): pass
>>> type.__new__(M_A, 'A', (object,), {})
<class '__main__.A'>
```
### multiple metaclass conflict
Refer: http://www.phyast.pitt.edu/~micheles/python/metatype.html

what is the metaclass of C ? Is it M_A or M_B ?
```
class M_A(type): pass
class M_B(type): pass
class A(object, metaclass = M_A): pass
class B(object, metaclass = M_B): pass
class C(A,B): pass
```
The correct answer is M_C(inherits from M_A and M_B):
However does not automatically create  M_C.

    M_A     M_B
     : \   / :
     A  M_C  B
      \  :  /
         C

The metatype conflict can be avoided by assigning the correct metaclass to C by hand:

    class M_AB(M_A,M_B): pass
    class C(A,B, metaclass):  # type(C) == M_AB
        pass

In general, a meta class H(A, B, C, D , ...) can be generated without conflicts only if `metaclass=type(H)` is a subclass of each of type(A), type(B), ...

To automatically avoid conflicts, by defining a smart class factory that generates the correct metaclass by looking at the metaclasses of the base classes:
```
def mkMetaCls(*bases):
    metabases =tuple(set([type(base) for base in bases]))
    metaname="_"+''.join([m.__name__ for m in metabases])
    return type(metaname, metabases, {})
class M_A(type): pass
class M_B(type): pass
class A(object, metaclass = M_A): pass
class B(object, metaclass = M_A): pass
class C(A,B, metaclass=mkMetaCls(A,B)): pass
```
The full demo [onconflict.py](/demo/py/meta_noconflict.py)

```
from meta_noconflict import makecls
class M_A(type): pass
class M_B(type): pass
class A(object, metaclass = M_A): pass

class D(A, metaclass=makecls(M_B,priority=True)):
type(D) # <class 'noconflict._M_BM_A'>
```


# 其它改变类的方法
## Monkey patch
is a way for a program to extend or modify supporting system software locally (affecting only the running instance of the program).
直接暴力修改：

    >> import math
    >>> math.pi
    3.141592653589793
    >>> math.pi = 3

## class decorator
class decorator 以显式的方式改变类: Foo = addID(Foo), addID可以是含`__new__`的metaclass, 也可以是普通的func/method

    @addID
    class Foo:
        pass