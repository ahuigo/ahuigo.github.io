---
layout: page
title:	Assemble in Mac OSX
category: blog
description: 
---
# Preface

# Register

## X86-64
32-bit 与 64-bit 寄存器

	63                            32             15      8 7      0
	---------------------------------------------------------------
	|%rax                     %eax |         %ax |   %ah  |  %al  |
	|-------------------------------------------------------------|
	|%rbx                     %ebx |         %bx |   %bh  |  %bl  |
	|--------------------------------------------------------------
	|%rcx                     %ecx |         %cx |   %ch  |  %cl  |
	|-------------------------------------------------------------|
	|%rdx                     %edx |         %dx |   %dh  |  %dl  |
	|-------------------------------------------------------------|
	|%rsi                     %esi |         %si |                |
	|-------------------------------------------------------------|
	|%rdi                     %edi |         %di |                |
	|-------------------------------------------------------------|
	|%rsp                     %esp |         %sp |                | 栈指针
	|-------------------------------------------------------------|
	|%rbp                     %ebp |         %bp |                | 帧指针
	---------------------------------------------------------------
	pc 程序计数器:
		rip

X86 通用寄存器： 

	eax、ebx、ecx、edx、edi、esi. 但对某些命令不是通用的，比如idivl 要求被除数在eax 中，除数为任意寄存器， edx 必须为0，执行idivl 后，eax 保存商，edx 保存余数。

X86 的特殊寄存器为：

	ebp esp 用于函数调用栈帧，
	eip 程序计数器
	eflags 保存标志位：
		CF 进位, OF 溢出, ZF 零， SF 负数

其中:

以 %r 开头的表示 64-bit 寄存器；
以 %e 开头的是 32-bit 寄存器;
而 %(a|c|d|b)x，%(s|d)i，%(s|b)p 这八个寄存器是让那些以 w （表示WORD）为结尾的指令如 movw 使用的;
而 %(a|c|d|b)(h|l) 这八个寄存器是让那些以 b（表示 BYTE） 为结尾的指令如 movb 使用的；

x86-64 与 x86-32 相比：

1. x86-64较x86-32多了8个通用64 bit寄存器: rax,rbx,rcx,rdx,rsi,rdi,rsp,rbp r8,r9,r10,r11,r12,r13,r14,r15 
2. x86-64全面支持x86-32和x86-16的通用寄存器: eax,ax,al,ah, ebx,bx,bl,bh, 
3. 还对传统的edi,esi做了改进: 

	edi ,32位 
	di,16位 
	dil,8位，在传统的x86机器中，di是不可按照8位来访问的，但在x86-64下可以。  esi也可以按照8位来访问。

4. 有一个很特别的寄存器 rip，相当于x86-32的eip. 在x86-32是不可直接访问的，如mov eax,eip是错的，但在x86-64位下却可以，如 mov rax,qword ptr [rip+100]是对的。
而且，它除了是个程序计数器外，也是个“数据基地址”，有此可见，它现在是身兼两职！为什么在x86-64位下要用rip做访 问数据的基地址呢？因为，在x86-64下，DS,ES,CS,SS都没有实际意义了，也就是说，它们不再参与地址计算，只是为了兼容x86-32。 FS,GS还是参与地址计算，它们两个和x86-32的意义相同。 

5. x86-64对FPU(数学处理单元)和MMX,SSE,SSE2 也做了很大的改进。

### Mov

	movq 
		Its 64bit because of the "q" in movq which is quad and quad is 64bit.
	movl 
		in which l is 32bit
	movw
		in which w is word 16bit
	movb
		for bytes
	movz 
		把字长较短的值存到字长较长的存储单元中,存储单元的高位用0填充。该指令可以有b(byte)、w(word)、l(long)三种后缀,分别表示单字节、两字节和四字节

# 语法

## GAS 与 NASM
有两种汇编语法: 
GAS 汇编器 采用AT&T , 比较古老
NASM 汇编器 采用 Intel, 比较新, 大多数编译器都支持的

### compile 编译的不同
汇编：
GAS：

	as –o program.o program.s

NASM：

	nasm –f elf –o program.o program.asm
	-f <format>
		-f macho : in the Mach-O format.
		-f elf/elf64 : in the elf/elf64 format.
	-arch 
		-arch i386/x86-64

链接（对于两种汇编器通用）：

	ld –o program program.o

在使用外部 C 库时的链接方法：

	ld –-dynamic-linker /lib/ld-linux.so.2 –lc –o program program.o

