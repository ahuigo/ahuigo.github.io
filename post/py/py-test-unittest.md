---
layout: page
title: py-test-unittest
category: blog
description: 
date: 2018-10-04
---
# Preface
- unittest
- doctest
- nose
> 参考：http://www.liaoxuefeng.com/wiki/0014316089557264a6b348958f449949df42a6d3a2e542c000/00143191629979802b566644aa84656b50cd484ec4a7838000

# Unittest
编写一个Dict类，这个类的行为和dict一致，但是可以通过属性来访问，用起来就像下面这样：

	>>> d = Dict(a=1, b=2)
	>>> d['a']
	1
	>>> d.a
	1

	class Dict(dict):

		def __init__(self, **kw):
			super().__init__(**kw)

		def __getattr__(self, key):
			try:
				return self[key]
			except KeyError:
				raise AttributeError(r"'Dict' object has no attribute '%s'" % key)

		def __setattr__(self, key, value):
			self[key] = value

## 测试类
编写一个测试类，从unittest.TestCase继承

	import unittest
	from mydict import Dict

	class TestDict(unittest.TestCase):

		def test_init(self):
			d = Dict(a=1, b='test')
			self.assertEqual(d.a, 1)
			self.assertEqual(d.b, 'test')
			self.assertTrue(isinstance(d, dict))

		def test_key(self):
			d = Dict()
			d['key'] = 'value'
			self.assertEqual(d.key, 'value')

		def test_attr(self):
			d = Dict()
			d.key = 'value'
			self.assertTrue('key' in d)
			self.assertEqual(d['key'], 'value')

		def test_keyerror(self):
			d = Dict()
			with self.assertRaises(KeyError):
				value = d['empty']

		def test_attrerror(self):
			d = Dict()
			with self.assertRaises(AttributeError):
				value = d.empty

以test开头的方法就是测试方法，不以test开头的方法不被认为是测试方法，测试的时候不会被执行。

### 断言

	self.assertEqual(abs(-1), 1); # 断言函数返回的结果与1相等

另一种重要的断言就是期待抛出指定类型的Error，比如通过d['empty']访问不存在的key时，断言会抛出KeyError：

	with self.assertRaises(KeyError):
		value = d['empty']

## 运行单元测试
一旦编写好单元测试，我们就可以运行单元测试。最简单的运行方式是在mydict_test.py的最后加上两行代码：

	if __name__ == '__main__':
		unittest.main()

这样就可以把mydict_test.py当做正常的python脚本运行：

	$ python3 mydict_test.py

另一种方法是在命令行通过参数-m unittest直接运行单元测试：

	$ python3 -m unittest mydict_test

这是推荐的做法，因为这样可以一次批量运行很多单元测试，并且，有很多工具可以自动来运行这些单元测试。

## setUp 与 tearDown
可以在单元测试中编写两个特殊的setUp()和tearDown()方法。这两个方法会分别在每调用一个测试方法的前后分别被执行。

setUp()和tearDown()方法有什么用呢？设想你的测试需要启动关闭一个数据库

	class TestDict(unittest.TestCase):
		def setUp(self):
			print('setUp...')

		def tearDown(self):
			print('tearDown...')

# doctest

	def abs(n):
		'''
		Function to get absolute value of number.

		Example:

		>>> abs(1)
		1
		>>> abs(-1)
		1
		>>> abs(0)
		0
		'''
		return n if n >= 0 else (-n)

Python内置的“文档测试”（doctest）模块可以直接提取注释中的代码并执行测试。

只有测试异常的时候，可以用...表示中间一大段烦人的输出。

	# mydict2.py
	class Dict(dict):
		'''
		Simple dict but also support access as x.y style.

		>>> d1 = Dict()
		>>> d1['x'] = 100
		>>> d1.x
		100
		>>> d1.y = 200
		>>> d1['y']
		200
		>>> d2 = Dict(a=1, b=2, c='3')
		>>> d2.c
		'3'
		>>> d2['empty']
		Traceback (most recent call last):
			...
		KeyError: 'empty'
		>>> d2.empty
		Traceback (most recent call last):
			...
		AttributeError: 'Dict' object has no attribute 'empty'
		'''
		def __init__(self, **kw):
			super(Dict, self).__init__(**kw)

		def __getattr__(self, key):
			try:
				return self[key]
			except KeyError:
				raise AttributeError(r"'Dict' object has no attribute '%s'" % key)

		def __setattr__(self, key, value):
			self[key] = value

	if __name__=='__main__':
		import doctest
		doctest.testmod()

测试：

	$ python3 mydict2.py