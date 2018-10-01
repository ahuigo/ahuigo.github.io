---
title: python 字典
---
# Dict

    key='city'
	dic = {'x': 1, 'y': 2, 2:100, key:'bj'}
	del dict['x']
    dict.pop(2) # key=2
	dict.setdefault('x', 123) # 返回原值或者123


## define dict
数字与字符是两种不同的索引: define by list/tuple/set/kw
```
dic = {'x': 1, 'y': 2, 2:100, key:'bj'}
dict(key1=1,)
l=((1,1),); dict(l)
t=[(1,1)]; dict(t)
s={(1,1)}; dict(s)
```

## copy dict
dict, list 赋值都是按引用的，如果是一维的值:

	l = li[:]
	objA = objB.copy()

如果是多维的：

	from copy import deepcopy
	myCopy = deepcopy(myDict)

或者用json

## dict key
在Python中，字符串、整数等都是不可变的。而list是可变的，就不能作为key：

    >>> key = [1, 2, 3]
    >>> d[key] = 'a list'
    TypeError: unhashable type: 'list'

### first key
	next(iter(a))

### init with same value

    >>> keys=[1,2,3]

    >>> dict(zip(keys,[0]*len(keys)))
    >>> dict.fromkeys(keys, 0)
    >>> {k:0 for k in keys}

## get value

    dic.get(key, default)
    dic[key]
	dict.items()
		[('x', 1), ('y', 2)]

### dict get keys and values

	dict.keys();//keys list generator
	dict.values();//values list generator
	list(dict.keys());//keys list
	list(dict.values());//values list

## del key
list 也一样

    dict.pop(key[, val]) 
        if key not found, return val
    list.pop(index_or_last)

### Is a dictionary popitem() atomic?
`popitem` is *atomic* so you don't have to put locks around it to use it in threads.

    d = {'matthew': 'blue', 'rachel': 'green', 'raymond': 'red'}
    while d:
        key, value = d.popitem()
        print key, '-->', value

## merge dict
python >=3.5
```
	z = {**x, **y}
```

or with update:

    d = {}
    d.update(d1).update(d2)

## OrderedDict(collections)
1. 使用dict时，Key是无序的。在对dict做迭代时，我们无法确定Key的顺序。
2. OrderedDict: keep key in order as defined

如果要保持Key的顺序，可以用OrderedDict：

	>>> from collections import OrderedDict
	>>> d = dict([('a', 1), ('b', 2), ('c', 3)])
	>>> d # dict的Key是无序的
	{'a': 1, 'c': 3, 'b': 2}
	>>> od = OrderedDict([('a', 1), ('b', 2), ('c', 3)])
	>>> od # OrderedDict的Key是有序的
	OrderedDict([('a', 1), ('b', 2), ('c', 3)])

注意，OrderedDict的Key会按照插入的顺序排列，不是Key本身排序：

	>>> od = OrderedDict()
	>>> od['z'] = 1
	>>> od['y'] = 2
	>>> od['x'] = 3
	>>> list(od.keys()) # 按照插入的Key的顺序返回
	['z', 'y', 'x']

### OrderedDict's keys
	>>> set((5,3,2,3))
	{2, 3, 5}
	>>> OrderedDict.fromkeys([5,3,2,3])
	OrderedDict([(5, None), (3, None), (2, None)])
	>>> OrderedDict.fromkeys([5,3,2,3]).keys()
	odict_keys([5, 3, 2])

### sort OrderedDict.items

    from collections import OrderedDict
	od=OrderedDict({5:6, 1:5})
	OrderedDict(sorted(od.items(), key=lambda item: item[1]))

### pop, popitem, last

	self.popitem(last=True) 默认删除尾部: LIFO
	self.popitem(last=False) 删除头部: FIFO

	self.pop(key='key') del self['key']
	self.pop('key', None)

    next(reversed(self))

### unshift(move_to_end)

    >>> d1 = OrderedDict([('a', '1'), ('b', '2')])
    >>> d1.update({'c':'3'})
    >>> d1.move_to_end('c', last=False)
    >>> d1
    OrderedDict([('c', '3'), ('a', '1'), ('b', '2')])

