---
layout: page
title:
category: blog
description:
---
# Preface

在标准I/O库中提供缓冲的主要目的就是减少系统函数read和write的调用，从而能够减少系统CPU时间。标准I/O库的缓冲主要分为3种：全缓冲、行缓冲和不缓冲。

# 1、全缓冲
全缓冲就是当输入或输出时，当缓冲区被填满了之后，才会进行实际的I/O操作。下面是一个将”hello world!“写入log.txt文件的程序，演示了这一个过程。log.txt是空文件，长度为0。

	#include <stdio.h>
	#include <stdlib.h>
	#include <errno.h>

	int main(void)
	{
	    FILE *stream;
	    if ((stream = fopen("./log.txt", "a")) == NULL) {
	        printf("error: %d\n", errno);
	        exit(1);
	    }

	    char buf[BUFSIZ];
	    setvbuf(stream, buf, _IOFBF,  BUFSIZ);
	    fputs("hello world!", stream);

	    sleep(20);

	    return 0;
	}

上例代码通过`setvbuf`函数设定stream流是全缓冲，`_IOFBF`表示`io full buffer`的意思，编译执行这个程序，然后立马查看log.txt文件：

	$ ls -l log.txt
	-rw-r--r-- 1 root root 0 Nov 20 22:40 log.txt

会发现文件的长度是0，直到睡眠结束后，字符” hello world!“才会写入到log.txt文件。

如果fputs了很多次后，长度还是小于BUFSIZ，但是需要将这些内容都实际写入文件，可以使用`fflush`函数。

	fflush(stream);

fflush函数根据指定的文件流将缓冲区的内容进行实际的操作，并清空缓冲区；如果参数为NULL，则会对所有打开的文件流操作。

# 2、行缓冲
当在输入或输出中遇到换行符时，才进行实际I/O操作。linux下标准输出默认是行缓冲，下面的例子使用标准输出演示这一个过程。

	#include <stdio.h>

	int main(void)
	{
	    fputs("hello", stdout);
	    sleep(2);
	    //这里一开始输出了换行符，所以前面的hello就被输出到屏幕上了。
	    fputs("\nworld", stdout);
	    sleep(2);

	    return 0;
	}

编译执行上面的程序，应当看到过两秒才会输出一个”hello“，再过两秒才输出”word“，然后程序就结束了。在C语言中，可以通过setvbuf来设定缓冲模式，其中_IOLBF表示行缓冲，就是IO line buffer的意思。

# 3、无缓冲
标准I/O库不进行任何字符缓冲，任何读写都是即时可见的。linux下标准错误输出默认是不缓冲，修改上面的例子：

	#include <stdio.h>

	int main(void)
	{
	    fputs("hello", stderr);
	    sleep(2);
	    fputs("world", stderr);
	    sleep(2);

	    return 0;
	}

编译执行上面的程序，结果就比较显而易见了。程序一执行的时候就会输出”hello“，过两秒输出”world“，再过两秒程序就结束了。在C语言中，可以通过setbuf来设定无缓冲模式，只要将第二个参数设置为NULL就可以了；也可以通过setvbuf来设定无缓冲模式，其中_IONBF表示行缓冲，就是IO not buffer的意思。
