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

## IO多路复用
IO多路复用，复用的是系统调用。通过有限次系统调用判断海量连接是否数据准备好了
无论下面的 select、poll、epoll，其都是这种思想实现的，不过在实现上，select/poll 可以看做是第一版，而 epoll 是第二版

# epoll
todo
https://zhuanlan.zhihu.com/p/316059142
