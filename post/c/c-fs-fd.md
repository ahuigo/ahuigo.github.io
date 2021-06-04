---
layout: page
title:	linux 文件系统 描述符
category: blog
description:
---
# 文件描述符相关
# dup 和dup2 函数
两次open 同一个文件打开的是两个数据相同file 结构体.
dup(2)/dup2(2) 用于复制现存的文件描述符，使两个文件描述符指向同一个file 结构体。
file 结构中的f_count（引用计数）加1 变成2 ，其它信息如: File Status Flag，读写位置等都保持不变。

	#include <unistd.h>
	int dup(int oldfd);
        等价于：fcntl(fd, F_DUPFD, 0)
	int dup2(int oldfd, int newfd);//newfd 指向oldfd 指向的文件
        等价于：但是不是原子的
        close(newfd);
        fcntl(oldfd, F_DUPFD, newfd)
	//调用成功, 则返回新分配或者指定的文件描述符，失败则返回 -1

dup 返回的新文件描述符一定是该进程未使用的最小文件描述符，这一点和open类似。
dup2 可以用newfd参数指定新描述符的数值。
	如果newfd当前已经打开，则自动将其关闭再做dup2操作
	如果oldfd等于newfd，则dup2直接返回newfd而不用先关闭newfd 再复制

如果返回的值-1，就是错误, for details, refer to  `man dup2`

![](/img/linux-fs-dup.png)

	#include <unistd.h>
	#include <sys/stat.h>
	#include <fcntl.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	int main(void) {
		int fd, save_fd;
		char msg[] = "This is a test\n";

		fd = open("somefile", O_RDWR|O_CREAT, S_IRUSR|S_IWUSR);
		if(fd<0) {
			perror("open");
			exit(1);
		}
		save_fd = dup(STDOUT_FILENO);
		dup2(fd, STDOUT_FILENO);
		close(fd);
		write(STDOUT_FILENO, msg, strlen(msg));
		dup2(save_fd, STDOUT_FILENO);
		write(STDOUT_FILENO, msg, strlen(msg));
		close(save_fd);
		return 0;
	}

# fcntl
> 配合阅读： https://mengkang.net/559.html
fcntl有5个功能：

    1. 复制描述符 cmd=F_DUPFD
    1. 获取/设置描述符标志 cmd=F_GETFD/F_SETFD
    1. 获取/设置文件状态标志 cmd=F_GETFL/F_SETFL
    1. 获取/设置异步所有权 cmd=F_GETOWN/F_SETOWN
    1. 获取/设置锁 cmd=F_GETLK,F_SETLK/F_SETLKW

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
	// flags &= ~O_NONBLOCK; //清理标志
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

## /dev/fd
以下调用中

    fd = open("/dev/fd/0", mode) 会忽略 mode
    等价于
    fd=dup(0)

这样做是为了方便shell命令使用：

    echo abc | cat /dev/fd/0

# Reference
- [linux fs] by 宋劲杉

[linux fs]: http://akaedu.github.io/book/ch29.html
[ext4]: https://ext4.wiki.kernel.org/index.php/Ext4_Disk_Layout#Inline_Data