### 基本结构的不同
NASM:

	; Text segment begins
	section .text
	   global _start

	; Program entry point
	   _start:

	; Put the code number for system call
		  mov   eax, 1 

	; Return value 
		  mov   ebx, 2

	; Call the OS
		  int   80h

GAS:

	# Text segment begins
	.section .text
	   .globl _start
	
	# Program entry point
	   _start:
	
	# Put the code number for system call
	      movl  $1, %eax
	
	/* Return value */
	      movl  $2, %ebx
	
	# Call the OS
	      int   $0x80

> Note: 以上代码编译和链接后的执行文档只能运行于linux i386，参考后面的中断一节

二者语法结构的不同

1. 源和目标顺序不同: 
	gas: `movl $1,%eax`
	nasm: `mov eax,1` 
2. 操作数加$:	
	gas: `pushl $4`
	nasm: `push 4`
	gas hex: `pushl $0x80`
	nasm hex: `push 0x80` or `push 80h`
4. 寄存器加%:
	gas: `%eax`
	nasm: `eax`
4. 操作数大小决定操作码和操作数: `AT&T` 操作码后缀`b,w,l`分别表示 `bytes,word,long(32)`;而intel 则在操作数前面加：`byte ptr,word ptr,dword ptr`
	gas: `movb foo, %al`
	nasm: `mov al, byte ptr foo`
5. 长跳转、调用、远返回不同：
	中间形式长跳转和调用：
		gas 用`lcall/ljmp $section, $offset`
		nasm 用`call/jmp far section:offset`
	远返回:
		gas: `lret $stack-adjust`
		nasm: `ret far stack-adjust`
5. 汇编器指令加`.`:
	section: 标识segment
		gas: `.section .text`
		nasm: `section .text`
	global:	标识入口
		gas: `.globl _start`
		nasm: `global _start`

二者相同点：

1. 标签以`:` 结尾：比如`_start:`
2. 都使用`int` 作中断调用

Refer to : [gas-nasm]

## comments 注释不同
	gas: 支持c 风格`/**/ `,`//`, shell 风格`#`
	nasm: 支持ini 风格`;`, `;//`

## 变量和内存访问
求三个数的最大值：

nasm:

	; Data section begins
	section .data
	   var1 dd 40
	   var2 dd 20
	   var3 dd 30

	section .text
	   global _start
	   _start:
		  mov   ecx, [var1]
		  cmp   ecx, [var2]
		  jg    check_third_var
		  mov   ecx, [var2]

	   check_third_var:
		  cmp   ecx, [var3]
		  jg    _exit
		  mov   ecx, [var3]
	   _exit:
		  mov   eax, 1
		  mov   ebx, ecx
		  int   80h

gas:

	.section .data
	   var1:
		  .int 40
	   var2:
		  .int 20
	   var3:
		  .int 30

	.section .text
	   .globl _start
	_start:
		  movl  (var1), %ecx
		  cmpl  (var2), %ecx
		  jg    check_third_var
		  movl  (var2), %ecx

	   check_third_var:
		  cmpl  (var3), %ecx
		  jg    _exit
		  movl  (var3), %ecx
	   _exit:
		  movl  $1, %eax
		  movl  %ecx, %ebx
		  int   $0x80

### 变量声明
*数字*
gas 使用`.long,.lint,.byte` 声明`32,16,8`位数字
nasm 使用`dd, dw, db` 声明`32,16,8`位数字

*字符*
gas 使用`.ascii, .asciz, .string`
	`nickname: .ascii "hilojack" `
nasm 使用`db`:
	`nickname db 'hilojack' `

*声明变量名*
gas 使用标签语法声明：`var1: .int 40`
nasm 使用变量名作前缀：`var1 dd 40`

### variable 变量使用
直接寻址:
	gas: `movl (var1), %eax`
	nasm: `mov eax, [var1]`

### Addressing Mode 寻址方式
ADDRESS(%BASE, %INDEX, MULTIPLIER)
FINAL ADDRESS = ADDRESS + BASE + INDEX * MULTIPLIER

- Direct Addressing Mode (直接寻址): movl ADDRESS,%eax
- Indirect Addressing Mode (间接寻址): movl (%ebx),%eax 以ebx 中的值作为地址
- Base Pointer Addressing Mode (基址寻址): movl ADDRESS(%edi)
- Indexed Addressing Mode (变址寻址): movl ADDRESS(,%edi,4)

