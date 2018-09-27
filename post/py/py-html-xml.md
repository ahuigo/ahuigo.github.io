---
title: python lxml 的使用
date: 2018-09-28
---
# python lxml 的使用
BeautifulSoup 可以使用lxml 解释器，lxml 这个解释器的使用并不复杂。

今天了解一下lxml 用法后，发现BS 完全可以代替它了. 而且BS 还提供了统一的接口

> 参考: https://www.cnblogs.com/dahu-daqing/p/6749666.html

## Load element

    from lxml import etree

    root = etree.fromstring('<root><foo id="foo_id">bar</foo></root>')
    root = etree.XML('<root><foo id="foo_id">bar</foo></root>')
    root = etree.HTML('<root><foo id="foo_id">bar</foo></root>') // 外面自动包html+body

    root = etree.Element('root')
    etree.tostring(root)
    print(root.tag)

    parser= etree.XMLParser(remove_blank_text=True) #去除xml文件里的空行
    root = etree.XML("<root>  <a/>   <b>  </b>     </root>",parser)
    print etree.tostring(root)

文件类型解析: xml 区分节点和树(貌似这个树没啥用！)

    tree =etree.parse('text')   #文件解析成元素树
    root3 = tree.getroot()      #获取元素树的根节点
    roottree == roottree.getroot().getroottree()
    print etree.tostring(root3,pretty_print=True)

Load to Object

    from lxml import objectify
    tree = objectify.fromstring(b'<html><body>...</body></html>')
    tree.body

    In [53]: tree = objectify.fromstring(b'<html><body>..<span>1</span
    ...: ></body></html>')
    In [56]: tree.findall('body/span')
    Out[56]: [1]

## Save Element/tree

    print etree.tostring(root)
    print(etree.tostring(root, xml_declaration=True,pretty_print=True,encoding='utf-8'))#指定xml声明和编码
    etree.write(sys.stdout, pretty_print=True)

## CURD Element

    # 添加子节点
    child1 = etree.SubElement(root, 'child1')
    child2 = etree.SubElement(root, 'child2')
    
    # 删除子节点
    # root.remove(child2)
    
    # 删除所有子节点
    # root.clear()
    
    # 插入节点
    print(len(root))
    print root.index(child1)  # 索引号
    root.insert(0, etree.Element('child3'))  # 按位置插入
    root.append(etree.Element('child4'))  # 尾部添加
    
    # 获取父节点
    print(child1.getparent().tag)
    # print root[0].getparent().tag   #用列表获取子节点,再获取父节点
    '''以上都是节点操作'''

## Attribute of Element
    
    # 7.创建属性
    # root.set('hello', 'dahu')   #set(属性名,属性值)
    # root.set('hi', 'qing')
    
    #12.判断文本类型
    print tt[0].is_text,tt[-1].is_tail  #判断是普通text文本,还是tail文本

    # 8.获取属性
    # print(root.get('hello'))    #get方法
    # print(root.keys(),root.values(),root.items())    #参考字典的操作
    # print root.attrib           #直接拿到属性存放的字典,节点的attrib,就是该节点的属性
    '''以上是属性的操作'''
    
    # 9.text和tail属性
    # root.text = 'Hello, World!'
    # print(root.text)
    
    # 10.test,tail和text的结合
    html = etree.Element('html')
    html.text = 'html.text'
    body = etree.SubElement(html, 'body')
    body.text = 'wo ai ni'
    child = etree.SubElement(body, 'child')
    child.text='child.text' #一般情况下,如果一个节点的text没有内容,就只有</>符号,如果有内容,才会<>,</>都有
    child.tail = 'tails'  # tail是在标签后面追加文本
    print(etree.tostring(html))
    # print(etree.tostring(html, method='text'))  # 只输出text和tail这种文本文档,输出的内容连在一起,不实用
    
## Findall+Find Element

    root = etree.XML("<root><a x='123'>aText<b/><c/><b/></a></root>")
    print(root.findall('a')[0].text)#findall操作返回列表
    print(root.find('.//a').text)   #find操作就相当与找到了这个元素节点,返回匹配到的第一个元素
    print(root.find('a').text)
    print [ b.text for b in root.findall('.//a') ]    #配合列表解析,相当帅气!
    print(root.findall('.//a[@x]')[0].tag)  #根据属性查询
    '''以上是搜索和定位操作'''
    print(etree.iselement(root))
    print root[0] is root[1].getprevious()  #子节点之间的顺序
    print root[1] is root[0].getnext()
    '''其他技能'''

## Xpath(支持修饰符的findall)

    root = etree.XML('<root><a><b>1</b></a></root>')
    root.xpath('.')[0].tag
    root.xpath('./a/b')[0].tag
    root.xpath('a/b')[0].xpath('/root')[0].tag

    page.xpath('/*')  # 任意tag
    page.xpath('.//b')  # 跨过多级tag

    # print(html.xpath('string()'))   #这个和上面的方法一样,只返回文本的text和tail
    print(html.xpath('//text()'))   #这个比较好,按各个文本值存放在列表里面
    tt=html.xpath('a/b//text()')
    print tt[0].getparent().tag     #这个可以,首先我可以找到存放每个节点的text的列表,然后我再根据text找相应的节点
    # for i in tt:
    #     print i,i.getparent().tag,'\t',

    # by attr
    for i in  a.xpath('//div[@class="quote"]/span[@class="text"]/text()'):
        print i
    
## Loop:iter Element

    root = etree.Element("root")
    etree.SubElement(root, "child").text = "Child 1"
    etree.SubElement(root, "child").text = "Child 2"
    etree.SubElement(root, "another").text = "Child 3"
    etree.SubElement(root[0], "childson").text = "son 1"

    # for i in root.iter():   #深度遍历
    # for i in root.iter('child'):    #只迭代目标值
    #     print i.tag,i.text
    # print etree.tostring(root,pretty_print=True)