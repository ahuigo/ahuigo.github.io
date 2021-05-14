---
layout: page
title:	c string
category: blog
description:
---
# String
## Define String
Const String Array

	char *str = "Hello";//只有两个字符'He'，不包含'\0' (const char * 常量数组)

String Array

	char str[10] = "Hello";
	char str[] = "Hello";//包含'\0' 有6个字符
	char str[2] = "Hello";//只有两个字符'He'，不包含'\0'
	char days[8][10] = { "Monday", "Tuesday", "Wednesday", "Thursday", "Saturday", "Sunday" };

### Bus Error
In many C compilers,  String literals are allocated in read-only memory.

 	char *str = "abc";
	str[0]='A';//bus error

String for string array are allocated in stack.

	char c[] = "abc";
	c[0]='A';//Ok


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
