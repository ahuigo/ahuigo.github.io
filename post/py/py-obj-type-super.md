---
title: python's super,type, object
date: 2018-10-04
---
# type vs object
type 即代表class 本身, 他继承: type-object
1. type: root instance: __class__, type(obj) === obj.__class__,
	`self.__class__` 不一定是`__class__`, 也可能是subclass(参考下面super的例子)
1. object: root subclass: mro

    >>> print(type(object));
    <class 'type'>

一般来说:

    # 实例不可以是自己
    >>> isinstance(int, int)
    False
    # 子类可以是自己
    >>> issubclass(int, int)
    True

*从class实例关系来说*, 所有class(包括type) 的 root metaclass: type

    >>> isinstance(1, type)
    False
    >>> isinstance(int, type)
    True
    >>> isinstance(type, type)
    True
    >>> isinstance(object, type)
    True

    >>> object.__class__
    >>> type.__class__
    <class 'type'>


*从object实例关系来说*, 所有class/object 的 root class: object

	>>> isinstance(1, object)
	>>> isinstance(int, object)
	>>> isinstance(type, object)
	>>> isinstance(object, object)
	True

特别，实例没有继承关系:
```
class A(type): pass
class B(type, metaclass=A): pass
class C(type, metaclass=B): pass
isinstance(C, B) # True
isinstance(C, A) # False
```

*从继承关系* MRO来说，所有class继承的根是(root inheritance): object

    >>> type.__mro__
    (<class 'type'>, <class 'object'>)
    >>> object.__mro__
    (<class 'object'>,)

    >>> issubclass(type, object)
    >>> issubclass(int, object)
    True

    >>> issubclass(object, type)
    False
    >>> issubclass(int, type)
    False

## 判断None 要用is
The operators `is` and `is not` test for object identity

    obj is not None


# type
通过type()函数创建的类和直接写class是完全一样的，因为Python解释器遇到class定义时，仅仅是扫描一下class定义的语法，然后调用type()函数创建出class。(都是动态创建的)

	class Hello(object):
		def hello(self, name='world'):
			print('Hello, %s.' % name)

用`class Xxx...`来定义类, 其实是扫描代码字符，然后调用`type()函数`创建类:
1. class的名称；
2. 继承的父类集合，注意Python支持多重继承，如果只有一个父类，别忘了tuple的单元素写法；
3. class的方法名称与函数绑定，这里我们把函数fn绑定到方法名hello上

eg:

	>>> def fn(self, name='world'): # 先定义函数
	...     print('Hello, %s.' % name)
	...
	>>> Hello = type('Hello', (object,), dict(hello=fn)) # 创建Hello class
            new_class = type.__new__(type, 'class_name<优化级小于qualname>', (object,), {'__qualname__': 'custom_class_name'})
                qualname 只是class别名, 不影响: isinstance(new_class, cls) == true
	>>> h = type.__new__(type, 'xx', (object,), {'hello':fn})
	<class '__main__.xx'>
	>>> h = type.__new__(type, 'xx', (object,), {'hello':fn, '__qualname__':'ahui'})
	<class '__main__.ahui'>
	>>> h().hello(1)
	1

## list subclass
	>>> type.__subclasses__(type)
	[<class 'abc.ABCMeta'>, <class 'enum.EnumMeta'>]

