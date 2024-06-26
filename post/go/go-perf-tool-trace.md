---
title: golang tool trace
date: 2023-08-29
private: true
---
# golang tool trace
go tool pprof -http=:4501，告诉你什么函数占用了最多的CPU时间，但它并不能帮助你确定是什么阻止了goroutine运行。

go tool trace 能够跟踪捕获各种执行中的事件，例如： 

    阻塞在运行时GC: 垃圾回收GC 事件
    Goroutine 的创建/阻塞/解除阻塞。
    被syscall阻塞: Syscall 的进入/退出/阻止
    Heap 的大小改变。
    Processor 启动/停止等等。
    time.Sleep 函数让当前的 goroutine 进入休眠状态，这种情况下 CPU 将不会执行任何操作，profile 不会有记录
    阻塞在共享内存:(channel/mutex etc) 竞争和逻辑冲突

## todo
https://about.sourcegraph.com/blog/go/an-introduction-to-go-tool-trace-rhys-hiltner
https://mp.weixin.qq.com/s/I9xSMxy32cALSNQAN8wlnQ

# 生成trace.out
## web 生成
    curl localhost:8181/debug/pprof/trace?seconds=10 > trace.out
    go tool trace --http=':8080' trace.out

## cli 生成
    // golib/perf/pprof/runtime-pprof.go
    f, _ := os.Create("trace.out")
    defer f.Close()

    trace.Start(f)
    defer trace.Stop()

# 分析trace.out

    go tool trace --http=':8080' trace.out
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --enable-blink-features=ShadowDOMV0,CustomElementsV0,HTMLImports

    1 View trace  
    最复杂、最强大和交互式的可视化显示了整个程序执行的时间轴。这个视图显示了在每个虚拟处理器上运行着什么，以及什么是被阻塞等待运行的。

    2 Goroutine analysis  
    显示了在整个执行过程中，每种类型的goroutines是如何创建的。在选择一种类型之后就可以看到关于这种类型的goroutine的信息。例如，在试图从mutex获取锁、从网络读取、运行等等每个goroutine被阻塞的时间。

    3 Network/Sync/Syscall blocking profile  
    这些图表显示了goroutines在这些资源上所花费的时间。它们非常接近pprof上的内存/cpu分析。这是分析锁竞争的最佳选择。

    4 Scheduler latency profiler  
    为调度器级别的信息提供计时功能，显示调度在哪里最耗费时间

## View Trace by proc

