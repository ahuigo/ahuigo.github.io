---
layout: page
title: py-str-hashlib
category: blog
description: 
date: 2018-10-04
---
# Preface
Python的hashlib提供了常见的摘要算法，如MD5，SHA1等等。

什么是摘要算法呢？摘要算法又称哈希算法、散列算法。它通过一个函数，把任意长度的数据转换为一个长度固定的数据串（通常用16进制的字符串表示）。

摘要算法就是通过摘要函数f()对任意长度的数据data计算出固定长度的摘要digest，目的是为了发现原始数据是否被人篡改过。

# encrypt

## hash

	hash('a');//12416037344

## base64

	>>> import base64
	>>> import pickle
	>>> base64.b64decode(open('a.txt').read())
	"(dp1\nS'count'\np2\nI5\nsS'ip'\np3\nV127.0.0.1\np4\nsS'session_id'\np5\nS'df7cd559362a9d170ecb1a4e7752c5ab999fb0eb'\np6\ns."
	>>> x =base64.b64decode(open('a.txt').read())
	>>> pickle.loads(x)
	{'count': 5, 'ip': u'127.0.0.1', 'session_id': 'df7cd559362a9d170ecb1a4e7752c5ab999fb0eb'}

由于标准的Base64编码后可能出现字符+和/，在URL中就不能直接作为参数，所以又有一种"url safe"的base64编码，其实就是把字符+和/分别变成-和_：

	>>> base64.b64encode(b'i\xb7\x1d\xfb\xef\xff')
	b'abcd++//'
	>>> base64.urlsafe_b64encode(b'i\xb7\x1d\xfb\xef\xff')
	b'abcd--__'
	>>> base64.urlsafe_b64decode('abcd--__')
	b'i\xb7\x1d\xfb\xef\xff'

# hashlib
## sha1
	hashlib.sha1(b'mypasswd').hexdigest()
		sha1=hashlib.sha1()
		sha1.update(b'mypasswd')
		sha1.hexdigest()
	hashlib.md5(b'mypasswd').hexdigest()
		md5 = hashlib.md5()
		md5.update(b'mypasswd'))
		md5.hexdigest()

## md5
我们以常见的摘要算法MD5为例，计算出一个字符串的MD5值：

	import hashlib
	md5 = hashlib.md5()
	md5.update('how to use md5 in python hashlib?'.encode('utf-8'))
	print(md5.hexdigest())

计算结果如下：

	d26a53750bc40b38b65a520292f69306

如果数据量很大，可以分块多次调用update()，最后计算的结果是一样的：

	md5.update('how to use md5 in '.encode('utf-8'))
	md5.update('python hashlib?'.encode('utf-8'))
	print(md5.hexdigest())

MD5是最常见的摘要算法，速度很快，生成结果是固定的128 bit字节，通常用一个32位的16进制字符串表示。

## SHA1
另一种常见的摘要算法是SHA1，调用SHA1和调用MD5完全类似：

	import hashlib

	sha1 = hashlib.sha1()
	sha1.update('how to use sha1 in '.encode('utf-8'))
	sha1.update('python hashlib?'.encode('utf-8'))
	print(sha1.hexdigest())

SHA1的结果是160 bit字节，通常用一个40位的16进制字符串表示。

比SHA1更安全的算法是SHA256和SHA512，不过越安全的算法不仅越慢，而且摘要长度更长。

有没有可能两个不同的数据通过某个摘要算法得到了相同的摘要？非常困难