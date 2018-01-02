---
layout: page
title:	c语言函数接口
category: blog
description: 
---
# Preface

# 可变参数
printf 带有一个可变参数，可变参数是通过`va_` 实现定位并获取参数的，`va_` 定义于`stdarg.h`

	#include <stdio.h>
	#include <stdarg.h>

	void myprintf(const char *format, ...) {
		 va_list ap;
		 char c;

		 va_start(ap, format);
		 while (c = *format++) {
		  switch(c) {
		  case 'c': {
			   /* char is promoted to int when passed through '...' */
			   char ch = va_arg(ap, int);
			   putchar(ch);
			   break;
		  }
		  case 's': {
			   char *p = va_arg(ap, char *);
			   fputs(p, stdout);
			   break;
		  }
		  default:
			   putchar(c);
		  }
		 }
		 va_end(ap);
	}

	int main(void) {
		 myprintf("c\ts\n", '1', "hello");
		 return 0;
	}

传入参数位于调用者(caller)所在的栈：

	 myprintf("c\ts\n", '1', "hello");
	 80484c5:	c7 44 24 08 b0 85 04 	movl   $0x80485b0,0x8(%esp) //pointer to "hello"
	 80484cc:	08 
	 80484cd:	c7 44 24 04 31 00 00 	movl   $0x31,0x4(%esp) //'1'
	 80484d4:	00 
	 80484d5:	c7 04 24 b6 85 04 08 	movl   $0x80485b6,(%esp) //pointer to "c\ts\n"
	 80484dc:	e8 43 ff ff ff       	call   8048424 <myprintf>

参数布局图：

![](/img/c-func-inf-stdarg.png)

c 语言的参数是从右往左依次压栈的，所以第一个参数位于栈顶，最后一个参数位于栈底。
对于32位系统来说，每个参数会占用栈内4 个字节的空间(对齐4字节边界)，这是因为：方便寻址; 所有的参数压栈时都会占用4字节(字符串可能超过4字节，只能压指针)

如何确定$0x80485b0 是一个pointer 而不是一个数值/字符呢？

- 通过format 中的"c" 确定用数值 :`va_arg(ap, int)`
- 通过format 中的"s" 确定用pointer :`va_arg(ap, char *)`

stdarg.h的简单实现,这个实现出自[Standard C Library]，(在llvm 中已经将`va_` 集成了)

	#ifndef _STDARG
	#define _STDARG

	/* type definitions */
	typedef char *va_list;
	/* macros */
	# ap 用于移动指针到下一个参数，var_arg 用于返回当前ap 批向的参数的值
	# 如果是int 那么 op += _Bnd(int, 3U)  即 op += 4, op 就指向int 元素后的单元
	# 如果是char 那么 op += _Bnd(char, 3U)  即 op += 4, op 就指char 元素后面的单元
	#define va_arg(ap, T) \
		(* (T *)(((ap) += _Bnd(T, 3U)) - _Bnd(T, 3U)))
	#define va_end(ap) (void)0

	# 初始:让ap 移动到下一个参数, 即format 后的第一个参数, 这需要移动一个指针sizeof(char *) 长度， 这对于32位系统来说, 所有的指针sizeof(anytype *)都是4字节
	#define va_start(ap, A) \
		(void)((ap) = (char *)&(A) + _Bnd(A, 3U))

	// (tips: 优先级从高到低的顺序 !~ , */ 高于 +- 高于 &|)
	#define _Bnd(X, bnd) (sizeof (X) + (bnd) & ~(bnd))

	#endif

_Bnd 用于将变量X的长度对齐到bnd+1字节的整数倍, 即bnd+1 对齐。
比如4 字节对齐, 8 bytes 刚好对齐，则 8+3&~3 还是为 8
比如4 字节对齐, 11 bytes 未对齐，则 11+3&~3 就对齐为 12

# Reference
- [如何实现malloc]
- [linux c] linux c 一站式编程 by 宋劲杉

[linuc c]: http://akaedu.github.io/book/ch24.html
[如何实现malloc]: http://blog.codinglabs.org/articles/a-malloc-tutorial.html
