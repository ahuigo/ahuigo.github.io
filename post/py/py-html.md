---
layout: page
title:
category: blog
description:
---
# Preface

# html

## emtities
encodeEntities - decodeEntities:

    Markup.escape('<blink>hacker</blink>')

via html

	import html
	print(html.unescape('&pound;682m'))

via bs4, 自动转：

	BeautifulSoup("<p>&pound;682m</p>")
	<html><body><p>£682m</p></body></html>

# BeautifulSoup
http://www.crummy.com/software/BeautifulSoup/bs4/doc/index.zh.html#find

## 解释器
Python的内置标准库, 速度中等, 容错能力强

	BeautifulSoup(markup, "html.parser")

lxml 是c 解释器, 速度快, 唯一支持xml/lxml

	BeautifulSoup(markup, ["lxml", "xml"])
	BeautifulSoup(markup, "xml")

html5lib 是python 写的, 不依赖外部扩展, 速度慢, 最强容错

	BeautifulSoup(markup, "html5lib")

## 数据类型

	soup = BeautifulSoup(markup, "html.parser")
	list = soup.select(...) 
	bs4.element.Tag = soup.select(...)[0] 

无论是soup还是Tag, 都支持select/find/find_all 这些方法

## install

	pip3 install BeautifulSoup4

## findNode(findTag)

### select

    soup.select('div.classname a[href^="/video"]')[0]

### by tag
查单个的tag2

	soup.tag1.tag2 # tag1 是tag2的父结点，祖父结点都可以。

如果想要得到所有的<p>标签,或是得到其它tag, 就需要用到 Searching the tree 中描述的方法,比如: find_all()
(findAll()是别名方法)

```
from bs4 import BeautifulSoup
html_doc = '''
	<body>
		<div name="hilo" class="class1 class2">
			<p>1</p>
			<p>2</p>
		</div>
		<div></div>
	</body>'''
soup = BeautifulSoup(html_doc, 'html.parser')
soup.body.div.findAll('p')[1]
soup.div.findAll('p')[1]
```

### parent,parents
parents 是迭代器

	>>> for node in BeautifulSoup("<html><body><div>1 23\n <p>red</p> 456\n</div></body></html>", 'html.parser').div.p.parents: print(node.name)
	...
	div
	body
	html
	[document]

### sibling

#### next_sibling and previous_sibling

	BeautifulSoup("<a><b>text1</b><c>text2</c></a>").a.b.next_sibling
	BeautifulSoup("<a><b>text1</b><c>text2</c></a>").a.c.previous_sibling

迭代

	>>> for i in BeautifulSoup("<a><b>text1</b><c>text2</c><d1></d1><d2></d2></a>").a.c.next_siblings: i
	...
	<d1></d1>
	<d2></d2>

### .contents 和 .children(含换行、空白字符)
tag的 .contents 属性可以将tag的子节点以列表的方式输出:

	>>> soup.div.contents
	['\n', <p>1</p>, '\n', <p>2</p>, '\n']

通过tag的 .children 生成器,可以对tag的子节点进行循环:

	for child in soup.div.children:
		print(child)

#### descendants
递归遍历

	>>> for node in BeautifulSoup('<div><sub><p></p></sub><sub></sub></div>', 'html.parser').div.descendants: node
	<sub><p></p></sub>
	<p></p>
	<sub></sub>

### find, find_all

	BeautifulSoup("<a><d>1</d><d id='2'>2</d></a>").a.find('d',id="2")
	<d id="2">2</d>

find 支持正则

	import re
	for tag in soup.find_all(re.compile("^b")):
	    print(tag.name)
	# body
	# b

#### find列表

	soup.find_all(["a", "b"])
	# [<b>The Dormouse's story</b>,
	#  <a class="sister" href="http://example.com/elsie" id="link1">Elsie</a>,
	#  <a class="sister" href="http://example.com/lacie" id="link2">Lacie</a>,
	#  <a class="sister" href="http://example.com/tillie" id="link3">Tillie</a>]

#### find custom

	def has_class_but_no_id(tag):
		return tag.has_attr('class') and not tag.has_attr('id')

	soup.find_all(has_class_but_no_id)

