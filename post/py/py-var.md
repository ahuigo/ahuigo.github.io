---
layout: page
title:
category: blog
description:
---
# Preface

# const

	from inspect import currentframe, getframeinfo
	__name__ == '__main__'; # module name
		在模块 “foo.bar.my_module” 中调用 logger.getLogger(__name__) 等价于调用logger.getLogger(“foo.bar.my_module”)
	__file__ == 'path_to_current_file'
	frameinfo = getframeinfo(currentframe())
	print frameinfo.filename, frameinfo.lineno

# variable
To check the existence of a local variable:

	if 'myVar' in locals(): 函数内部定义的
	  # myVar exists.

To check the existence of a global variable:

	if 'myVar' in globals():
	  # myVar exists.

calling a func by name

    getattr(foo, 'func')()
    locals()["func"]()
    globals()["func"]()

## equal
判断两个变量是否相等（值相同）使用==， 而判断两个变量是否指向同一个对象使用 is。

>>> a1, a2 = [], []
>>> a1 == a2
True
>>> a1 is a2
False

## reference
不同于string/number 之外，list, tuple, dict 都是引用型的，无论是赋值，还是func 传值, 还是线程`threading.Thread(target=run_thread, args=(list,))`

    def f(d):
        d[1]=1
    d={}
    f(d)
    print(d) # {1:1}

## copy
string,bytes,int 都是不可变值类型

    >>> a=''; b=a; b=''
    >>> id(a),id(b)
    (80080, 80080)
    >>> a=''; b=a; b='a'
    >>> id(a),id(b)
    (18780080, 20291280)

complex data : list,set,是引用型，tuple 是不可变引用型(从这个意义上说，tuple 相当于值类型)

    >>> a=1,; b=a; b=2,
    >>> a,b
    ((1,), (2,))
    >>> id(a),id(b)
    (4321539240, 4321598824)

copy list:

    L_copy = L[:]
    id(L_copy)!=id(L)

    list.copy()
    dict.copy()

deepcopy:

    from copy import deepcopy
    myCopy = deepcopy(myDict)

# Data Type
数据类型

- String
- List( Array)
- None

Example

	type(range(1)) is list
	type(9.0) is float

Convert data type:

	int('07')
	float(9)
	str(9)

## type

	>>> type(fn)==types.FunctionType
	True
	>>> type(className); types.type
	>>> type(obj); class className
	>>> type(abs)==types.BuiltinFunctionType
	True
	>>> type(lambda x: x)==types.LambdaType
	True
	>>> type((x for x in range(10)))==types.GeneratorType
	True

## isinstance
可用来判断数据类型

	isinstance('abc', str); # True
	isinstance(b'abc', bytes); # True
	isinstance(1, int); # True
	isinstance(1, (int, str)); # True
	isinstance('abc', Iterable); # True
	isinstance([1, 2, 3], (list, tuple))

	>>> isinstance(1, int)
	True
	>>> isinstance(1, type)
	False

判断子类:

	issubclass(obj.__class__, (list, tuple))
	issubclass(list, (list, tuple)); # true

# boolean
False

    {} or [1]: [1]
    [1] or {2}: [1]
    [1] and {2}: {2}
    [1] and None: None
	if {} or None or []: print([])

True

	if not {}


# set
set和dict类似，也是一组key的集合，但不存储value。由于key不能重复，所以，在set中，没有重复的key。

	myset = {'x', 1, 'y', 2, 2,100}
	>>> x = set('ssppaamm')
	>>> y = set(['s','p','a','m'])
    {'s', 'a', 'm', 'p'}
	>>> x, y
	(set(['a', 'p', 's', 'm']), set(['a', 'p', 's','m']))

set 只能存不可变hashable: 字符串、数字、bytes

    >>> set([1,2,3,[1]])
    TypeError: unhashable type: 'list
    >>> a = 'abc'

不可变对象本身a 是不变的，如果变了，其实是生成了新的变量'Abc':

    >>> a = 'abc'
    >>> a.replace('a', 'A')
    'Abc'
    >>> a
    'abc'

注意，传入的参数[1, 2, 3]是一个list，而显示的{1, 2, 3}只是告诉你这个set内部有1，2，3这3个元素，显示的顺序也不表示set是有序的。。
> set 是无序的

## add set
会改变s本身，返回None

	s.add(item);
	s.update([x1,x2]); union a set

通过remove(key)方法可以删除元素：

	>>> s.remove(4)
	{1, 2, 3}

set可以看成数学意义上的无序和无重复元素的集合，因此，两个set可以做数学意义上的交集、并集等操作：

	>>> s1 = set([1, 2, 3])
	>>> s2 = set([2, 3, 4])
	>>> s1 & s2
	{2, 3}
	>>> s1 | s2
	{1, 2, 3, 4}

set和dict的唯一区别仅在于没有存储对应的value，但是，set的原理和dict一样

## issubset(t)

	s.issubset(t)
	s <= t
	测试是否 s 中的每一个元素都在 t 中

	s.issuperset(t)
	s >= t
	测试是否 t 中的每一个元素都在 s 中

## operate set

	s.union(t)
	s | t

	s.intersection(t)
	s & t

	s.difference(t)
	s - t

	s.symmetric_difference(t)
	s ^ t 返回一个新的 set 包含 s 和 t 中不重复的元素

	s.copy() 返回 set “s”的一个浅复制

### multi operator

	s.update(t); 返回None,改变s
	s |= t
	返回增加了 set “t”中元素后的 set “s”

	s.intersection_update(t)
	s &= t
	....

## loop set

	if x in set
	for x in set
	len(set)

## frozenset
frozenset() 返回一个冻结的不可变集合

    foo = frozenset([1,2,3,4])

# Enum(__members__)
默认从1开始计数。

	>>> from enum import Enum
	>>> Month = Enum('Month', ('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'))
	>>> for name, member in Month.__members__.items():
	...      print(name, '=>', member, ',', member.value)
	...
	Jan => Month.Jan , 1
	Feb => Month.Feb , 2

如果需要更精确地控制枚举类型，可以从Enum派生出自定义类：
@unique装饰器可以帮助我们检查保证没有重复值。
```
from enum import Enum, unique

@unique
class Weekday(Enum):
	Sun = 0 # Sun的value被设定为0
	Mon = 1
	Tue = 2
```

多种访问方法：

    >>> Weekday.Mon == 1
    False
	>>> day1 = Weekday.Mon
	>>> print(day1)
	Weekday.Mon
	>>> print(Weekday.Tue)
	Weekday.Tue
	>>> print(Weekday['Tue'])
	Weekday.Tue
	>>> print(Weekday.Tue.value)
	2
	>>> print(Weekday(1))
	Weekday.Mon
