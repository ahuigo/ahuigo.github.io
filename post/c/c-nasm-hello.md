---
layout: page
title:	nasm helloworld
category: blog
description: 
---
# Preface

本文以hello world 为例介绍，nasm 汇编语法。所有示例 基于mac osx 系统调用, 所以不能在linux 下使用

# hello word

	; hello.asm - a "hello, world" program using NASM

	section .text

	global mystart                ; make the main function externally visible

	mystart:

	; 1 print "hello, world"

		; 1a prepare the arguments for the system call to write
		push dword mylen          ; message length                           
		push dword mymsg          ; message to write
		push dword 1              ; file descriptor value

		; 1b make the system call to write
		mov eax, 0x4              ; system call number for write
		sub esp, 4                ; OS X (and BSD) system calls needs "extra space" on stack(store current pc address)
		int 0x80                  ; make the actual system call

		; 1c clean up the stack
		add esp, 16               ; 3 args * 4 bytes/arg + 4 bytes extra space = 16 bytes
		
	; 2 exit the program

		; 2a prepare the argument for the sys call to exit
		push dword 0              ; exit status returned to the operating system

		; 2b make the call to sys call to exit
		mov eax, 0x1              ; system call number for exit
		sub esp, 4                ; OS X (and BSD) system calls needs "extra space" on stack
		int 0x80                  ; make the system call

		; 2c no need to clean up the stack because no code here would executed: already exited
		
	section .data

	  mymsg db "hello, world", 0xa  ; string with a carriage-return
	  mylen equ $-mymsg             ; string length in bytes

# compile & link

compile:

	nasm -f macho hello.asm

link:

	ld -o hello -e mystart hello.o

run

	./hello

check exit status

	echo $?

# Procedural "hello, world"

	; hello.asm - a "hello, world" program using NASM
		
	section .text

	global mystart                ; make the main function externally visible

	; a procedure wrapping the system call to write
	mywrite:
		mov eax, 0x4              ; system call write code
		int 0x80                  ; make system call
		ret

	; a procedure wrapping the system call to exit
	myexit:
		mov eax, 0x1              ; system call exit code
		int 0x80                  ; make system call
		; no need to return

	mystart:

	; 1 print "hello, world"

		; 1a prepare arguments
		push dword mylen           ; message length                           
		push dword mymsg           ; message to write
		push dword 1               ; file descriptor value
		; 1b make call
		call mywrite
		; 1c clean up stack
		add esp, 12
		
	; 2 exit the program

		; 2a prepare arguments
		push dword 0              ; exit code
		; 2b make call
		call myexit
		; 2c no need to clean up because no code here would executed...already exited!
		
	section .data

	  mymsg db "hello, world", 0xa  ; string with a carriage-return
	  mylen equ $-mymsg             ; string length in bytes

Compile and run above code as in the first example.

Note that the the oddness of "extra space" on the stack has disapeared. Instead of adding "extra space" manually, it is added automatically as part of `call mywrite` and `call myexit` lines when the address of the subsequent instruction is pushed onto the stack.

The `ret` lines pops *this address* off the stack and the program continues executing at that address.

# Library "hello, world"
This example shows how the `mywrite` and `myexit` procedures can be moved out to separate library.

sys.asm:

	; sys.asm - system call wrapper procedures

	section .text

	; make the library API externally visible
	global mywrite
	global myexit

	mywrite:
		mov eax, 0x4              ; sys call write code
		int 0x80                  ; make system call
		ret

	myexit:
		mov eax, 0x1              ; sys call exit code
		int 0x80                  ; make system call

hello.asm:

	; hello.asm - a "hello, world" program using NASM
		
	section .text

	; tell the assembler about library functions are used and the linker will resolve them
	extern mywrite
	extern myexit

	global mystart                ; make the main function externally visible

	mystart:                      ; write our string to standard output

	; 1 print "hello, world"

		; 1a prepare arguments
		push dword mylen           ; message length                           
		push dword mymsg           ; message to write
		push dword 1               ; file descriptor value
		; 1b make call
		call mywrite
		; 1c clean up stack
		add esp, 12                ; 3 args * 4 bytes/arg = 12 bytes
		
	; 2 exit the program

		; 2a prepare arguments
		push dword 0              ; exit code
		; 2b make call
		call myexit
		; 2c no need to clean up because no code here would executed...already exited!
		
	section .data

	  mymsg db "hello, world", 0xa  ; string with a carriage-return
	  mylen equ $-mymsg             ; string length in bytes

Assemble the above two source files:

	nasm -f macho sys.asm
	nasm -f macho hello.asm

Link the object files to produce the hello excutable:

	ld -o hello -e mystart hello.o sys.o

# exit the program
The above program use the exit system call explicitly. 
If you use gcc, this is not necessary. Because gcc compiler will link the code with libc,which contains the C start-up routine that is marked by the linker as the starting point for excution.
The C start-up routine then call this assemble code, and return control to C start-up routine.
Then the C start-up routine will use exit system call at the end.

> See Advanced Programming in the UNIX Environment chapter 7 for more information about the C start-up routine.

# Reference
- [mac-nasm] 

[mac-nasm]: 
http://peter.michaux.ca/articles/assembly-hello-world-for-os-x
