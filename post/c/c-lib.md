---
layout: page
title:	c lib 库
category: blog
description:
---
# Preface
在[c 编译](/p/c-compile) 中我提到了c 的标准库，c标准库包括: header(.h 文件)头文件，和lib（.c）库文件。
大多数库函数在libc 中, 本笔记总结了常用的库函数：string, io, ...。

# String
头文件在string.h

	//Initial
	void *memset(void *s, int c, size_t n);//c 为填充的值

	//strlen
	size_t strlen(const char *s);

	//copy
	strcpy
	strncpy

	//memcopy
	void * memcpy(void *restrict dst, const void *restrict src, size_t n); //与strncpy 不同，memcpy copy 时，不会因"\0"而结束, 而是直到完成拷贝n 个字节为止。strncpy则是最多n个字符
	void *memmove(void *dest, const void *src, size_t n);//memmove 与 memcpy都是copy, 但memmove 通过中间的temp 实现 dest 与 src 可以重叠。

> restrict 是C99 关键字，表示指针指向的内存与其它指针的内存不能重叠。否则会出现意外写的情况

size_t 定义在 `#include <sys/_types/_size_t.h>` 里面

## toupper

	#include <ctype.h>
	char toupper(char);

## Concat

	char *strcat(char *dest, const char *src);
	char *strncat(char *dest, const char *src, size_t n);

## Compare

	int memcmp(const void *s1, const void *s2, size_t n);//不把'\0'作为结束符
	int strcmp(const char *s1, const char *s2);
	int strncmp(const char *s1, const char *s2, size_t n);
	//posix 标准
	int strcasecmp(const char *s1, const char *s2);
	int strncasecmp(const char *s1, const char *s2, size_t n);

## Search

	//search char
	char *strchr(const char *s, int c);
	char *strrchr(const char *s, int c);// 返回值：如果找到字符c，返回字符串s中指向字符c的指针，如果找不到就返回NUL
	//search str
	char *strstr(const char *haystack, const char *needle);

## Dup String
Allocates sufficient memory for a copy the string s1

	char * strdup(const char *s1);

## Split String
分割字符串时，string 会被改写: delimiter 会被替换成'\0'. Delimiter 可以是一个字符, 也可以是字符集, 比如":;"

	char *strtok(char *str, const char *delim);
	char *strtok_r(char *str, const char *delim, char **saveptr);
	//This interface is obsoleted by strsep(3).

使用strtok 内部静态变量记录下一个token 位置

	token = strtok(str, ":;");
	printf("%s\n", token);
	while ( (token = strtok(NULL, ":;")) != NULL)
		printf("%s\n", token);

strtok_r 使用外部的 *p 记录下一个token 位置

	char *p;
	token = strtok(str, ":;", &p);
	printf("%s\n", token);
	while ( (token = strtok_r(NULL, ":;", &p)) != NULL)
		printf("%s\n", token);

### strsep
strsep 用于将strtok/strtok_r 淘汰掉：

	char *strsep(char **stringp, const char *delim);
	//stringp 相当于saveptr. 返回token. delim 同样会被替换成'\0'

Example:

	char *token, *string, *tofree;

	tofree = string = strdup("abc,def,ghi");
	assert(string != NULL);
	while ((token = strsep(&string, ",")) != NULL)
		   printf("%s\n", token);
	free(tofree);

Man Page的BUGS部分指出了用strtok和strtok_r函数需要注意的问题(这两函数)

- 这两个函数要改写字符串以达到分割的效果 , 不能用于常量字符串，因为试图改写.rodata段会产生段错误 或者 bus error
- 在做了分割之后，字符串中的分隔符(delimiter)就被'\0'覆盖了
- strtok函数使用了静态变量，它不是线程安全的，必要时应该用可重入的strtok_r函数


## Bus Error
In many C compilers,  String literals are allocated in read-only memory.

 	char *str = "abc";
	str[0]='A';//bus error

String for string array are allocated in stack.

	char c[] = "abc";
	c[0]='A';//Ok

# IO 标准I/O库函数
标准I/O库函数的声明文件在stdio.h, 其中不仅定义了io函数, 还定义了相关的全局变量与常量

	#define EOF -1
	int errno;//全局

其中EOF(-1) 不是一个字符，在64位系统中一般为4字节的0xffffFFFF, 从文件中读取的任何一个字符都和它不等

