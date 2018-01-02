# Preface
http://nvie.com/posts/iterators-vs-generators/
## Iterable


## Iterable, 迭代器,
### iterable vs iterable
区别:
1. Iterable(能用for的都是): type(obj)->__iter__(), iter(obj)是否真的返回 Iterator, isinstance 其实判断不出来(按协议是应该考虑的).
2. Iterator(能用next的都是): type(obj)->__iter__(), type(obj)->__next__() 同时定义,

An *iterable* is any object, not necessarily a data structure, that can *return an iterator via iter*:
```
    >>> hasattr(str, '__iter__')
    True  
    >>> hasattr(bool, '__iter__')
    False
```

*Iterator* protocol is implemented whenever you *iterate* over a sequence of data.
when you use a for loop, the following is happened in background.
1. first *iter()* method is called on the object to *converts it to an iterator object*.
2. the *next()* method is called on the iterator object to get the next element of the sequence.
3. A `StopIteration exception` is raised when there are no elements left to call.

```
    >>> simple_list = [1]
    >>> my_iterator = iter(simple_list)
    >>> print(my_iterator)
    <list_iterator object at 0x7f66b6288630>  
    >>> next(my_iterator)
    1  
    >>> next(my_iterator)
    Traceback (most recent call last):  
      File "<stdin>", line 1, in <module>
    StopIteration
```

### Iterable 有哪些
1. str-dict 都是Iterable(同时有__iter__)
2. Iterable 可以生成Iterator: Iterator = iter(Iterable)

> *Often*, for pragmatic reasons, iterable classes will implement both `__iter__() and __next__()` in the same class, and have `__iter__()` return self, which makes the class both *an iterable and its own iterator*. It is perfectly fine to return a different object as the iterator, though. While `dict, str...`  only has `__iter__()`


集合数据类型如list、dict、str等是Iterable但不是Iterator，不过可以通过iter()函数获得一个Iterator对象。
Python的for循环本质上就是通过不断调用next()函数实现的，例如：

    for x in [1, 2, 3, 4, 5]:
        pass

实际上完全等价于：

    # 首先获得Iterator对象:
    it = iter([1, 2, 3, 4, 5])
    while True:
        try:
            # 获得下一个值:
            x = next(it)
        except StopIteration:
            # 遇到StopIteration就退出循环
            break

### 判断iterable/iterator

	import collections
	class fib:
	    def __init__(self):
	        self.prev = 0
	        self.curr = 1
	    def __iter__(self):
	        return self

	    def __next__(self):
	        value = self.curr
	        self.curr += self.prev
	        self.prev = value
	        return value

	f=fib()

	## False: type(fib)==type has no __iter__/__next__
	print(isinstance(fib, collections.Iterable));
    hasattr(type(fib), '__iter__')
	print(isinstance(fib, collections.Iterator));
    hasattr(type(fib), '__next__')

	## True: 'fib'  has __iter__/__next__
	print(isinstance(f, collections.Iterable));
    hasattr(type(f), '__iter__')
	print(isinstance(f, collections.Iterator));
    hasattr(type(f), '__next__')
	print(next(f))
	print(next(f))
	for x in f: print(x);quit()

## Iterator
> Not all Iterator is generate from Iterable, but also `class <type>`

Any object that has a `__next__()` and `__iter__()` method is therefore an iterator(support `for and next statement`)
There are countless examples of iterators. All of the itertools functions return iterators. Some produce infinite sequences:

	>>> from itertools import count
	>>> counter = count(start=13)
	>>> next(counter)
	13
	>>> next(counter)
	14

Some produce infinite sequences from finite sequences:

	>>> from itertools import cycle
	>>> colors = cycle(['red', 'white', 'blue'])
	>>> next(colors)
	'red'
	>>> next(colors)
	'white'

Some produce finite sequences from infinite sequences:

	>>> from itertools import islice
	>>> colors = cycle(['red', 'white', 'blue'])  # infinite
	>>> limited = islice(colors, 0, 4)            # finite
	>>> for x in limited:                         # so safe to use for-loop on
	...     print(x)
	red
	white
	blue
	red

iterator support for-next: e.g. permutations
```
>>> horses = [1, 2, 3, 4]
>>> races = itertools.permutations(horses)
>>> print(races)
>>> print(list(itertools.permutations(horses)))
<itertools.permutations object at 0xb754f1dc>
[(1, 2, 3, 4),
 (1, 2, 4, 3),.......
 ```

## generator, 生成器
 A generator is a special kind of iterator—the elegant kind: 使用yield 代替了复杂的iter(), next()

- container: an object is a container when it can be asked whether it contains a certain element

