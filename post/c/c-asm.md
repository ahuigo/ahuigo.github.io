---
layout: page
title:	c 与 汇编
category: blog
description: 
---
# Preface

本文是 https://akaedu.github.io/book/ch19s01.html 相关的笔记

# 函数调用

	int bar(int c, int d) {
		int e = c + d;
		return e;
	}

	int foo(int a, int b) {
		return bar(a, b);
	}

	int main(void) {
		foo(2, 3);
		return 0;
	}

以上源码很简单。

	$ gcc main.c -g
	$ objdump -dS a.out
	...
	08048394 <bar>:
	int bar(int c, int d)
	{
	 8048394:	55                   	push   %ebp
	 8048395:	89 e5                	mov    %esp,%ebp
	 8048397:	83 ec 10             	sub    $0x10,%esp
		int e = c + d;
	 804839a:	8b 55 0c             	mov    0xc(%ebp),%edx
	 804839d:	8b 45 08             	mov    0x8(%ebp),%eax
	 80483a0:	01 d0                	add    %edx,%eax
	 80483a2:	89 45 fc             	mov    %eax,-0x4(%ebp)
		return e;
	 80483a5:	8b 45 fc             	mov    -0x4(%ebp),%eax
	}
	 80483a8:	c9                   	leave  
	 80483a9:	c3                   	ret    

	080483aa <foo>:

	int foo(int a, int b)
	{
	 80483aa:	55                   	push   %ebp
	 80483ab:	89 e5                	mov    %esp,%ebp
	 80483ad:	83 ec 08             	sub    $0x8,%esp
		return bar(a, b);
	 80483b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	 80483b3:	89 44 24 04          	mov    %eax,0x4(%esp)
	 80483b7:	8b 45 08             	mov    0x8(%ebp),%eax
	 80483ba:	89 04 24             	mov    %eax,(%esp)
	 80483bd:	e8 d2 ff ff ff       	call   8048394 <bar>
	}
	 80483c2:	c9                   	leave  
	 80483c3:	c3                   	ret    

	080483c4 <main>:

	int main(void)
	{
	 80483c4:	8d 4c 24 04          	lea    0x4(%esp),%ecx
	 80483c8:	83 e4 f0             	and    $0xfffffff0,%esp
	 80483cb:	ff 71 fc             	pushl  -0x4(%ecx)
	 80483ce:	55                   	push   %ebp
	 80483cf:	89 e5                	mov    %esp,%ebp
	 80483d1:	51                   	push   %ecx
	 80483d2:	83 ec 08             	sub    $0x8,%esp
		foo(2, 3);
	 80483d5:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
	 80483dc:	00 
	 80483dd:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
	 80483e4:	e8 c1 ff ff ff       	call   80483aa <foo>
		return 0;
	 80483e9:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	 80483ee:	83 c4 08             	add    $0x8,%esp
	 80483f1:	59                   	pop    %ecx
	 80483f2:	5d                   	pop    %ebp
	 80483f3:	8d 61 fc             	lea    -0x4(%ecx),%esp
	 80483f6:	c3                   	ret   
	...

`$ gobjdump -dS a.out` 输出源码与汇编对照

	(gdb) start
	...
	main () at main.c:14
	14		foo(2, 3);
	(gdb) s
	foo (a=2, b=3) at main.c:9
	9		return bar(a, b);
	(gdb) s
	bar (c=2, d=3) at main.c:3
	3		int e = c + d;
	(gdb) disassemble 
	Dump of assembler code for function bar:
	0x08048394 <bar+0>:	push   %ebp
	0x08048395 <bar+1>:	mov    %esp,%ebp
	0x08048397 <bar+3>:	sub    $0x10,%esp
	0x0804839a <bar+6>:	mov    0xc(%ebp),%edx
	0x0804839d <bar+9>:	mov    0x8(%ebp),%eax
	0x080483a0 <bar+12>:	add    %edx,%eax
	0x080483a2 <bar+14>:	mov    %eax,-0x4(%ebp)
	0x080483a5 <bar+17>:	mov    -0x4(%ebp),%eax
	0x080483a8 <bar+20>:	leave  
	0x080483a9 <bar+21>:	ret    
	End of assembler dump.
	(gdb) si
	0x0804839d	3		int e = c + d;
	(gdb) si
	0x080483a0	3		int e = c + d;
	(gdb) si
	0x080483a2	3		int e = c + d;
	(gdb) si
	4		return e;
	(gdb) si
	5	}
	(gdb) bt
	#0  bar (c=2, d=3) at main.c:5
	#1  0x080483c2 in foo (a=2, b=3) at main.c:9
	#2  0x080483e9 in main () at main.c:14
	(gdb) info registers 
	eax            0x5	5
	ecx            0xbff1c440	-1074674624
	edx            0x3	3
	ebx            0xb7fe6ff4	-1208061964
	esp            0xbff1c3f4	0xbff1c3f4
	ebp            0xbff1c404	0xbff1c404
	esi            0x8048410	134513680
	edi            0x80482e0	134513376
	eip            0x80483a8	0x80483a8 <bar+20>
	eflags         0x200206	[ PF IF ID ]
	cs             0x73	115
	ss             0x7b	123
	ds             0x7b	123
	es             0x7b	123
	fs             0x0	0
	gs             0x33	51
	(gdb) x/20 $esp
	0xbff1c3f4:	0x00000000	0xbff1c6f7	0xb7efbdae	0x00000005
	0xbff1c404:	0xbff1c414	0x080483c2	0x00000002	0x00000003
	0xbff1c414:	0xbff1c428	0x080483e9	0x00000002	0x00000003
	0xbff1c424:	0xbff1c440	0xbff1c498	0xb7ea3685	0x08048410
	0xbff1c434:	0x080482e0	0xbff1c498	0xb7ea3685	0x00000001

除了用`objdump`, 我们还可以用gdb 的`disassemble` 反汇编，它后面跟函数名，则反汇编函数. 默认是反汇编当前的函数. 我们用以了：

1. si命令可以一条指令一条指令地单步调试。
2. info registers可以显示所有寄存器的当前值。
3. gdb中表示寄存器名时前面要加个$，例如p $esp可以打印esp寄存器的值，
4. 在例子中esp寄存器的值是0xbff1c3f4，所以x/20 $esp命令查看内存中从0xbff1c3f4地址开始的20个32位数。

在x86平台上这个栈是从高地址向低地址增长的，我们知道每次调用一个函数都要分配一个栈帧来保存参数和局部变量，现在我们详细分析这些数据在栈空间的布局，根据gdb的输出结果图示如下：

![](/img/linux-c-asm.func-frame.png)

分析下bar:

	ebp: 进入frame 时，本身交给栈保存(push %esp)
	ebp: 保存上一frame 的esp(mov %esp, %ebp)
	esp: 指向本frome (sub 0x10, %esp)
