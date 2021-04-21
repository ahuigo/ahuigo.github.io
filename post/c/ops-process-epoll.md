---
title: epoll
date: 2020-12-19
private: true
---
# 重识异步与阻塞
参考：网络 IO 演变过程 https://zhuanlan.zhihu.com/p/353692786

数据传输中：
1. 第一阶段：硬件接口（网络）到内核态。阻塞与非阻塞
    1. 阻塞 IO(BIO)
    2. 非阻塞 IO(NIO)
2. 第二阶段：内核态到用户态。同步与异常
    3. IO 多路复用第一版(select/poll)
    4. IO 多路复用第二版(epoll)
3. 异步 IO(AIO)


## 非阻塞
非阻塞 IO 是需要系统内核支持的，在创建了连接后，可以调用 setsockop 设置 noblocking.
缺点：频繁的系统调用是比较消耗系统资源的。

    APP                         Kernel
    recvfrom ---sys call-->     nodata ready(io)
             <---EWOULDBLOCK
    recvfrom ---sys call-->     nodata ready(io)
             <---EWOULDBLOCK
    recvfrom ---sys call-->     data ready  (io)
                                    | (kernel copy to user)
                                    v
    program  <----return ok        copy complete

## IO多路复用

    APP                         Kernel
    select  ---sys call-->     nodata ready(io)
             ........
    select  ----return  -->     data ready  (io)
    recvfrom ---sys call-->     data ready  (io)
                                    | (kernel copy to user)
                                    v
    recvfrom <----return ok        copy complete

IO多路复用，复用的是系统调用。通过有限次系统调用判断海量连接是否数据准备好了
无论下面的 select、poll、epoll，其都是这种思想实现的，不过在实现上，select/poll 可以看做是第一版，而 epoll 是第二版

1. select/poll 本质是IO阻塞（只有一次system call)
1. recvfrom 本质是kernel data 拷贝到user 阻塞

IO 多路复用中，select()/poll()/epoll_wait()这几个函数对应第一阶段；read()/recvfrom()对应第二阶段

# select与poll
man select :

    int select (int n, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);

poll

    int poll (struct pollfd *fds, unsigned int nfds, int timeout);

    struct pollfd {
        int fd; /* file descriptor */
        short events; /* requested events to watch */
        short revents; /* returned events witnessed */
    };

区别
1. select 只能监听1024个fd(可改), poll 不限制
相同
2. select 和 poll 都需要在返回后，通过遍历文件描述符来获取已经就绪的socket
3. 都频繁的将海量 fd 集合从用户态传递到内核态，再从内核态拷贝到用户态

# epoll
一开始就在内核态分配了一段空间，来存放管理的 fd,所以在每次连接建立后，交给 epoll 管理时，需要将其添加到原先分配的空间中，后面再管理时就不需要频繁的从用户态拷贝管理的 fd 集合。通通过这种方式大大的提升了性能。


todo
https://zhuanlan.zhihu.com/p/316059142
