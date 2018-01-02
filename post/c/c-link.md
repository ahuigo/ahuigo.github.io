---
layout: page
title:	linux c link 详解
category: blog
description: 
---
# Preface

# Multi Relocatable File
以倒序打印为例子


	/* stack.c */
	char stack[512];
	int top = -1;

	void push(char c) {
		stack[++top] = c;
	}

	char pop(void) {
		return stack[top--];
	}

	int is_empty(void) {
		return top == -1;
	}

	/* main.c */
	#include <stdio.h>

	int a, b = 1;
	int main(void) {
		push('a');
		push('b');
		push('c');
		
		while(!is_empty())
			putchar(pop());
		putchar('\n');

		return 0;
	}

可以一步编译:

	gcc -o main.c stack.c

也可以多步编译:

	gcc -c main.c stack.c
	gcc -o main main.o stack.o

## nm 查看符号表

	test > nm main.o
	0000000000000004 C a
	0000000000000000 D b
					 U is_empty
	0000000000000000 T main
					 U pop
					 U push
					 U putchar
	test > nm stack.o
	000000000000004d T is_empty
	000000000000002c T pop
	0000000000000000 T push
	0000000000000200 C stack
	0000000000000000 D top

可以看到，在main.o 中 pop/push/putchar 等都是未定义的, a 是C(全局未初始化) b是D(全局已经初始化), T 是已定义的函数名
可以看到，在stack.o 中 is_empty/pop/push 是定义的，stack 是C(全局未初始化)

	test > nm main
	...
	0000000000400668 T _fini
	0000000000400390 T _init
	00000000004003e0 T _start
	00000000006009b0 B a
	0000000000600994 D b
	0000000000400575 T is_empty
	00000000004004c4 T main
	0000000000400554 T pop
	0000000000400528 T push
					 U putchar@@GLIBC_2.2.5
	00000000006009c0 B stack
	0000000000600998 D top

在可执行文件中，putchar 仍然是未定义的，因为它需要被动态链接


	Section Headers:
	  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
	  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
	  [ 5] .dynsym           DYNSYM          0000000000400280 000280 000060 18   A  6   1  8
	  [ 6] .dynstr           STRTAB          00000000004002e0 0002e0 000040 00   A  0   0  1
	  [ 9] .rela.dyn         RELA            0000000000400348 000348 000018 18   A  5   0  8
	  [10] .rela.plt         RELA            0000000000400360 000360 000030 18   A  5  12  8
	  [12] .plt              PROGBITS        00000000004003a8 0003a8 000030 10  AX  0   0  4
	  [13] .text             PROGBITS        00000000004003e0 0003e0 000288 00  AX  0   0 16
	  [15] .rodata           PROGBITS        0000000000400678 000678 000010 00   A  0   0  8
	  [24] .data             PROGBITS        0000000000600990 000990 00000c 00  WA  0   0  4
	  [25] .bss              NOBITS          00000000006009a0 00099c 000220 00  WA  0   0 32
	  [27] .shstrtab         STRTAB          0000000000000000 0009c9 0000fe 00      0   0  1
	  [28] .symtab           SYMTAB          0000000000000000 001248 0006c0 18     29  47  8
	  [29] .strtab           STRTAB          0000000000000000 001908 00021b 00      0   0  1

	 Num:    Value          Size Type    Bind   Vis      Ndx Name
	 ....
    41: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS main.c
    42: 0000000000000000     0 FILE    LOCAL  DEFAULT  ABS stack.c
    47: 0000000000600990     0 NOTYPE  WEAK   DEFAULT   24 data_start
    49: 00000000004003e0     0 FUNC    GLOBAL DEFAULT   13 _start
    53: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND putchar@@GLIBC_2.2.5
    54: 0000000000000000     0 FUNC    GLOBAL DEFAULT  UND __libc_start_main@@GLIBC_2.2.5
    55: 0000000000400554    33 FUNC    GLOBAL DEFAULT   13 pop
    56: 0000000000600998     4 OBJECT  GLOBAL DEFAULT   24 top
    58: 0000000000600990     0 NOTYPE  GLOBAL DEFAULT   24 __data_start
    59: 00000000006009b0     4 OBJECT  GLOBAL DEFAULT   25 a
    60: 0000000000400528    44 FUNC    GLOBAL DEFAULT   13 push
    64: 0000000000400575    21 FUNC    GLOBAL DEFAULT   13 is_empty
    65: 000000000060099c     0 NOTYPE  GLOBAL DEFAULT  ABS __bss_start
    66: 0000000000600994     4 OBJECT  GLOBAL DEFAULT   24 b
    68: 00000000006009c0   512 OBJECT  GLOBAL DEFAULT   25 stack
    70: 00000000004004c4    99 FUNC    GLOBAL DEFAULT   13 main