小提示, 有intel 中有一个lea (Load Effiect Address)指令. 可以使用它进行加法运算, 它不会使用ALU 单元, 它使用的是地址单元, 执行以单时钟为周期.

	lea    (%rdx,%rax,1),%eax ;//%rdx + %rax * 1 = %rdx + %rax => %eax

GAS 中基索引寻址模式的一般形式如下：

	ADDRESS (, index, multiplier)
	或
	(offset, index, multiplier)
	或
	ADDRESS(base, index, multiplier)

eg:

	movl  -4(%ebp), %edi
	movb  (%ebx, %edi, 1), %dl

NASM:

	mov   al, byte [ebx + edx]
	multiplier:
		byte
		word
		dword

## macro 使用宏
读取字符串，并向用户显示问候语

nasm:

	section .data
	   prompt_str  db   'Enter your name: '
	   STR_SIZE  equ  $ - prompt_str ; $ is the location counter

	   greet_str  db  'Hello '
	   GSTR_SIZE  equ  $ - greet_str

	section .bss

	; Reserve 32 bytes of memory
	   buff  resb  32

	; A macro with two parameters
	; Implements the write system call
	   %beginmacro write 2 
		  mov   eax, 4
		  mov   ebx, 1
		  mov   ecx, %1
		  mov   edx, %2
		  int   80h
	   %endmacro

	; Implements the read system call
	   %beginmacro read 2
		  mov   eax, 3
		  mov   ebx, 0
		  mov   ecx, %1
		  mov   edx, %2
		  int   80h
	   %endmacro

	section .text
	   global _start
	   _start:
		  write prompt_str, STR_SIZE
		  read  buff, 32

	; Read returns the length in eax
		  push  eax

	; Print the hello text
		  write greet_str, GSTR_SIZE
		  pop   edx

	; edx  = length returned by read
		  write buff, edx

	   _exit:
		  mov   eax, 1
		  mov   ebx, 0
		  int   80h

gas:

	.section .data
	   prompt_str:
		  .ascii "Enter Your Name: "
	   pstr_end:
		  .set STR_SIZE, pstr_end - prompt_str

	   greet_str:
		  .ascii "Hello "
	   gstr_end:
		  .set GSTR_SIZE, gstr_end - greet_str

	.section .bss
	// Reserve 32 bytes of memory
	   .lcomm  buff, 32

	// A macro with two parameters
	//  implements the write system call
	   .macro write str, str_size 
		  movl  $4, %eax
		  movl  $1, %ebx
		  movl  \str, %ecx
		  movl  \str_size, %edx
		  int   $0x80
	   .endm

	// Implements the read system call
	   .macro read buff, buff_size
		  movl  $3, %eax
		  movl  $0, %ebx
		  movl  \buff, %ecx
		  movl  \buff_size, %edx
		  int   $0x80
	   .endm

	.section .text
	   .globl _start
	   _start:
		  write $prompt_str, $STR_SIZE
		  read  $buff, $32

	// Read returns the length in eax
		  pushl %eax

	// Print the hello text
		  write $greet_str, $GSTR_SIZE
		  popl  %edx

	// edx = length returned by read
	   write $buff, %edx

	   _exit:
		  movl  $1, %eax
		  movl  $0, %ebx
		  int   $0x80

.bss 中分配空间

	nasm 使用resb,resw,resd 在.bss 中声明字节、字、双字
		varname resb size
	gas 使用 .lcomm 分配字节级空间
		.lcomm varname, size

*位置计数器* 
nasm 提供位置计数器`$`，`$$` 来操作位置计数

	STR_SIZE  equ  $ - prompt_str; $ is the location counter

gas 只能通过标签计算下一个存储位置

	.set STR_SIZE, pstr_end - prompt_str


*宏* 
nasm 宏的语法是`%beginmacro` 后跟宏名，和参数数量，宏的第一个参数是`%1`，第二个是`%2`... 以`%endmacro`结尾

	%beginmacro macroname 2
		mov   eax, 4; write to stdout
		mov   ebx, 1; 
		mov   ecx, %1; buf
		mov   edx, %2; buf_len
		int   80h
	%endmacro

GAS 提供 .macro 和 .endm 指令来创建宏。
.macro 指令后面跟着宏名称，后面可以有参数，也可以没有参数。在 GAS 中，宏参数是按名称指定的。例如：

	.macro macroname arg1, arg2
	   movl \arg1, %eax
	   movl \arg2, %ebx //宏参数名称时，在名称前面加上一个反斜线。如果不这么做，链接器会把名称当作标签而不是参数
	.endm

