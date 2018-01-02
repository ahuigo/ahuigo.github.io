---
layout: page
title:	
category: blog
description: 
---
# Preface
ELF 文件格式是一个开放标准，linux 系统的可执行文件都采用此格式。它用于三种不同的文件类型：

- 可重定位的目标文件（Relocatable, Object file）
- 可执行文件(Excutable)
- 共享文件(Share Object, Share Library)

本文以 求最大值的gas 汇编文件`mas.s`为例介绍 elf 格式文件

	 .section .data
	data_items: 		#These are the data items
	 .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0

	 .section .text
	 .globl _start
	_start:
	 movl $0, %edi  	# move 0 into the index register
	 movl data_items(,%edi,4), %eax # load the first byte of data
	 movl %eax, %ebx 	# since this is the first item, %eax is
				# the biggest

	start_loop: 		# start loop
	 cmpl $0, %eax  	# check to see if we've hit the end
	 je loop_exit
	 incl %edi 		# load next value
	 movl data_items(,%edi,4), %eax
	 cmpl %ebx, %eax 	# compare values
	 jle start_loop 	# jump to loop beginning if the new
				# one isn't bigger
	 movl %eax, %ebx 	# move the value as the largest
	 jmp start_loop 	# jump to loop beginning

	loop_exit:
	 # %ebx is the status code for the _exit system call
	 # and it already has the maximum number
	 movl $1, %eax  	#1 is the _exit() syscall
	 int $0x80

1. 汇编编译器将源文件编译成目标文件: max.o, 它由很多的`section`组成,包括我们定义的`.section`, 以及编译器自动添加的section（比如符号表） 
2. 链接器将目标文件中的`section`链接合并成`segment`, 生成可执行文件max
3. 加载器(Loader) 根据可执行文件中的`segment` 信息加载运行程序

*Section and Segment* 

链接器把ELF 文件看作Section 的集合，而加载器把ELF 文件看作segment 的集合：

![](/img/as-elf-section-segment.png)


左边是链接器的section 视角, 右边是加载器的 segment 视角:

1. ELF header 描述了体系结构和操作系统基本信息, 包括Section Header Table/Program Header Table 在文件中的位置
2. Section Header Table 对链接器有用，它描述了每个 section 的位置
3. Program Header Table 对加载器有用，它描述了每个 segment 的位置

> 目标文件需要链接器处理，一定要有Section Header Table
> 执行文件需要加载器处理，一定要有 Program Header Table
> 共享库需要动态链接和加载，两个都要有 Section/Program Header Table

# 目标文件

	$ readelf -aW max.o

	ELF Header:
	  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
	  Class:                             ELF64
	  Data:                              2's complement, little endian
	  Version:                           1 (current)
	  OS/ABI:                            UNIX - System V
	  ABI Version:                       0
	  Type:                              REL (Relocatable file)
	  Machine:                           Advanced Micro Devices X86-64
	  Version:                           0x1
	  Entry point address:               0x0
	  Start of program headers:          0 (bytes into file)
	  Start of section headers:          224 (bytes into file)
	  Flags:                             0x0
	  Size of this header:               64 (bytes)
	  Size of program headers:           0 (bytes)
	  Number of program headers:         0
	  Size of section headers:           64 (bytes)
	  Number of section headers:         8
	  Section header string table index: 5

## Section Headers

ELF header 描述的系统是UNIX/System V, header 占用64 bytes,
Section headers 起始于224 bytes(0xE0), 共8个，每个64 bytes, 终止于224+8*64 = 736 bytes(0x02E0)

	Section Headers:
	  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
	  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
	  [ 1] .text             PROGBITS        0000000000000000 000040 00002d 00  AX  0   0  4
	  [ 2] .rela.text        RELA            0000000000000000 0003c8 000030 18      6   1  8
	  [ 3] .data             PROGBITS        0000000000000000 000070 000038 00  WA  0   0  4
	  [ 4] .bss              NOBITS          0000000000000000 0000a8 000000 00  WA  0   0  4
	  [ 5] .shstrtab         STRTAB          0000000000000000 0000a8 000031 00      0   0  1
	  [ 6] .symtab           SYMTAB          0000000000000000 0002e0 0000c0 18      7   7  8
	  [ 7] .strtab           STRTAB          0000000000000000 0003a0 000028 00      0   0  1
	Key to Flags:
	  W (write), A (alloc), X (execute), M (merge), S (strings)
	  I (info), L (link order), G (group), x (unknown)
	  O (extra OS processing required) o (OS specific), p (processor specific)

