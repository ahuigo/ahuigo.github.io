---
title: python3 的struct 字节处理工具
date: 20180505
---
# python3 的字节处理
1. 而在C语言中，我们可以很方便地用struct、union来处理字节，以及字节和int，float的转换。
2. Python3 中处理bytes 字节也很方便，同时还提供了强大的struct 处理工具

# 一般的字节处理
在Python中，比方说要把一个32位无符号整数变成字节，也就是4个长度的bytes，你得配合位运算符这么写：

	>>> n = 10240099
	>>> b1 = (n & 0xff000000) >> 24
	>>> b2 = (n & 0xff0000) >> 16
	>>> b3 = (n & 0xff00) >> 8
	>>> b4 = n & 0xff
	>>> bs = bytes([b1, b2, b3, b4])
	>>> bs
	b'\x00\x9c@c'

非常麻烦。如果换成浮点数就无能为力了。

好在Python提供了一个struct模块来解决bytes和其他二进制数据类型的转换。

## int to bytes(Buffer) 
int to bytes： as Js's `Buffer.from([1,2,3])`

	>>> bytes([0, 1, 97])
	b'\x00\x01a'

int to strhex

    >>> hex(16)
    '0x10'

### str2hex

    'abc'.encode().hex()
        '616263'
    bytes.fromhex('6162')
        b'abc'

Refer: py/py-strack for unpack

## base64

    import base64
    >>> base64.b64encode(b'a')
    b'YQ=='
    >>> base64.b64decode(b'a')

# struct

## pack
struct的pack函数把任意数据类型变成bytes：

	>>> import struct
	>>> struct.pack('>I', 8) # big-endian
    b'\x00\x00\x00\x08'
	>>> struct.pack('<I', 8) # big-endian
    b'\x08\x00\x00\x00'

pack的第一个参数是处理指令，`>I`的意思是：

	> 表示字节顺序是big-endian，也就是网络序，
	I 表示4字节无符号整数。

后面的参数个数要和处理指令一致。

## unpack
unpack把bytes变成相应的数据类型：

	>>> struct.unpack('>IH', b'\xf0\xf0\xf0\xf0\x80\x80')
	(4042322160, 32896)

根据`>IH`的说明，后面的bytes依次变为:

    c	char
    b	signed char	    B	unsigned char
    h: 2 bytes integer  H：2字节无符号整数。
	i: 4bytes integer   I：4字节无符号整数和
    l: 8bytes           L: 8 byte unsigned

所以，尽管Python不适合编写底层操作字节流的代码，但在对性能要求不高的地方，利用struct就方便多了。

struct模块定义的数据类型可以参考Python官方文档：

https://docs.python.org/3/library/struct.html#format-characters

## bmp
Windows的位图文件（.bmp）是一种非常简单的文件格式，我们来用struct分析一下。

首先找一个bmp文件，没有的话用“画图”画一个。

读入前30个字节来分析：

	>>> s = b'\x42\x4d\x38\x8c\x0a\x00\x00\x00\x00\x00\x36\x00\x00\x00\x28\x00\x00\x00\x80\x02\x00\x00\x68\x01\x00\x00\x01\x00\x18\x00'

BMP格式采用小端方式存储数据，文件头的结构按顺序如下：

1. 两个字节：'BM'表示Windows位图，'BA'表示OS/2位图；
1. 一个4字节整数：表示位图大小；
1. 一个4字节整数：保留位，始终为0；
1. 一个4字节整数：实际图像的偏移量；
1. 一个4字节整数：Header的字节数；
1. 一个4字节整数：图像宽度；
1. 一个4字节整数：图像高度；
1. 一个2字节整数：始终为1；
1. 一个2字节整数：颜色数。

所以，组合起来用unpack读取：

	>>> struct.unpack('<ccIIIIIIHH', s)
	(b'B', b'M', 691256, 0, 54, 40, 640, 360, 1, 24)

结果显示，b'B'、b'M'说明是Windows位图，位图大小为640x360，颜色数为24。