# MRO, Method Resolution Order
http://python-history.blogspot.com/2010/06/method-resolution-order.html
[Python的方法解析顺序(MRO)](http://hanjianwei.com/2013/07/25/python-mro/)

Python has three MRO:

1. classic class: DFS(Deep Search First) (<= 2.1)
2. new-style class: pre-computed `__mro__`when a class was defined(DFS+*保留最后一个重复*):(2.2)
3. C3 Agrithm(>=2.3)

## new-style mro

      A  B
      |/\/ 
      X  Y
       \ /
        Z

	class A(object): pass
	class B(object): pass
	class X(A, B): pass
	class Y(B, A): pass
	class Z(X, Y): pass

Using the tentative new MRO algorithm, the MRO for these classes would be *Z, X, Y, B, A, object*. (Here 'object' is the universal base class.)
However, I didn't like the fact that *B and A were in reversed order*.

上述继承关系违反了线性化的「 单调性原则 」。Michele Simionato对单调性的定义为：
> A MRO is monotonic when the following is true: if C1 precedes C2 in the linearization of C, then C1 precedes C2 in the linearization of any subclass of C. Otherwise, the innocuous(无意的) operation of deriving(起源, 产生) a new class could change the resolution order of methods, potentially introducing very subtle(细微, 不易察觉的) bugs.

## C3
Python should adopt the C3 Linearization algorithm described in the paper "A Monotonic Superclass Linearization for Dylan" (K. Barrett, et al, presented at OOPSLA'96).

我们把类 C 的线性化（MRO）记为 L[C] = [C1, C2,…,CN]。其中 C1 称为 L[C] 的头，其余元素 [C2,…,CN] 称为尾。如果一个类 C 继承自基类 B1、B2、……、BN，那么我们可以根据以下两步计算出 L[C]：

	L[object] = [object]
	L[C(B1…BN)] = [C] + merge(L[B1]…L[BN], [B1,…,BN])

这里的关键在于 merge，其输入是一组列表，按照如下Monotonic 方式输出一个列表:

1. 检查第一个列表的头元素（如 L[B1] 的头），记作 H。
2. 若 H *仅出现* 在其它列表的*头部*(或者*不出现*)则将其*输出*，并将其从所有列表中删除，然后回到步骤1；
3. 如果出现在其它某些列表的*非头部*, 选它则会违反 Monotonic; 需要回到步骤1按顺序检查*其它非头部*的列表
4. 重复上述步骤，直至列表为空    

    >>> class X(object): pass
    >>> class Y(object): pass
    >>> class A(X, Y): pass
    >>> class B(Y, X): pass
    >>> class C(A, B): pass

我们看看 C 的线性化结果：

	L[C] = [C] + merge(L[A], L[B], [A], [B])
	     = [C] + merge([A, X, Y, object], [B, Y, X, object], [A, B])
	     = [C, A] + merge([X, Y, object], [B, Y, X, object], [B])
	     = [C, A, B] + merge([X, Y, object], [Y, X, object])

X 是其它列表的非头部(乱序了), 无法构建继承关系

	class First(object):
	    def __init__(self):
	        print("first")

	class Second(First):
	    def __init__(self):
	        print("second")

	class Third(First, Second):
	    def __init__(self):
	        print("third")

	L(Third) = [Third] + merge([1, O], [2, 1, O], [1, 2])
	1 is non-head of `[1, 0]`
	2 is non-head of `[1, 2]`

You'll get:

	TypeError: Cannot create a consistent method resolution
	order (MRO) for bases Second, First

再来一个Monotonic 合法的例子:

    L[A] = [A] + merge(L[B], L[C], [B], [C])
         = [A] + merge([B, D, E, object], [C, D, F, object], [B], [C])
         = [A, B] + merge([D, E, object], [C, D, F, object], [C])
         = [A, B, C] + merge([D, E, object], [D, F, object])
         = [A, B, C, D] + merge([E, object], [F, object])
         = [A, B, C, D, E] + merge([object], [F, object])
         = [A, B, C, D, E, F] + merge([object], [object])
         = [A, B, C, D, E, F, object]

## super
1. 最好的示例: https://rhettinger.wordpress.com/2011/05/26/super-considered-super/
2. Things to Know About Python Super [1 of 3] (for experts): http://www.artima.com/weblogs/viewpost.jsp?thread=236275

super 是用来*执行* 继承类的func的, super 本质super的实例化

	super().__init__() # python3
    super(__class__,self).__init__() # python2
        parent-class__.__init__(self, ...)

    # 类似于，但是不等于, 事实上super() 会沿着整个inheritance chain 传导
	def super(cls, inst):
		mro = inst.__class__.mro() # Always the most derived class
	    return mro[mro.index(cls) + 1] # 主要逻辑是这个

### super 的参数
1. super(a_type, obj)
MRO 指的是 `type(obj)`即`obj.__class__` 的 MRO, MRO 中的那个类就是 a_type , 同时 isinstance(obj, a_type) == True 。

2. super(type1, type2)
MRO 指的是 type2 的 MRO, MRO 中的那个类就是 type1 ，同时 issubclass(type2, type1) == True 。

### super 作用
super(c, obj_or_type) 将返回一个从 MRO 中 c 之后的类中查找方法的对象。
1. 如果super(C, obj)的`obj.__class__.mro()`是`[A,B,C,D,E,object]`
2. 那么super 只会从 C 之后查找，即: 只会在 D 或 E 或 object 中查找 方法

示例: https://rhettinger.wordpress.com/2011/05/26/super-considered-super/

```python
class Root:
    def draw(self):
        # the delegation chain stops here
        assert not hasattr(super(), 'draw')
		# or pass

class Shape(Root):
    def __init__(self, shapename, **kwds):
        self.shapename = shapename
        super().__init__(**kwds)
    def draw(self):
        print('Drawing.  Setting shape to:', self.shapename)
        super().draw()

class ColoredShape(Shape):
    def __init__(self, color, **kwds):
        self.color = color
        super().__init__(**kwds)
    def draw(self):
        print('Drawing.  Setting color to:', self.color)
        super().draw()

class Moveable:
    def __init__(self, x, y):
        self.x = x
        self.y = y
    def draw(self):
        print('Drawing at position:', self.x, self.y)

class MoveableAdapter(Root):
    def __init__(self, x, y, **kwds):
        self.movable = Moveable(x, y)
        super().__init__(**kwds)
    def draw(self):
        self.movable.draw()
        super().draw()

class MovableColoredShape(ColoredShape, MoveableAdapter):
    pass

MovableColoredShape(color='red', shapename='triangle',
                    x=10, y=20).draw()
```
output:
```
Drawing.  Setting color to: red
Drawing.  Setting shape to: triangle
Drawing at position: 10 20
```

### bound and unbound with super
类似js 的bind this概念

    >>> class B(object):
    ...     def __repr__(self):
    ...         return "<instance of %s>" % self.__class__.__name__
    >>> class C(B):
    ...     pass
    >>> class D(C):
    ...     pass
    >>> d = D()

    # you get
    >>> print super(C, d).__repr__
    <bound method D.__repr__ of <instance of D>>
    B.__repr__(d,...)
    >>> print super(C, D).__repr__
    <unbound method D.__repr__>
    B.__repr__(D,...)
    ```