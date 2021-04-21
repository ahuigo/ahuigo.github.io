---
layout: page
title:	linux c socket 编程
category: blog
description:
---
# Preface
Socket 可以有很多概念：

1. 在TCP/IP 中,"IP + TCP或UDP端口号" 唯一标识网络通讯中的*进程*，"IP+端口号"就被称为socket
2. 在TCP 协议中，建立连接的两个进程各有一个socket 标识，这两个*socket pair* 唯一标识一个*连接*。(socket 有插座的意识，常用来描述网络连接的一对一关系)
4. TCP/IP 最早在BSD UNIX 上实现，为TCP/IP 协议设计的应用层编程接口称为*socket API*

本文重点介绍socket API, 主要包括TCP 协议的函数接口、简要介绍基于UDP 协议和UNIX domain Socket 的函数接口。

# 预备

## 网络字节序

内存中多字节数据存储有大小端之分, TCP/IP 协议规定数据流采用大端字节序(低地址高字节)：比如16位UDP 端口号0x03e8, 低地址放0x03, 高地址放0xe8. 发送时会先发0x03, 再发0xe8.

- 小端序(little-endian), 如果0xABCD 存在地址0x100中，则0x100 存放0xCD, 0x101 中存放0xAB. (加法好加！低地址低字节)
- 大端序(big-endian), 如果0xABCD 存在地址0x100中，则0x100 存放0xAB, 0x101 中存放0xCD(低地址高字节, 大端序更容易阅读).

网络字节序(Network Byte Order)使用大端序(big-endian byte order)
主机字节序(Machine/Host Byte Order): 一般是小端序(littel-endian byte order), 但也有大端序。 如果发送到主机缓冲区的数据还是小端字节序，就需要字节序转换大端序。

为了使网络程序具有可移植性，大小端计算机上编译后都可以正常运行, 可以为以下库函数作字节序转换:

	#include <arpa/inet.h>
	//convert values between host byte order and network byte order(both binary)
	uint32_t htonl(uint32_t hostlong);
	uint16_t htons(uint16_t hostshort);
	uint32_t ntohl(uint32_t netlong);
	uint16_t ntohs(uint16_t netshort);

h表示host n表示network l表示32位整数 s 表示16位整数. htonl 可以将32位的主机字节序转为网络字节序。如果主机使用大端字节序，这些参数会原样返回。

Example:

	b=0x0102;
	a=htonl(b);
	(lldb) x/4xb &b
	0x7fff5fbffb78: 0x02 0x01 0x00 0x00 (小端序)
	(lldb) x/4xb &a
	0x7fff5fbffb7c: 0x00 0x00 0x01 0x02 (大端序)

## socket地址的数据类型(sockaddr)和相关函数
socket API 是一层抽象的网络编程接口，适用于各类低层网络协议，如：IPv4、IPv6、UNIX Domain Socket。然而各种网络协议的地址格式不同：

	struct sockaddr   {
		16 位地址类型;
		14 字节地址数据;
	}

sockaddr_in 定义在`netinet/in.h`:

	/*
	 * Socket address, internet style.
	 */
	struct sockaddr_in {
		__uint8_t	sin_len;
		sa_family_t	sin_family;	//8bit AF_INET(ipv4), AF_INET6(ipv6), AF_UNIX
		in_port_t	sin_port;	//16bit htons(80)
		struct	in_addr sin_addr;//32bit sin_addr.s_addr=htonl(INADDR_ANY=0)
		char		sin_zero[8];
	};
	struct in_addr {
		in_addr_t s_addr; //htonl(INADDR_ANY = 0x00000000)
	};
	typedef	__uint32_t	in_addr_t;	/* base type for internet address */

	/*in sys/un.h*/
	struct sockaddr_un{
		16 位地址类型AF_UNIX;
		108字节路径名;
	}

![](/img/linux-c-socket-socketaddr.png)

*关于定义*

- IPv4 和IPv6 地址格式定义在netinet/in.h; IPv4 用sockaddr_in 结构体表示16位端口和32位ip; IPv6 用sockaddr_in6 表示16位端口和128位IP及一些控制字段。
- UNIX Domain Socket 地址格式定义在sys/un.h, 用socket_un 结构体表示
- 各socket 地址结构体的开头是相同的，前16位表示整个结构体的长度（并不是所有UNIX 实现都有长度，linux 就没有）,后16位表示地址类型。
- IPv4、IPv6、UNIX Domain Socket 的地址类型(sin_family)分别定义为常数AF_INET、AF_INET6、AF_UNIX. 因为可以通过地址类型区分结构体，所以socket API 接受各种类型的sockaddr, 例如bind/accept/connect, 这些函数的参数应该设计成void *. 但因为scoket API 早于ANSI C标准，所以这些参数用struct sockaddr * 表示, 在传递参数之前要强制转换一下：

	struct sockaddr_in servaddr;
	bind(listen_fd, (struct sockaddr *)&servaddr, sizeof(servaddr));

`sockaddr` 初始化:

	struct sockaddr_in servaddr;
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);// INADDR_ANY 这个宏表示本地任意一个ip
	servaddr.sin_port = htons(SERV_PORT)

> *bzero*, 用于变量清0

