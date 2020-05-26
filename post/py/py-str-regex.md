---
layout: page
title: python 的正则表达式
category: blog
description:
---
# regex 语法

	import re
    re.compile(pattern, [,modifier]).match(str)
    re.match(pattern, str[, modifier])
    re.sub(r'from', 'to', 'content', flags=re.IGNORECASE)
    re.split(r'[\s\,]+', 'a,b, c  d')

## ignore string Escape

	>>> print('abc\n001')
	abc
	001
	>>> print(r'abc\n001')
	abc\n001

escape regex string

    >>> re.escape('[]')
    \[\]

in js:

    function escapeRegExp(string) {
        return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
    }

## 分组:

	>>> import re
	>>> m = re.match(r'(\d{3})\-(\d{3,8})', '010-12345')
	<_sre.SRE_Match object; span=(0, 9), match='010-12345'>

	>>> m.group(0)
	>>> m.group()
	010-12345
	>>> m.group(1)
        010
	>>> m.group(2)
        12345
	>>> m.groups()
	('010', '12345')
	>>> m.groups()[0]
	010

named group

    re.sub(r'(?P<quote>")abc\1',r'\g<quote>ABC\g<quote>' ,'"abc"')

## refer group

    pattern itself	    
        (?P=quote) (as shown)
        \1
    processing match object m	
        m.group('quote')
            m.end('quote') end index of quote
    in a string passed to the repl argument of re.sub()	
        \g<quote>
        \g<1>
        \1

    re.sub(r'(?P<quote>")abc\1',r'\g<quote>ABC\g<quote>' ,'"abc"')

## 命名分组

    # 分组必须带括号
    (?<name>pattern) # wrong
    (?P<name>pattern)
    (?:pattern) # 非命名

	pattern = re.search(r'(?P<fstar>f.*)(?P<bstar>b.*)', 'Hello foobar')
	pattern.group('fstar')

groups 列出所有的分组，但是不包含: group(0)=group()即整个匹配

    >>> re.match('((t)(e))st', 'TeSt', re.IGNORECASE).groups()
    ('Te', 'T', 'e')
    >>> re.match('((t)(e))st', 'TeSt', re.IGNORECASE).group()
    'TeSt'
    >>> re.match('((t)(e))st', 'TeSt', re.IGNORECASE).group(0)
    'TeSt'

group 可以取多个key

    >>> m.group('k1','k2')
    ('v1','v2')

groupdict 判断key 存在性

    mdict = m.groupdict()
    'k1' in mdict

## 元字符
可以是unicode

    re.split(r'[，,]+', '你好，我是..')
    >>> re.match(r'.', '你好').group()
    '你'

## 去贪婪

	r'\d{3,8}?'
	r'\d+?'

## 条件(IF-Then-Else)模式
条件可以是一个数字或者分组命名。表示如果存在前面捕捉到的分组就....

	(?(num)then|else)
	(?(GroupName)then)

比如我们可以用这个正则表达式来检测打开和闭合的尖括号：

	strings = [  "<pypix>",    # returns true
				 "<foo",       # returns false
				 "bar>",       # returns false
				 "hello" ]     # returns true

	for string in strings:
		pattern = re.search(r'^(<)?[a-z]+(?(1)>)$', string)
		if pattern:
			print 'True'
		else:
			print 'False'

在上面的例子中，1 表示分组 (<)，当然也可以为空因为后面跟着一个问号。条件也可以为命名:

    re.search(r'^(?P<flag><)?[a-z]+(?(flag)>)$', string)

## 断言

    >>> re.match(r'(\w+)=1,(?=bc\w+)', 'a=1,bcd')
    ('a')
    >>> re.match(r'(\w+)=([^=]*)(?:(?=,\w+=)|$)', 'a=1,b=3').groups()
    ('a', '1')

# regex 函数

	re.match(r'regex', str)
	re.compile(r'regex').match(str)

## compile
一个正则表达式要重复使用几千次，出于效率的考虑，我们可以预编译该正则表达式，接下来重复使用时就不需要编译这个步骤了，直接匹配：

	>>> re_telephone = re.compile(r'^(\d{3})-(\d{3,8})$')
	# 使用：
	>>> re_telephone.match('010-12345').groups()
	('010', '12345')
	>>> re_telephone.match('010-8086').groups()
	('010', '8086')

### modifier
compile with modifier:

	re.compile(r'.*', re.S) # re.S == re.DOTALL
	re.compile(r'.*', re.S|re.IGNORECASE) 
    re.IGNORECASE
    re.UNICODE

## replace, sub

    re.sub(r'helo', 'hello', 'helo world', flags=re.IGNORECASE)
        str.replace(needle, word, 1);

like `str.replace`

	re.sub(r'\w+', lambda m: m.group().upper(), ' hilo jack')
	' HILO JACK'

str.replace([list], rep) not work

## search
match 是匹配"^pattern"，search 则匹配"pattern", 失败返回None

	re.match() ^pattern
	re.fullmatch() ^pattern$
	re.search() pattern

eg:
    re.match('test', 'TeSt', re.IGNORECASE)
    re.search('test', 'TeSt', re.IGNORECASE)
        str.find('tt')

	>>> pattern = re.compile("d")
	>>> pattern.search(" dog")     # Match at index 1
	<_sre.SRE_Match object; span=(1, 2), match='d'>
	>>> pattern.search("dog123", 2)  # No match; "g123" doesn't include the "d"
    None

### search info

	>>> re.search(r'abc', '1 abc').span()
	(2, 5)
	not include 5

If you want to locate a match anywhere in string, use search() .

## split
用正则表达式切分字符串比用固定的字符更灵活，请看正常的切分代码：

	>>> 'a b   c'.split(' ')
	['a', 'b', '', '', 'c']

嗯，无法识别连续的空格. 不给参数就可以喽	

	>>> 'a b   c'.split()
	['a', 'b', 'c']

用正则表达式试试：

	>>> re.split(r'[\s\,]+', 'a,b, c  d')
	['a', 'b', 'c', 'd']

## findall
re.search/match/fullmatch 都是只找一次. 多个分组还会覆盖！

    >>> m=re.match(r'((\w+)=(\w+),?)+', 'a=1,b=2')
    >>> m.groups()
    ('b=2', 'b', '2')

Use re.findall or re.finditer instead.

	re.findall(pattern, string) returns a list of matching strings.
	re.finditer(pattern, string) returns an iterator over MatchObject objects.

findall

    >>> re.findall(r'(a)(\w+)', ' ahui jack')
    [('a', 'hui'), ('a', 'ck')]
    # 不会返回分组结果
    >>> re.findall(r'(\w+)', ' ahui jack')
	['ahui', 'jack']

## finditer
返回分组

	>>> r=re.compile(r'(\w+)-(\w+)')
	>>> m=r.finditer(' 1-a1 2-a2')
	>>> for i in m:
	...     print(i.groups())
	...
	('1', 'a1')
	('2', 'a2')

# glob 语法