You can perform such membership tests on lists, sets, or tuples alike:

	>>> assert 1 in [1, 2, 3]      # lists
	>>> assert 4 not in [1, 2, 3]
	>>> assert 1 in {1, 2, 3}      # sets
	>>> assert 4 not in {1, 2, 3}
	>>> assert 1 in (1, 2, 3)      # tuples
	>>> assert 4 not in (1, 2, 3)

Dict membership will check the keys:

	>>> d = {1: 'foo', 2: 'bar', 3: 'qux'}
	>>> assert 1 in d
	>>> assert 4 not in d
	>>> assert 'foo' not in d  # 'foo' is not a _key_ in the dict

Finally you can ask a string if it "contains" a substring:

	>>> s = 'foobar'
	>>> assert 'b' in s
	>>> assert 'x' not in s
	>>> assert 'foo' in s  # a string "contains" all its substrings

> Not all containers are necessarily iterable. An example of this is a Bloom filter. Probabilistic data structures like this can be asked whether they contain a *certain element*, but they are *unable to return their individual elements*.

### Generator Expressions
Generator is an *iterable* created using a function with a `yield` statement.

    def my_gen():
    ...     for x in range(5):
    ...             yield x

### generator comprehension
Generator expressions allow the creation of a generator on-the-fly *without a yield keyword*.

    >>> g = (i for i in range(7) if i%2==0)
    <generator object <genexpr> at 0x1066f9468>
    >>> list(g)
    [0, 2, 4, 6]

We can check how much memory is taken by both types using `sys.getsizeof()` method.

    gen = (i for i in range(7) if i%2==0)
    >>> sys.getsizeof(gen)


# yield
it require for the `first send()` to be `None`
> You can't send() a value the first time because the generator did not execute until the point where you have the yield statement, so there is nothing to do with the value.(没有停在yield 语句)

## send next close
1. r = c.send(n); # 向generator yield 传值, 并启动generator 执行
1. r = next(c); # 等价于：r = c.send(None)
2. c.close()

	def cc():
		n = 1
		while True:
			n += 1;
			if n>=4: return 'done'
			yield n

	c = cc()
	print(next(c))
	print(next(c))
	print(next(c))

next(c) 等价于c.send(None)

	2
	3
	Traceback (most recent call last):
	  File "a.py", line 11, in <module>
	    print(next(c))
	StopIteration: done

这个Stop是可以捕获的:

    def f():
        x=yield 0
        return x
    b=f()
    try:
        print(b.send(None)) # 0
        print(b.send(11))
        print(b.send(12))
    except StopIteration as e:
        print(e.value) # 11


# data comprehension
## list comprehension
list comprehension finishes evaluation, not Iterator

    >>> [x ** 2 for x in range(7) if x % 2 == 0]
    [0, 4, 16, 36]
    >>> comp_list = [x for x in "some text" if x !=" "]

use list comprehension to combine several lists

    >>> nums = [1, 2, 3, 4, 5]
    >>> letters = ['A', 'B', 'C', 'D', 'E']
    >>> nums_letters = [[n, l] for n in nums for l in letters]
    [[1, 'A'], [1, 'B'], [1, 'C']....] # 注意，这是二维数组的关系, 还可以是多维
    >>> nums_letters = [(n, l) for n in nums for l in letters]

发挥你的想像：

    >>> [(i,i) for i in range(3)]
    [(0, 0), (1, 1), (2, 2)]
    >>> [(i,j) for i in range(3) for j in range(20) if j%10==0]
    [(0, 0), (0, 10), (1, 0), (1, 10), (2, 0), (2, 10)]

## dict comprehension
    >>> dict_comp = {x:chr(65+x) for x in range(1, 11)}
    {1: 'B', 2: 'C', 3: 'D', 4: 'E', 5: 'F', 6: 'G', 7: 'H', 8: 'I', 9: 'J', 10: 'K'}
    >>> type(dict_comp)
    <class 'dict'>  

	{n:m for n, m in {1:2,3:4}.items()}
	dict((n*2, n) for n, m in {1:2,3:4}.items())


## set comprehension
    >>> set_comp = {x ** 3 for x in range(10) if x % 2 == 0}
    {0, 8, 64, 512, 216}
    >>> type(set_comp)
    <class 'set'>  

## generator comprehension
list generator:

	g = (x * x for x in range(10))
	>>> print(g)
	<generator object <genexpr> at 0x10c7dd888>
	>>> next(g)
	0
	>>> ''.join(str(i) for i in [1,2])
	'12'

斐波拉契数列用列表生成式写不出来，但是，用函数把它打印出来却很容易：

	def fib(max):
		n, a, b = 0, 0, 1
		while n < max:
			print(b)
			a, b = b, a + b
			n = n + 1
		return 'done'

上面的函数可以输出斐波那契数列的前N个数, 改成generator 就是：

	def fib(max):
		n, a, b = 0, 0, 1
		while n < max:
			yield b
			a, b = b, a + b
			n = n + 1
		return 'done'