## IP 地址转换
本文只关注IPv4 的IP 地址，sockaddr_in中的成员struct in_addr 表示32位的IP地址
我们常用的点分十进制IP 地址表示(dotted-and-decimal notation) 与 二进制ip (struct in_addr) 转换函数：

	#include <arpa/inet.h>
	//It returns binary ip. Use of this function is problematic because -1 a valid address(255.255.255.255). Avoid its use is in favor of inet_aton(), inet_pton(3) or getaddrinfo(3), which provide a cleared way to indicate error return.
	in_addr_t
		inet_addr(const char *strptr);

	/*Convert an addr (struct * in_addr) between network format and presentation format! (With malloc)*/
	int
		inet_aton(const char *strptr, struct in_addr *addrptr);
	char *
		inet_ntoa(struct in_addr inaddr);//network to address

	/*Convert an addr (struct * in_addr) between network format and presentation format! (Without malloc, with IPV6 support)*/
	int
		inet_pton(int af, const char *strptr, void *addrptr);
	const char *
		inet_ntop(int af, const void * restrict src, char * restrict dst, socklen_t size);

	af:
		AF_INET
		AF_INET6
	size:
		防止dst 溢出

其中inet_pton 和 inet_ntop 不仅支持IPv4 的in_addr 也支持IPv6 的inet6_addr, 因些其参数类型是void * addrptr.

1. ip = network address + host address
2. byte order: host byte order, network  byte order

Example1:

	//Same as: inet_aton("192.168.0.1", &addr.sin_addr); It only support AF_INET , not support AF_INET6/AF_UNIX
	inet_pton(AF_INET, "192.168.0.1", &addr.sin_addr);

	//Same as: str = inet_ntoa(addr.sin_addr);
	inet_ntop(AF_INET, &addr.sin_addr, str, sizeof(str));

Example2: (p:点分ip, h: binary ip n:in_addr_t in_addr sockaddr_in):

	//create servaddr
	bzero(&servaddr, sizeof(servaddr));
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
		inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);
	servaddr.sin_port = htons(SERV_PORT);

	//output servaddr
   	inet_ntop(AF_INET, &servaddr.sin_addr, str, sizeof(str));//string
	ntohs(servaddr.sin_port));//int

# 基于TCP 的网络程序
基于TCP 协议的客户端/服务端程序的一般流程是：
![](/img/linux-c-socket-tcp-flow.png)

连接:
1. 调用socket(), bind(), listen() 完成初始化, 调用accept()阻塞等待，处于监听端口的状态
2. 客户端调用socket()初始化后，调用connect() 发出SYN段并阻塞等待服务器应答，服务器应答一个SYN-ACK 段，客户端才从connect 返回，同时应答一个ACK 段
3. 服务器端收到ACK 段后从accept() 返回

数据传输
连接建立后，TCP 协议提供全双工的通信服务，但一般是客户端主动发起请求 服务端被动处理请求。
1. 因此服务端从accept 返回后就立刻*调用read()*, 读socket 就像是读管道一样，如果没有数据到达就阻塞等待
2. 客户端调用*write()* 发送请求给服务端，服务端收到后从read() 返回, 然后对客户端的请求进行处理
3. 此时客户端调用read() 阻塞等待服务应答，直到服务端调用write() 将处理结果返回客户端. 然后调用read() 阻塞等待下一条请求。
4. 客户端收到响应后从read() 返回，发用write() 发送下一条请求，如此循环下去

关闭连接的过程：
1. 客户端没有更多请求时，就调用close() 关闭连接，就像是写端关闭的管道一样；服务端的read()返回0，服务端就知道客户端关闭的连接
2. 服务端也调用close() 关闭连接。Note: 任何一方调用close()，另一方就会调用close() 关闭连接, 连接的两个方向都会关闭，不能再互发数据了。如果一方调用shutdown() 则会处于半连接的状态，还可接收对方发送的数据。

*应用层和TCP 协议是如何交互的？*
1. 应用程序调用某个socket 函数时TCP 协议层是完成什么动作: 比如调用connect 会发送SYN 段
2. 应用层如何知道TCP 层协议的状态变化, 比如从某个socket 函数返回就表明TCP 收到了某些段，比如read() 返回0 表明收到了FIN 段。

## 简单的TCP 网络程序

### server 端
以下socket API 实现了 server 从client 读取字符的功能：

	/* server.c */
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <ctype.h>

	#define MAXLINE 80
	#define SERV_PORT 8000

	void perr_exit(const char *s){
		perror(s);
		exit(1);
	}
	void Bind(int fd, const struct sockaddr *sa, socklen_t salen){
		if(bind(fd, sa, salen)<0){
			perr_exit("Bind error");
		}
	}
	int main(void) {
		struct sockaddr_in servaddr, cliaddr;
		socklen_t cliaddr_len;
		int listenfd, connfd;
		char buf[MAXLINE];
		char str[INET_ADDRSTRLEN];
		int i, n;

		listenfd = socket(AF_INET, SOCK_STREAM, 0);

		bzero(&servaddr, sizeof(servaddr));
		servaddr.sin_family = AF_INET;
		servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
		servaddr.sin_port = htons(SERV_PORT);

		Bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));

		listen(listenfd, 20);

		printf("Accepting connections ...\n");
		while (1) {
			cliaddr_len = sizeof(cliaddr);
			connfd = accept(listenfd,
					(struct sockaddr *)&cliaddr, &cliaddr_len);

			n = read(connfd, buf, MAXLINE);
			printf("received from %s at PORT %d\n",
			       inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)),
			       ntohs(cliaddr.sin_port));

			for (i = 0; i < n; i++)
				buf[i] = toupper(buf[i]);
			write(connfd, buf, n);
			close(connfd);
		}
	}

以上程序用最的主要函数是:

