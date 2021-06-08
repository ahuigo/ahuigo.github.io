---
layout: page
title:	linux c 之 编译
category: blog
description:
---
# Preface

本文总结关于c 编译的基础用法: 宏，头文件

# include 头文件
公共的东西(External 声明，定义)，可以放到头文件中：`*.h`, 可以被多次引用（其实跟`.c`没啥区别）

    #ifndef   _MY_H
    #define  _MY_H
    extern void my(void);
    #endif

角括号include ,gcc首先查找-I选项指定的目录,然后查找系统的头文件目录(通常 是/usr/include)

	#include <stdio.h>

双引号include ,gcc首先查找.c文件所在的目录,然后查找-I选项指定的 目录,然后查找系统的头文件目录

	#include "stdio.h"

	gcc -I~/headers/

> 1.如果需要查询一个函数的定义位置，比如strlen， 可以使用 man strlen, 可以发现函数头为`string.h`
> 2.下面的编译命令`gcc -E a.c` 会显示出实际的`.h` 文件路径

## list header dependcy

    gcc -M a.c
    gcc -MM a.c

# Macro

The C preprocessor implements the macro language used to transform C, C++, and Objective-C programs before they are compiled. It can also be useful on its own.

gcc 可通过指定 -E 得到预处理结果

	gcc -E a.c

## Object-like Macro

	#define N 50
	#undefine N
	#define N 5

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



# gcc
以 [linux c linker] 的倒序打印为例子：

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

## 编译目标档*.o

	gcc -c main.c stack.c # gcc main.c 直接得到main.out

	# 查看目标档的符号表
	nm main.o
	ll main.o stack.o

### Assemble

	# 编译为汇编码(assemble code)
	gcc -S a.c -o a.s

### gcc -E

	gcc -E a.c ;//查看所有编译源码(展开stdio.h 等)

### gcc -v
查看编译过程: 包括include lib

### gcc -l*加入外部函式库, -L指定动态库PATH

	cat > sin.c <<MM
	#include <stdio.h>
	int main(void) {
		printf("%f\n",sin(3.14/4));
	}
	MM
	# 直接编译的话,如果找不到相应的库，会提示undefined reference to sin。
	# -lm 加入libm.so这个函式库(不需要写lib 和.so)
	# -lc 加入libc.so这个函式库(不需要写lib 和.so), 这个是默认的，不需要指定
	gcc -lm sin.c

	# 通过-L 设定搜索函式库(.so,.a) 的路径
	gcc -lm sin.c -L/lib64 -L/usr/lib

	# 通过-I 指定搜索include header(*.h) 的路径，或者通过环境变量CPATH 设定
	gcc sin.c -I/usr/include

## 连接link目标文件

	gcc main.o stack.o -o main

用nm命令 查看目标文件 的符号表：
1. main.o中有未定义的符号push、pop、is_empty、putchar，前三个符号在stack.o中实现了，链接生成可执行文件main时可以做符号解析
2. 而putchar是libc的库函数，在可执行文件main中仍然是未定义的，要在程序运行时做动态链接。

	nm main.o
		T main //Text 表示代码
		U push
		U pop
		U is_empty
		U putchar
	nm stack.o
		T push
		T pop
		T is_empty

用readelf -a main 可以看到:
- main 的.bss 合并了main.o与stack.o 的.bss;
- main 的.data 合并了main.o 与stack.o 的.data;
- main 的.text 合并了main.o 与stack.o 的.text 代码段.

如下图：

![](/img/linux-c-link-segment.png)

典型的内存分配图(出自 APUE):

![](/img/linux-c-memory-arrangement.png)

