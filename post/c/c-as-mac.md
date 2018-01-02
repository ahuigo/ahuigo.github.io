---
layout: page
title:	Assemble in Mac OSX
category: blog
description: 
---
# Preface
本文旨在比较MacOSX 与 linux 下汇编的差别。

|linux(AT & T)| mac(intel)|
|movl $1,%eax| mov eax, 0x1|
|movl $4,%ebx| mov ebx, 0x4|
|.section .data|section .data|
|.globl mystart| global mystart|
|int $0x80| int 0x80|

# hello.s

	
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
	.section .data ,

	.section .text ,
	.globl _start
	_start:
	movl $1, %eax	# this is the linux kernel command
		# number (system call) for exiting
		# a program

	movl $4, %ebx	# this is the status number we will
		# return to the operating system.
		# Change this around and it will
		# return different things to
		# echo $?

	int $0x80	# this wakes up the kernel to run
		# the exit command

编译为目标文件(Assemble -> Object)：

	as hello.s -o hello.o

用ld 链接目标文件(Object->Excutable), 

	ld  hello.o -o hello.out -lc -arch x86_64 -lcrt1.10.6.o 

> 起始符号有 _main 和start的区别， 
gcc认_main，as ld认start，但是，只要在 ld 加上参数 -lcrt10.6.o 同样可以接受_main 

# Reference
http://peter.michaux.ca/articles/assembly-hello-world-for-os-x