## fopen & fclose

	//FILE 是被标准库所封装(encapsulation) 的结构体. 其基于内核层的文件描述符的fd(由open() 打开无缓冲io)
	FILE *fopen(const char *path, const char *mode);
		mode
			r read only(必须存在)
			w write only(不存在则创建，已经存在则截断（Truncate）为0字节)
			a append (不存在则创建)
			r+ rw (必須存在)
			w+ rw (不存在则创建)

			+ 含读写的意义，而r 要求文件必须存在，w a 则可以创建文件
	Return
	     Upon successful completion fopen(), fdopen(), and freopen() return a FILE pointer.  Otherwise, NULL is returned and the global variable errno is set to indicate the error.

fclose 返回值：成功返回0，出错返回EOF并设置errno

	int fclose(FILE *fp);

## read write io

	//by byte
	//出错或者读到文件末尾时返回EOF(EOF并不是一个字节, 而是0xffff ffff)
	int fgetc(FILE *stream);
	int getchar(void);//same as fgetc(stdin) 这个函数会阻塞进程。 从终端设备输入时有两种方法表示文件结束，一种方法是在一行的开头输入Ctrl-D，另一种方法是利用Shell的Heredoc语法


	int fputc(int c, FILE *stream);
	int putchar(int c);
	返回值：成功返回写入的字节，出错返回EOF

	//By string
	//以'\n' 或者 '\0' 或者size 结束
	char * fgets(char * restrict str, int size, FILE * restrict stream);

	//The functions fputs() and puts() return a nonnegative integer on success and EOF on error.
	int fputs(const char *restrict s, FILE *restrict stream);

return:

	Upon successful completion, it return a pointer to string.
	When end-of-file occurs before any characters are read, it returns NULL and buffer contents remain unchanged.
	When 'Ctrl-D' occurs, it returns NULL and buffer contents remain unchanged.

### 按记录读写
一个记录可以是结构体，也可以是数组...

nmemb是请求读或写的记录数，fread和fwrite返回的记录数有可能小于nmemb指定的记录数。例如当前读写位置距文件末尾只有一条记录的长度，调用fread时指定nmemb为2，则返回值为1。如果当前读写位置已经在文件末尾了，或者读文件时出错了，则fread返回0。如果写文件时出错了，则fwrite的返回值小于nmemb指定的值

	//by record
	size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
	size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
	返回值：读或写的记录数. 成功时返回的记录数等于nmemb，出错或读到文件末尾时返回的记录数小于nmemb，也可能返回0

示例:

	struct record array[2] = {{"Ken", 24}, {"Knuth", 28}};
	FILE *fp = fopen("recfile", "w");
	if (fp == NULL) {
		perror("Open file recfile");
		exit(1);
	}
	fwrite(array, sizeof(struct record), 2, fp);//写两条record 数据
	fclose(fp);

## 格式化I/O函数

### printf

	//to stdout
	int printf(const char *format, ...);
	//to file
	int fprintf(FILE *stream, const char *format, ...);
	//to str
	int sprintf(char *str, const char *format, ...);
	//to n str
	int snprintf(char *str, size_t size, const char *format, ...);

	int vprintf(const char *format, va_list ap);
	int vfprintf(FILE *stream, const char *format, va_list ap);
	int vsprintf(char *str, const char *format, va_list ap);
	int vsnprintf(char *str, size_t size, const char *format, va_list ap);

返回值：成功返回格式化输出的字节数（不包括字符串的结尾'\0'），出错返回一个负值

v打头的函数表示的可变参数不是以*...* 传入，而是以*va_list* 传入。实际上，所有可变参数都是通过函数栈传入的，v+ 函数只不过是将可变参数的基栈指针作形参传入，避免了可变参数压栈长度的不确定。可参考 [](/p/c-func-inf)

例子：

	#include <stdio.h>
	#include <stdlib.h>
	#include <errno.h>
	#include <stdarg.h>
	#include <string.h>
	err_sys("line: %d, error:%s \n", 36, "Bus Error");
	void err_sys(const char *fmt, ...) {
		int err = errno;
		#define MAXLINE 80
		char buf[MAXLINE+1];
		va_list ap;

		//ap 指下fmt 后面的参数
		va_start(ap, fmt);

		//传入参数的栈指针ap
		vsnprintf(buf, MAXLINE, fmt, ap);//以ap 栈指针代替...

		fputs(buf, stderr);
		va_end(ap);//没有什么用 (void)0
	}