*socket* 用于打开一个网络通讯端口，成功的话会返回文件描述符, 出错则返回-1：

	#include <sys/socket.h>
	int socket(int family, int type, int protocol);
	params:
		family: 和网络协议相关
			AF_INET AF_INET6 AF_UNIX
		type: 和传输协议相关
			SOCK_STREAM(面向数据流, eg. TCP)
			SOCK_DGRAM(面向数据报, eg. UDP)
		protocol:
			介绍从略，指定为0即可。

*sockaddr_in* servaddr 用于确定ip/port/family(同协议相关), *bzero*, 用于变量清0

	/*
	 * Socket address, internet style.
	 */
	struct sockaddr_in {
		__uint8_t	sin_len;
		sa_family_t	sin_family;//8bit
		in_port_t	sin_port;// htons(SERV_PORT);
		struct	in_addr sin_addr;//sin_addr.s_addr = htonl(INADDR_ANY); 表示任意ip
		char		sin_zero[8];
	};
	bzero(&servaddr, sizeof(servaddr));


*bind* 用于监听网络地址和端口，客户端通过网络地址和端口向服务器发起连接。
bind 会将listenfd 和 sockaddr 绑定在一起, 使得listen_fd 这个网络文件描述符能监听 sockaddr 中所指定的ip/port. sockaddr 是一个通用结构体，所以还需要指定结构体的大小。

服务器本地IP可以有多个（多个网上的情况）, 所以用INADDR_ANY 表示任意的本地IP, 直到接收到客户端的请求，才确定使用哪个IP

	int bind(int sockfd, const struct sockaddr *myaddr, socklen_t addrlen);

*listen* 用于声明sockfd 处于监听状态
用于确定等待连接队列数量backlog，如果队列已经满了新的客户端请求会被直接忽略，否则尚未accept 的连接(已经经过3次握手)会被加入到请求队列并保持连接状态(established). 成功返回0，错误返回-1

	int listen(int sockfd, int backlog);

*accept* 用于读取连接队列中的请求，如果没有请求，就阻塞等待直到客户端有连接请求。
它有一个传入传出参数(value-result argument): cliaddr, addrlen

	int accept(int sockfd, struct sockaddr *cliaddr, socklen_t *addrlen);
	params:
		cliaddr: 传出客户端地址信息,可以传NULL
		addrlen: 传入客户端地址结构体的长度，防止缓冲区溢出；传出地址长度，它可能小于调用者提供的cliaddr 本身的长度。
	return:
		返回一个数据文件描述符connfd, client 与 server 就通过connd 传输数据.

服务器结构一般是这样的死循环，每一次接受一个connfd, 然后通过它传输数据，最后关闭connfd 连接，而不关闭监听文件描述符listenfd(accept 接手连接后，listenfd 就和连接没有关系了)

	while (1) {
		cliaddr_len = sizeof(cliaddr);
		connfd = accept(listenfd,
				(struct sockaddr *)&cliaddr, &cliaddr_len);
		n = read(connfd, buf, MAXLINE);
		...
		close(connfd);
	}

### client 端

	/* client.c */
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <sys/socket.h>
	#include <netinet/in.h>

	#define MAXLINE 80
	#define SERV_PORT 8000

	int main(int argc, char *argv[]) {
		struct sockaddr_in servaddr;
		char buf[MAXLINE];
		int sockfd, n;
		char *str;

		if (argc != 2) {
			fputs("usage: ./client message\n", stderr);
			exit(1);
		}
		str = argv[1];

		sockfd = socket(AF_INET, SOCK_STREAM, 0);

		bzero(&servaddr, sizeof(servaddr));
		servaddr.sin_family = AF_INET;
		inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);
		servaddr.sin_port = htons(SERV_PORT);

		connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr));

		write(sockfd, str, strlen(str));

		n = read(sockfd, buf, MAXLINE);
		printf("Response from server:\n");
		write(STDOUT_FILENO, buf, n);

		close(sockfd);
		return 0;
	}

客户端不需要bind 设定监听地址(系统会自动分配)，也不需要listen 启动监听并设定队列长度(系统分配), 也不需要用accept 接受并处理一个连接(因为它自己就是发起方).
只需要用connect 连接服务器地址，并处理数据(write, read)：

	int connect(int sockfd, const struct sockaddr *servaddr, socklen_t addrlen);
	return:
		-1
			errno = EINTR interrupted by signal
			errno = ECONNABORTED
		0 success

开启服务端：

	./server

查看netstat :

	$ netstat -anp tcp | grep 8000
	tcp4       0      0  *.8000                 *.*                    LISTEN

可以看到server程序监听8000端口，IP地址还没确定下来。现在编译运行客户端：

	$ ./client abcd
	Response from server:
	ABCD

再看看服务端:

	$ ./server
	 Accepting connections ...
	 received from 127.0.0.1 at PORT 59757

在client 中的`write`前加一个`sleep(10)`, 再查看网络：

	$ netstat -apn|grep 8000
	tcp        0      0 0.0.0.0:8000            0.0.0.0:*               LISTEN     8343/server(listenfd)
	tcp        0      0 127.0.0.1:44406         127.0.0.1:8000          ESTABLISHED8344/client
	tcp        0      0 127.0.0.1:8000          127.0.0.1:44406         ESTABLISHED8343/server(connfd)

在client 中的`write`后加一个`sleep(10)`, 再查看网络时，你会发现server 主动断开连接了(FIN_WAIT2), 还客户端还没有关闭(CLOSE_WAIT)：

	$ netstat -anp tcp | grep 8000
	tcp4       0      0  127.0.0.1.8000         127.0.0.1.64355        FIN_WAIT_2
	tcp4       3      0  127.0.0.1.64355        127.0.0.1.8000         CLOSE_WAIT
	tcp4       0      0  *.8000                 *.*                    LISTEN