通过`readelf -aW main` 可以看到
.text(13) 合并了两者的.text 段：main 的main(_start), stack 的push/pop/is_empty
.data(24) 合并了全局已经初始化的变量: main 的b, stack 的top
.bss(25) 合并了全局未初始化的变量: main 的a, stack 的stack

![](/img/linux-c-link-merge-section.png)

如果这样写的话，main 中的每个段来自的stack 变量就会在前面：

	$ gcc stack.o main.o -o main
	
链接的过程由链接脚本(Linker Script)决定的：每个段分配什么地址，怎么对齐，哪些段在前，哪些合并到一个segment, 以及插入一些符号到最终的文件(_start, __bss_start, _edata, _end)

## ld 链接细节
可以通过`ld -T <linker>`  指定新的链接脚本，或者通过`ld --version` 查看默认的链接脚本：

	ld --verbose
	GNU ld version 2.20.51.0.2-5.42.el6 20100205
	  Supported emulations:
	   elf_x86_64
	   elf_i386
	   i386linux
	   elf_l1om
	using internal linker script:
	==================================================
	/* Script for -z combreloc: combine and sort reloc sections */
	OUTPUT_FORMAT("elf64-x86-64", "elf64-x86-64",
			  "elf64-x86-64")
	OUTPUT_ARCH(i386:x86-64)
	ENTRY(_start)
	SEARCH_DIR("/usr/x86_64-redhat-linux/lib64"); SEARCH_DIR("/usr/local/lib64"); SEARCH_DIR("/lib64"); SEARCH_DIR("/usr/lib64"); SEARCH_DIR("/usr/x86_64-redhat-linux/lib"); SEARCH_DIR("/usr/lib64"); SEARCH_DIR("/usr/local/lib"); SEARCH_DIR("/lib"); SEARCH_DIR("/usr/lib");
	SECTIONS
	{
	  /* Read-only sections, merged into text segment: */
	  PROVIDE (__executable_start = SEGMENT_START("text-segment", 0x400000)); . = SEGMENT_START("text-segment", 0x400000) + SIZEOF_HEADERS;
	  .interp         : { *(.interp) }
	  .note.gnu.build-id : { *(.note.gnu.build-id) }
	  .hash           : { *(.hash) }
	  .dynsym         : { *(.dynsym) }
	  .dynstr         : { *(.dynstr) }
	  ....
	  .rela.dyn       :
		{
		  *(.rela.init)
		  *(.rela.text .rela.text.* .rela.gnu.linkonce.t.*)
		  *(.rela.fini)
		  *(.rela.rodata .rela.rodata.* .rela.gnu.linkonce.r.*)
		  *(.rela.data .rela.data.* .rela.gnu.linkonce.d.*)
		  *(.rela.tdata .rela.tdata.* .rela.gnu.linkonce.td.*)
		  *(.rela.tbss .rela.tbss.* .rela.gnu.linkonce.tb.*)
		  *(.rela.ctors)
		  *(.rela.dtors)
		  *(.rela.got)
		  *(.rela.sharable_data .rela.sharable_data.* .rela.gnu.linkonce.shrd.*)
		  *(.rela.sharable_bss .rela.sharable_bss.* .rela.gnu.linkonce.shrb.*)
		  *(.rela.bss .rela.bss.* .rela.gnu.linkonce.b.*)
		  *(.rela.ldata .rela.ldata.* .rela.gnu.linkonce.l.*)
		  *(.rela.lbss .rela.lbss.* .rela.gnu.linkonce.lb.*)
		  *(.rela.lrodata .rela.lrodata.* .rela.gnu.linkonce.lr.*)
		  *(.rela.ifunc)
		}
	  .init           :
	  {
		KEEP (*(.init))
	  } =0x90909090
	  .plt            : { *(.plt) *(.iplt) }
	  .text           :
	  {
		*(.text.unlikely .text.*_unlikely)
		*(.text .stub .text.* .gnu.linkonce.t.*)
		/* .gnu.warning sections are handled specially by elf32.em.  */
		*(.gnu.warning)
	  } =0x90909090


	  .rodata         : { *(.rodata .rodata.* .gnu.linkonce.r.*) }
	  /* Adjust the address for the data segment.  We want to adjust up to
		 the same address within the page on the next page up.  */
	  . = ALIGN (CONSTANT (MAXPAGESIZE)) - ((CONSTANT (MAXPAGESIZE) - .) & (CONSTANT (MAXPAGESIZE) - 1)); . = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));
	  ...
	  .data           :
	  {
		*(.data .data.* .gnu.linkonce.d.*)
		SORT(CONSTRUCTORS)
	  }
	  _edata = .; PROVIDE (edata = .);
	  __bss_start = .;
	  .bss            :
	  {
	   *(.dynbss)
	   *(.bss .bss.* .gnu.linkonce.b.*)
	   *(COMMON)
	   . = ALIGN(. != 0 ? 64 / 8 : 1);
	  }
	}

