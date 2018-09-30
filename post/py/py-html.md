---
title: 用BeautifulSoup 处理 html/xml
date: 2018-09-28
---
# 用BeautifulSoup 处理 html/xml
一般转义html 用一下几个方法

via html

    html.escape(u'<看>')
    >>> html.escape(u'<看>')
    '&lt;看&gt;'
    >>> html.escape(u'<看>').encode('ascii', 'xmlcharrefreplace')
    b'&lt;&#30475;&gt;'

via bs4, 只能输出：

	BeautifulSoup("<p>&pound;682m</p>")
	<html><body><p>£682m</p></body></html>

bs4 install:

	pip3 install BeautifulSoup4
    In [57]: from bs4 import BeautifulSoup
    ...:     html_doc = '''
    ...:         <body>
    ...:             <div name="hilo" class="class1 class2">
    ...:                 <p>1</p>
    ...:                 <p>2</p>
    ...:             </div>
    ...:             <div></div>
    ...:         </body>'''
    ...:     soup = BeautifulSoup(html_doc, 'html.parser')
    ...:     soup.body.div.findAll('p')[1]
    ...:     soup.div.findAll('p')[1]

## 解释器
但是要处理html/xml，就要上工具了:
2. xml 性能差，麻烦
3. lxml cpython 写的性能好
1. BS 是最方便的胶水

Python的内置标准库, 速度中等, 容错能力强

	BeautifulSoup(markup, "html.parser")
	BeautifulSoup(open('a.xml').read())

lxml 是c 解释器, 速度快, 唯一支持xml/lxml

	BeautifulSoup(markup, ["lxml", "xml"])
	BeautifulSoup(markup, "xml")

html5lib 是python 写的, 不依赖外部扩展, 速度慢, 最强容错

	BeautifulSoup(markup, "html5lib")

which parser should I use?

    from bs4.diagnose import diagnose
    diagnose(data)

## findNode(findTag)
都支持select/find/find_all 这些方法(Note: findAll === find_all)

	soup = BeautifulSoup(markup, "html.parser")
	list = soup.select(...) 

### select

    soup.select('div.classname a[href^="/video"]')[0]
    soup.html('> body') # js document.querySelector 本身不支持

### by tag
查单个的tag2

	soup.tag1.tag2 # tag1 是tag2的父结点、祖父结点
    soup.find('tag1').find('tag2')

### findChild, findChildren

    bs.html.findChild('body')

### list child, children

    list(soup.children)

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

    find_all( name , attrs , recursive , text , **kwargs )

如果想要得到所有的<p>标签,或是得到其它tag, 就需要用到 Searching the tree 中描述的方法,比如: find_all()

	soup = BeautifulSoup("<a><d>1</d><d id='2'>2</d></a>").a.find('d',id="2")
	<d id="2">2</d>
    soup.findAll('tag')[0]

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

#### by text

	soup.find_all('div', text='Python')
	soup.find_all('div', text=re.compile('^Python$'))

#### by attr

	soup.find_all('div', id='link2')
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

node type:

    type(bs.new_tag('div'))
        bs4.element.Tag

    type(bs)
        bs4.BeautifulSoup

    type(bs.new_string('text'))
        bs4.element.NavigableString

### create node
via new tag

	tag = soup.new_tag("i")
	tag.string = "Don't"

    tag = BeautifulSoup('<i>Don\'t</i>', 'html.parser')
    tag = BeautifulSoup('<i>Don\'t</i>', 'lxml').i

via text node

	'bar'
    # or 
    soup.new_string('bar')

### wrap

	soup.p.wrap(soup.new_tag("div")
	# <div><p><b>I wish I was bold.</b></p></div>
    soup.div.unwrap()

### append
append tag/text

    soup.body.append(soup.new_tag('div'))

append text(text 自动escape htmlentities)

	soup = BeautifulSoup("<a>Foo</a>")
	soup.a.append("Bar")
	# <html><head></head><body><a>FooBar</a></body></html>

### insert(内部)
insert text/tag 到指定位置

	markup = '<a href="http://example.com/">I linked to <i>example.com</i></a>'
	soup = BeautifulSoup(markup)

	tag.insert(1, "but did not endorse ")
	# <a href="http://example.com/">I linked to but did not endorse <i>example.com</i></a>

#### insert_before, insert_after
insert_before() 方法在当前node 前插入内容:

    tag = soup.new_tag("i")
    tag.string = "Don't"
    div = BeautifulSoup("<div><b>stop</b></div>", 'html.parser')
    div.b.insert_before(tag)
	# <div><b><i>Don't</i>stop</b></div>

insert_after() 方法在当前tag或文本节点后插入内容:

	soup.b.i.insert_after(soup.new_string(" ever "))
	# <b><i>Don't</i> ever stop</b>

### delete

    node.extract()

### replaceWith

    node.replaceWith(new_tag/text)

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

	>>> soup.div.p.string = '1'
	>>> soup.div.p.string
	'1'

python2 string 不能被编辑，但能替换

	soup.div.p.string.replace_with("No longer bold")
	soup.div.p.string = "other string"

pythone3 text 真只读

    p.string

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

## save to file
remove body

    next(soup.body.children)
    str(soup.body.rss)
    soup.encode()

美化对齐:

	tag.prettify()

### strip tags

	b.div.get_text()
	b.div.text

### xml
By default parser like lxml, html.parser, they will wrap it with html/body

    soup.html.body.unwrap()
    if soup.html.slelect('>head'):
        soup.head.unwrap()

`dignose` will tell you  to load xml with `lxml-xml` 

    BS(data, 'lxml-xml')

xml 不能创建CDATA: `[![CDATA]xxxx]]`