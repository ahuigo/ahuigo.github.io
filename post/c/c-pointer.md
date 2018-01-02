---
layout: page
title:	c 语言之指针
category: blog
description: 
---
# Preface
关于指针有两种运算符：*号是指针间接寻址运算符（Indirection Operator），*pi表示取指针pi所指向的变量的值，也称为Dereference操作. &运算符的操作数必须是左值，因为只有左值才表示一个内存单元，才会有地址，指针有时称为变量的引用（Reference），所以根据指针找到变量称为Dereference。

千万要避免出现"野指针"（Unbound Pointer）: 

	int *p; *p=0

可以对指针给初值NULL.

	#define NULL ((void *)0)
	int *p=NULL;//NULL 是空指针 ，0 被转换为通用指针 void *

# 指针与const限定符
a是一个指向const int型的指针，a所指向的内存单元不可改写

	const int *a;
	int const *a;
	(*a)++; // 非法
	
a是一个指向int型的 const指针，*a是可以改写的，但a不允许改写：

	int * const a;

a是一个指向const int型的const指针，因此*a和a都不允许改写。

	const int * const a;

> 如果不想函数指针参数改变变量值，应该使用const 指针

# 指向数组的指针与多维数组
`[]`比`*` 优先级高，所以int *a[10], 中a 表示数组。 a++是不合法的。

	//int *a[10]
	typedef int *t;
	t a[10];

而int (*a)[10] 中a 表示指针，即指向数组的指针, a++是合法的。

	//int (*a)[10]
	typedef int t[10];
	t *a;

应用：

	int a[10];
	int (*pa)[10] = &a;//&a 与&a[0] 是不同的，&a 移动的是一个数组的a[10] 长度 sizeof(int [10]), 而&a[0] 指针移动的是一个int 的长度 sizeof(int)，而&a指针移动的是整个a[10]. 另外，&a[0]与a 是相同的

	//或者
	int a[5][10];
	int (*pa)[10] = &a[0];

# Function Pointer
与结构体不现，函数名本身func 或者 &func 都代表函数地址。
	
函数指针的定义也很简单，即将函数原型的函数名改成(*f) 就行了。

	void say_hello(const char *str) {
		printf("Hello %s\n", str);
	}
	int main(void) {
		void (*f)(const char *) = say_hello;// 写成&say_hello 也是一样的。这与数据a 只能表示&a[0] 可不一样。
		f = say_hello;
		f = &say_hello;//这样也是可以的
		f("Guys");	//自动取地址
		(*f)("Guys");
		return 0;
	}

首先定义函数类型F：

	typedef int F(void);

这种类型的函数不带参数，返回值是int。那么可以这样声明f和g：

	F f, g;

函数e返回一个F *类型的函数指针: 

	F *e(void);
	F *((e))(void); //如果给e多套几层括号仍然表示同样的意思：

fp 就是一个F * 类型的指针:

	int (*fp)(void);
	F *fp;

复杂的声明:

	typedef void (*sighandler_t)(int);
	sighandler_t signal(int signum, sighandler_t handler);

这个声明来自signal(2)。sighandler_t是一个函数指针，它所指向的函数带一个参数，返回值为void，signal是一个函数，它带两个参数，一个int参数，一个sighandler_t参数，返回值也是sighandler_t参数。如果把这两行合成一行写，就是：

	void (*signal(int signum, void (*handler)(int)))(int);

# Struct Pointer

	typedef struct s *t;
	struct s{
		int i;
	};
	struct s v={2};
	t pv=&v;//v 代表结构体本身，而&v 代表结构体地址
	printf("%d %d %d\n", v.i, pv->i, (*pv).i);//“.” 是结构体运算符，而"->"是指针运算符，"*pv" 得到的是结构体本身