ENTRY(_start) 确定入口点, 可以通过`-e 指定入口点`

每个段的描述格式是：

	段名 : { 组成 }
	.plt : { *(.plt) *(.iplt) }
		左边是生成执行文件的.plt 段，右边表示所有目标文件的.plt .iplt 段

PROVIDE (__executable_start = SEGMENT_START("text-segment", 0x400000)); . = SEGMENT_START("text-segment", 0x400000) + SIZEOF_HEADERS;
是text segment 的起点, 这个segment 包括.plt, .text, .rodata.


以下是Data Segment 的起始地址，要做一系列的对齐，此segment 包括后面的.got, .data, .bss

	. = ALIGN (CONSTANT (MAXPAGESIZE)) - ((CONSTANT (MAXPAGESIZE) - .) & (CONSTANT (MAXPAGESIZE) - 1)); . = DATA_SEGMENT_ALIGN (CONSTANT (MAXPAGESIZE), CONSTANT (COMMONPAGESIZE));

> 关于对齐，还有另外一种实现方式，可以参考 [](/p/c-func-inf) 中的`_Bnd`, `p + bnd & ~bnd`

# 定义和声明
定义的变量会分配内存，而声明则是告诉编译器它是一个什么类型的符号. 
如果编译器不知道这是什么符号，否则compiler 会报`warning`

	$ gcc -c main.c -Wall
	main.c: In function ‘main’:
	main.c:8: warning: implicit declaration of function ‘push’

所以要对用到的符号事先声明：

	/* main.c */
	#include <stdio.h>

	extern void push(char);
	extern char pop(void);
	extern int is_empty(void);

	int main(void) {
		push('a');
		push('b');
		push('c');
		
		while(!is_empty())
			putchar(pop());
		putchar('\n');

		return 0;
	}

External 修饰的关键字是声明一个外部变量/函数(它不是定义), 表示关键字具有External Linkage -- 这些External 声明关键字会指向同一地址

	函数声明中的external 可以省略(函数声明和函数定义形式本来就不一样)



# xxx
参考[linux c20], 以下例子：

	#include <stdio.h>
	const int A = 10;
	int a = 20;
	static int b = 30;
	int c;

	int main(void) {
		static int a = 40;
		char b[] = "Hello world";
		register int c = 50;

		printf("Hello world %d\n", c);

		return 0;
	}

编译连接后生成a.out, 用`readelf -a` 查看符号表:

	$ gcc -g a.c
	$ readelf -a a.out
	...
		68: 08048540     4 OBJECT  GLOBAL DEFAULT   15 A
		69: 0804a018     4 OBJECT  GLOBAL DEFAULT   23 a
		52: 0804a01c     4 OBJECT  LOCAL  DEFAULT   23 b
		53: 0804a020     4 OBJECT  LOCAL  DEFAULT   23 a.1589
		81: 0804a02c     4 OBJECT  GLOBAL DEFAULT   24 c
	...

	Section Headers:
	  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
	...
	  [13] .text             PROGBITS        08048360 000360 0001bc 00  AX  0   0 16
	...
	  [15] .rodata           PROGBITS        08048538 000538 00001c 00   A  0   0  4
	...
	  [23] .data             PROGBITS        0804a010 001010 000014 00  WA  0   0  4
	  [24] .bss              NOBITS          0804a024 001024 00000c 00  WA  0   0  4
	...

# 变量存储布局

## Scope 作用域
本文内容包括变量/函数的作用域(scope), 变量的初始化(initialize), 链接时符号的查找范围(Linkage) 参考[linux c]

