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
https://mp.weixin.qq.com/s/I9xSMxy32cALSNQAN8wlnQ

# 生成trace.out
## web 生成
    curl 'localhost:4500/debug/pprof/trace?seconds=10' > trace.out
    go tool trace --http=:8080 trace.out

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

## 1. View Trace by proc
按`?` 获取快捷键帮助, s/w 放大/缩小时间轴; 面板介绍：

1 Timeline  
显示执行的时间，根据跟踪定位的不同，时间单位可能会发生变化。你可以通过使用键盘快捷键（WASD键，就像视频游戏一样😊）来导航时间轴。

2 Heap  
在执行期间显示内存分配，这对于发现内存泄漏非常有用，并检查垃圾回收在每次运行时能够释放多少内存。

3 Goroutines  
在每个时间点显示有多少goroutines在运行，有多少是可运行的（等待被调度的）。大量可运行的goroutines可能显示调度竞争，例如，当程序创建过多的goroutines，会导致调度程序繁忙。

4 OS Threads  
显示有多少OS线程正在被使用，有多少个被syscalls阻塞。

5 Virtual Processors(PROC)
每个虚拟处理器显示一行。虚拟处理器的数量由GOMAXPROCS环境变量控制（默认为内核数）。

6 Goroutines and events  
显示在每个虚拟处理器上有什么goroutine在运行。连接goroutines的连线代表事件。

### 分析trace chan
```
// golib/perf/pprof/trace/trace-chan
func main() {
	trace.Start(os.Stderr)
	defer trace.Stop()
	ch := make(chan int)
	go func() {
		ch <- 42
	}()
	<-ch
}
```
![Alt text](/img/go/profile/trace-chan-view1.webp)

在示例图片中，我们可以看到goroutine "G1.runtime.main"衍生出了4个不同的goroutines:
- G5和G6、G7 都是负责收集trace数据的goroutine
- G8是我们使用“go”关键字启动的那个。

事件：处理器Proc的第二行可能显示额外的事件，比如syscalls和运行时事件以及gc 处理

点击第1段G1 main.main可看到：
1. Start: 0ns
1. Wall Duration: 128ns (墙钟时间, 包括暂停时间)
1. Self Duration: 116ns
1. 4个outgoing flow event: 启动了4个go routinue

outgoing/incoming flow event:
- 点击outgoing flow 的go event可查看启动其它go的start 位置;
- 点击incomming flow 的go event可查看启动self的start 位置

### trace sleep
```
// golib/perf/pprof/trace/trace-chan
func main() {
	trace.Start(os.Stderr)
	defer trace.Stop()
	time.Sleep(time.Microsecond * 200)
	time.Sleep(time.Microsecond * 200)
	time.Sleep(time.Microsecond * 200)
}
```
sleep self Duration 很短，要放大时间尺度才能看到:
- sleep 启动时应该是proc end，然后是不断的中断检查proc　start/proc end
- sleep 结束时会有proc start


## 2. Goroutine analysis
示例：

	Start location	                            Count	Total execution time
    main.main	                                1	    327.169µs
    runtime.traceStartReadCPU.func1	            1	    163.2µs
    runtime.(*traceAdvancerState).start.func1	1	    54.72µs
    runtime/trace.Start.func1	                1	    1.728µs
    main.main.func1	                            1	    1.024µs go func(){}()
    (Inactive, no stack trace sampled)	4	(非活动状态的，也就是说它们在采样期间没有执行任何代码)

Inactive(no stack trace sampled) 指非活动状态的goroutine，它们在采样期间没有执行任何代码. 一般代表：
1. Goroutine 在采样开始前就已经完成了它的任务。
2. Goroutine 在整个采样期间都在等待某个事件，比如等待 I/O 操作完成，等待锁释放，等待 channel 数据等。
4. Goroutine 在采样结束后才开始执行。


然后点开任意一个goroutine group, 可以看到：

    Goroutine	Total		Execution time	Block time	Block time (syscall)	Sched wait time	Syscall execution time	Unknown time

    Goroutine：这是 Goroutine 的标识符，用于区分不同的 Goroutine。
    Total：这是 Goroutine 的总运行时间，包括所有的执行时间和等待时间。
    Execution：这是 Goroutine 在执行（即 CPU 运行）状态下的时间。
    Sched wait time：这是 Goroutine 在等待被 Go 调度器调度到运行队列的时间。
        Scheduler wait：旧版本

    Block time：这是 Goroutine 在等待同步原语（如互斥锁或条件变量）的时间。
        Block time syscall：这是 Goroutine 在执行阻塞系统调用的时间。
        Syscall execution time：这是 Goroutine 在执行系统调用的时间。

旧版本：

    Network wait：这是 Goroutine 在等待网络 I/O 操作完成的时间。
    GC sweeping：这是 Goroutine 在执行垃圾回收的清扫阶段的时间。
    GC pause：这是 Goroutine 在等待垃圾回收的暂停阶段的时间。

