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

## dict key
在Python中，字符串、整数等都是不可变的。而list是可变的，就不能作为key：

    >>> key = [1, 2, 3]
    >>> d[key] = 'a list'
    TypeError: unhashable type: 'list'

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

    dict.pop(key) list.pop(index_or_last)
    del dict[key]

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
or

	def merge_dicts(*dict_args):
	    result = {}
	    for dictionary in dict_args:
	        result.update(dictionary)
	    return result
	merge_dicts(x,y)
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
```
	>>> set((5,3,2,3))
	{2, 3, 5}
	>>> OrderedDict.fromkeys([5,3,2,3])
	OrderedDict([(5, None), (3, None), (2, None)])
	>>> OrderedDict.fromkeys([5,3,2,3]).keys()
	odict_keys([5, 3, 2])
```

### sort OrderedDict.items

	>>> od=OrderedDict({5:6, 1:5})
	>>> OrderedDict(sorted(od.items(), key=lambda item: item[1]))

### pop, popitem

	self.popitem(last=True) 默认删除尾部: LIFO
	self.popitem(last=False) 删除头部: FIFO
	self.pop(key=1) 默认: del self[1]
	self.pop(key='key') del self['key']

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
dict subclass that calls a factory function to supply missing values: `defaultdict(callable_or_None)`
```
from collections import defaultdict
>>> defaultdict()['k']
KeyError: 'k'
>>> defaultdict(None)['k']
KeyError: 'k'
>>> defaultdict(lambda:1)['k']
1
```
除了在Key不存在时返回默认值，defaultdict的其他行为跟dict是完全一样的。


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


# Note
## Looping over dictionary keys and delete
Note: in python 3 to iterate through a dictionary you have to *explicidly* write: *list(d.keys())* because d.keys() returns a "dictionary view" (an iterable that provide a dynamic view on the dictionary’s keys).

    for k in list(d.keys()):
        if k.startswith('r'):
            del d[k]


1. If you mutate something while you're iterating over it, you're living in a state of sin and deserve what ever happens to you.

## dict iterms and delete
items 不是iter, 可以在里面直接删除元素, iteritems(.keys()/.values() 都是generator)则不行

	//list
	list.items() //error
	//gnenerator object itemview
	for k, v in dict.items()
		dict.pop(k)

