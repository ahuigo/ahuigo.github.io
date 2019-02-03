---
layout: page
title:	linux系统IO
category: blog
description: 
---
# Preface
c语言的标准I/O操作实际上是调用的系统内核IO.

# 标准输出的低层实现
以汇编的hello world 为例

	.data					# section declaration
	msg:
		.ascii	"Hello, world!\n"	# our dear string
		len = . - msg			# length of our dear string = current pc_counter(.) - start address of msg
	.text	# section declaration
			# we must export the entry point to the ELF linker or
		.global _start	# loader. They conventionally recognize _start as their
				# entry point. Use ld -e foo to override the default.

	_start:
	# write our string to stdout
		movl	$len,%edx	# third argument: message length
		movl	$msg,%ecx	# second argument: pointer to message to write
		movl	$1,%ebx		# first argument: file handle (stdout)
		movl	$4,%eax		# system call number (sys_write)
		int	$0x80		# call kernel

	# and exit
		movl	$0,%ebx		# first argument: exit code
		movl	$1,%eax		# system call number (sys_exit)
		int	$0x80		# call kernel

以上汇编的.text 部分主要分两部分：

1. write部分：eax 中存的是系统调用号4(4 代表调用的是sys_write), 要传的三个参数分别是:ebx,ecx,edx. ebx中的1代表标准stdout
2. exit部分：调用的是eax=1(sys_exit), 退出码存放于ebx 

汇编相当于以下c代码：

	#include <unistd.h>
	char msg[14] = "Hello, world!\n";
	#define len 14

	int main(void) {
		write(1, msg, len);
		_exit(0);
	}

write函数是系统调用的包装函数，其内部实现就是把传进来的三个参数分别赋给ebx、ecx、edx寄存器，然后执行movl $4,%eax和int $0x80两条指令. 这个函数不是C代码实现的，它可能是用汇编或者c内联汇编写的。_exit函数也是如此。

# c标准I/O 与 Unbuffered I/O 函数

c标准I/O 调用的是系统函数，比如:

|标准IO | 系统调用|参数| 返回| 说明|
|fopen(3)| open(2)| file, mode|*FILE| 包括文件描述符,I/O缓冲区，当前位置|
|fgetc(3)| read(2) |* FILE	|char|从缓冲区读取一个字符，如果缓冲区没有，就调用read(2)刷新缓冲区|
|fputc(3)| write(2)|* FILE	|char|如果缓冲区未满，就直接存一个字符，否则就调用write(2)|
|fclose(3)|write(2), close(2)| * FILE| 如果I/O缓冲区中还有数据没写回文件，就调用write(2)写回文件，然后调用close(2)关闭文件，释放FILE结构体和I/O缓冲区。|