本例子构造了两个宏read 和write：

*read*
	nasm:
	  read  buff, 32;32 是长度
	gas:
	  read  $buff, $32;
	
*write*
	nasm: 
		write prompt_str, STR_SIZE
	gas: 
		write $prompt_str, $STR_SIZE

## function 函数，外部例程和堆栈
这个清单演示了函数、各种内存寻址方案、堆栈和库函数的使用方法: 实现选择排序

nasm:

	section .data
		array db 89, 10, 67, 1, 4, 27, 12, 34, 86, 3
		ARRAY_SIZE equ $ - array

		array_fmt db "  %d", 0
		usort_str db "unsorted array:", 0
		sort_str db "sorted array:", 0
		newline db 10, 0

	section .text
		extern puts
		global _start

	_start:
	  push  usort_str
	  call  puts
	  add   esp, 4

	  push  ARRAY_SIZE
	  push  array
	  push  array_fmt
	  call  print_array10
	  add   esp, 12

	  push  ARRAY_SIZE 
	  push  array
	  call  sort_routine20

	; Adjust the stack pointer
	  add   esp, 8

	  push  sort_str
	  call  puts
	  add   esp, 4

	  push  ARRAY_SIZE 
	  push  array
	  push  array_fmt
	  call  print_array10
	  add   esp, 12
	  jmp   _exit

	  extern printf

	print_array10:
	  push  ebp
	  mov   ebp, esp
	  sub   esp, 4
	  mov   edx, [ebp + 8]
	  mov   ebx, [ebp + 12]
	  mov   ecx, [ebp + 16]

	  mov   esi, 0

	push_loop:
	  mov   [ebp - 4], ecx
	  mov   edx, [ebp + 8]
	  xor   eax, eax
	  mov   al, byte [ebx + esi]
	  push  eax
	  push  edx

	  call  printf
	  add   esp, 8
	  mov   ecx, [ebp - 4]
	  inc   esi
	  loop  push_loop

	  push  newline
	  call  printf
	  add   esp, 4
	  mov   esp, ebp
	  pop   ebp
	  ret

	sort_routine20:
	  push  ebp
	  mov   ebp, esp

	; Allocate a word of space in stack
	  sub   esp, 4 

	; Get the address of the array
	  mov   ebx, [ebp + 8] 

	; Store array size
	  mov   ecx, [ebp + 12]
	  dec   ecx

	; Prepare for outer loop here
	  xor   esi, esi

	outer_loop:
	; This stores the min index
	  mov   [ebp - 4], esi 
	  mov   edi, esi
	  inc   edi

	inner_loop:
	  cmp   edi, ARRAY_SIZE
	  jge   swap_vars
	  xor   al, al
	  mov   edx, [ebp - 4]
	  mov   al, byte [ebx + edx]
	  cmp   byte [ebx + edi], al
	  jge   check_next
	  mov   [ebp - 4], edi

	check_next:
	  inc   edi
	  jmp   inner_loop

	swap_vars:
	  mov   edi, [ebp - 4]
	  mov   dl, byte [ebx + edi]
	  mov   al, byte [ebx + esi]
	  mov   byte [ebx + esi], dl
	  mov   byte [ebx + edi], al

	  inc   esi
	  loop  outer_loop

	  mov   esp, ebp
	  pop   ebp
	  ret

	_exit:
	  mov   eax, 1
	  mov   ebx, 0
	  int   80h