其中：
`Address` 是这些段加载到内存的虚拟地址，将在链接后填写, 在链接前空缺, 所以在目标文件中是0
`Offset` 和 `size` 指出各`Section` 的文件地址和长度，比如`.data` 这个section 的文件地址是0x70, 长度是0x38（14个4字节整数的长度是0x38）

根据这些信息，可以得到各section 的位置：

	`.text`		保存代码
	`.shstrtab` 保存着各Section 的名字
	`.strtab`	保存着程序各符号的名字
	`.bss`		存放未初始化的变量，不占用程序空间
	`.data`		保存一段初始值
	`.rel.text`	告诉链接器哪些地方需要做重定位
	`.symtab`	符号表

	起始文件地址	Section或Header
	0x00	ELF Header
	0x40	.text	
	0x70	.data
	0xa8	.bss（此段为空）
	0xa8	.shstrtab(保存各section name)
	0xe0	Section Header Table
	0x2e0	.symtab (symbol table)
	0x3a0	.strtab(保存各symbol name)
	0x3c8	.rela.text

可以用hexdump 查看这个文件的16 进制

	$ hexdump -C max.o 
	00000000  7f 45 4c 46 02 01 01 00  00 00 00 00 00 00 00 00  |.ELF............|
	00000010  01 00 3e 00 01 00 00 00  00 00 00 00 00 00 00 00  |..>.............|
	00000020  00 00 00 00 00 00 00 00  e0 00 00 00 00 00 00 00  |................|
	00000030  00 00 00 00 40 00 00 00  00 00 40 00 08 00 05 00  |....@.....@.....|
	00000040  bf 00 00 00 00 67 8b 04  bd 00 00 00 00 89 c3 83  |.....g..........|
	00000050  f8 00 74 12 ff c7 67 8b  04 bd 00 00 00 00 39 d8  |..t...g.......9.|
	00000060  7e ed 89 c3 eb e9 b8 01  00 00 00 cd 80 00 00 00  |~...............|
	00000070  03 00 00 00 43 00 00 00  22 00 00 00 de 00 00 00  |....C...".......|
	00000080  2d 00 00 00 4b 00 00 00  36 00 00 00 22 00 00 00  |-...K...6..."...|
	00000090  2c 00 00 00 21 00 00 00  16 00 00 00 0b 00 00 00  |,...!...........|
	000000a0  42 00 00 00 00 00 00 00  00 2e 73 79 6d 74 61 62  |B.........symtab|
	000000b0  00 2e 73 74 72 74 61 62  00 2e 73 68 73 74 72 74  |..strtab..shstrt|
	000000c0  61 62 00 2e 72 65 6c 61  2e 74 65 78 74 00 2e 64  |ab..rela.text..d|
	000000d0  61 74 61 00 2e 62 73 73  00 00 00 00 00 00 00 00  |ata..bss........|
	000000e0  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
	*
	00000120  20 00 00 00 01 00 00 00  06 00 00 00 00 00 00 00  | ...............|
	00000130  00 00 00 00 00 00 00 00  40 00 00 00 00 00 00 00  |........@.......|
	00000140  2d 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |-...............|
	...