## 错误处理与读写控制

### retry 重试
系统调用accept/read/write(阻塞的情况下) 被中断后应该重试(此系统调用被中断后会被丢弃，不会回到原来的地方继续执行).
Note: connect 也会被阻塞, 但是被中断后不能立刻重试, 否则不断的连接会加重服务器的负担

- EINTR : The *system call* was interrupted by a signal that was caught before a valid connection arrived.

RST 复位：当服务端和客户端经过3次握手后，二者都进入ESTABLISHED 状态. 如果*服务端accept 收到RST 复位链接的响应*(这是一个异常响应)，POSIX 规定errno 必须是ECONNABORTED. 一般服务端可以忽略这个错误(内核会处理复位终止的连接，进程不用理会)，重新调用accept 接收请求队列。

- ECONNABORTED : A connection has been aborted.

如果服务端的进程主动将连接关闭后，处于FIN_WAIT2 状态，此时客户端发服务端发送SYN 包时，服务端会直接返回RST 复位信号(而非ACK 信息), *客户端用read 读取RST 状态的TCP 协议层*时，会收到"对方复位连接":

- ECONNRESET : connection reset by peer 对方复位连接


	void perr_exit(const char *s){
		perror(s);
		exit(1);
	}

socket:

	int Socket(int family, int type, int protocol){
		int n;//
		if((n = socket(family, type, protocol)) < 0 ){
			perr_exit("accept error");
		}
		return n;
	}

Bind:

	void Bind(int fd, const struct sockaddr *sa, socklen_t salen) {
		if (bind(fd, sa, salen) < 0)
			perr_exit("bind error");
	}

Listen:

	void Listen(int fd, int backlog){
		if(listen(fd, backlog)<0)
			perr_exit("Listen error");
	}

### Accept

Accept: 在中断(EINTR) 或者 传数据过程中收到复位(ECONNABORTED)时, 就需要重试

	int Accept(int fd, (struct sockaddr *) sa, socklen_t * salen){
		int n;//
		while((n = accept(fd, sa, salen)) < 0 ){
			switch(errno){
				case ECONNABORTED: //RST
				case EINTR:
					break;
				default:
					perr_exit("accept error");
			}
		}
		return n;
	}

### Read
Read 重试：

	ssize_t Read(int fd, void * buf, size_t nbytes){
		ssize_t n;
	again:
		if ( (n = read(fd, buf, nbytes)) == -1) {
			if (errno == EINTR)
				goto again;
			else
				return -1;
		}
		return n;
	}

Write 重试：

	ssize_t Write(int fd, const void *ptr, size_t nbytes) {
		ssize_t n;
	again:
		if ( (n = write(fd, ptr, nbytes)) == -1) {
			if (errno == EINTR)
				goto again;
			else
				return -1;
		}
		return n;
	}

TCP 是面向流的，read 和 write 返回的值有可能小于要读写的值。这是因为读写缓冲区的大小是有限的。

比如:
对于read 调用，接收缓冲区大小20 bytes, 而请求读100个字节时，它只能返回20字节。此时就需要再次读
对于write 调用，发送缓冲区大小20 bytes, 而请求写100个字节时，它只能一次写20字节。如果socket 设置的是O_NONBLOCK 非阻塞，它也会直接返回20字节

此时就需要*多次读写*, 直到完成读写任务(读完，写完):

	ssize_t Readn(int fd, void *vptr, size_t n) {
		size_t  nleft;
		ssize_t nread;
		char   *ptr;

		ptr = vptr;
		nleft = n;
		while (nleft > 0) {
			if ( (nread = read(fd, ptr, nleft)) < 0) {//默认阻塞
				if (errno == EINTR)
					nread = 0;
				else
					return -1;
			} else if (nread == 0) //When the other side has been closed.
				break;
			nleft -= nread;
			ptr += nread;
		}
		return n - nleft;
	}

	ssize_t Writen(int fd, const void *vptr, size_t n) {
		size_t nleft;
		ssize_t nwritten;
		const char *ptr;

		ptr = vptr;
		nleft = n;
		while (nleft > 0) {
			if ( (nwritten = write(fd, ptr, nleft)) <= 0) {
				if (nwritten < 0 && errno == EINTR)
					nwritten = 0;
				else
					return -1;
			}
			nleft -= nwritten;
			ptr += nwritten;
		}
		return n;
	}

Close:

	void Close(int fd){
		if(close(fd) == -1) perr_exit("Close error");
	}

可变长协议中，TFTP的字段用'\0'分隔，HTTP按'\n'分隔，可封装一个专门的readline ：

	static ssize_t Readc(int fd, char *c){
		static char buf[100];
		static char *read_ptr;
		static int read_len;
		if(read_len <= 0){
			Again:
			if((read_len = read(fd, buf, sizeof(buf))) < 0){
				if(errno == EINTR){
					goto Again;
				}
				return -1;
			}else if(read_len == 0){
				return 0;
			}
			read_ptr = buf;
		}
		read_len--;
		*c = *read_ptr++;
		return 1;
	}
	ssize_t Readline(int fd, void *ptr, size_t maxlen){
		int n;
		for(n=1; n<maxlen; n++){
			switch(Readc(fd, ptr)){
				case 1:
					if(*ptr=='\n'){
						break 2;
					}
					++ptr;
					break;
				case 0: break 2;
				default: return -1;break;
			}
		}
		*ptr = '\0';
		return n-1;
	}

