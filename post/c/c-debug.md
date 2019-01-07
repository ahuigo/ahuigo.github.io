---
layout: page
title:	c debug
category: blog
description:
---
# assert
断言, 如果定义了NODEBUG (或者直接在编译时加上选项-DNDEBUG), 则assert函数则不被编译

	#define NDEBUG
	assert(111)

# objdump & otool
objdump 是linux 下的工具，用于将源代码、文件名、与汇编码对应显示
otool/gobjdump 是mac 下类似的工具， 与objdump -SI 相近的命令是otool -tV

	gcc -g a.c
	" -dS 与 -SI 好像是一样的
	objdump -dS a.out
	gobjdump -dS a.out
	otool -tV a.out

objdump:

	-d, --disassemble        Display assembler contents of executable sections
	-D, --disassemble-all    Display assembler contents of all sections
	-S, --source             Intermix source code with disassembly

otool

	- otool -tV <executable>
	-t   Display the contents of the (__TEXT,__text) section.
		 With the -v flag, this disassembles the text.
		 And with -V, it also symbolically disassembles the operands.

	-d     Display the contents of the (__DATA,__data) section.

> 除了用`objdump`, 我们还可以用gdb 的`disassemble` 反汇编，它后面跟函数名，则反汇编函数. 默认是反汇编当前的函数. 我们用以了：

# strace
> 最新的strace 有一个-k 参数, 显示调用栈. Mac 下没有strace 但是有很好用的: sample
[/p/c-debug-strace](/p/c-debug-strace)

- strace 跟踪进程系统调用
- pstack 跟踪进程栈

# heap
Refer [c-debug-heap](/p/linux-c-debug-heap)
