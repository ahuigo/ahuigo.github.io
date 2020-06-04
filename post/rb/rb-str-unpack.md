---
title: ruby unpak
date: 2020-05-16
private: true
---
# ruby unpack
Refer: https://www.runoob.com/ruby/ruby-array.html
## str.unpack
下表列出了方法 String#unpack 的解压指令。

    指令	返回	描述
    A	String	移除尾随的 null 和空格。
    a	String	字符串。
    B	String	从每个字符中提取位（首先是最高有效位）。
    b	String	从每个字符中提取位（首先是最低有效位）。
    C	Fixnum	提取一个字符作为无符号整数。
    c	Fixnum	提取一个字符作为整数。
    D, d	Float	把 sizeof(double) 长度的字符当作原生的 double。
    E	Float	把 sizeof(double) 长度的字符当作 littleendian 字节顺序的 double。
    e	Float	把 sizeof(float) 长度的字符当作 littleendian 字节顺序的 float。
    F, f	Float	把 sizeof(float) 长度的字符当作原生的 float。
    G	Float	把 sizeof(double) 长度的字符当作 network 字节顺序的 double。
    g	Float	把 sizeof(float) 长度的字符当作 network 字节顺序的 float。
    H	String	从每个字符中提取十六进制（首先是最高有效位）。
    h	String	从每个字符中提取十六进制（首先是最低有效位）。
    I	Integer	把 sizeof(int) 长度（通过 _ 修改）的连续字符当作原生的 integer。
    i	Integer	把 sizeof(int) 长度（通过 _ 修改）的连续字符当作有符号的原生的 integer。
    L	Integer	把四个（通过 _ 修改）连续字符当作无符号的原生的 long integer。
    l	Integer	把四个（通过 _ 修改）连续字符当作有符号的原生的 long integer。
    M	String	引用可打印的。
    m	String	Base64 编码。
    N	Integer	把四个字符当作 network 字节顺序的无符号的 long。
    n	Fixnum	把两个字符当作 network 字节顺序的无符号的 short。
    P	String	把 sizeof(char *) 长度的字符当作指针，并从引用的位置返回 \emph{len} 字符。
    p	String	把 sizeof(char *) 长度的字符当作一个空结束字符的指针。
    Q	Integer	把八个字符当作无符号的 quad word（64 位）。
    q	Integer	把八个字符当作有符号的 quad word（64 位）。
    S	Fixnum	把两个（如果使用 _ 则不同）连续字符当作 native 字节顺序的无符号的 short。
    s	Fixnum	把两个（如果使用 _ 则不同）连续字符当作 native 字节顺序的有符号的 short。
    U	Integer	UTF-8 字符，作为无符号整数。
    u	String	UU 编码。
    V	Fixnum	把四个字符当作 little-endian 字节顺序的无符号的 long。
    v	Fixnum	把两个字符当作 little-endian 字节顺序的无符号的 short。
    w	Integer	BER 压缩的整数。
    X	 	向后跳过一个字符。
    x	 	向前跳过一个字符。
    Z	String	和 * 一起使用，移除尾随的 null 直到第一个 非null。
    @	 	跳过 length 参数给定的偏移量。

解压各种数据。

    "abc \0\0abc \0\0".unpack('A6Z6')   #=> ["abc", "abc "]
    "abc \0\0".unpack('a3a3')           #=> ["abc", " \000\000"]
    "abc \0abc \0".unpack('Z*Z*')       #=> ["abc ", "abc "]
    "aa".unpack('b8B8')                 #=> ["10000110", "01100001"]
    "aaa".unpack('h2H2c')               #=> ["16", "61", 97]
    "\xfe\xff\xfe\xff".unpack('sS')     #=> [-2, 65534]
    "now=20is".unpack('M*')             #=> ["now is"]
    "whole".unpack('xax2aX2aX1aX2a')    #=> ["h", "e", "l", "l", "o"]

## array.pack
与字符串相对应

    a = [ "a", "b", "c" ]
    n = [ 65, 66, 67 ]
    puts a.pack("A3A3A3")   #=> "a  b  c  "
    puts a.pack("a3a3a3")   #=> "a\000\000b\000\000c\000\000"
    puts n.pack("ccc")      #=> "ABC"

## 进制转换(字符形式)
### hex 转换

    'abc'.unpack('H*') #=> ["616263"]
    ["616263"].pack('H*')
### binary 转换
    "\x01".unpack('B*') => ["00000001"]

## 编码到字符
    n = [ 65, 66, 67 ]
    puts n.pack("ccc")      #=> "ABC"