## 将client 改成交互输入

	/* client.c */
	int main(int argc, char *argv[]) {
		struct sockaddr_in servaddr;
		char buf[MAXLINE];
		int sockfd, n;
		char str[100];

		sockfd = socket(AF_INET, SOCK_STREAM, 0);

		bzero(&servaddr, sizeof(servaddr));
		servaddr.sin_family = AF_INET;
		inet_pton(AF_INET, "127.0.0.1", &servaddr.sin_addr);
		servaddr.sin_port = htons(SERV_PORT);

		connect(sockfd, (struct sockaddr *)&servaddr, sizeof(servaddr));

		while(fgets(str, sizeof(str), stdio)){
			write(sockfd, str, strlen(str));
			n = read(sockfd, buf, MAXLINE);
			if(n ==0){
				printf("The other side has been closed\n");
			}
			printf("Response from server:\n");
			write(STDOUT_FILENO, buf, n);
		}

		close(sockfd);
		return 0;
	}

Result:

	$ ./client
	aa
	Response from server:
	AA
	bb
	The other side has been closed
	Response from server:
	cc
	$

可以看到第二次输入时，服务端就关闭了连接. 但是client 并没有终止。原因是：

1. 第1次请求结束时，服务端处理完数据就已关闭了连接，双方状态变成：`client: CLOSE_WAIT, server: FIN_WAIT_2`
1. 第2次请求，client(CLOSE_WAIT) 发送数据， write 只负责把数据交给TCP 协议层就返回了，所以不会报错.
server(FIN_WAIT_2)收到ACK + 数据后，返回client一个RST 信号。client 收到RST 段后，状态保存在TCP 协议层，无法立即通知应用层. 双方都会关闭连接。
3. 第3次请求时, client 向关闭的连接write 请求时. 触发SIGPIPE 信号，导致client terminate 退出

> 如果client 用sigaction处理SIGPIPE信号，write 就会返回-1, 并set errno=EPIPE

让服务端用一个连接接收多次请求, 即处理完一次请求后不close, 保持连接:

	while (1) {
		cliaddr_len = sizeof(cliaddr);
		connfd = accept(listenfd,
						(struct sockaddr *)&cliaddr, &cliaddr_len);

		while((n = read(connfd, buf, MAXLINE)) > 0){
			  printf("received from %s at PORT %d\n",
					 inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)),
					 ntohs(cliaddr.sin_port));

			  for (i = 0; i < n; i++)
				  buf[i] = toupper(buf[i]);
			  printf("writing\n");
			  write(connfd, buf, n);
		}
		printf("Closing\n");
		close(connfd);
	}

如果再开一个client 的话，第二个client 将因server 不accept 而暂时不响应，仅当第一个client 结束后，第二个client 才能收到响应。

## 使用fork 并发处理多个请求
一个进程只能处理一个请求，为了同时处理多个请求，就需要fork 出多个子进程

	while (1) {
		cliaddr_len = sizeof(cliaddr);
		connfd = accept(listenfd,
						(struct sockaddr *)&cliaddr, &cliaddr_len);
		pid = fork();
		if(pid == -1){
			perror("failed to fork");
			exit(1);
		}else if(pid == 0){
			while((n = read(connfd, buf, MAXLINE)) > 0){
				  printf("received from %s at PORT %d\n",
						 inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)),
						 ntohs(cliaddr.sin_port));
				  for (i = 0; i < n; i++)
					  buf[i] = toupper(buf[i]);
				  printf("writing\n");
				  write(connfd, buf, n);
			}
			printf("Closing child\n");
			close(connfd);
		}else{
			printf("Closing parent\n");
			close(connfd);
		}
	}

## setsockopt
做一个测试，开启server ，再开启client

	$ netstat -anp tcp |grep 8000
	tcp4       0      0  127.0.0.1.8000         127.0.0.1.49750        ESTABLISHED
	tcp4       0      0  127.0.0.1.49750        127.0.0.1.8000         ESTABLISHED
	tcp4       0      0  *.8000                 *.*                    LISTEN

### client 处于半连接
此时用ctrl-c 关闭 server. 此时client 还没有终止，它处于`CLOSE_WAIT`

	$ netstat -anp tcp |grep 8000
	tcp4       0      0  127.0.0.1.8000         127.0.0.1.49750        FIN_WAIT_2
	tcp4       0      0  127.0.0.1.49750        127.0.0.1.8000         CLOSE_WAIT

由于还有连接占用8000, 再开启server 时会bind 失败：

	Bind error: Address already in use

### client 关闭半连接
将client 关闭，此时server 端的连接收到FIN 后，server 的连接从`FIN_WAIT2` 变成 `TIME_WAIT`, 仍然显示：

	$ netstat -apn |grep 8000 ; # mac 下的netstat 好像不能显示TIME_WAIT ?
	 tcp        0      0 127.0.0.1:8000          127.0.0.1:44685         TIME_WAIT  -
	$ ./server
	 bind error: Address already in use

这个`TIME_WAIT` 状态需要再等两个MSL（maximum segment lifetime）的时间后才能回到CLOSED状态, 然后才能再次监听8000 端口
RFC 规定MSL 为两分钟，不同的OS 实现不同，linux 默认是15秒，即30秒后就可以再次启动server 了。

在连接`127.0.0.1:8000` 未断开之前，无法监听`0.0.0.0:8000` 即`*:8000` 是不合理的。虽然占用的是同一端口，但ip 地址是不同的（connfd 监听的是特定的ip address, listenfd 监听的是wildcard address）

解决的方法是用setsockopt() 设置socket 描述符SO_REUSEADDR 为1，表示允许创建ip 不同，端口号相同的多个socket 文件描述符:

	int opt = 1;
	setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));

