---
title: go routines protocol
date: 2022-09-13
private: true
---
# go routines protocol
## MPG
golang调度模型是: M(master)-P(process)-G(goroutines). 简单的说:
1. Master: 是操作系统的线程，（M工作在内核态，由内核负责切换，也有人叫内核态线程）
    1. 线程的切换开销比较大, 包括用户态与内核态的切换——cpu调度（十几个寄存器的修改）、可能还有页的切换
    2. **线程栈空间**是MB级别，golang一般采用2MB-4MB
2. P(process): 它工作在用户态，负责goroutine切换的调度器，一个Master对应一个Process, 一个Process 管理多个G
3. G(goroutine): 这个就是协程(也有人叫用户态线程 或 轻量线程)
    1. 协程切换不需要用户态与内核态切换，只需要修改PC/SP/DX寄存器。（Note: P、G只工作在用户态，Master 工作在内核态）
    2. **协程栈空间** 默认是2KB(go>1.4).  所以很容易实现10万级的协程

golang 对多核CPU支持:
1. 单个Master-Process 只能执行一个goroutine
2. 多个Master-Process 可以执行多个goroutine, 一般默认master 个数是cpu内核数量(`GOMAXPROCS`)

对于多核cpu来说，多个goroutine 并行执行。以及gorounine 执行非原子操作。就需要对共享的变量加锁，否则就可能出现问题，比如：
> 一个协程读一个字符串，只读了一半; 就被另外一个协程改写了（e.g. https://github.com/ahuigo/golib/blob/main/lock/atom/race-string_test.go）

具体可参考(Go 语言设计与实现)：https://draveness.me/golang/docs/part3-runtime/ch06-concurrency/golang-goroutine/