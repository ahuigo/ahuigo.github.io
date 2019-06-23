---
date: 2018-03-03
title: python 的list/tuple 笔记
---
# list and tuple
因为tuple 是增加删除元素的不可变的list(数据可以变)，所以代码更安全。
如果可能，能用tuple代替list就尽量用tuple。

	list = [1,2]
	list +=[3,]

	tuple = (1,2)
	tuple +=(3,)

	sorted(['a', 'z', 'g'])
        [a, g, z]
	sorted(['a', 'z', 'g']).pop(-1); # last
	sorted(['a', 'z', 'g']).pop(); # last
        z
	sorted('azg']).pop(0); # first

> For more details, refer to `pydoc list`
> sorted(s) 不改变s

The difference between list and tuple:

	1. tuple can be dictionary identifier key
	{(1,2):1} ok
	{[1,2]:1} error

	2. Tuples are immutable, and usually contain an heterogeneous sequence ..., and list is sorted

	3. tuple can be accessed by index, but cann't be deleted
    >>> tuple=(1,2,2,'2')
	del tuple[0] error

## unpack list tuple
too many values to unpack:

    a,*args = 1,2,3,4
    a,_ = 1,2,3,4 # for go language

### unpack dict

## list unique
use set if the item is hash-able

	set(list_or_tuple)

or use any part which is hash-able:

	>>> lis = [('one', 'a'), ('two', 'b'), ('three', 'a')]
	>>> seen = set()
	>>> [item for item in lis if item[1] not in seen and not seen.add(item[1])]
	[('one', 'a'), ('two', 'b')]

让set 也保持顺序 use OrderedDict.keys():

	>>> set((5,3,2,3))
	{2, 3, 5}
	>>> OrderedDict.fromkeys([5,3,2,3])
	OrderedDict([(5, None), (3, None), (2, None)])
	>>> OrderedDict.fromkeys([5,3,2,3]).keys()
	odict_keys([5, 3, 2])

## list copy

    l=[1,2,3]
    lc=l.copy()
    lc[:]=l

    dc=dic.copy()

## slice without copy

    >>> a = numpy.arange(3)
    >>> b = a[1:3]

## list merge, tuple merge

	[1,2] + [2,3,]
	(1,) + (2,)
	list.extend([2,3]) # 改变自己

merge to set, 利用`*args` 展开

	>>> {*(1,2), *[3,4]}
	{1, 2, 3, 4}
	>>> {*(1,2), *[3,2]}
	{1, 2, 3}

## list join

	list1 = [1, 2, 3]
	str1 = ''.join(str(e) for e in list1)

## list dict

	>>> list([1,2,3])
	[1, 2, 3]
	>>> list({'a':1,'b':2,'c':3})
	['b', 'c', 'a']

## loop list and tuple

	for idx, val in enumerate(ints):
		print(idx, val)
	for idx, val in enumerate(ints, start=5):
		print(idx, val)

## in list

	if x in list
	if index < len(list)

### find in list
Finding the first occurrence

	next(x for x in lst if ...)

which will return the first match or raise a StopIteration if none is found. Alternatively, you can use

	first_or_default = next((x for x in lst if ...), None)

### find location(index)

	[1,2,3][True] == 2
	[1,2,3].index(2) == 1
	[1,2,3].index('2') == ValueError

    next((v for v in enumerate([1,2,3]) if v =='2'), 'default')

## zip list

	>>> xl = [1,3,5]
	>>> yl = [9,12,13,14]
	>>> print(list(zip(xl,yl)) # 取最短的
	[(1, 9), (3, 12), (5, 13)]

	l = [(1,2), (3,4), (8,9)]
	>>> zip(*l) # matrix转置
	[(1, 3, 8), (2, 4, 9)]

## join and split

	','.join([1,2])
	'1,2'.split(',');
	'1,2,3'.split(',',1);# 只切割一次

## shuffle list

	import random
	list=[1,2,3]
	random.shuffle(list)

## Access List index 

	.index(value, [start, [stop]])

## Access List valueby

	list[0]
	[1,2][0]
	[1,2][-1]

### get by default

    v,=[1][1:2] or ['default']
     (a[4:]+['default'])[0]

### slice list and tuple
exclude end

	list[start:end:step]
	list[0:3]
	   list[:3]
	list[:-1]
	list[::-1] # reverse
	list[::5]
	print list[0:10:2]

	len = len(list)
	list[0:len]

## in array

	>>> 0 in range(1)
	True
	>>> x in range(1, 10)
	>>> 'hilo' in 'hilojack'

## range:

	>>> print range(4)
	[0, 1, 2, 3]
	>>> print range(2,4)
	[2, 3]

## repeat
repeat

	'.'.join(['pad']*2)

## pop,append(push)

	>>> list = [1,2]
	>>> del list[0]
	>>> list.pop(0)
	>>> list.append(3)
	>>> list.pop(-1) # same as list.pop() last one
	3
	>>> list.pop(0) # first one
	1

### insert and shift

    list.insert(pos, item)
    list = list[1:]

    from collections import deque
    items = deque([1, 2])
    items.append(3) # deque == [1, 2, 3]
    items.rotate(1) # The deque is now: [3, 1, 2]
    items.rotate(-1) # Returns deque to original state: [1, 2, 3]

    items.appendleft(item)
    item = items.popleft() # deque == [2, 3]

## list with enumerate

	>>> for k,v in [['k1','v1'],['k2','v2']]: print k,v
	>>> for k,v in [('k1','v1'),('k2','v2')]: print k,v
	k1 v1
	k2 v2

	>>> for k,v in enumerate([['k1','v1'],['k2','v2']], start=2): print k,v
	...
	1 ['k2', 'v2']

# .sort .reverse ... inplace like js

	.count(value) -> integer -- return number of occurrences of value
	.reverse() -> reverse *IN PLACE*
	.sort(key=None, reverse=False) -- stable sort *IN PLACE*; not support cmp=None
	sorted(l, key=None, reverse=False) -- stable sort *Not IN PLACE*;

## sort key

    >>> d=['a','C', 'A','z']; d.sort(key=str.lower))
    ['a', 'A', 'C', 'z']

    >>> a={1:2,2:4,4:1,3:3}
    >>> sorted(a.items())
    [(1, 2), (2, 4), (3, 3), (4, 1)]
    >>> sorted(a.items(), key=lambda x:x[1])
    [(4, 1), (1, 2), (3, 3), (2, 4)]

python3 没有cmp. 利用python 的magic`__gt__,__eq__,...` 实现cmp:

    key=functools.cmp_to_key(compare)

    from functools import cmp_to_key

    nums = [1, 3, 2, 4]
    nums.sort(key=cmp_to_key(lambda a, b: a - b))
    print(nums)  # [1, 2, 3, 4]

remove and insert(in place)

	.insert(index, object)
	.remove(value) -- remove first occurrence of value.

## sorted list

    colors = ['red', 'green', 'blue', 'yellow']
    sorted(colors):
    sorted(colors, reverse=True):

自定义排序顺序

    sorted(colors, key=len)

> 如果要改变自身，则用l.sort(key, reverse=True) *IN PLACE*

## reversed list and tuple(not include dict):     

    for color in reversed([1,2,3]):
    for color in list[::-1]:

`list.reverse()` is *IN PLACE*

## bisect
用于插入有序数组

	import bisect
	l = [3,1,9]
	l.sort() # 必须先排序
	bisect.insort(l, 2)

直接插入:

    l.insert(index,item)