For more details, 参考 UNP 第7章 以及`man setsockopt`

	int
     setsockopt(int socket, int level, int option_name, const void *option_value, socklen_t option_len);

	 level
		 To manipulate options at the socket level, level is specified as SOL_SOCKET.
		 To manipulate options at any other level the protocol number of the appropriate protocol controlling the option is supplied. see /etc/protocols
	 option_name
	 	SO_DEBUG enables debugging in the underlying protocol modules.

## 完整的server.c

	/* server.c */
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <unistd.h>
	#include <sys/socket.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include <ctype.h>

	#define MAXLINE 80
	#define SERV_PORT 8000

	void perr_exit(const char *s){
		perror(s);
		exit(1);
	}
	void Bind(int fd, const struct sockaddr *sa, int salen){
		if(bind(fd, sa, salen)<0){
			perr_exit("Bind error");
		}
	}
	int main(void) {
		struct sockaddr_in servaddr, cliaddr;
		socklen_t cliaddr_len;
		int listenfd, connfd;
		char buf[MAXLINE];
		char str[INET_ADDRSTRLEN];
		int i, n;
		pid_t pid;

		listenfd = socket(AF_INET, SOCK_STREAM, 0);
		bzero(&servaddr, sizeof(servaddr));
		servaddr.sin_family = AF_INET;
		servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
		servaddr.sin_port = htons(SERV_PORT);

		int saopt = 1;
		setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &saopt, sizeof(saopt));
		Bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));

		listen(listenfd, 20);

		printf("Accepting connections ...\n");
		while (1) {
			cliaddr_len = sizeof(cliaddr);
			connfd = accept(listenfd,
							(struct sockaddr *)&cliaddr, &cliaddr_len);
			pid = fork();
			if(pid == -1){
				perror("failed to fork");
				exit(1);
			}else if(pid == 0){
				while((n = read(connfd, buf, MAXLINE)) > 0){
					  printf("received from %s at PORT %d\n",
							 inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)),
							 ntohs(cliaddr.sin_port));

					  for (i = 0; i < n; i++)
					  buf[i] = toupper(buf[i]);
					  printf("writing\n");
					  write(connfd, buf, n);
				}
				printf("Closing child\n");
				close(connfd);
			}else{
				printf("Closing parent\n");
				close(connfd);
			}
		}
	}

## select
select 是网络程序中很常见的系统调用，它可以同时监听多个阻塞 socket 文件描述符fd(比如多个网络连接) ，哪个有数据到达就处理哪个。这样就不需要用fork 和多进程就可实现server 同时处理多个网络请求。

> select 是OS 系统接口，原理就是IO复用(不用fork)。更加高级多路IO 复用有 linux 下的epoll, 以及mac 下的 kqueue , nginx 支持:  `[ kqueue | rtsig | epoll | /dev/poll | select | poll ]`

select 会返回ready 状态的文件描述符数量, 即在`readfds`, `writefds`, `errorfds` 中处于ready 状态的文件描述符数量。

有点恶心的是，fd_set 是hash 数据结构，检测时文件描述符的*遍历* 是通过第一个参数nfds, 也就是不在 `0 ~ nfds-1` 范围内的文件描述符不被检测！

select 是*阻塞函数*，仅当发生错误，或者至少检测到有一个文件描述符是ready 状态才返回

select 会针对`readfds`, `writefds`, `errorfds` 过滤出ready 态的文件描述符，并替换原来的`readfds`, `writefds`, `errorfds`!
i.e., readfds 包含`2,3`，nfds 为4，如果检测到 `0~3` 中只有文件描述符3 是 ready for reading, 那么select 会用3 替换原来的readfds

	int select(int nfds, fd_set *restrict readfds, fd_set *restrict writefds, fd_set *restrict errorfds, struct timeval *restrict timeout);

思路：

1. 将 listenfd, connfd(若有) 放到fd_set：`readfds` 中
2. 然后用select 监听`readfds` 中的fd 是否处于ready for read.(这个函数是阻塞式的)
3. 若有fd ready, 用`FD_ISSET(listenfd, &reset)` 判断是否有`new connection`,
4. 用`FD_ISSET(connfd, &reset)` 判断是否*收到新的data*, 是否关闭请求

Example:

