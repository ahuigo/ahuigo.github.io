---
layout: page
title:
category: blog
description:
---
# Preface

Python的内建模块itertools提供了非常有用的用于操作迭代对象的函数。

# itertools
itertools模块提供的全部是处理迭代功能的函数，它们的返回值不是list，而是Iterator，只有用for循环迭代的时候才真正计算。

1. i: Iterators terminating on the shortest input sequence:
```
Iterator	Arguments	Results	Example
chain()	p, q, …	p0, p1, … plast, q0, q1, …	chain('ABC', 'DEF') --> A B C D E F
compress()	data, selectors	(d[0] if s[0]), (d[1] if s[1]), …	compress('ABCDEF', [1,0,1,0,1,1]) --> A C E F
dropwhile()	pred, seq	seq[n], seq[n+1], starting when pred fails	dropwhile(lambda x: x<5, [1,4,6,4,1]) --> 6 4 1
groupby()	iterable[, keyfunc]	sub-iterators grouped by value of keyfunc(v)	 
ifilter()	pred, seq	elements of seq where pred(elem) is true	ifilter(lambda x: x%2, range(10)) --> 1 3 5 7 9
ifilterfalse()	pred, seq	elements of seq where pred(elem) is false	ifilterfalse(lambda x: x%2, range(10)) --> 0 2 4 6 8
islice()	seq, [start,] stop [, step]	elements from seq[start:stop:step]	islice('ABCDEFG', 2, None) --> C D E F G
imap()	func, p, q, …	func(p0, q0), func(p1, q1), …	imap(pow, (2,3,10), (5,2,3)) --> 32 9 1000
starmap()	func, seq	func(*seq[0]), func(*seq[1]), …	starmap(pow, [(2,5), (3,2), (10,3)]) --> 32 9 1000
tee()	it, n	it1, it2, … itn splits one iterator into n	 
takewhile()	pred, seq	seq[0], seq[1], until pred fails	takewhile(lambda x: x<5, [1,4,6,4,1]) --> 1 4
izip()	p, q, …	(p[0], q[0]), (p[1], q[1]), …	izip('ABCD', 'xy') --> Ax By
izip_longest()	p, q, …	(p[0], q[0]), (p[1], q[1]), …	izip_longest('ABCD', 'xy', fillvalue='-') --> Ax By C- D-
```
2. Combinatoric generators:
```
Iterator	Arguments	Results
product()	p, q, … [repeat=1]	cartesian product, equivalent to a nested for-loop
permutations()	p[, r]	r-length tuples, all possible orderings, no repeated elements
combinations()	p, r	r-length tuples, in sorted order, no repeated elements
combinations_with_replacement()	p, r	r-length tuples, in sorted order, with repeated elements
product('ABCD', repeat=2)   指数:m^2 =16             AA AB AC AD BA BB BC BD CA CB CC CD DA DB DC DD
permutations('ABCD', 2)	 	排列:m*(m-1)=4*3=12	 	AB AC AD BA BC BD CA CB CD DA DB DC
combinations('ABCD', 2)	 组合: m*(m-1)/2!=6	  AB AC AD BC BD CD
combinations_with_replacement('ABCD', 2)	A只能在前, sorted 指数：4+3+2+1 	AA AB AC AD BB BC BD CC CD DD
```

## from_iterable(['ABC', 'DEF']) --> A B C D E F

## takewhile(break_func, iterable)
过去我们用:

    for str in iter(lambda:f.read(20), '')

如果使用multiple sentinel:
通常我们会通过takewhile()等函数根据条件判断来截取出一个有限的序列：
```
takewhile(lambda x: x<5, [1,4,6,4,1]) --> 1 4

	>>> natuals = itertools.count(1)
	>>> ns = itertools.takewhile(lambda x: x <= 10, natuals)
	>>> list(ns)
	[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

## dropwhile(break_func, iterable)
dropwhile(lambda x: x<5, [1,4,6,4,1]) --> 6,4,1

## combinations(iterable, r)
Return r length subsequences of elements from the input iterable.
```
# combinations('ABCD', 2) --> AB AC AD BC BD CD
# combinations(range(4), 3) --> 012 013 023 123
```

## count
首先，我们看看itertools提供的几个“无限”迭代器：

	>>> import itertools
	>>> natuals = itertools.count(1)
	>>> for n in natuals:
	...     print(n)
	...
	1
	2
	3
	...

因为count()会创建一个无限的迭代器，所以上述代码会打印出自然数序列，根本停不下来，只能按Ctrl+C退出。

## cycle
cycle()会把传入的一个序列无限重复下去：

	>>> import itertools
	>>> cs = itertools.cycle('ABC') # 注意字符串也是序列的一种
	>>> for c in cs:
	...     print(c)
	...
	'A'
	'B'
	'C'
	'A'
	'B'
	'C'
	...

同样停不下来。

## repeat(10, 3) --> 10 10 10

## chain()
chain()可以把一组迭代对象串联起来，形成一个更大的迭代器：

	>>> for c in itertools.chain('ABC', 'XYZ'):
	...     print(c)
	# 迭代效果：'A' 'B' 'C' 'X' 'Y' 'Z'
    >>>for i in itertools.chain({'a':2,'b':5}, [2,3,5]): print(i)
    ... a b 2 3 5

## groupby()
groupby()把迭代器中相邻的重复元素挑出来放在一起：

	>>> for key, group in itertools.groupby('AAABBBCCAAA'):
	...     print(key, list(group))
	...
	A ['A', 'A', 'A']
	B ['B', 'B', 'B']
	C ['C', 'C']
	A ['A', 'A', 'A']

实际上挑选规则是通过函数完成的，只要作用于函数的两个元素返回的值相等，这两个元素就被认为是在一组的，而函数返回值作为组的key。如果我们要忽略大小写分组，就可以让元素'A'和'a'都返回相同的key：

	>>> for key, group in itertools.groupby('AaaBBbcCAAa', lambda c: c.upper()):
	...     print(key, list(group))
	...
	A ['A', 'a', 'a']
	B ['B', 'B', 'b']
	C ['c', 'C']
	A ['A', 'A', 'a']
