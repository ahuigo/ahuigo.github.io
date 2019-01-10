---
title: 并发模型
---
# 并发模型
廖老师介绍了一本《七周七并发模型》，值得一读。 这本书从最基础的线程和锁模型讲起，介绍了许多非常有用的并发模型：

    通过无变量的函数式编程实现并发，是无锁并发的一种模型；

    Clojure对于状态和标识的分离，可以轻松实现内存事务模型；

    Erlang的Actor模型是容错性非常高的分布式并发模型；

    CSP模型是另一种分布式并发模型，被Go和Clojure采用；

    GPU的并行计算主要针对数据密集型计算的并行，搞游戏的一定要看；

    Hadoop和Storm分别适合超大数据量的批处理和流式处理。

有人做了下笔记：http://frobisher.me/2017/07/06/seven-concurrency-models-introductions/

## 传统的多进程、线程模型
传统的并发模型一般有一个消息队列（共享内存），然后通过thread 或者 process 去取消息。这时候取消息就有竞争关系，有两种解决竞争的方法
1. 加锁, 会有性能问题
1. 无锁队列：lock-free，是利用处理器的原子指令来避免对锁的使用(CAS或LL)

# 角色模型Actor
Actor 模型是一种并发模型, 正是因为他有如下特性，所以很适合用于分布式处理 
1. Actor 间相互独立, 不共享内存: 消息接收者是通过地址区分的，有时也被称作“邮件地址”
2. Actor 是可以创建其他actors
2. Actor 可向其他Actors 发送消息(本地和其他的机器)
2. Actor 接受来自其他Actors 的消息(本地和其他的机器)

Actor与信箱是耦合的, CSP 与 channel 是独立的
   
每个actor维持一个私有状态。Actor 接受其他Actors 的消息这个事有点特别：
1. actor 决定要如何`回答接下来的消息`：比如当前状态是`1`，那么接收到消息`add(1)`, 状态不改变，只有等下一条消息到来时才改变为`2`。
2. Actor 接受到的消息必须顺序处理。所以这些消息要放置在*mailbox* 收信息箱。

## 容错(Fault tolerance)
Erlang 实现了Actor 模型，他的每个process(erlang 虚拟机中的process) 就是一个actor
其中有一个actor(supervisor process) 就是监控其他actor 是否崩溃, 马上恢复

## 参考
- https://zh.wikipedia.org/wiki/%E8%A7%92%E8%89%B2%E6%A8%A1%E5%9E%8B