#### printf转换说明的可选项

	|#	|8进前加0,16进制前加0x(或者0X) | printf("%#o", 077) 输出077 printf("%#X", 0xff) 输出0Xff 否则输出ff	|
	|-	|格式化后的内容居左，右边可以留空格。	|见下面的例子|
    |宽度	|用一个整数指定格式化后的最小长度，如果格式化后的内容没有这么长，可以在左边留空格，如果前面指定了-号就在右边留空格。宽度有一种特别的形式，不指定整数值而是写成一个*号，表示取一个int型参数作为宽度。	|printf("-%10s-", "hello")打印-␣␣␣␣␣hello-，printf("-%-*s-", 10, "hello")打印-hello␣␣␣␣␣-。|
	|.	|用于分隔上一条提到的最小长度和下一条要讲的精度。	|见下面的例子|
	|精度	|用一个整数表示精度，对于字符串来说指定了格式化后保留的最大长度，对于浮点数来说指定了格式化后小数点右边的位数，对于整数来说指定了格式化后的最小位数。精度也可以不指定整数值而是写成一个*号，表示取下一个int型参数作为精度。	|printf("%.4s", "hello")打印hell，printf("-%6.4d-", 100)打印-␣␣0100-，printf("-%*.*f-", 8, 4, 3.14)打印-␣␣3.1400-。|
	|字长	|对于整型参数，hh、h、l、ll分别表示是char、short、long、long long型的字长，至于是有符号数还是无符号数则取决于转换字符；对于浮点型参数，L表示long double型的字长。	|printf("%hhd", 255)打印-1。|

转换字符:

	|转换字符	|描述	|举例|
	|d i	|取int型参数格式化成有符号十进制表示，如果格式化后的位数小于指定的精度，就在左边补0。	|printf("%.4d", 100)打印0100。|
	|o u x X	|取unsigned int型参数格式化成无符号八进制（o）、十进制（u）、十六进制（x或X）表示，x表示十六进制数字用小写abcdef，X表示十六进制数字用大写ABCDEF，如果格式化后的位数小于指定的精度，就在左边补0。	|printf("%#X", 0xdeadbeef)打印0XDEADBEEF，printf("%hhu", -1)打印255。|
	|c	|取int型参数转换成unsigned char型，格式化成对应的ASCII码字符。	|printf("%c", 256+'A')打印A。|
	|s	|取const char *型参数所指向的字符串格式化输出，遇到'\0'结束，或者达到指定的最大长度（精度）结束。	|printf("%.4s", "hello")打印hell。|
	|p	|取void *型参数格式化成十六进制表示。相当于%#x。	printf("%p", main)打印main函数的首地址0x80483c4。|
	|f	|取double型参数格式化成[-]ddd.ddd这样的格式，小数点后的默认精度是6位。	|printf("%f", 3.14)打印3.140000，printf("%f", 0.00000314)打印0.000003。|
	|e E|取double型参数格式化成[-]d.ddde±dd（转换字符是e）或[-]d.dddE±dd（转换字符是E）这样的格式，小数点后的默认精度是6位，指数至少是两位。	|printf("%e", 3.14)打印3.140000e+00。|
	|g G|取double型参数格式化，精度是指有效数字而非小数点后的数字，默认精度是6。如果指数小于-4或大于等于精度就按%e（转换字符是g）或%E（转换字符是G）格式化，否则按%f格式化。小数部分的末尾0去掉，如果没有小数部分，小数点也去掉。	|printf("%g", 3.00)打印3，printf("%g", 0.00001234567)打印1.23457e-05。|
	|% |格式化成一个%。	|printf("%%")打印一个%。|

使用`+-*/` 时

	long double %lf > double %f > float %f > long long %lld > long %ld >int %d > short %d > char %c

### scanf

	#include <stdio.h>
	int scanf(const char *format, ...); //from stdin
	int fscanf(FILE *stream, const char *format, ...);  //from file
	int sscanf(const char *str, const char *format, ...);   //from string

    scanf("id=%d", &id)

	#include <stdarg.h>
	int vscanf(const char *format, va_list ap);
	int vsscanf(const char *str, const char *format, va_list ap);
	int vfscanf(FILE *stream, const char *format, va_list ap);
	返回值：返回成功匹配和赋值的参数个数，成功匹配的参数可能少于所提供的赋值参数，返回0表示一个都不匹配，出错或者读到文件或字符串末尾时返回EOF并设置errno

	sscanf(str, "%d %s %d", &day, monthname, &year);

转换说明中的可选项有：

- *号，表示这个转换说明只是用来匹配一段输入字符，但匹配结果并不赋给后面的参数。

	scanf("%*d %d", &i);//跳过第一个数字

