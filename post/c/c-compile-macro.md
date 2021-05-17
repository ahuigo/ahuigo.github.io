---
layout: page
title:	linux c 之 编译
category: blog
description:
---
# Macro

The C preprocessor implements the macro language used to transform C, C++, and Objective-C programs before they are compiled. It can also be useful on its own.

gcc 可通过指定 -E 得到预处理结果

	gcc -E a.c

demo: c-lib/compile/c-macro.c



## Object-like Macro

	#define N 50
	#undefine N
	#define N 5

### cc macro
通过编译参数定义宏

    # 相当于 #define POSIX_C_SOURCE=200809L
    cc -D_POSIX_C_SOURCE=200809L a.c

## Function-like Macro
	#define MAX(a,b) (a)>(b)?(a):(b)

macro
1. Func-like 宏比纯函数编译出的文件要大。 因为宏定义的MAX 函数会被预处理为 (a)>(b)?(a):(b), 而真正的函数只需要传参数 和 call 语句。
2. Func-like 宏没有参数类型, 不作参数检查
3. Func-like 宏要避免 Side Effect(即参数的值变化). 比如 MAX(++a, ++b), 对于a/b 来说会有多次side Effect
4. Func-like 宏要避名直接就将 *函数 或 表达式*作为参数。因为没有形参保存*函数或表达式*的结果，参数本身有会重复运算问题。

e.g.

	/**
	 * 求数组最大值。
	 * 如果MAX是正常的函数，max 时间复杂度是O(n)
	 * Func-like MAX是不是函数，max 在最好的情况下，时间复杂度是O(n)， 最坏的情况下时间复杂度是O(2^n)
	 */
	int max(int n)
	{
		return n == 0 ? a[0] : MAX(a[n], max(n-1)); // 0? a[0] : (a[n] > max(n-1)) ? (a[n]) : max(n-1);
	}

Func-like 宏如果包含多条语句怎么办？转义换行符:

	#define DEVICE_INIT(k,v) \
	{	device_init1(k,v);\
		device_init2(k,v);\
	}

	if(n > 0)
		DEVICE_INIT(k,v);
	else
		return 1;

因为 DEVICE_INIT(k,v); 后面有分号，宏展开后有语法错误(; 表示一条空语句)。do-while(0) 可以很好的解决这个问题(while(0)会被编译器优化掉，不用担心这会增加执行文件长度)

	#define DEVICE_INIT(k,v) \
	do{	device_init1(k,v);\
		device_init2(k,v);\
	}while(0)

	if(n > 0)
		DEVICE_INIT(k,v);
	else
		return 1;

## Inline Function 内联函数
函数调用有调用开销，为了节省这一开销，C99支持了 内联函数inline 关键字，它是告诉编译器在编译时，将函数像MAX 宏那样展开。

	static inline int MAX(int a, int b){
		return a>b ? a:b;
	}

## #、##运算符和可变参数
`#` 运算符用于创建字符串，#运算符后面应该跟一个形参, 用来标识要转换为字符串的参数

Example: 替换为字符串："hello world", 注意多个空白会被替换成一个

	#define STR(s) # s
	STR(hello 	world)

Example: 替换为字符串：`fputs("strncmp(\"ab\\\"c\\0d\", \"abc\", '\\4\"') == 0" ": @\n", s);` , 换行符被省略了

	#define STR(s) #s
	fputs(STR(strncmp("ab\"c\0d", "abc", '\4"')
		== 0) STR(: @\n), s);

`##` 运算符把前后两个预处理Token连接成一个预处理Token，和#运算符不同，##运算符不仅限于函数式宏定义，变量式宏定义也可以用
比如，将con 与 cat 合并, 得到`concat`

	#define CONCAT(a, b) a##b
	CONCAT(con, cat)

Example: 定义一个宏展开成两个`#`, 不可写成`####`, 它会被切割成两个`##` token, 会产生错误

	#define HASH_HASH # ## #

得到`123`:

	#define FOO(a, b, c) a##b##c
	FOO(1,2,3)
	FOO(,2,3) //得到23


`...` 也可用于宏函数的可变参数， 可变参数的形参用__VA_ARGS表示

	#define showStr(...) showlist(#__VA_ARGS__)
	#define showArgs(...) printf(__VA_ARGS__)
	#define report(test, ...) ((test)?printf(#test):\
		printf(__VA_ARGS__))

	showStr(The first, second, and third items.);
	showArgs(The first, second, and third items.);
	report(x>y, "x is %d but y is %d", x, y);

	#define DEBUGP(format, ...) printk(format, ## __VA_ARGS__)
	DEBUGP("a"); //当__VA_ARGS 为空时，## 做字符串拼接时会吃掉前面的逗号","，不会得到: printk("a",). 这种用法只针对##__VA_ARGS, 这只是预编译器特别处理的, 不要太纠结了

	#define funcx(a, ...) a, ## __VA_ARGS__
	funcx("a"); //当__VA_ARGS 为空时，## 做字符串拼接时会吃掉前面的逗号","，不会得到: `"a"`, 这种用法只针对##__VA_ARGS
	funcx("a",1,2); //"a",1,2
	funcx(,,3,4); //,,3,4 这会导致错误


处理结果：

	showlist(The first, second, and third items.);
	printf("The first, second, and third items.");
	printf(The first, second, and third items.);

	((x>y)?printf("x>y"): printf("x is %d but y is %d", x, y));
	"a"
	"a"
	"a",1,2

## Condition Preprocessor
条件语句可以嵌套使用

### ifndef

	#ifndef DEF
	#define DEF
	extern void push(char);
	#endif

这种保护头文件的用法称为Header Guard: 防止定义 声明 其它代码 被定义多次

### if

	#if MAX == 2
	#elseif
	#endif

不一定要事先定义#define MAX 2. 也可以直接用 `gcc -E b.c -DMAX=2`

### defined

	#defined z 0
	#if defined x || !defined y || z && VER < 3
	#if 0 || 1 || 0 && 0 < 3

## Inner Macro

	__FILE__
	__LINE__

> c99 引入了一个变量名: __func__ 而不是宏，`printf("%s\n", __func__);`