这些是由链接脚本(Linker Script) 决定的: 哪些段要做合并，段合并时的地址分配，如何对齐，哪个段在前哪个段在后.
链接器还要插入一些符号到生成的文件中，比如：__bss_start,_edata,_end.
用ld 做链接时，可以用-T 指定链接脚本，可以用`ld --verbose` 查看默认链接脚本。可参考[](http://akaedu.github.io/book/ch20s01.html)

各段的含义：

	.bss段(Block Started by Symbol Segment): 静态内存分配的，未初始化的全局变量(int i)
	.data段(Data Segment): 静态内存分配的，已初始化的全局变量(int i=1)
	.rodata段(Data Segment): 只读常量(#const int MAX=80)
	.text段：代码段,只读
	stack: 局部变量、函数参数、调用现场保存与恢复, 运行时分配
	heap: 堆，malloc分配的, 运行时分配
	.plt: 动态链接代码, 运行时装载

.bss在加载时与.data合并到一个Segment中, .bss 不占用可执行文件的空间(因为它没有初值)，仅在加载程序时开辟内容并初始化为0(它只是编译期未初始化的全局变量)

### .plt 段 协助完成动态链接的过程
如果查看 在可执行文件main 的符号表，你会发现其中有个 __libc_start_main 也是未定义的, 这个符号是在libc中定义的，libc并不像其它目标文件一样链接到可执行文件main中，而是在运行时做动态链接：

1. 操作系统在加载执行main这个程序时，首先查看它有没有需要动态链接的未定义符号。
2. 如果需要做动态链接，就查看这个程序指定了哪些共享库（我们用-lc指定了libc）以及用什么动态链接器来做动态链接（我们用-dynamic-linker /lib/ld-linux.so.2指定了动态链接器）。
3. 动态链接器在共享库中查找这些符号的定义，完成链接过程。

### exit

	exit(main(argc, argv));

exit 是libc 库中的函数(/lib64/libc.so.6):
1. 首先做一些清理工作，
2. 然后调用 _exit系统调用终止进程，
3. main函数的返回值最终被传给_exit系统调用，成为进程的退出状态.

参考:
[](http://akaedu.github.io/book/ch19s02.html#asmc.main) ,
`man 3 exit`, `man 2 _exit`

## -O 优化

	# -O0表示没有优化,-O1为缺省值，-O3优化级别最高
	gcc -O2 -c main.c
	# Wall 显示警告(Warning all)
	gcc -Wall -c main.c


## nm 查看符号表
	#查看目录档
	nm a.o
	#查看执行档
	nm a.out

# 函式库
分类：函式库分为动态(.so)和静态(.a)两种

	静态库(.a):
		编译时，直接编译进目标文件
	动态库(.so):
		编译时，没有编译进目标文件，当需要是时直接呼叫动态库(也叫共享库)
		libc.so 动态函式库c : 这个是默认的, 不需要-lc, 它实现了stdio.h
		libm.so 动态函式库m : 可以在编译时用 -lm 指定, 它实现了math.h

linux 核心提供了大量核心相关的函式库与外部参数，这个函式库通常放置在/usr/include, /lib, /usr/lib

# Static Library 静态库

	> lib/push.c
	char stack[512];
	int top = -1;
	void push(int a){
		stack[++top] = a;
	}

	> cat lib/pop.c
	extern int stack[512];
	extern int top;
	int pop(){
		return stack[top--];
	}

	> cat lib/stack.h
	extern void push(int);
	extern int pop();

	> cat a.c
	#include "stack.h"
	int main()
	{
		push(1);
		return 0;
	}


编译：

	> gcc -c lib/*.c

生成静态库：

	> ar rs libstack.a push.o pop.o

ar r中的r类似于tar 打包, 即将后面的文件列表添加到文件包。s是专用于生成静态库的,表示为静态库创建索引,这个索引被链接器使用

编译a.c:

	> gcc a.c -L. -lstack -Ilib

关于参数：
- -L 批定库文件(*.a *.so)搜索路径, 即使库文件在当前目录(.)，gcc 默认也不会去找的
- -lstack 指定库文件名:libstack.*(编译器会首先找共享库libstack.so,如果没有就找静态库libstack.a,所以编译器是优先考虑共享库的,如果希望编译器只链接静态库,可以指定-static选项)
- -I 指定头文件(*.h)搜索路径 默认会搜索当前目录

可以通过 `gcc -print-search-dirs` 查看默认lib 和 header搜索路径

	gcc -print-search-dirs

> 静态库在连接时，会作为程序的一部分(全局变量等地址是固定的)。如果很多程序用到同一套库，为了减少内存消耗，应该将其打包为共享动态库(全局变量的地址需要一张寻址表确定)
> 函式库一般位于/lib64 /lib /usr/lib /usr/lib64
kernel的函式库则位于/lib/modules

你可以在[c 标准库](/p/c-lib) 了解更多的信息

# gcc 搜索路径(search path, find path)
可以通过gcc -v 参数查看gcc 在编译/预先编译时的实际的搜索详细信息(其中包括了headers 的默认路径). 指定-E 参数只进行预编译(stop after preprocessing stage)

	gcc -x c -v -E /dev/null
	gcc -x c++ -v -E /dev/null # for c/c++

可以通过 `gcc -print-search-dirs` 查看默认lib 和 header搜索路径

	gcc -print-search-dirs

> Note: header 一般在/usr/include

# Shared Library 共享库

	> gcc -c lib/*.c  -fPIC

因为需要编译为动态的共享库，所以编译时，必须加-fPIC 编译为与位置无关(Position Independent Code )的目标代码（Relocatable）.一般的目标文件的全局变量地址在链接时会确定 固定的地址。而-fPIC 可以实现生成的共享库中，地址不是写死的, 而是加载时再确定(比如加载时将动态库的数据段基地址写到ebx)

生成共享库：

	> gcc -shared -o libstack.so push.o pop.o

使用共享库编译链接:

	> gcc a.c -g -L. -lstack -Ilib -o main

由于共享库在编译时，并没有编译到main中，所以执行main 时，可能找不到共享库libstack.so：

	$ ./main
	./main: error while loading shared libraries: libstack.so: cannot open shared object file: No such file or directory
	$ ldd main
		linux-gate.so.1 =>  (0xb7f5c000)
		libstack.so => not found
		libc.so.6 => /lib/tls/i686/cmov/libc.so.6 (0xb7dcf000)
		/lib/ld-linux.so.2 (0xb7f42000)

## Shared Library Path while excute 程序执行时的享库的执行路径
依次按以下顺序查找(`man ld.so`,`man ld`)：

1. LD_LIBRARY_PATH 不建议
3. (ELF only) Using the directories specified in the DT_RUNPATH dynamic section attribute of the binary if present
2. /etc/ld.so.cache中查找。这个缓存文件由ldconfig命令读取配置文件/etc/ld.so.conf之后生成.
3. Using path `/usr/lib` then `/usr/local/lib`.
4. 指定 -L $SCADDRESS/lib/ -lapue
5. 指定 -F
     The default framework search path is /Library/Frameworks then /System/Library/Frameworks.  

对于mac  来说: `man ld`

    Search paths
     ld maintains a list of directories to search for a library or framework to use.  
     The default library search path is `/usr/lib` then `/usr/local/lib`.  
     The -L option will add a new library search path.  
     The default framework search path is /Library/Frameworks then /System/Library/Frameworks.  
     (Note: previously, /Network/Library/Frameworks was at the end of the default path.  If you need that functionality, you need to explicitly add -F/Network/Library/Frameworks).  
     The -F option will add a new framework search path.  
     The -Z option will remove the standard search paths.  
     The -syslibroot option will prepend a prefix to all search paths.

### DT_RUNPATH(不推荐)
这种方法是将共享库路径，写死到.dynamic段 中。通过参数 ` -Wl,-rpath,/home/akaedu/somedir`表示`-rpath /home/akaedu/somedir` 是由gcc传递给链接器的 选项。可以看到readelf的结果多了一条RPATH 记录:

	$ gcc main.c -g -L. -lstack -Istack -o main -Wl,-rpath,/home/akaedu/somedir
	$ readelf -a main
		...
		Dynamic section at offset 0xf10 contains 23 entries:
		  Tag        Type                         Name/Value
		 0x00000001 (NEEDED)                     Shared library: [libstack.so]
		 0x00000001 (NEEDED)                     Shared library: [libc.so.6]
		 0x0000000f (RPATH)                      Library rpath: [/home/akaedu/somedir]
		...

这个编译用到了gcc 选项:

	-Wl,option
	   Pass option as an option to the linker.  If option contains commas, it is split into multiple options at the commas.

### ldconfig
linux 编大部分程序在编译时，都是使用的动态共享库. 每个程式在执行时，都会从硬盘读取动态库。ldconfig能将动态库事先读入到cache中，就可以提升读入的效率。
实现机制：

1. 在/etc/ld.so.conf 中指定要载入的动态库目录
2. 执行ldconfig，它会将配置指定的动态库载入cache
3. 同时将cache 记录到 /etc/ld.so.cache

我们可以手动控制执行：

	ldconfig
		无参数
		-f conf_file
		-C cache 指定cache 记录文件，默认 /etc/ld.so.cache
		-p 读出/etc/ld.so.cache


#### ld.so.conf

	> cat /etc/ld.so.conf
	/usr/lib64/mysql
	hwcap 1 nosegneg

生成ld.so.cache, 可以加 `-v`( verbose).

	sudo ldconfig -v

> Mac 下请参考 man dyld 设置共享库加载路径。

> hwcap是x86平台的Linux特有的一种机制,系统检测到当前平台是i686而不 是i586或i486,所以在运行程序时使用i686的库,这样可以更好地发挥平台的性能,也可以利用一些新的指令,所以上面ldd命令的输出结果显示动态链接器搜索到 的libc是/lib/tls/i686/cmov/libc.so.6,而不是/lib/libc.so.6

## 动态库的执行
调用动态库函数时，并不是直接call 函数地址，比如动态库中的push 函数地址只能在加载时被确定：

	push('a');
	 80484b5:	c7 04 24 61 00 00 00 	movl   $0x61,(%esp)
	 80484bc:	e8 17 ff ff ff       	call   80483d8 <push@plt>

通过gdb 单步执行时可以看出:  跳到了 -> .plt 段`push@plt`,
第一条指令又跳到`jmp *0x804a008` ,
0x804a008 中保存的地址为动态链接器地址，所以它又会jmp 到动态链接器(/lib/ld-linux.so.2),
链接器会找到动态库，获取动态库的地址(写入到0x804a008, 下次jmp时直接取到push 链接器，而不用再调用动态链接器)及以及数据段基址(写入到ebx)
下一次调用push 时，

	7		push('a');
	(gdb) si
	0x080484bc	7		push('a');
	(gdb) si
	0x080483d8 in push@plt ()
	 80483d8:	ff 25 08 a0 04 08    	jmp    *0x804a008
	 80483de:	68 10 00 00 00       	push   $0x10
	 80483e3:	e9 c0 ff ff ff       	jmp    80483a8 <_init+0x30>

## 共享库命名
soname 是主版本命名。 比如`libcap.so.2` 是soname ,只包含主版本号。主版号一致就可以被应用程序所使用。

	libcap.so.2 -> libcap.so.2.10

realname 包括次版本，编译时生成共共享文件时的 realname (realname 带次版本号)

	$ gcc -shared -Wl,-soname,libstack.so.1 -o libstack.so.1.0  push.o pop.o

linker name 是链接时 -l 参数所要查找的文件名，它没有主版本号。比如, 编译时 -lstack 参数 表示要查找 libstack.so

## Virtual Memory 虚拟内存
VA 虚拟地址有几个好处:

1. 虚拟内存管理可以控制物理内存的访问权限. 利用CPU 与MMU 的保护机制实现对text 段的写保护
2. 让每个进程有独立的地址空间, 不存在地址冲突。
对于共享库来说，每个进程的data segment 虚拟地址是相同的，但是映射到的PA是不相同的。对于 text segment 来说，它们被映射到相同的物理地址PA. 这防止了地址冲突，又充分利用了内存。
3. VA到PA的映射会给分配和释放内存带来方便，物理地址不连续的几块内存可以映射成虚拟地址连续的一块内存。
比如要用malloc分配一块很大的内存空间，虽然有足够多的空闲物理内存，却没有足够大的连续空闲内存，这时就可以分配多个不连续的物理页面而映射到连续的虚拟地址范围。如下图所示。
4. 将虚拟内存映射到硬盘。
不是所有的虚拟内存都映射到内存，当内存不够用时，可以映射到硬盘。这使得各进程分配的内存之和可能会大于实际可用的物理内存 而不会崩溃。
因为各进程分配的只不过是虚拟内存的页面，这些页面的数据可以映射到物理页面，也可以临时保存到磁盘上而不占用物理页面.
硬盘上临时保存虚拟内存页面的分区或者交换文件，统称(SWAP device). 都是一些不常用的虚拟内存页面。

	物理内存 + 交换设备 = 可分配内存大小

### 换页(paging)
将空闲的物理页面换出(Page out) 到交换设备， 以及这交换设备中的数据换入(Page in) 物理页面， 这两个过程统称 Paging.

# ldd 查看程序依赖的库
在linux 下查看执行文件使用的共享库用ldd,

	ldd *.a
	ldd *.so

	ldd [-vdr] a.out 详细的库信息
		-v 递归显示动态库依赖
		-d 显示丢失的库
		-r 将ELF相关错误显示出来

> `otool -L` is a equivalent command for Mac OSX.


# Reference
- [linux c linker]

[linux c linker]: http://akaedu.github.io/book/ch20s05.html