- 用一个整数指定的宽度N。表示这个转换说明最多匹配N个输入字符，或者匹配到输入字符中的下一个空白字符结束。
- 对于整型参数可以指定字长，有hh、h、l、ll（也可以写成一个L），含义和printf相同。但l和L还有一层含义，当转换字符是e、f、g时，表示赋值参数的类型是float *而非double *.

## seek
操作读写位置的函数

	int fseek(FILE *stream, long offset, int whence);
	返回值：成功返回0，出错返回-1并设置errno
		whence
			SEEK_SET 从文件开头移动offset个字节
			SEEK_CUR 从当前位置移动offset个字节
			SEEK_END 从文件末尾移动offset个字节

	long ftell(FILE *stream);
	返回值：成功返回当前读写位置，出错返回-1并设置errno

	void rewind(FILE *stream);

## stdin/stdout/stderr
linux 中的设备也是文件，字符设备文件如:

	crw-rw-rw-  1 root  wheel    2,   0 Oct  3 23:35 /dev/tty

2 是主设备号，标识内核中的一个驱动程序；0 是次设备号，标识设备驱动程序所管理的一个设备。

程序执行后会打开三个设备文件指针(FILE *)：stdin/stdout/stderr. 这三个指针是libc定义的全局变量。

> 之所以把stdout 与 stderr 分开是为了方便重定向

## errno/perror
errno 是定义在libc 中的全局变量, 在errno.h 中声明。
而perror 是用于打印错误信息的：

    //The perror() function finds the error message corresponding to the current value of the global variable errno (intro(2)) and writes it, followed by a newline, to the standard error file descriptor.
	void perror(const char *s);

	perror("Failed to open file a.txt!");

返回错误码errno 所对应的字符串

	#include <string.h>
	char *strerror(int errnum);

	fputs(strerror(errno), stderr);

# IO buffer
一般地，用户调用c 标准的io 函数时，读写的是标准库的io buffer 区，当buffer满了后，会触发内核系统调用 flush操作，将io buffer 数据写回硬盘。

![io buffer](/img/io-buffer.png)

有时，用户也可以直接调用库函数fflush 或者fclose 直接将数据写回磁盘。

C标准库的I/O缓冲区有三种类型：全缓冲、行缓冲和无缓冲。当用户程序调用库函数做写操作时，不同类型的缓冲区具有不同的特性。

全缓冲
	如果缓冲区写满了就写回内核。常规文件通常是全缓冲的。

