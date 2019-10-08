---
title: Python 语法
date: 2018-03-01
---
# compare
```s
>>> 1<3>=3>1==1<100
True
```

# exec
## exec func by name

    locals()["myfunction"]()
    globals()["myfunction"]()

or 

    import foo
    getattr(foo, 'bar')()

# Condition & Loop

## try finnaly

    try:
        1/0
    except Exception as e:
        print('first:',e)
        raise e
    finally:
        print('second: finally')


## control

	exit(0);
		like exit(0) in c

	sys.exit()
		SystemExit 异常，没有捕获这个异常，会直接退出；捕获这个异常可以做一些额外的清理工作。

## switch

	def zero():
		print("zero")
	one = lambda:print('one')

	{'a':lambda x: print(x), 'b':zero}['a'](2)
		2

## if

    a = b > 1 and 1 or 0
    a = (1, 0)[b > 1]

	x=10;
	if 1<=x<=5:
		print x
	elif x==6: print x*x
	else: print x*x*x

if is

	if L is None:
	if L == None:

## loop

### for

	for i in range(5): print i
	for i in [1],2,3: print i

Iterator For

	[w.capitalize() for w in ['aa','bb','cc']]

#### for 本质

	for arg in argv:
	for(i=0; i<len(argv); i++): arg = argv[i] //len(argv) 是实时计算的, 会受argv.pop 的影响

### 判断对象是否可迭代
可用：

	hasattr([],'__iter__')

或者:

	>>> from collections import Iterable
	>>> isinstance('abc', Iterable) # str是否可迭代
	True
	>>> isinstance([1,2,3], Iterable) # list是否可迭代
	True
	>>> isinstance(123, Iterable) # 整数是否可迭代
	False

Python内置的enumerate函数可以把一个list变成索引-元素对，这样就可以在for循环中同时迭代索引和元素本身：

	>>> for i, value in enumerate(['A', 'B', 'C']):
	...     print(i, value)
	...
	0 A
	1 B

### while

	while x < 6:
		Statement

# List Comprehensions, 列表生成式
列表生成式即List Comprehensions

	>>> [x * x for x in range(1, 11)]
	[1, 4, 9, 16, 25, 36, 49, 64, 81, 100]

for循环后面还可以加上if判断，这样我们就可以筛选出仅偶数的平方：

	>>> [x * x for x in range(1, 11) if x % 2 == 0]
	[4, 16, 36, 64, 100]

还可以使用两层循环，可以生成全排列：

	>>> [m + n for m in 'AB' for n in 'XYZ']
	['AX', 'AY', 'AZ', 'BX', 'BY', 'BZ']

列出文件

	>>> import os # 导入os模块，模块的概念后面讲到
	>>> [d for d in os.listdir('.')] # os.listdir可以列出文件和目录

# logic/bit/compare expression

## bit/logic expr
and or not xor

    x & y
    x | y
    ~ x
    x ^ y

bit

    x << y
    x >> y  

    >>> -1<<2
    -4
    >>> -1>>2
    -1
    >>> ~1
    -2
    >>> ~-1
    0
    >>> 1^1
    0

## logic
    and or not
	>>> False or 0 or '' or 3
	3

## compare
	>>> x =5; 1 < x < 10
	True

	!= (not equal)
	== (equal)
	>= (greater-than-equal)
	<= (less-than-equal)
	True
	False

# with
with 可以捕获异常, 类必须支持`__enter__, __exit__`相当于文件open/close:

	class DummyResource:
		def __enter__(self):
			print('enter');
			return self	  # 可以返回不同的对象
		def __exit__(self, exc_type, exc_value, exc_tb):
			print( 'Free resource.')
			if exc_tb is None:
				print('Exited without exception.')
			else:
				print('Exited with exception raised.')
				return True   # 不再raise 出异常

	with DummyResource() as obj:
		10/0
		print('do sth...')

1. exc_tb 是错误发生位置
2. 利用with 断言指定类型的Error，比如通过d['empty']访问不存在的key时，断言会抛出KeyError：

	with self.assertRaises(KeyError):
		value = d['empty']

# break, iterators and sentinel values
调用一个函数直到遇到标记值break

    blocks = []
    while True:
        block = f.read(32)
        if block == '':
            break
        blocks.append(block)

更好的方法via `iter(func,mark)`或者`iter(lambda:func(), mark)` 遇到标记自动break：

    blocks = []
    # for block in iter(functools.partial(f.read, 32), ''):
    for block in iter(lambda:f.read(32), ''):
        blocks.append(block)

    In [6]: with open("2.txt","r+b") as f:
    ...:     mm = mmap.mmap(f.fileno(),0,prot=mmap.PROT_READ)
    ...:     for line in iter(lambda: mm.readline(), b''):
    ...:         print(line)
    ...:

## limit iter

    for _, item in zip(range(limit), items):
        print(item)
    for item in itertools.islice(items, 0, stop): # stop=None include end
        print(item)

# Distinguishing multiple exit points in loops

    def find(seq, target):
        found = False
        for i, value in enumerate(seq):
            if value == target:
                found = True
                break
        if not found:
            return -1
        return i

Better: break else

    def find(seq, target):
        for i, value in enumerate(seq):
            if value == target:
				print('found, break else')
                break
        else:
            return -1
        return i

    for i in range(1):
        pass
    else:
        print('not found, loop over')


# Simultaneous state updates
Better

    x, y, dx, dy = (x + dx * t,
                    y + dy * t,
                    influence(m, x, y, dx, dy, p='x'),
                    influence(m, x, y, dx, dy, p='y'))