常量
	const int i = 1; //位于.rodata (只读数据段)，通常它和.text(代码段) 合并到一个Segment中，操作系统将这个Segment的页面只读保护起来

|变量位置 		| 作用域scope	| 存储位置				| 初始化				| 标识符的链接属性（Linkage）|
|var_in_file 	| 所有文件		| .data/.bss(未初始化)	| 0/Static Initializer | 外部链接（External Linkage）|
|static_in_file | 当前文件		| .bss					| 0/Static Initializer| 内部链接（Internal Linkage）|
|var_in_block 	| block			| stack					| undefined/Dynamic Initializer | 无链接（No Linkage）|
|static_in_block | block		| .data/.bss(未初始化)	| 0/Static Initializer| 内部链接（Internal Linkage）|
|register_in_block | block		| rigister(如果寄存器足够)| undefined/Dynamic Initializer| 无链接（No Linkage）|

> .bss在加载时与.data合并到一个Segment中, .bss 不占用可执行文件的空间(因为它没有初值)，仅在加载程序时开辟内容并初始化为0(编译期未初始化的全局变量)
关于段位置请参考[](/p/linux-c-compile) 之link

初始化有Static Initializer和Dynamic Initializer两种情况:

- 前者表示Initializer中只能 使用常量表达式,表达式的值必须在编译时就能确定, 未初始化时，在执行程序时会分配内存并初始化为0
- 后者表示Initializer 中可以使用任意的右 值表达式,表达式的值可以在运行时计算

Refer to: http://akaedu.github.io/book/ch20s02.html#id2787367

## 链接标识符 Linkage

标识符的链接属性（Linkage）有三种：

### 外部链接（External Linkage）
如果最终的可执行文件由多个程序文件链接而成，一个标识符在任意程序文件中即使声明多次也都代表同一个变量或函数，则这个标识符具有External Linkage。具有External Linkage的标识符编译后在符号表中是GLOBAL的符号。例如上例中main函数外面的a和c，main和printf也算。

### 内部链接（Internal Linkage）
如果一个标识符在某个程序文件中即使声明多次也都代表同一个变量或函数，则这个标识符具有Internal Linkage，它的scope 局限在file 或者 block.
如果有另一个foo.c程序和main.c链接在一起，在foo.c中也声明一个static int b;，则那个b和这个b不代表同一个变量。

> 具有Internal Linkage的标识符编译后在符号表中是LOCAL的符号，但main函数里面那个a不能算Internal Linkage的，因为即使在同一个程序文件中，在不同的函数中声明多次，也不代表同一个变量。

### 无链接（No Linkage）。
除以上情况之外的标识符都属于No Linkage的，例如函数的局部变量，以及不表示变量和函数的其它标识符. 不同函数内的同名变量是占用不同的内存空间

## Storage Class Specifier 存储类修饰符
 auto(Exteral|None), static(Internal Storage), register(None Storage), extern(External Storage), volatile(限定编译器优化)

对于变量来说，auto 是默认的，

	auto int i;
	int i;

对于函数来说，extern 是默认的。

	//以下是等价的
	external int func(int a);
	int func(int a);

extern 意为“外来的”···它的作用在于告诉编译器：有这个变量，它可能不存在当前的文件中，但它肯定要存在于工程中的某一个源文件中或者一个Dll的输出中。否则编译器就会认为该变量是新定义的，要分配内存空间的。 

volatile 确保本条指令不会因编译器的优化而省略，且要求每次直接读值

	volatile int i;
	i = 1; //防止编译器将这条给省略掉(一般用于串并口寄存器: 不同时间序的不同值是有意义的，而不是只保留最后的值)
	i = 2;


## Storage Duration (Lifetime) 变量的生存期

静态生存期（Static Storage uration），具有外部或内部链接属性，或者被static修饰的变量，在程序开始执行时分配和初始化一次，此后便一直存在直到程序结束。这种变量通常位于.rodata，.data或.bss段


自动生存期（Automatic Storage Duration），链接属性为无链接并且没有被static修饰的变量，这种变量在进入块作用域时在栈上或寄存器中分配，在退出块作用域时释放. 这些数据的长度是一定的, 通常是函数参数及局部变量,保存现场

动态分配生存期（Allocated Storage Duration），以后会讲到调用malloc函数在进程的堆空间中分配内存，调用free函数可以释放这种存储空间。这些数据的长度是任意指定的。


# Reference
- [linux c20]

[linux c20]: http://akaedu.github.io/book/ch20.html