行缓冲
	如果用户程序写的数据中有换行符就把这一行写回内核，或者如果缓冲区写满了就写回内核。标准输入和标准输出对应终端设备时通常是行缓冲的。
	( 这些特性取决于终端的工作模式，终端可以配置成一次一行的模式，也可以配置成一次一个字符的模式，默认是一次一行的模式，关于终端的配置可参考[APUE2e](http://akaedu.github.io/book/bi01.html#bibli.apue))

	比如 printf("hello world"); 不会立即打印到屏幕

无缓冲
	用户程序每次调库函数做写操作都要通过系统调用写回内核。标准错误输出通常是无缓冲的，这样用户程序产生的错误信息可以尽快输出到设备。

## 行缓冲例子
main 函数的执行是从 exit(main(argc, argv)); 开始的。exit函数首先关闭所有尚未关闭的FILE *指针（关闭之前要做Flush操作），然后通过_exit系统调用进入内核退出当前进程。但是Ctrl + C 时，exit 不会被执行。
下面的代码运行时，因为stdout 是行缓冲的，而且按ctrl+c 退出进没有flush 操作，所以屏幕不会有任何输出。

	int main() {
		printf("hello world");
		while(1);
		return 0;
	}

如果把 `return 0` 改成`exit(0)`（不是`_exit(0)`）, 就会触发flush ,使得屏幕显示出"hello world"

除了写满缓冲区、写入换行符之外，行缓冲还有一种情况会自动做Flush操作。如果：
- 用户程序调用库函数`从无缓冲的文件中读取`
- 或者`从行缓冲的文件中读取`，并且这次读操作会引发系统调用从内核读取数据

那么在读取之前会自动Flush所有行缓冲。

### 手动flush
可以调fflush函数手动做Flush操作。

	int fflush(FILE *stream);//fflush(stdout);

> Note: fflush(NULL)可以对所有打开文件的I/O缓冲区做Flush操作

# time
time 的头文件在time.h

	//get time_t
	time_t time(struct time_t *timeptr);
	time_t timep; time(&timep);

	//get tm via time_t
	struct tm * gmtime(const time_t *clock);
	struct tm * gmtime_r(const time_t *clock, struct tm *result);
	//get local tm via time_t
	struct tm * localtime(const time_t *clock);
	struct tm * localtime_r(const time_t *clock, struct tm *result);

	//get time_t(local) via tm
	time_t mktime(struct tm *timeptr);
	time_t timegm(struct tm *timeptr);

	//get char(local) via time_t
	char * ctime(const time_t *clock);
	char * ctime_r(const time_t *clock, char *buf);

	//get char via tm
	char * asctime(const struct tm *timeptr);
	char * asctime_r(const struct tm *restrict timeptr, char *restrict buf);

	double difftime(time_t time1, time_t time0);

    printf("%s", asctime(gmtime(&timep)));
    printf("%s", ctime(&timep));

Example:

	time_t t;
	time(&t);
	printf("%s\n", ctime(&t));

`man ctime` for tm structure. The tm structure includes at least the following fields:

	int tm_sec;     /* seconds (0 - 60) */
	int tm_min;     /* minutes (0 - 59) */
	int tm_hour;    /* hours (0 - 23) */
	int tm_mday;    /* day of month (1 - 31) */
	int tm_mon;     /* month of year (0 - 11) */
	int tm_year;    /* year - 1900 */
	int tm_wday;    /* day of week (Sunday = 0) */
	int tm_yday;    /* day of year (0 - 365) */
	int tm_isdst;   /* is summer time in effect? */
	char *tm_zone;  /* abbreviation of timezone name */
	long tm_gmtoff; /* offset from UTC in seconds */

## timezone

	#include <stdlib.h>
	//putenv("TZ=PST8PDT");
    setenv("TZ", "Asia/Shanghai", 1);
	tzset();//if not Initial

时区文件在:

- /usr/share/zoneinfo/
- /usr/share/zoneinfo/Asia/Shanghai
- /usr/share/zoneinfo/PST8PDT

[timezone](http://php.net/manual/en/timezones.asia.php)

## sleep

   #include <unistd.h>
   unsigned int sleep(unsigned int seconds);

# number

## str2num
不设置errno 信息, 如果返回0，表示转换失败 或者数值本身就是0：

	#include <stdlib.h>
	int atoi(const char *nptr);
	double atof(const char *nptr);

	eg. printf("%f\n", atof("1.3e8"));

设置errno 信息，加强版的atoi/atof, 转换失败时，同样返回0

	long int strtol(const char *nptr, char **endptr, int base);//支持"0xff"和base
	double strtod(const char *nptr, char **endptr);

strol 可识别：

1. strtol("0x0f", NULL, 16);//15 必须指定base=16
1. endptr 指向最后一个未被识别的字符
1. 如果数值溢出，errno为ERANGE，

## rand

	int rand(void);//generate integer range from [0, RAND_MAX)
	//rand, srand is obsoleted by arc4random
	#define ARC4RANDOM_MAX      0x100000000
	((double)arc4random() / ARC4RANDOM_MAX);


# Memory

## malloc与free
在函数调用过程中，可以申请获得可变长数组(VLA, Variable Length Array). 但是这个数组是栈上的，不是全局数组。
其实，c 标准库中malloc 可以通过brk 系统向操作系统申请堆空间的内存，内存不用时通过free 释放(其实还是通过malloc) ，malloc 可以将内存用于下次分配。

	void *malloc(size_t size);//return NULL when error
	void free(void *ptr);

堆空间的本质是 以block 构成的链表结构, 包括以下操作：extend_block(上移break 并分配新的block), split_block(将多余空间生成block), find_block(查找满足size的free block) ... 具体可参考[如何实现malloc]

> 申请内存后要记得free, 否则容易出现内存泄漏(Memory Leak )

	void *calloc(size_t nmemb, size_t size);//size*nmemb 且初始化为0
	void *realloc(void *ptr, size_t size);//变更申请到的空间大小，同时保留数据;
	//1. realloc(ptr, 0)，ptr不是NULL，则相当于调用free(ptr)。
	//2. realloc(NULL, size)，则相当于调用malloc(size)，
	返回值：成功返回所分配内存空间的首地址，出错返回NULL


## bzero/memset
清0:

	bzero(&servaddr, sizeof(servaddr));
	memset(&un, 0, sizeof(un));

# Time
	time_t time();//unix time
	localtime()

# Reference
- [如何实现malloc]
- [linux c] linux c 一站式编程 by 宋劲杉

[linuc c]: http://akaedu.github.io/book/
[如何实现malloc]: http://blog.codinglabs.org/articles/a-malloc-tutorial.html
