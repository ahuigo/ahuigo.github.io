---
layout: page
title:	linux c tool
category: blog
description: 
---
# Preface
本文只简单罗列工具，具体请参考[](/p/c-debug)

# hex
查看二进制

	hexdump -C a.out

# disassemble

## objdump/gobjdump
objdump反汇编时可以把C代码(-S)和汇编代码穿插起来显示（前提时在编译程序时通过`gcc -g`将源码嵌入）

	//linux
	objdump -dS a.out
	//mac osx
	gobjdump -dS a.out
	
Mac osx 还可以用otool 代替，不过用法上会有很大区别

# nm
查看符号表
参考[](/p/as-elf)

	nm a.o

# readelf/greadelf
查看elf 文件(目标文件、共享库、可执行文件) 的section/symbol 表. 
参考[](/p/as-elf)

	readelf -aW a.out
		-W wide output