### FIFO
OrderedDict可以实现一个FIFO（先进先出）的dict，当容量超出限制时，先删除最早添加的Key：

	from collections import OrderedDict

	class LastUpdatedOrderedDict(OrderedDict):

		def __init__(self, capacity):
			super(LastUpdatedOrderedDict, self).__init__()
			self._capacity = capacity

		def __setitem__(self, key, value):
			containsKey = 1 if key in self else 0
			if len(self) - containsKey >= self._capacity:
				last = self.popitem(last=False)
				print('remove:', last)
			if containsKey:
				del self[key]
				print('set:', (key, value))
			else:
				print('add:', (key, value))
			OrderedDict.__setitem__(self, key, value)

## defaultdict
除了在Key不存在时返回默认值，defaultdict的其他行为跟dict是完全一样的。

    from collections import defaultdict
    >>> defaultdict()['k']
    KeyError: 'k'
    >>> defaultdict(None)['k']
    KeyError: 'k'
    >>> defaultdict(lambda:1)['k']

### Counting with defaultdict

    d = defaultdict(int)
    for color in colors:
        d[color] += 1

or with collections.Counter:

    d=collections.Counter()
    d[color] +=1

### Grouping with dictionaries

    d = defaultdict(list)
    for name in names:
        key = len(name)
        d[key].append(name)


## check

### is empty

    >>> dct = {}
    >>> bool(dct)
    False
    >>> not dct
    >>> if dct: ..


### has_key

	if key in dict:

    ## for obj only
	if hasattr(obj, 'attribute'):
		# obj.attr_name exists.

### has_value

    'one' in d.values()

## dict to object

	class Dict2Obj(object):
		def __init__(self, initial_data):
			for key in initial_data:
				setattr(self, key, initial_data[key])
    class Employee(object):
        def __init__(self, *initial_data, **kwargs):
            for dictionary in initial_data:
                for key in dictionary:
                    setattr(self, key, dictionary[key])
            for key in kwargs:
                setattr(self, key, kwargs[key])
    Employee(dict1,d2,d3,k1=v1,k2=v2)

### ChainMap
    collections.ChainMap(d1,d2,d3)
        dict-like class for creating a single view of multiple mappings


## foreach dict

	for k in dict:
		print "%s : %d" % (k,dict[k])

	for k,v in dict.items():
		print "%s : %d" % (k,v)

	>>> for v in {'k1':'v1','k2':'v2'}.items(): print v;
	...
	('k2', 'v2')
	('k1', 'v1')
    >>> k, v = 1,3
    >>> k, v = (1,3)

### chunk dict

    from itertools import islice

    def chunks(data, SIZE=10000):
        it = iter(data)
        for i in range(0, len(data), SIZE):
            yield {k:data[k] for k in islice(it, SIZE)}

# loop modifify inplace 
## update inplace

    d.update((k, v * 0.5) for k,v in d.items())

## delete dict
Note: in python 3 to iterate through a dictionary you have to *explicidly* write: *list(d.keys())* because d.keys() returns a "dictionary view" (an iterable that provide a dynamic view on the dictionary’s keys).

	# list 将iter 转了一下
    for k in list(d.keys()):
        if k.startswith('r'):
            del d[k]

## delete list value
If you mutate something while you're iterating over it, you're living in a state of sin and deserve what ever happens to you.

    a = [1,2,3,4,5]
    # for k,i in enumerate(a): # too wrong
    for i in a:
    	a.remove(i) # or a.pop(0) 也会发生错误
    # a = [2,4]

正确的方式: copy or reverse

	a = [1,2,3,4,5]
	# for i in a[:]: 
	for i in list(a): 
		a.remove(i)
	# a = []

## delete list index(inplace)

    a = [1,2,3,4,5]
    del_index = []
    for i,v in a:
        del_index.insert(0, i)
    for i in del_index: 
        a.pop(i)

or inplace

    a = [1,2,3,4,5]
    for i,v in list(enumerate(a))[::-1]:
        #a.remove(v)
        a.pop(i)

## dict iterms and delete
py3: items/iteritems 是iter(.keys()/.values() 都是generator) 都不可以直接改变原值
需要list copy出一份才可

	//list
	list.items() //error
	for k, v in list(dict.items())
		dict.pop(k)