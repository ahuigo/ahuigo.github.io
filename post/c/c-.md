---
layout: page
title:	linux c 简介
category: blog
description:
---
# Preface

# todo
linux c
http://blog.xiayf.cn/slides/tlpi-1/index.html#/2

# Variable

## Int

	signed int i;
	unsigned int i;
	srand(time(NULL));//初始化seed
	rand();//再取随机数

常量

	123;//signed
	-1;//signed
	123u;//u/U unsigned
	123l; //long
	123ll; //long long
	123ul; //unsigned long

## float

	1.0 // 默认double
	1.0f //float
	1.0l //long double

### Usual Arithmetic Conversion
当使用'+-*/%>!=' 时，转换顺序为：

	long double %lf > double %f > float %f > long long %lld > long %ld >int %d > short %d > char %c
	//There is no format for a float, because if you attempt to pass a float to printf, it'll be promoted to double before printf receives it.

传递参数时，实参也要转为形参的类型。

### 存储
64 位机器中，float 一般为32位, double 一般为64位。浮点数采用了IEEE 标准。在float 由以下位构成：

	Sign(1 bit) + exponential(8 bit + 127) + base number(23 bit)

对于数字3， 其二进制科学计数法为: 1.10000000 * 2^1. 那么其存储形式为(exponential 需要加127), base number 要去掉整数部分1, 留下.1000000:

	sign(0) + exponential(1000 0000) + base (100 0000 0000 0000 0000 0000)

你可能会奇怪，base number 隐含了1.xxxx * 2^ (exponential+127)，那如何表示0呢？0 不能写成1.xxxx的形式哟。其实，当一个数的绝对值小于 1.0^(-126)时，base number 不会隐含整数部分1. 这类数实际会被存储为 1.xxxx * 2^(-127 + 127). 23位中，最高位是整数部分1 或者0，剩余22 位是小数，指数恒为-127(实际存储为0)

0 的二进制科学计数法为: 0.00000000 * 2^(-127 + 127).

	sign(0) + exponential(0000 0000) + base (000 0000 0000 0000 0000 0000)

1.0*2^(-127) 的二进制科学计数法为: 1.0000000 * 2^(-127 + 127).

	sign(0) + exponential(0000 0000) + base (100 0000 0000 0000 0000 0000)

### 精度
对于 float 32 位而言：

	23 位base number，所能表示的精度为小数后6位( 1/2^23 = 1.19209e-7)
	8位的 exponential 指数能表示 2^-127 ~ 2^128 即 10^-38 ~ 10^38

对于 double 64 位而言：

	52 位base number，所能表示的精度为小数后15位( 2^-52 = 2.2204e-16)
	11位的 exponential 指数能表示 2^-2043 ~ 2^2048 即 10^-308 ~ 10^308

对于 扩展精度 而言：

	64 位base number，所能表示的精度为小数后19位( 2^-64 = 5.4210e-20)
	15位的 exponential 指数能表示 2^-2043 ~ 2^2048 即 10^-4932 ~ 10^4932

## char
char 变量在x86 平台的gcc 中被定义为有符号的， 这也是c 标准的Rationale (根本依据)之一: 优先考虑效率。

	char  c;
	signed char  c;
	unsigned char  c;

string 实际上是char 数组.

## 复合数据类型(Compound Type)
String, Array, Struct, Enum

## enum 枚举
	enum coordinate_type { RECTANGULAR, POLAR };//0,1
	enum coordinate_type { RECTANGULAR = 1, POLAR };//1,2

	enum coordinate_type t;

## Struct
	struct dot{double x, y; } z1, z2;
	struct dot z1={1.1,2.3}, z2={1, 5.5};//参数未给全，则初始化为0
	struct dot z3=z2;//不是指向同一内存
	struct dot z4;
	z4=z3;//不是指向同一内存存储！传参也是如此

### Bit Field
	typedef struct {
		unsigned int one:1;
		unsigned int two:3;
		unsigned int three:10;
		unsigned int four:5;
		unsigned int :2;
		unsigned int five:8;
		unsigned int six:8;
	} demo_type;
	demo_type.four //5位数据