其中的socklib.h 从这里下载 [socklib.h](https://raw.githubusercontent.com/ahuigo/c-lib/master/socklib.h)

	/* server.c */
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h>
	#include <netinet/in.h>
	#include <arpa/inet.h>
	#include "socklib.h"

	#define MAXLINE 80
	#define SERV_PORT 8000

	int main(int argc, char **argv) {
		int i, maxi, maxfd, listenfd, connfd, sockfd;
		int nready, client[FD_SETSIZE];
		ssize_t n;
		fd_set rset, allset;
		char buf[MAXLINE];
		char str[INET_ADDRSTRLEN];
		socklen_t cliaddr_len;
		struct sockaddr_in	cliaddr, servaddr;

		listenfd = Socket(AF_INET, SOCK_STREAM, 0);

		bzero(&servaddr, sizeof(servaddr));
		servaddr.sin_family      = AF_INET;
		servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
		servaddr.sin_port        = htons(SERV_PORT);

		int saopt = 1;
		setsockopt(listenfd, SOL_SOCKET, SO_REUSEADDR, &saopt, sizeof(saopt));
		Bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr));

		Listen(listenfd, 20);

		maxfd = listenfd;		/* initialize */
		maxi = -1;			/* index into client[] array */
		for (i = 0; i < FD_SETSIZE; i++)
			client[i] = -1;	/* -1 indicates available entry */
		FD_ZERO(&allset);
		FD_SET(listenfd, &allset); /* add new descriptor to allset hash table*/

		for ( ; ; ) {
			rset = allset;	/* structure assignment */

			nready = select(maxfd+1, &rset, NULL, NULL, NULL);//Block until there is any fd ready
			if (nready < 0)
				perr_exit("select error");

			if (FD_ISSET(listenfd, &rset)) { /* new client connection */
				cliaddr_len = sizeof(cliaddr);
				connfd = Accept(listenfd, (struct sockaddr *)&cliaddr, &cliaddr_len);

				printf("received from %s at PORT %d\n",
					   inet_ntop(AF_INET, &cliaddr.sin_addr, str, sizeof(str)),
					   ntohs(cliaddr.sin_port));

				for (i = 0; i < FD_SETSIZE; i++)
					if (client[i] < 0) {
						client[i] = connfd; /* save descriptor */
						break;
					}
				if (i == FD_SETSIZE) {
					fputs("too many clients\n", stderr);
					exit(1);
				}

				FD_SET(connfd, &allset);	/* add new descriptor to allset */
				if (connfd > maxfd)
					maxfd = connfd; /* for select */
				if (i > maxi)
					maxi = i;	/* max index in client[] array */

				if (--nready == 0)
					continue;	/* no more readable descriptors */
			}

			for (i = 0; i <= maxi; i++) {	/* check all clients for data */
				if ( (sockfd = client[i]) < 0)
					continue;
				if (FD_ISSET(sockfd, &rset)) {
					if ( (n = Read(sockfd, buf, MAXLINE)) == 0) {
						/* connection closed by client */
						Close(sockfd);
						FD_CLR(sockfd, &allset);
						client[i] = -1;
					} else {
						int j;
						for (j = 0; j < n; j++)
							buf[j] = toupper(buf[j]);
						Write(sockfd, buf, n);
					}

					if (--nready == 0)
						break;	/* no more readable descriptors */
				}
			}
		}
	}

# 基于UDP 的网络程序

