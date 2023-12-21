---
title: process fork exec
date: 2023-12-21
private: true
---
# process fork exec
## 不同的进程共享port?
如果进程先绑定一个端口号，然后在fork一个子进程，这样的话就可以是实现多个进程绑定一个端口号

那么： 
1. 我先启动 `golang server port:80`
2. 再fork出新进程，它会继承80端口，此时用exec()替换成`node server:80`。
3. 这样两个不同的进程可以共享同一个端口。 这样做，可以成功吗？

### 只fork 是可以共享port 端口
前提是开启`SO_REUSEADDR` 和 `SO_REUSEPORT` 套接字选项：
1. SO_REUSEADDR 允许在同一个端口上启动多个套接字，只要每个套接字绑定的本地 IP 地址不同。
2. SO_REUSEPORT （某些操作系统支持，例如 Linux）允许多个套接字绑定到完全相同的地址和端口组合上，前提是所有之前已经绑定该地址/端口的套接字在设置了 SO_REUSEPORT 选项。

否则报：address already in use

### fork()+exec() 不可以共享port 端口
exec() 替换的含义：
- 当你在子进程里执行 exec() 系列函数时，它实际上是完全替换当前进程的内存空间、代码段和数据段为新的程序，而不是在原程序上添加或修改。

所以，如果 Go 服务是父进程，那么使用 exec() 后，整个 Go 服务的进程会被 Node.js 的进程镜像替换掉。