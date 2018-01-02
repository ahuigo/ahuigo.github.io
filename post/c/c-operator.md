---
layout: page
title: c 语言运算符	
category: blog
description: 
---
# Preface

# Bit Operator位运算

## 位移

	<< 左移有符号与无符号没有区别
	>> 右移(对有符号数来说，符号位不变)

## 与或非

	& | ~

## Mask 掩码
提取8-15 位 (用& 1)

	(i & 0x0000ff00) >> 8
	(i >> 8) & ~(~0 << 8)

8-15 位清0 (用 & 0)

	mask = 0x0000ff00
	i & ~mask
	i & ~(0xff << 8)

8-15 位置1 (用 |1)

	i | 0xff00

## xor 异或

	1. a^a == 0 比movl $0, %eax 快
	2. a^b^b == a 可用于交换：a = a^b; b = a^b; a = a^b;
	3. a^1 == ~a , a^0 == a
	4. a1^a2^a3...^an 的结果是1 则1的个数为奇数个，否则1的个数为偶数个. （0不影响计算结果）

# sizeof typedef
sizeof 是在编译时确定的, 不是预编译哦

	sizeof i;//获取变量长度
	sizeof(int);

	char str[100];
	sizeof(str); //相当于sizeof(char [100])

	char *str = "abc";
	sizeof(str); //相当于sizeof(char *), 对于64位系统来说，就是8

	sizeof(expression)
	sizeof(func()) //函数返回值的长度
	sizeof(func) //函数偏移地址长度? 我也不知道

## typedef
准确地说,sizeof表达式的值是size_t类型的,这个类型定义在stddef.h头文件中,不过你的代 码中只要不出现size_t这个类型名就不用包含这个头文件.

size_t这个类型是整型中的某一种,编译器可能会用typedef做一个类型声 明:

	typedef unsigned long size_t;

定义类型关键字：

	typedef char str_arr[20];
	str_arr name; //Same as : char name[20]

# Side Effect与Sequence Point
上学或者面试时，我们可能会被问及以下表达式的输出:

	(i++) + (++i) - (i--)

其正确答案是Undefined。 这个表达式隐含多个Side Effect(即变量值发生变化)。C99 规定了，当到达一个Sequence Point时,在此之前的Side Effect必须全部作用完毕,在此之后的Side Effect必须一个都没发 生。
在到达下一个Sequence Point 过程中, side Effect 的顺序在C99 中是没有规定的。在不同的编译器或者平台下，会是不同的结果。

写表达式应遵循的原则一:在两个Sequence Point之间,同一个变量的值只允许被改变一次。以下是各种Sequence Point 解释。

## function sequence point 
foo(f(), g()); f()与g() 的顺序是不确定的。f(),g() 与 foo() 间有一个 Sequence Point 即函数调用前是一个Sequence Point

## Short Circuit
短路原则中，每个expr1 结束是一个 Sequence Point

	(expr1)? expr2: expr3;
	expr1 && expr2;
	expr1 || expr2;

## Statement 声明
一个完整的声明末尾是Sequence Point, 比如下面的a=++i 结束就是一个 Sequence Point
	
	int a=++i, b = --i;

## Exprssion 
在一个完整的表达式末尾是Sequence Point

	expr1, expr2;

## Function
函数返回时是Sequence Point

## IO
像printf、scanf这种带转换说明的输入/输出库函数,在处理完每一个转换说明相关的输入/输出操作时是一个Sequence Point。

# Reference
- [linux c] linux c 一站式编程 by 宋劲杉

[linuc c]: http://akaedu.github.io/book/
