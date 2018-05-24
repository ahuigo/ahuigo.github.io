---
layout: page
title:
category: blog
description:
---
# Preface

# file

## hexdump
	hexdump file

## od
od 支持更丰富的格式化输出

	od -tx1 -tc -Ax file

	-t type
		[d|o|u|x][C|S|I|L|n]
			 Signed decimal (d), octal (o), unsigned decimal (u) or hexadecimal (x).  Followed by an optional size specifier, which may be either C (char), S (short), I (int), L (long), or a byte count as a decimal integer.

		c
			Characters in the default character set.  Non-printing characters are represented as 3-digit octal character codes
	-A base
		Specify the input address base.  base may be one of d, o, x or n, which specify decimal, octal, hexadecimal addresses or no address, respectively.


# I/O Redirection 重定向

	2>&1 # stderr>stdout
	&>err_out.txt # stderr and stdout

## tee 双向重导向
tee 用于将stdin的内容保存至文件， 再将其stdin 定向给下一个命令

	 cmd | tee file1 file2 |cmd
	 cmd | tee file >(cmd)
	 cmd | tee -a file |cmd
	 cmd | tee /dev/tty |cmd
	 cmd | tee /dev/stdout |cmd

	if true ; then
		cat <<- MM | sudo tee -a a.txt > /dev/null
		The leading tab is ignored.
		MM
	fi

	cat <<- MM >> a.txt
	The leading tab is ignored.
		MM

## pipe
管道(pipe)实现了将上一进程的stdout 重定向到下一进程的stdin.
很多命令可以通过加参数 "-" 支持pipe.

	cat file | expand -
	tar -cvf - /home | tar -xvf - #tar 将打包结果送到stdout, 这个stdout再通过管道送给tar解包.

### pipe with sub_process

	c=0
	cat <<-MM | while read; do ((c++)); done;
	a
	b
	MM
	echo $c

对于bash 来说，管道中的命令是在`sub process` 中执行的，`parent process`的`$c` 保持不变。
而zsh 的管道不会使用子进程。

### named pipe, 命名管道

	process1 > named_pipe
	process2 < named_pipe

表现出来就像这样：

	process1 | process2

创建named pipe:

	$ mkfifo pipe1
	$ ls -l pipe1
	prw-r--r-- 1 pipe1

在第一个终端中，将输出定向到管道，*命令会被挂起*, 因为在管道的另一端没有任何接受数据, `管道被阻塞了`：

	$ ls -l > pipe1

直到在第二个终端中，另一个进程读取些命名管理的输出端, 它就不再阻塞了：

	$ cat < pipe1