Bit field 中的位的存储位置视编译器不同而不同，还受字节对齐的影响（有padding）

### offsetof
offsetof 是用于求偏移的，这个宏定义于`stddef.h`：

	#define offsetof(TYPE, MEMBER) ((int)&((TYPE *)0)->MEMBER)

求sockaddr_un 中sum_path 的偏移：

	offsetof(struct sockaddr_un, sun_path);

## Union

	typedef union {
		struct {
			unsigned int one:1;
			unsigned int two:3;
			unsigned int three:10;
			unsigned int four:5;
			unsigned int :2;
			unsigned int five:8;
			unsigned int six:8;
		} bitfield;
		unsigned char byte[8];
	} demo_type;

	demo_type.bitfield.four

### 嵌套
	struct Segment s = {{ 1.0, 2.0 }, { 4.0, 6.0 }}; //嵌套初始化

## Array
	int count[4] = {1,2,};//用0 做初始化
	int count[4] ;//用0 做初始化
	int count[] = {1,2}  ;
	struct {
		float x;
	} a[4] = {1.2, 1.3, 1,4, 1,5}

### Multi Dementional Array
	int a[3][2] = { 1, 2, 3, 4, 5 };
	int a[3][2] = { {1, 2}, {3, 4}, {5 }};
	int a[][2] = { 1, 2, 3, 4, 5 };

### String Array
	char str[10] = "Hello";
	char str[] = "Hello";//包含'\0' 有6个字符
	char str[2] = "Hello";//只有两个字符'He'，不包含'\0'
	char days[8][10] = { "Monday", "Tuesday", "Wednesday", "Thursday", "Saturday", "Sunday" };

### 传值
	arr1 = arr2 ;//不能像结构体那样相互传值
	//也就不能用数组类型作为函数的参数或返回值。
	int foo(int arr[5]){//对于数组类型有一条特殊规则: 数组名做右值使用时,自动转换成指向数组首元素的指针

	}

## String


## Scope
Local Variable: func-> Statement Block
> Notice: 局部变量的初始值是不可预料的(有时会是上一个函数的局部变量值)

# Operator
!高于*/%,高于+-,高于~,高于>、<、>=、<=,高 于==、!=,高于&&,高于||
前缀自增运算符(Prefix Increment Operator)
后缀自增运 算符(Postfix Increment Operator)

# Statement
过程抽象(Procedure Abstraction)

# strace
[linux-process-tool](/p/linux-process-tool)

跟踪进程的系统调用
linux: strace
mac: dtruss

	dtruss ./a.out

# format
indent 用于格式化c 代码

	indent -kr -i4 file

-kr选项表示K&R风格,-i8表示缩进8个空格的长度

# dic

	%: percent sign
	; : simicolon
	_ Underscore
	{} brace
	() Bracket
	^ caret
	& ampersand
	! Exclamation Mark
	Remainder 余数 Quotient 商
	Parity 奇偶性 even/odd Number
	Encapsulate 封装
	Initializer 初始值
	Scientific Notation 科学计数法
	Operator 操作符 运算符
	Operand 操作数
	Precedence 优先级
	Implicit Conversion 隐式转换
	Accumulator 累加器
	Scope 作用域
	Identifier 标识符(变量名，函数名，常量名)
	预处理指示 (Preprocessing Directive)
	Side Effect :副作用(Side Effect)--打印 改变计算机存储 单元里的数据或者做输入或输出操作,这些都算Side Effect
	"#号(Pound Sign,Number Sign或Hash Sign)
	尖括号(Angel Bracket)
	转换说明: Conversion Specification
	点位符: Placeholder
	分隔：Delimiter
	Complement: 补码
	关键字: Keyword (Reserved Word)
		auto break case char const continue default do double
		else enum extern float for goto if inline int long
		register restrict return short signed sizeof static struct switch typedef union unsigned void volatile while _Bool _Complex _Imaginary

	Implicit Conversion 隐匿转换
	Explicit Conversion 显式转换
	Type Cast 类型转换
	Link Editor 链接器

# Reference
[鸟哥的linux 私房菜]: http://linux.vbird.org/linux_basic/0520source_code_and_tarball.php
