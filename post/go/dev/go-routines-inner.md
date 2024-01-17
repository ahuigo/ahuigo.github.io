---
title: golang 的协程调度
date: 2018-09-27
---
# golang 的协程调度
协程是由用户态自己手动去调度的、轻量的上下文切换。
具体到不同的语言，协程有所不同，主要分串行和并行两大类：
1. js、python 的async/await 模型的协程是串行的。
2. golang 的协程是建立在 CSP model 并发模型基础上的，可以被认为是微线程（由于是并行模型，同样要操心线程安全的问题）。

推荐看：Go调度器系列（3）图解调度原理
https://segmentfault.com/a/1190000018775901

## routine 与channel
routine 如果用原生的channel 进行高并发通信，多个channel 会产生竞争，CPU 密集的其效率不会有想象的高，而是适合IO 密集的

## Golang 的调度机制
Golang 的调度机制涉及三个部分
1. G（Goroutine）就是协程, 包含了协程的栈空间
1. P（Processor) 是处理器，也称为上下文
1. M（Work Thread) 是一个线程, 一个M绑定一个P，M和P可能数量不同(P空闲没有绑定M) 

他们的关系如下
1. P 协程队列和全局队列：
   1. 局部：除了每个P 持有一个G 协程队列, 队列数组255(局部)
   1. 全局：还有一个空闲的全局的G 队列（全局）
   1. P 的数量取决于GOMAXPROCS（最大256), 默认是cpu cores 的数量
2. M 运行时必须绑定一个P(除非M 休眠), M负责从P中取出G 并执行
   2. 如过P没有G 了，就从全局的G 中偷，数量为全局G的个数/P个数
   2. 如果全局的G也空了，就从其他的P 中偷，数量为一半
3. G 进入P 队列的过程：
   1. G先加入到本地或全局队列
   2. G 在找一个空闲的P(指没有绑定M的P)，P先创建M并绑定，G被放到这个P
   3. 新建M 所绑的 P 的初始化队列会从其他 G 队列中取任务过来

[示意图1](https://zhuanlan.zhihu.com/p/37432194):
![](/img/go/routine-inner.1.png.png)


[示意图2](https://speakerdeck.com/retervision/go-runtime-scheduler?slide=14):
![](/img/go/routine-inner.2.png)
M 会循环执行G:
1. 从本地P找G
2. 从全局找G
2. 从其他P偷G

## 协程的阻塞与中断
> 参考 https://povilasv.me/go-scheduler/

[如图](https://zhuanlan.zhihu.com/p/37432194)，
当协程G4 遇到阻塞调用（比如系统调用syscall）超过10ms时 ，这个G4连同M2 会被剥离出P0，产生一个新的M3 来接手P0(如果没有空闲的M线程). (OS本身倒很灵敏的把该阻塞线程调度走)

![](/img/go/routine-inner.3.png)

系统调用syscall 返回时，G4 会被放回本地的P, M2 放入到空闲的idle threads

除了系统调用，go runtime 执行网络调用(network call) 也会干相同的事（go 集成了poll）, Go runtime 在遇到以下阻塞时都会发生协程切换

    blocking syscall (for example opening a file),
    network input,
    channel operations,
    primitives in the sync package.

### 阻塞的中断机制
M 在执行G 时，可能G 阻塞, 超时就强制切换(只有在用到非内联函数时才可以)

协程的切换时间片是10ms, 这个过程，又被称为 中断，挂起。

go程序启动时会首先创建一个特殊的内核线程 `sysmon`，用来监控和管理，其内部是一个循环：
1. 记录所有 P 的 G 任务的计数 `schedtick`，schedtick会在每执行一个G任务后递增
2. 如果检查到 `schedtick` 一直没有递增，说明这个 P 一直在执行同一个 G 任务，如果超过10ms，就在这个G任务的栈信息里面加一个 tag 标记
3. 然后这个 G 任务在执行的时候，如果遇到非内联函数调用，就会检查一次这个标记，然后中断自己，把自己加到队列末尾，执行下一个G
4. 如果没有遇到非内联函数 调用的话，那就会一直执行这个G任务，直到它自己结束；如果是个死循环，并且 GOMAXPROCS=1 的话。那么一直只会只有一个 P 与一个 M，且队列中的其他 G 不会被执行！

下面的这段代码，hello world 不会被输出

    func main(){
        runtime.GOMAXPROCS(1)
        go func(){
            fmt.Println("hello world")
        }()
        go func(){
            for {
        
            }
        }()
        select {}
    }

## GOMAXPROCS 的优化
这个参数并不是默认为cpu 数就好，原因在于：
1. G将M阻塞时，G被剥离P有一个延时(10ms), 这造成了对M/P的浪费
2. P太少的话，Go调度器不会马上把这个M/P持有的G抢走

可以参考：https://my.oschina.net/linker/blog/1504199 

## 观察协程的调度
https://povilasv.me/go-scheduler/ 提供了一个查看协程调度例子。PS: `go tool trace`  是另一款go调试工具

    $ GODEBUG=scheddetail=1,schedtrace=1000 ./program
    SCHED 0ms: gomaxprocs=8 idleprocs=7 threads=2 spinningthreads=0 idlethreads=0 runqueue=0 gcwaiting=0 nmidlelocked=0 stopwait=0 sysmonwait=0

    P0: status=1 schedtick=0 syscalltick=0 m=0 runqsize=0 gfreecnt=0
    P1: status=0 schedtick=0 syscalltick=0 m=-1 runqsize=0 gfreecnt=0
    P2: status=0 schedtick=0 syscalltick=0 m=-1 runqsize=0 gfreecnt=0
    P3: status=0 schedtick=0 syscalltick=0 m=-1 runqsize=0 gfreecnt=0
    P4: status=0 schedtick=0 syscalltick=0 m=-1 runqsize=0 gfreecnt=0
    P5: status=0 schedtick=0 syscalltick=0 m=-1 runqsize=0 gfreecnt=0
    P6: status=0 schedtick=0 syscalltick=0 m=-1 runqsize=0 gfreecnt=0
    P7: status=0 schedtick=0 syscalltick=0 m=-1 runqsize=0 gfreecnt=0
    M1: p=-1 curg=-1 mallocing=0 throwing=0 preemptoff= locks=1 dying=0 helpgc=0 spinning=false blocked=false lockedg=-1
    M0: p=0 curg=1 mallocing=0 throwing=0 preemptoff= locks=1 dying=0 helpgc=0 spinning=false blocked=false lockedg=1
    G1: status=8() m=0 lockedm=0

## 参考
- 林冠宏 https://juejin.im/post/5b7678f451882533110e8948
- go runtime scheduler slides by Gao Chao https://speakerdeck.com/retervision/go-runtime-scheduler?slide=31