#### by key word

	soup.find_all(id='link2')
	soup.find_all(href=re.compile("elsie"))
	soup.find_all(href=re.compile("elsie"), id='link1')

有些tag属性在搜索不能使用,比如HTML5中的 data-* 属性:

	data_soup = BeautifulSoup('<div data-foo="value">foo!</div>')
	data_soup.find_all(data-foo="value")
	# SyntaxError: keyword can't be an expression

但是可以通过 find_all() 方法的 attrs 参数定义一个字典参数来搜索包含特殊属性的tag:

	data_soup.find_all(attrs={"data-foo": "value"})
	# [<div data-foo="value">foo!</div>]

#### by css

	soup.find_all("a", class_="sister")
	# [<a class="sister" href="http://example.com/elsie" id="link1">Elsie</a>,
	#  <a class="sister" href="http://example.com/tillie" id="link3">Tillie</a>]

class_ 参数同样接受不同类型的 过滤器 ,字符串,正则表达式,方法或 True :

	soup.find_all(class_=re.compile("itl"))
	# [<p class="title"><b>The Dormouse's story</b></p>]

	def has_six_characters(css_class):
		return css_class is not None and len(css_class) == 6

	soup.find_all(class_=has_six_characters)

tag的 class 属性是 多值属性 .按照CSS类名搜索tag时,可以分别搜索tag中的每个CSS类名:

	css_soup.find_all("p", class_="strikeout")
	# [<p class="body strikeout"></p>]

	css_soup.find_all("p", class_="body strikeout")

完全匹配 class 的值时,如果CSS类名的顺序与实际不符,将搜索不到结果:

	soup.find_all("a", attrs={"class": "sister"})

## add node

### create node

via new tag

	tag = soup.new_tag("i")
	tag.string = "Don't"

via text node

	'bar'

via bs4

	tag = BeautifulSoup('<br>', 'html.parser')

### wrap

	soup.p.wrap(soup.new_tag("div")
	# <div><p><b>I wish I was bold.</b></p></div>

### append

	soup = BeautifulSoup("<a>Foo</a>")
	soup.a.append("Bar")
	# <html><head></head><body><a>FooBar</a></body></html>

### insert
insert 到指定位置

	markup = '<a href="http://example.com/">I linked to <i>example.com</i></a>'
	soup = BeautifulSoup(markup)

	tag.insert(1, "but did not endorse ")
	# <a href="http://example.com/">I linked to but did not endorse <i>example.com</i></a>

#### insert_before, insert_after
insert_before() 方法在当前node 或文本节点前插入内容:

	tag = soup.new_tag("i")
	tag.string = "Don't"
	BeautifulSoup("<b>stop</b>").b.string.insert_before(tag)
	# <b><i>Don't</i>stop</b>

insert_after() 方法在当前tag或文本节点后插入内容:

	soup.b.i.insert_after(soup.new_string(" ever "))
	# <b><i>Don't</i> ever stop</b>

## attribue

### tag name

	>>> soup.div.name
	'div'

### get attr

	>>> soup.div.attrs['name']
	>>> soup.div['name']
	'hilo'
	>>> soup.div.attrs['class']
	>>> soup.div['class']
	['class1', 'class2']

has attr

	tag.has_attr('name')

### set attr

	>>> soup.div['class'] = ['class1', 'class2']

### del attr

	del tag['class']
	del tag.attrs['class']
	del tag.attrs['name']

## string, strings
`type(node) = NavigableString`时，可以显示`string`

	>>> soup.div.p.string
	'1'

string 不能被编辑，但能替换

	soup.div.p.string.replace_with("No longer bold")
	soup.div.p.string = "other string"

### strings 迭代器

	>>> for str in BeautifulSoup("<div>1 23\n <p>red</p> 456\n</div>", 'html.parser').div.strings: str;
	...
	'1 23\n '
	'red'
	' 456\n'

输出的字符串中可能包含了很多空格或空行,使用 .stripped_strings 可以去除前后多余空白内容:

	>>> for str in BeautifulSoup("<div>1 23\n <p>red</p> 456\n</div>", 'html.parser').div.stripped_strings: str;
	...
	'1 23'
	'red'
	'456'

## format
美化对齐:

	tag.prettify()

### strip tags

	b.div.get_text()