GAS:

	.section .data
	   array:
		  .byte  89, 10, 67, 1, 4, 27, 12, 34, 86, 3
	   array_end:
		  .equ ARRAY_SIZE, array_end - array

	   array_fmt: .asciz "  %d"
	   usort_str: .asciz "unsorted array:"
	   sort_str: .asciz "sorted array:"
	   newline: .asciz "\n"

	.section .text
	   .globl _start
	   _start:

		  pushl $usort_str
		  call  puts
		  addl  $4, %esp

		  pushl $ARRAY_SIZE
		  pushl $array
		  pushl $array_fmt
		  call  print_array10
		  addl  $12, %esp

		  pushl $ARRAY_SIZE
		  pushl $array
		  call  sort_routine20

	# Adjust the stack pointer
		  addl  $8, %esp

		  pushl $sort_str
		  call  puts
		  addl  $4, %esp

		  pushl $ARRAY_SIZE
		  pushl $array
		  pushl $array_fmt
		  call  print_array10
		  addl  $12, %esp
		  jmp   _exit

	   print_array10:
		  pushl %ebp
		  movl  %esp, %ebp
		  subl  $4, %esp
		  movl  8(%ebp), %edx
		  movl  12(%ebp), %ebx
		  movl  16(%ebp), %ecx

		  movl  $0, %esi

	   push_loop:
		  movl  %ecx, -4(%ebp)  
		  movl  8(%ebp), %edx
		  xorl  %eax, %eax
		  movb  (%ebx, %esi, 1), %al
		  pushl %eax
		  pushl %edx

		  call  printf
		  addl  $8, %esp
		  movl  -4(%ebp), %ecx
		  incl  %esi
		  loop  push_loop

		  pushl $newline
		  call  printf
		  addl  $4, %esp
		  movl  %ebp, %esp
		  popl  %ebp
		  ret

	   sort_routine20:
		  pushl %ebp
		  movl  %esp, %ebp

	# Allocate a word of space in stack
	      subl  $4, %esp
	
	# Get the address of the array
	      movl  8(%ebp), %ebx
	
	# Store array size
	      movl  12(%ebp), %ecx
	      decl  %ecx
	
	# Prepare for outer loop here
	      xorl  %esi, %esi
	
	   outer_loop:
	# This stores the min index
	      movl  %esi, -4(%ebp)
	      movl  %esi, %edi
	      incl  %edi
	
	   inner_loop:
	      cmpl  $ARRAY_SIZE, %edi
	      jge   swap_vars
	      xorb  %al, %al
	      movl  -4(%ebp), %edx
	      movb  (%ebx, %edx, 1), %al
	      cmpb  %al, (%ebx, %edi, 1)
	      jge   check_next
	      movl  %edi, -4(%ebp)
	
	   check_next:
	      incl  %edi
	      jmp   inner_loop
	
	   swap_vars:
	      movl  -4(%ebp), %edi
	      movb  (%ebx, %edi, 1), %dl
	      movb  (%ebx, %esi, 1), %al
	      movb  %dl, (%ebx, %esi, 1)
	      movb  %al, (%ebx,  %edi, 1)
	
	      incl  %esi
	      loop  outer_loop
	
	      movl  %ebp, %esp
	      popl  %ebp
	      ret
	
	   _exit:
	      movl  $1, %eax
	      movl  0, %ebx
	      int   $0x80

## repeat
GAS 如果次数是 3：

	.rept 3
	   movl $2, %eax
	.endr

就相当于：

	movl $2, %eax
	movl $2, %eax
	movl $2, %eax

NASM 重复`expression`次：

	%rep <expression>
	   nop
	%endrep

或者：

	times <expression> nop

## x86-64的汇编(nasm)

	mov eax,0ah 
	rax也等于000000000000000ah 

	再如： 
	mov rcx,0aaaaaaaaaaaaaaaah 
	(此时ecx等于0aaaaaaaah) 

	规则： 
	Example 1: 64-bit Add: 
	Before:	RAX =0002_0001_8000_2201 
			RBX =0002_0002_0123_3301 
	ADD RBX,RAX ;48 is a REX prefix for size. 
	Result:RBX = 0004_0003_8123_5502 

	Example 2: 32-bit Add: 
	Before: RAX = 0002_0001_8000_2201 
			RBX = 0002_0002_0123_3301 
	ADD EBX,EAX ;32-bit add 
	Result:RBX = 0000_0000_8123_5502 
	(32-bit result is zero extended) 

	Example 3: 16-bit Add: 
	Before: RAX = 0002_0001_8000_2201 
			RBX = 0002_0002_0123_3301 
	ADD BX,AX ;66 is 16-bit size override 
	Result:RBX =  0002_0002_0123_5502 
	(bits 63:16 are preserved) 

	Example 4: 8-bit Add: 
	Before: RAX = 0002_0001_8000_2201 
			RBX = 0002_0002_0123_3301 
	ADD BL,AL ;8-bit add 
	Result: RBX = 0002_0002_0123_3302 
	(bits 63:08 are preserved) 

## c asm (c 语言内嵌汇率)
格式：

	__asm__(assembler template 
		: output operands                  /* optional */
		: input operands                   /* optional */
		: list of clobbered registers      /* optional */
	);