其中 data 对应于[0x70~0xa8）
填充的数据分别是： .long 3,67,34,222,45,75,54,34,44,33,22,11,66,0 ,这些数据会原样加载到内存


	00000070  03 00 00 00 43 00 00 00  22 00 00 00 de 00 00 00  |....C...".......|
	00000080  2d 00 00 00 4b 00 00 00  36 00 00 00 22 00 00 00  |-...K...6..."...|
	00000090  2c 00 00 00 21 00 00 00  16 00 00 00 0b 00 00 00  |,...!...........|
	000000a0  42 00 00 00 00 00 00 00  00 2e 73 79 6d 74 61 62  |B.........symtab|

## symbol table

`.shstrtab` 与 `.strtab` 是分别保存着section name 和 symbol name

	.shstrtab[a8, e0): section names
	000000a0  42 00 00 00 00 00 00 00  00 2e 73 79 6d 74 61 62  |B.........symtab|
	000000b0  00 2e 73 74 72 74 61 62  00 2e 73 68 73 74 72 74  |..strtab..shstrt|
	000000c0  61 62 00 2e 72 65 6c 61  2e 74 65 78 74 00 2e 64  |ab..rela.text..d|
	000000d0  61 74 61 00 2e 62 73 73  00 00 00 00 00 00 00 00  |ata..bss........|

	.strtab[3a0, 3c8): symbol names
	000003a0  00 64 61 74 61 5f 69 74  65 6d 73 00 73 74 61 72  |.data_items.star|
	000003b0  74 5f 6c 6f 6f 70 00 6c  6f 6f 70 5f 65 78 69 74  |t_loop.loop_exit|
	000003c0  00 5f 73 74 61 72 74 00  09 00 00 00 00 00 00 00  |._start.........|

## rela.txt

`.rela.text` 告诉链接器哪些地方需要重新定位
`.symtab` 是符号表，标识所有section 的number, Bind, Type等,
以下是从section header table: `.rela.text`和 `.symtab` section 读出的 关于两个section 的信息.

	Relocation section '.rela.text' at offset 0x3c8 contains 2 entries:
	  Offset          Info           Type           Sym. Value    Sym. Name + Addend
	000000000009  00020000000b R_X86_64_32S      0000000000000000 .data + 0
	00000000001a  00020000000b R_X86_64_32S      0000000000000000 .data + 0

	There are no unwind sections in this file.

在`.symtab` 中

- Ndx 是符号把在section 的Number， 
- value 是每个符号所代表的地址，在目标文件中这个地址是相对于section 的相对地址(比如data_item 相对.data 的地址为0)
- Bind 批示符号是否是全局GLOBAL 或 LOCAL, 比如 _start 是全局(用.global 声明过的符号)，而其它的则是LOCAL

	Symbol table '.symtab' contains 8 entries:
	   Num:    Value          Size Type    Bind   Vis      Ndx Name
		 0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
		 1: 0000000000000000     0 SECTION LOCAL  DEFAULT    1
		 2: 0000000000000000     0 SECTION LOCAL  DEFAULT    3
		 3: 0000000000000000     0 SECTION LOCAL  DEFAULT    4
		 4: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT    3 data_items
		 5: 000000000000000f     0 NOTYPE  LOCAL  DEFAULT    1 start_loop
		 6: 0000000000000026     0 NOTYPE  LOCAL  DEFAULT    1 loop_exit
		 7: 0000000000000000     0 NOTYPE  GLOBAL DEFAULT    1 _start

除了readelf 还可以用`nm `查看符号表：

	$ nm max.o
	0000000000000000 T _start		global
	0000000000000000 d data_items	data
	0000000000000026 t loop_exit	label
	000000000000000f t start_loop	label

## .text 代码
使用objdump 反汇编出.text 代码：

	 $ objdump -dS max.o
	 Disassembly of section .text:
	0000000000000000 <_start>:
	   0:	bf 00 00 00 00       	mov    $0x0,%edi
	   5:	67 8b 04 bd 00 00 00 	mov    0x0(,%edi,4),%eax
	   c:	00
	   d:	89 c3                	mov    %eax,%ebx

	000000000000000f <start_loop>:
	   f:	83 f8 00             	cmp    $0x0,%eax
	  12:	74 12                	je     26 <loop_exit>
	  14:	ff c7                	inc    %edi
	  16:	67 8b 04 bd 00 00 00 	mov    0x0(,%edi,4),%eax
	  1d:	00
	  1e:	39 d8                	cmp    %ebx,%eax
	  20:	7e ed                	jle    f <start_loop>
	  22:	89 c3                	mov    %eax,%ebx
	  24:	eb e9                	jmp    f <start_loop>

	0000000000000026 <loop_exit>:
	  26:	b8 01 00 00 00       	mov    $0x1,%eax
	  2b:	cd 80                	int    $0x80

目前所有指令中用到的符号地址都是相对地址，下一步链接器要修改这些指令，把其中的地址都改成加载时的内存地址，这些指令才能正确执行。

# 可执行文件
先生成可执行文件max(`ld -o max max.o`)

	$ readelf -aW max
	ELF Header:
	  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
	  Class:                             ELF64
	  Data:                              2's complement, little endian
	  Version:                           1 (current)
	  OS/ABI:                            UNIX - System V
	  ABI Version:                       0
	  Type:                              EXEC (Executable file)
	  Machine:                           Advanced Micro Devices X86-64
	  Version:                           0x1
	  Entry point address:               0x4000b0
	  Start of program headers:          64 (bytes into file)
	  Start of section headers:          320 (bytes into file)
	  Flags:                             0x0
	  Size of this header:               64 (bytes)
	  Size of program headers:           56 (bytes)
	  Number of program headers:         2
	  Size of section headers:           64 (bytes)
	  Number of section headers:         6
	  Section header string table index: 3

在ELF header 中:
- `Type` 从REL(Relocatable file) 变成了`EXEC(Executable file)`
- Entry point address 从0 改成了 0x4000b0
- Start of program headers 从0 变成了 64, 多了2个program header(2) (也就是.text 和.data )
- Start of section headers 变成了 56, 少了2个section header(6)，(也就是 .bss 与.rela.text 在链接后被删除了)


	Section Headers:
	  [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
	  [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
	  [ 1] .text             PROGBITS        00000000004000b0 0000b0 00002d 00  AX  0   0  4
	  [ 2] .data             PROGBITS        00000000006000e0 0000e0 000038 00  WA  0   0  4
	  [ 3] .shstrtab         STRTAB          0000000000000000 000118 000027 00      0   0  1
	  [ 4] .symtab           SYMTAB          0000000000000000 0002c0 0000f0 18      5   6  8
	  [ 5] .strtab           STRTAB          0000000000000000 0003b0 000040 00      0   0  1
	Key to Flags:
	  W (write), A (alloc), X (execute), M (merge), S (strings)
	  I (info), L (link order), G (group), x (unknown)
	  O (extra OS processing required) o (OS specific), p (processor specific)

## segment header
在 program headers 中描述了两个segment ：
主要变化是address 定位下来了: 

- headers + .text 定位到 0x400000, .text 定位到0x4000b0, 终止于0x4000dd(+0x2d)
- .data 则定位到 0x6000e0, 终止于0x600118(+0x38)

	Program Headers:
	  Type           Offset   VirtAddr           PhysAddr           FileSiz  MemSiz   Flg Align
	  LOAD           0x000000 0x0000000000400000 0x0000000000400000 0x0000dd 0x0000dd R E 0x200000
	  LOAD           0x0000e0 0x00000000006000e0 0x00000000006000e0 0x000038 0x000038 RW  0x200000

	 Section to Segment mapping:
	  Segment Sections...
	   00     .text
	   01     .data

在Program headers 中, 包括了

- 由`.text` 、 ELF header、Program Header Table 合并成的segment(FileSiz 指出长度是0x0000dd)
- 由`.data` 构成的另一个segment(长度0x38)
- VirtAddr 表示加载到虚拟地址, PhysAddr 在X86 平台上没有意义，物理地址是不确定的(尽管这里PhysAddr 和VirtAddr 相同)
- Flg 指出segment 是否R(Read), W(Write), E(Excute)
- Align的值0x200000（2M）是x86平台的内存页面大小. 加载程序时，文件会按该大小加载到内存的页

下图展示了文件和加载地址的对应关系
![](/img/as-elf-segment-memory.png)

根据section headers 的off/address/size 信息

- 这个可执行文件很小，不超过一个内存页面，但是两个不同的segment 必须加载到*不同的内存页面*，因为MMU 的权限保护机制是以内存页面为单位的，一个页面只有一种权限。

- 另外，segment 在文件页面内偏移多少，其在内存页面内也必须偏移多少。
图示中第二个segment 在文件中偏移了0xe0, 其相对于内存内面0x600000 也会偏移0xe0, 这是为了简化链接器和加载器的实现。
同样的，图示中.text 偏移0xb0, 内存页面加载地址就是0x4000b0. (注意，这些地址是指虚拟地址，不是实际的物理地址)

也就是说：
第一个segment 会加载到内存页面的0x400000, .text 偏移到0x4000b0. .start 位于.text 开头，其在内存页面的地址也是0x4000b0
第二个segment 会加载到内存页面的0x6000e0, .data 偏移到0x6000e0

## 符号表
目标文件中符号在section 中相对地址value, 在可执行文件中被改成了绝对地址。另外还增加了3 个符号：`__bss_start, _edata, _end`, 这些符号由链接脚本添加

	Symbol table '.symtab' contains 10 entries:
	   Num:    Value          Size Type    Bind   Vis      Ndx Name
		 0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
		 1: 00000000004000b0     0 SECTION LOCAL  DEFAULT    1
		 2: 00000000006000e0     0 SECTION LOCAL  DEFAULT    2
		 3: 00000000006000e0     0 NOTYPE  LOCAL  DEFAULT    2 data_items
		 4: 00000000004000bf     0 NOTYPE  LOCAL  DEFAULT    1 start_loop
		 5: 00000000004000d6     0 NOTYPE  LOCAL  DEFAULT    1 loop_exit
		 6: 00000000004000b0     0 NOTYPE  GLOBAL DEFAULT    1 _start
		 7: 0000000000600118     0 NOTYPE  GLOBAL DEFAULT  ABS __bss_start
		 8: 0000000000600118     0 NOTYPE  GLOBAL DEFAULT  ABS _edata
		 9: 0000000000600118     0 NOTYPE  GLOBAL DEFAULT  ABS _end

再看下反汇编结果：可以看到data, jmp/je/jle 中的相对地址都变成了绝对地址(虚拟地址)

	$ objdump -d max
	00000000004000b0 <_start>:
	  4000b0:	bf 00 00 00 00       	mov    $0x0,%edi
	  4000b5:	67 8b 04 bd e0 00 60 	mov    0x6000e0(,%edi,4),%eax
	  4000bc:	00
	  4000bd:	89 c3                	mov    %eax,%ebx

	00000000004000bf <start_loop>:
	  4000bf:	83 f8 00             	cmp    $0x0,%eax
	  4000c2:	74 12                	je     4000d6 <loop_exit>
	  4000c4:	ff c7                	inc    %edi
	  4000c6:	67 8b 04 bd e0 00 60 	mov    0x6000e0(,%edi,4),%eax
	  4000cd:	00
	  4000ce:	39 d8                	cmp    %ebx,%eax
	  4000d0:	7e ed                	jle    4000bf <start_loop>
	  4000d2:	89 c3                	mov    %eax,%ebx
	  4000d4:	eb e9                	jmp    4000bf <start_loop>

	00000000004000d6 <loop_exit>:
	  4000d6:	b8 01 00 00 00       	mov    $0x1,%eax
	  4000db:	cd 80                	int    $0x80

事实上，je/jle/jmp 机器码并没有变（比如`74 12`），只是反汇编的结果显示绝对地址而已。因为
跳转指令（je/jle/jmp）指定的是相对于当前地址向前或者向后跳转多少字节, 这些短跳转指令只有16位, 跳转的范围很小
长跳转指令: 32位, 指定一个内存绝对地址，这被称为绝对跳转


	  4000b5:	67 8b 04 bd e0 00 60 	mov    0x6000e0(,%edi,4),%eax
	  4000b5:	67 8b 04 bd e0 00 60 	mov    0x6000e0(,%edi,4),%eax

而data 的地址对应的机器码则改变了。链接器是怎么知道要改这两处的？这是根据`.rela.text` 重定位信息来改的：

	Relocation section '.rela.text' at offset 0x3c8 contains 2 entries:
	  Offset          Info           Type           Sym. Value    Sym. Name + Addend
	000000000009  00020000000b R_X86_64_32S      0000000000000000 .data + 0
	00000000001a  00020000000b R_X86_64_32S      0000000000000000 .data + 0

第一列offset 指示.text 需要改的地方: 在.text 段中的相对地址是0x9 和 0x1a. 这两个地址在原来的目标文件中是0x0，现在改成了0x6000e0. 这是基准地址也是.data 的起始地址。

# Reference
- [linux c] by 宋劲杉 第18章第5节之 elf 文件格式

[linux c]: 
http://akaedu.github.io/book/ch18s05.html