[库函数与系统调用的层次关系](http://akaedu.github.io/book/ch28s02.html)
![c-io](/img/c-io-sys.1.png)

open、read、write、close等系统函数称为无缓冲I/O（Unbuffered I/O）函数，因为它们位于C标准库的I/O缓冲区的底层. 两者有以下区别：

1. 系统I/O(Unbuffered I/O) 较慢：它每次调用都需要进内核，系统空间函数比用户空间函数要慢许多, 因为用户空间是主要是对内存(I/O缓存)做操作。
2. 系统I/O 自己管理缓冲区的话比较麻烦
3. C 标准I/O库函数要时刻注意 I/O 缓冲区与实际文件一致性，必要时要调用fflush(3)
4. 有的设备不需要buffer, 一般直接用Unbuffered I/O函数: 网络编程通常直接调用Unbuffered I/O函数。
5. Unbuffered I/O 函数(unistd.h)是UNIX 标准的一部分，而C 标准I/O(stdio.h) 是c 标准的一部分, C 标准是跨平台的。

## 关于UNIX 标准
POSIX（Portable Operating System Interface）是由IEEE制定的标准，致力于统一各种UNIX系统的接口:

- POSIX.1(IEEE 1003.1)标准定义了：UNIX系统的函数接口，及相关的c 标准库函数。
- POSIX.2(IEEE 1003.2)标准增加了定义：Shell的语法和各种基本命令的选项,帐号，管理等

*POSIX.1只定义接口而不定义实现*，所以并不区分一个函数是库函数还是系统调用，至于哪些函数在用户空间实现，哪些函数在内核中实现，由操作系统的开发者决定，各种UNIX系统都不太一样。

在UNIX的发展历史上主要分成*BSD和SYSV两个派系*，各自实现了很多不同的接口，比如BSD的网络编程接口是socket，而SYSV的网络编程接口是基于STREAMS的TLI。POSIX在统一接口的过程中，有些接口借鉴BSD的，有些接口借鉴SYSV的，还有些接口既不是来自BSD也不是来自SYSV，而是凭空发明出来的（例如一站式编程所提涉及的pthread库就属于这种情况），通过Man Page的COMFORMING TO部分可以看出来一个函数接口属于哪种情况。Linux的源代码是完全从头编写的，并不继承BSD或SYSV的源代码，没有历史的包袱，所以能比较好地遵照POSIX标准实现，既有BSD的特性也有SYSV的特性，此外还有一些Linux特有的特性，比如epoll(7)，依赖于这些接口的应用程序是不可移植的，但在Linux系统上运行效率很高。

*POSIX定义的接口有些规定是必须实现的，而另外一些是可以选择实现的*。有些非UNIX系统也实现了POSIX中必须实现的部分，那么也可以声称自己是POSIX兼容的，然而要想声称自己是UNIX，还必须要实现一部分在POSIX中规定为可选实现的接口，这由另外一个标准SUS（Single UNIX Specification）规定。SUS是POSIX的超集，一部分在POSIX中规定为可选实现的接口在SUS中规定为必须实现，完整实现了这些接口的系统称为XSI（X/Open System Interface）兼容的。SUS标准由The Open Group维护，该组织拥有UNIX的注册商标（http://www.unix.org/），XSI兼容的系统可以从该组织获得授权使用UNIX这个商标。

## 文件描述符
linux 中的进程由进程描述符(task_struct, Process Descriptor)描述。它有一个指针，指向文件描述表(files_struct, File Descriptor).
表中有一个指向已经打开文件的指针. 文件描述表中的索引(0,1,2..), 就是文件描述符是一个int

|专有的文件描述符(unistd.h)|对应的FILE 结构体(stdio.h)|
|#define STDIN_FILENO 0|stdin|
|#define STDOUT_FILENO 1|stdout|
|#define STDERR_FILENO 2|stderr|

### open(2) 创建一个文件描述符
当调用open 打开一个文件或创建一个新文件时，内核分配一个文件描述符并返回给用户程序，该文件描述符表项中的指针指向新打开的文件

### close(2) 删除一个文件描述符

# open & close

	#include <fcntl.h>
	
	int open(const char *pathname, int flags[, mode_t mode]);
	返回值：成功返回新分配的文件描述符fd，出错返回-1并设置errno
		flags
			O_RDONLY 只读打开(00)
			O_WRONLY 只写打开(01)
			O_RDWR 可读可写打开(10)
			//以下参数可以与或非, 
			O_APPEND (1000)表示追加。如果文件已有内容，这次打开文件所写的数据附加到文件的末尾而不覆盖原来的内容。
			O_CREAT 若此文件不存在则创建它。使用此选项时需要提供第三个参数mode，表示该文件的访问权限。
			O_EXCL 如果同时指定了O_CREAT，并且文件已存在，则出错返回。
			O_TRUNC 如果文件已存在，并且以只写或可读可写方式打开，则将其长度截断（Truncate）为0字节。
			O_NONBLOCK (100)对于设备文件，以O_NONBLOCK方式打开可以做非阻塞I/O（Nonblock I/O），非阻塞I/O在下一节详细讲解。
		mode
			文件权限，与umask 一起使用
		return:
			返回文件描述符，文件描述符是从0,1,2开始顺序增加的
		

	int close(int fd);
	返回值：成功返回0，出错返回-1并设置errno
	Note:
		当进程结束时，内核会自动关闭进程“忘记”关闭的td. 但是如果进程是长时运行的，若不手动关闭td, 也会耗用大量的系统资源

open函数与C标准I/O库的fopen函数有些细微的区别：	

- 以可写的方式fopen一个文件时，如果文件不存在会自动创建，而open一个文件时必须明确指定O_CREAT才会创建文件，否则文件不存在就出错返回。
- 以w或w+方式fopen一个文件时，如果文件已存在就截断为0字节，而open一个文件时必须明确指定O_TRUNC才会截断文件，否则直接在原来的数据上改写。

## mode 与 umask
open的mode参数和当前进程的umask掩码共同决定。
比如touch 进程创建文件的mode 为0666，而umask 为0022， 则文件的权限是: 0666 & ~022 = 0644

# read & write

## read
读数据时，读写位置自动后移size_t

	#include <unistd.h>
	ssize_t read(int fd, void *buf, size_t count);
	返回值：成功返回读取的字节数，出错返回-1并设置errno，如果在调read之前已到达文件末尾，则这次read返回0

*返回值可能小于 count*	
1. 读常规文件时，读取到文件末尾，
2. 当从终端设备读取到换行 
3. 从网络读，根据不同的传输层协议和内核缓存机制，返回值可能小于请求的字节数

*内核层为该文件记录了读取的位置*
read 与 c 标准IO中的读最大的差别就是，没有自己的buffer， 比如, fgetc 读取一个字节时：	
fgetc 可能是调用read 读了1024 个字节到c 标准库的buffer.FILE 结构体记录的文件位置是1，而该文件在内核中的读取位置却移动了1024字节

## write

	ssize_t write(int fd, const void *buf, size_t count);
	返回值：成功返回写入的字节数，出错返回-1并设置errno

返回值:	
1. 对于常规文件来说，返回值等于count
2. 对于设备和网络文件来说，可能小于count

## 阻塞(Block)
1. 读写常规文件不会阻塞
2. 读写设备(没有换行符 )或者网络文件(没有收发到数据包)时，会有阻塞

### 阻塞对进程的影响

#### 进程调用阻塞函数后会进入*sleep*	
当进程调用一个阻塞的系统函数时，该进程被置于睡眠（Sleep）状态. 此时内核可调试其它进程运行。
直到进程等待的事件发生了（比如网络收到数据包了，或者sleep 时间到了）.进程才恢复running 状态

处于*running*状态的进程有两种情况：

- 正在被调度：程序计数器eip 存放的是进程的指令地址
- 就绪状态：它并没有等待其它事件，随时都可以执行。只是cpu 的片时正用于其它进程，就绪队列轮到该进程时，它会被立即执行。

#### *读取设备文件缓冲区* 可能会对父进程产生影响。

	#include <unistd.h>
	#include <stdlib.h>
	int main(void) {
		char buf[10];
		int n;
		n = read(STDIN_FILENO, buf, 5);
		write(STDOUT_FILENO, buf, n);
		return 0;
	}

在shell 中编译以上代码并执行：
	
	$ ./a.out
	hello world<Enter>
	hello$ world
	bash: world: command not found

这是因为a.out 只读取了设备缓冲区的前5个字符"hello", a.out 结束后，其父进程shell 读取了剩下的" world"

### 强制不阻塞(轮询,Poll)
如果open 一个设备时指定O_NONBLOCK标志， read/write就不会阻塞。以read 为例，如果设备文件没有数据是，它会直接返回-1, 同时设置errno 为EWOULDBLOCK 或者EAGAIN(二者宏定义的值相同). 这表示读写该设备时，你应该用阻塞(Would Block 虚拟语气)， 或者再读一次(again). 

这种非阻塞的方式, 叫轮询：调用者只是读取一次，而不是阻塞死等：

	while(1) {
		非阻塞read(设备1);
		if(设备1有数据到达)
			处理数据;
		非阻塞read(设备2);
		if(设备2有数据到达)
			处理数据;
		...
		sleep(n);//以免做大量的无用功的查询(Tight Loop -> Light Loop)
	}

以非阻塞读取当前终端：

	#include <unistd.h>
	#include <fcntl.h>
	#include <errno.h>
	#include <string.h>
	#include <stdlib.h>
	#include <stdio.h>
	#define MSG_TRY "try again\n"
	
	int main(void) {
		char buf[10];
		int fd, n;
		fd = open("/dev/tty", O_RDONLY|O_NONBLOCK);
		if(fd<0) {
			perror("open /dev/tty");
			exit(1);
		}
	tryagain:
		n = read(fd, buf, 10);
		printf("n=%d\n", n);
		if (n < 0) {
			if (errno == EAGAIN) {
				sleep(1);
				write(STDOUT_FILENO, MSG_TRY, strlen(MSG_TRY));
				goto tryagain;
			}
			perror("read /dev/tty");
			exit(1);
		}
		write(STDOUT_FILENO, buf, n);
		close(fd);
		return 0;
	}

# lseek 设置读写位置
打开一个文件时，内核中为之记录一个读写位置0(APPEND 的初始位置是文件末尾)， 当读取或者写入了多少字节，这个位置就会往后移动多少字节。
一c 标准I/O 库中的fseek 一样，lseek 可以改变这个位置：

	#include <unistd.h>
	off_t lseek(int fd, off_t offset, int whence);
		whence
			SEEK_SET 从文件开头移动offset个字节
			SEEK_CUR 从当前位置移动offset个字节
			SEEK_END 从文件末尾移动offset个字节

偏移可以超过文件末尾，下一次写时，这中间的空白区域被置为0.

	off_t currpos;
	currpos = lseek(fd, 0, SEEK_CUR);
	

lseek 成功时 返回当前偏移, 失败是返回-1, 并且设置errno 为ESPIPE(该设备不支持偏移). 这与fseek 不同，成功是返回0， 失败时返回-1. 需要获取当前偏移时需要用ftell

# fcntl
> 配合阅读： https://mengkang.net/559.html

前面以read 为例介绍非阻塞I/O时，为何不直接使用STDIN_FILENO 而重新open 一下`/dev/tty` 呢？
因为我们需要通过open 指定O_NONBLOCK. 	

其实，可以通过fcntl 改变已经打开文件的访问控制属性(descriptor status flags)：读，写，追加，非阻塞...

	#include <unistd.h>
	#include <fcntl.h>
	int fcntl(int fd, int cmd);
	int fcntl(int fd, int cmd, long arg);
	int fcntl(int fd, int cmd, struct flock *lock);
		cmd
			F_GETFL 获取flags
			F_SGEFL 设置flags
			其它 设置锁

举几个例子：

	//获取当前文件打开属性
	int n;
	int flags;
	flags = fcntl(STDIN_FILENO, F_GETFL);

	//设置非阻塞
	flags |= O_NONBLOCK;
	if (fcntl(STDIN_FILENO, F_SETFL, flags) == -1) {
		perror("fcntl");
		exit(1);
	}

获取文件打开的属性：


	if ((val = fcntl(atoi(argv[1]), F_GETFL)) < 0) {
		printf("fcntl error for fd %d\n", atoi(argv[1]));
		exit(1);
	}
	//O_ACCMODE 值为0x03, 用于获取flag的低2位
	switch(val & O_ACCMODE) {
		case O_RDONLY://00
			printf("read only");
			break;
		case O_WRONLY://01
			printf("write only");
			break;
		case O_RDWR: //10 
			printf("read write");
			break;
		default:
			fputs("invalid access mode\n", stderr);
			exit(1);
	}
	if (val & O_APPEND) //0b1000 
		printf(", append");
	if (val & O_NONBLOCK)  //0b100         
		printf(", nonblocking");

测试：

	$ ./a.out 2 2>>temp.foo
	write only, append
	$ ./a.out 5 5<>temp.foo
	read write

也可以将标准输出、标准错误都重定向到空设备， 这样就看不到消息了。

	$ command > /dev/null 2>&1

# ioctl
fcntl 设置的*当前进程*如何访问设备或文件的访问控制属性，例如读、写、追加、非阻塞、加锁等	
而ioctl 设置的是*文件本身*的属性: 如文件的读写权限、串口波特率、检验位、终端大小等

	#include <sys/ioctl.h>
	int ioctl(int fd, int request, ...);
	//失败返回-1

ioctl 获取终端大小:

	#include <stdio.h>
	#include <stdlib.h>
	#include <unistd.h>
	#include <sys/ioctl.h>
	
	int main(void) {
		struct winsize size;
		if (isatty(STDOUT_FILENO) == 0)
			exit(1);
		if(ioctl(STDOUT_FILENO, TIOCGWINSZ, &size)<0) {
			perror("ioctl TIOCGWINSZ error");
			exit(1);
		}
		printf("%d rows, %d columns\n", size.ws_row, size.ws_col);
		return 0;
	}

# mmap 将文件与内存映射
mmap 将文件的一部分直接映射到内存. 内存与文件将实时互同步。

	#include <sys/mman.h>
	//如果mmap成功则返回映射首地址，如果出错则返回常数MAP_FAILED。当进程终止时，该进程的映射内存会自动解除，
	void *mmap(void *addr, size_t len, int prot, int flag, int filedes, off_t off);

	//也可以调用munmap解除映射。munmap成功返回0，出错返回-1。
	int munmap(void *addr, size_t len);

- addr	
如果addr参数为NULL，内核会自己在进程地址空间中选择合适的地址建立映射。如果addr不是NULL，则给内核一个提示，应该从什么地址开始映射，内核会选择addr之上的某个合适的地址开始映射。建立映射后，真正的映射首地址通过返回值可以得到。

- len参数是需要映射的那一部分文件的长度。off参数是从文件的什么位置开始映射，必须是页大小的整数倍（在32位体系统结构上通常是4K）。filedes是代表该文件的描述符。写数据时, 不能超过len, 也不能超出文件本身的大小。

- prot参数有四种取值：	

1. PROT_EXEC表示映射的这一段可执行，例如映射共享库
2. PROT_READ表示映射的这一段可读
3. PROT_WRITE表示映射的这一段可写(写文件时，即不能超过 len, 也不能超过文件本身的大小)
4. PROT_NONE表示映射的这一段不可访问

- flag参数有很多种取值, 用于确定内存是否共享：

1. MAP_SHARED多个进程对同一个文件的映射是共享的，一个进程对映射的内存做了修改，另一个进程也会看到这种变化。
2. MAP_PRIVATE多个进程对同一个文件的映射不是共享的，一个进程对映射的内存做了修改，另一个进程并不会看到这种变化，也不会真的写到文件中去。

> 共享库的代码就是通过mmap 映射到内存的代码区（PROT_EXEC）的. 可以通过`strace ./a.out` 观察到这个mmap 调用

示例：

	int *p;
	int fd = open("a.txt", O_RDWR);
	if (fd < 0) {
		perror("open hello");
		exit(1);
	}
	p = mmap(NULL, 6, PROT_WRITE, MAP_SHARED, fd, 0);
	if (p == MAP_FAILED) {
		perror("mmap");
		exit(1);
	}
	close(fd);
	p[0] = 0x30313233;//既使fd 被关闭了，a.txt 也能被改写为3210, 而且这个改写是实时的(unbuffered)
	munmap(p, 6);
	return 0;


# 参考
- [linux c io] linux c 一站式编程 by 宋劲杉

[linuc c io]: 
http://akaedu.github.io/book/