UDP 通讯过程图, 出自[UNPv13e](http://akaedu.github.io/book/bi01.html#bibli.unp)

![](/p/linux-c-socket-udp.png)


UDP 不需要连接，协议可靠性需要在应用层实现。关闭server, 再开启server, client 请求时仍然有效果

需要用到：

	ssize_t
    	recvfrom(int socket, void *restrict buffer, size_t length, int flags, struct sockaddr *restrict address, socklen_t *restrict address_len);
	ssize_t
		sendto(int socket, const void *buffer, size_t length, int flags, const struct sockaddr *dest_addr, socklen_t dest_len);

Example:

[](https://raw.githubusercontent.com/ahuigo/c-lib/master/udp/server.c)
[](https://raw.githubusercontent.com/ahuigo/c-lib/master/udp/client.c)

# UNIX Domain Socket IPC
在网络通讯socket API 的基础上，发展出一种IPC 机制: UNIX Domain Socket。

与网络socket 本机通讯相比，IPC 更有效率，不需要走loopback 地址127.0.0.1：

1. 不需要网络协议栈: 不需要拆包，计算校验和，维护序号，应答等； 只需要将数据从一个进程copy 到另外一个进程
2. IPC 通讯本质是可靠的，而网络协议是为不可靠的通讯设计的
3. UNIX Domain Socket 也提供面向流和面向数据包两种API 接口，类似TCP 和UDP. 但是面向消息(数据包)的通讯是可靠的，它不会乱序

UNIX Domain Socket 与网络socket 一样，通过socket(AF_UNIX, SOCK_STREAM/SOCK_DGRAM, 0) 文件描述符通讯:

1. 它们的地址不一样: 后者用sockaddr_in(IP+PORT); 前者用sockaddr_un 表示文件地址 sun_path，这个文件由bind 创建，如果socket 存在则bind 返回错误

## bind UNIX Domain Socket

	#include <stdlib.h>
	#include <stdio.h>
	#include <string.h>
	#include <stddef.h>
	#include <sys/socket.h>
	#include <sys/un.h>

	int main(void) {
		int fd, size;
		struct sockaddr_un un;

		memset(&un, 0, sizeof(un));
		un.sun_family = AF_UNIX;
		strcpy(un.sun_path, "foo.socket");
		if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0) {
			perror("socket error");
			exit(1);
		}
		size = offsetof(struct sockaddr_un, sun_path) + strlen(un.sun_path);//sun_path 是最后一个成员，其偏移加len 就是整个结构体的长度, 结构体的实际长度随sun_path 可变，但小于sizeof(un).
		if (bind(fd, (struct sockaddr *)&un, size) < 0) {
			perror("bind error");
			exit(1);
		}
		printf("UNIX domain socket bound\n");
		exit(0);
	}

result:

	➜  test  ./a.out
	bind error: Address already in use
	➜  test  rm foo.socket
	➜  test  ./a.out
	UNIX domain socket bound

## server
与网络编程一样bind fd 后需要listen fd, 再accept

	#include <stddef.h>
	#include <ctype.h>
	#include <sys/socket.h>
	#include <sys/un.h>
	#include <sys/stat.h>
	#include <errno.h>
	#include <string.h>
	#include <unistd.h>
	#include "socklib.h"

	#define QLEN 10

	/*
	 * Create a server endpoint of a connection.
	 * Returns fd if all OK, <0 on error.
	 */
	int serv_listen(const char *name){
		int fd, n, err, rval;
		socklen_t len;
		struct sockaddr_un un, cliaddr;

		//fill in socket address with name
		memset(&un, 0, sizeof(un));
		un.sun_family = AF_UNIX;
		strcpy(un.sun_path, name);
		unlink(name);

		//create stream socket
		fd = socket(AF_UNIX, SOCK_STREAM, 0);

		//bind name to socket descriptor
		len = offsetof(struct sockaddr_un, sun_path) + strlen(name);
		if(bind(fd, (struct sockaddr *)&un, len)<0){
			rval = -2;
			goto errout;
		}

		// tell kernel we're a server
		if(listen(fd, QLEN)<0){
			rval = -3;
			goto errout;
		}

		return fd;

	errout:
		err = errno;
		close(fd);//It will override errno
		errno = err;
		return(rval);
	}

	/**
	 * 这是一个accept 模块，accept 得到的客户端地址也是一个socket 文件:
	 * 		如果不是, 就返回一个小于0的错误值;
	 * 		如果是socket 文件，此文件就没有用了，直接unlink.
	 * 通过uidptr 返回客户端程序的uid id
	 */
	int serv_accept(int listenfd, uid_t *uidptr) {
		int                 connfd, err, rval;
		socklen_t			len;
		time_t              staletime;
		struct sockaddr_un  un;
		struct stat         statbuf;

		len = sizeof(un);
		if ((connfd = accept(listenfd, (struct sockaddr *)&un, &len)) < 0)
			return(-1);     /* often errno=EINTR, if signal caught */

		/* obtain the client's uid from its calling address */
		len -= offsetof(struct sockaddr_un, sun_path); /* len of pathname ??? really??*/
		un.sun_path[len] = 0;           /* null terminate */

		if (stat(un.sun_path, &statbuf) < 0) {
			rval = -2;
			goto errout;
		}

		if (S_ISSOCK(statbuf.st_mode) == 0) {
			rval = -3;      /* not a socket */
			goto errout;
		}

		if (uidptr != NULL)
			*uidptr = statbuf.st_uid;   /* return uid of caller */
		unlink(un.sun_path);        /* we're done with pathname now */
		return(connfd);

	errout:
		err = errno;
		close(connfd);
		errno = err;
		return(rval);
	}
	#define MAXLINE 80
	int main(){
		int listenfd, connfd;
		int i, n;
		char buf[MAXLINE];
		if((listenfd = serv_listen("serv_socket")) < 0){
			perr_exit("listen failed");
		}
		uid_t uid;
		if((connfd = serv_accept(listenfd, &uid)) < 0){
			perr_exit("accept failed");
		}
		while((n = read(connfd, buf, MAXLINE)) >= 0){
			for(i=0; i<n; i++){buf[i] = toupper(buf[i]);}
			write(connfd, buf,n);
		}
		return 0;
	}

## client
与网络socket 不一样，UNIX Domain Socket 一般要显式调用bind 确定客户端自己的socket, 而不依赖系统自动分配地址。
因为客户端自己指定socket 文件，该*文件名*可以包含*客户端的pid* ,以区分不同客户端

	#include <stdio.h>
	#include <string.h>
	#include <unistd.h>
	#include <stddef.h>
	#include <sys/stat.h>
	#include <sys/socket.h>
	#include <sys/un.h>
	#include <errno.h>
	#include "socklib.h"

	#define CLI_PATH    "/var/tmp/"      /* +5 for pid = 14 chars */
	#define MAXLINE 80

	/*
	 * Create a client endpoint and connect to a server.
	 * Returns fd if all OK, <0 on error.
	 */
	int cli_conn(const char *name) {
		int                fd, len, err, rval;
		struct sockaddr_un un;

		/* create a UNIX domain stream socket */
		if ((fd = socket(AF_UNIX, SOCK_STREAM, 0)) < 0)
			return(-1);

		/* fill socket address structure with our address */
		memset(&un, 0, sizeof(un));
		un.sun_family = AF_UNIX;
		sprintf(un.sun_path, "%s%05d", CLI_PATH, getpid());
		printf("client sun_path: %s%05d\n", CLI_PATH, getpid());
		len = offsetof(struct sockaddr_un, sun_path) + strlen(un.sun_path);

		unlink(un.sun_path);        /* in case it already exists */
		if (bind(fd, (struct sockaddr *)&un, len) < 0) {
			rval = -2;
			goto errout;
		}

		/* fill socket address structure with server's address */
		memset(&un, 0, sizeof(un));
		un.sun_family = AF_UNIX;
		strcpy(un.sun_path, name);
		len = offsetof(struct sockaddr_un, sun_path) + strlen(name);
		if (connect(fd, (struct sockaddr *)&un, len) < 0) {
			rval = -4;
			goto errout;
		}
		return(fd);

	errout:
		err = errno;
		close(fd);
		errno = err;
		return(rval);
	}

	int main(){
		int servfd, n;
		char buf[MAXLINE];

		printf("Input a line to upper\n");
		servfd = cli_conn("serv_socket");
		if(servfd <0){
			perr_exit("connect failed");
		}
		while(fgets(buf, MAXLINE, stdin)){
			write(servfd, buf, strlen(buf));
			n = read(servfd, buf, MAXLINE);
			write(1, buf, n);
		}
		close(servfd);
		return 0;
	}

# 简单的web 服务器
web 服务器其实是基于tcp/ip 的http 协议，默认每次请求read 请求头后，然后response 结束就关闭连接。除非"keep-alive" 保持连接，这个比较复杂

- 如果请求的是可执行程序，那么这个可执行程序就是CGI 程序, 比如php CGI(与CLI 相对)
- 如果请求的是静态资源，那么读取并响应此资源

# 参考
- 本文图文均参考[socket 编程]

[socket 编程]: http://akaedu.github.io/book/ch37.html