比如：

	int main() {
		int a = 10, b;

		//b = a ; %0 = %1
		__asm__("movl %1, %%eax\n\t"
			"movl %%eax, %0\n\t"
			:"=r"(b)        /* output %0*/
			:"r"(a)         /* input %1*/
			:"%eax"         /* clobbered register */ 指示编译器eax 被征用了，不要动它了
			);
		printf("Result: %d, %d\n", a, b);
		return 0;
	}

# 汇编流程
1. 将源码通过as 编译为目录文件(`source -> objecti`)
2. 将目标文件通过ld 连接为可执行文件(`object -> excute`)
3. 执行文件

## 汇编代码结构
如下所示, 汇编代码完成:返回一个程序状态码

### section
汇编程序是以section 划分的, 在linux 中使用`.section` 分节, 在mac osX 中使用 `section`  分节. 	
`.section .data` `section data` 表示数据段. read-write
`.section .text` `section text` 表示代码段. read-excute

#### section data
	.section .data
	data_items:
		; .long 代表后面的数字是长整形, 4个字节
		.long 3,67,34,222,45,75,54,34,44,33,22,11,66,0
	byte_items:
		; .byte 1个字节
		.byte 3,3
	ascii_items:
		; .ascii 字符串
		.ascii "Hello World!\0"

	.section .text
	movl data_items(,%edi,4), %eax


### global
`.globl Symbol` `global Symbol` 指向程序的入口为Symbol, symbol 表示一个地址

### example

	#PURPOSE: Simple program that exits and returns a
	#	  status code back to the Linux kernel
	#
	#INPUT:   none
	#
	#OUTPUT:  returns a status code. This can be viewed
	#	  by typing
	#
	#	  echo $?
	#
	#	  after running the program
	#
	#VARIABLES:
	#	  %eax holds the system call number
	#	  %ebx holds the return status
	#
	.section .data

	.section .text
	.globl _start
	_start:
	 movl $1, %eax	# this is the linux kernel command
			# number: 1 (system call) for exiting
			# a program

	 movl $4, %ebx	# this is the status number we will
			# return to the operating system.
			# Change this around and it will
			# return different things to
			# echo $?

	 int $0x80	# this wakes up the kernel to run
			# the exit command

## Object File 目标文件
目标文件布局

|起始文件地址   | Section或Header |
|0	   | ELF Header |
|0x34   | .text |
|0x60   | .data |
|0x98   | .bss（未初始化的全局变量） |
|0x98   | .shstrtab (保存section 名字)|
|0xc8   | Section Header Table |
|0x208  | .symtab (符号表)|
|0x288  | .strtab (保存符号的名字)|
|0x2b0  | .rel.text (告诉链接器,需要重新定位的地方) |

可执行文件会把多个section 连接为一个segment, 连接时会确定标号的虚拟地址

	.bss
		block storage segment, 不占代码空间，程序启动时才会分配空间并初始化为0，用于未初始化的变量
		nasm 使用resb,resw,resd 在.bss 中声明字节、字、双字
			varname resb size
		gas 使用 .lcomm 分配字节级空间
			.lcomm varname, size

# Interrupt 中断
Refer to :http://stackoverflow.com/questions/16801432/cant-link-object-file-using-ld-mac-os-x

## 80h on i386
int 会中断并执行异常处理程序, 0x80 所指向的异常处理程序叫系统调用(System Call), 处于内核模式.

	int $0x80 , int 0x80

*不同的OS, 不同的architecture 使用不同的中断方式*:

	`int $0x80` on i386/linux
	`syscall` on x86-64/linux
	`svc` in Thumb mode on ARMv7/linux

所以在x86-64/linux 上使用：

	xor rdi, rdi
	mov al, 60
	syscall

如果你反汇编`/lib64/libc.so.6`的`exit()`话, 就可以发现这段汇编代码

## exit on linux

	movl $1,%eax  mov eax,1 

	eax 中的值是linux _exit 的系统调用号.
		`$1` in eax is the system call number of `_exit()` (which is called by exit in libc) on linux kernel
	ebx 中的值是传给系统调用的第一个参数
		 `$2` in ebx is the first argument to the syscall, the exit status

对于Mac/linux 来说，二者都提供了c 函数`void exit(int)`，可以通过调用此函数实现跨平台：

# Reference
- [linux c]
- [gas-nasm]

[linux c]: http://akaedu.github.io/book/ch18.html
[gas-nasm]:
http://www.ibm.com/developerworks/cn/linux/l-gas-nasm.html
[mac-nasm]: 
http://peter.michaux.ca/articles/assembly-hello-world-for-os-x
