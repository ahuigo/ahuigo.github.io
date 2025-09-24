---
title: Go profiler
date: 2019-08-23
private:
---
# Go profiler
## Go profiler 指标
使用Go 内置的profiler我们能获取以下的样本信息：

    CPU profiles    cpu 分析
    Heap profiles   内存 分析
    mutex profiling 锁性能分析
    block profile   阻塞分析
    goroutines      状态分析
    traces等        调用栈分析

## go profiling相关的分析工具
主要有以下几种工具
1. `go test` 基准测试文件：比如使用命令`go test -bench . -cpuprofile prof.cpu` 生成采样文件后，再通过命令 `go tool pprof [binary] prof.cpu` 来进行分析。
2. `runtime` 工具：通过在代码里面调用 `runtime.StartCPUProfile`或者`runtime.WriteHeapProfile`等能方便的采集程序运行的`堆栈、goroutine、内存分配和占用、io 等信息`并生成 `.prof` 文件. 基于runtime, 官方还提供了：
    1. `pkg/profile` : 它封装了 `runtime/pprof` 的接口，使用起来更简单
    2. `net/http/pprof`：也是基于`runtime/pprof`, 用于分析http 服务的性能瓶颈. 

> 更多调试的使用，可以阅读Go Blog的 Profiling Go Programs: https://go.dev/blog/pprof

# pprof 的使用
`go tool pprof` 可以采集并生成 `.pprof` 文件、下载prof并生成分析结果（火焰图、调用栈等）. 下面具体总结一下

## pprof 命令的基本用法
`go tool pprof`的基本用法见:https://github.com/google/pprof， 常用的指令有：

Generate a text report of the profile, sorted by hotness:

    $ pprof -top [main_binary] profile.pb.gz
        main_binary:  Local path to the main program binary, to enable symbolization
        profile.pb.gz: Local path to the profile in a compressed protobuf, or
                    URL to the http service that serves a profile.

### pprof 输出形式
使用 -text 选项可以直接将结果以文本形式打印出来。

    $ go tool pprof -text cpu.pprof

Generate a graph in an SVG file, and open it with a web browser:

    pprof -web [main_binary] profile.pb.gz

Run pprof on interactive mode:

    pprof [main_binary] profile.pb.gz

Run pprof via a web interface

    pprof -http=[host]:[port] [main_binary] profile.pb.gz

pprof 其它输出格式

    $ go tool pprof
    Output formats (select at most one):
        -gif             Outputs a graph image in GIF format
        -dot             Outputs a graph in DOT format
        -png             Outputs a graph image in PNG format
        -text            Outputs top entries in text form
        -tree            Outputs a text rendering of call graph
        -web             Visualize graph through web browser

### top sort

    cum 包含函数调用的时间，比如cpuFunc 就包含了longRun 的时间
    flat 是函数自身的cpu 占用
    sum% 之前累加每一行flat%的累加（见top方法）

    top20 -cum

### pprof 交互模式指令
进入pprof 交互模式后，可以执行`top`,`top20`, `list`, `help`等各种指令，具体参考`help`

    $ go tool pprof hello cpu.prof
    (pprof) list main.main (查看main.main函数)
    (pprof) list main (查看main.main, runtime.main 函数)
    (pprof) traces (打印调用栈)
    (pprof) top20 -cum (包含函数调用的时间)


## runtime/pprof 生成prof 文件

### 生成prof 文件
如果是常规的程序,  需要在代码执行前开启生成`pprof` 文件代码, 可参考:[golib/perf/pprof/runtime-pprof.go](https://github.com/ahuigo/golib/blob/master/perf/pprof/runtime-pprof.go)


    // https://jvns.ca/blog/2017/09/24/profiling-go-with-pprof/
    package main
    import "runtime"
    import "runtime/pprof"
    import "os"
    import "time"

    func main() {
        //pprof.StartCPUProfile(os.Stdout)
        pprof.StartCPUProfile(os.Create("cpu.prof"))
        defer pprof.StopCPUProfile()
        go leakyFunction()
        time.Sleep(500 * time.Millisecond)
        f, _ := os.Create("mem.prof")
        defer f.Close()
        runtime.GC()
        pprof.WriteHeapProfile(f);
    }

    func leakyFunction() {
        s := make([]string, 3)
        for i:= 0; i < 10000000; i++{
            s = append(s, "magical pprof time")
        }
    }

运行程序后可以得到 cpu.prof 和 mem.prof 文件，然后使用 go tool pprof 分析。

    go tool pprof [binary] cpu.prof
    go tool pprof [binary] mem.prof

example:

    $ go run runtime-pprof.go
    $ go tool pprof cpu.prof
    (pprof) top 显示耗时最多的top func
    ......
    (pprof) web 打开web 界面查看调用关系图、火焰图

### 分析可执行文件源码
比如`hello`：

    $ go run runtime-pprof.go
    $ go build -o hello runtime-pprof.go
    $ go tool pprof hello cpu.prof
    (pprof) list main.main (查看main.main函数)
    (pprof) list main (查看main.main, runtime.main 函数)
    (pprof) traces (打印调用栈)

### 将分析输出为 pdf 格式文件：

    go tool pprof --pdf hello cpu.prof > cpu.pprof.pdf

## pkg/profile 包(runtime/pprof 的封装)
pkg/profile 是对 runtime/pprof 的封装，更易用一点儿

### 生成mem.pprof
    import (
        "github.com/pkg/profile"
        "math/rand"
    )

    func main() {
        defer profile.Start(profile.MemProfile, profile.MemProfileRate(1)).Stop()
        concat(100)
    }
### 生成cpu.pprof

    import (
        "github.com/pkg/profile"
    )
    func main() {
        defer profile.Start().Stop()
        concat(100)
    }

运行后：将生成类似

    cpu profiling ..., /tmp/profile068616584/cpu.pprof


## net/http/pprof
> 示例：github.com/ahuigo/golib/gonic/ginapp/gin-pprof.go
如果程序为 web 服务， 我们则可借助`net/http/pprof`包 来完成profile 采样:

如果是`http` server, 只需要引入`import _ "net/http/pprof"` 就可监控性能采样请求

    // src/net/http/pprof/pprof.go
    func init() {
        http.Handle("/debug/pprof/", http.HandlerFunc(Index))
        http.Handle("/debug/pprof/cmdline", http.HandlerFunc(Cmdline))
        http.Handle("/debug/pprof/profile", http.HandlerFunc(Profile))
        http.Handle("/debug/pprof/symbol", http.HandlerFunc(Symbol))
        http.Handle("/debug/pprof/trace", http.HandlerFunc(Trace))
    }

如果是gonic, 由于它没有使用`http`, 我们要手动注册路由——监控性能采样请求

### gonic pprof
https://github.com/DeanThompson/ginpprof 为我们提供了api：

    import "github.com/DeanThompson/ginpprof"
    ...
    router := gin.Default()
    ginpprof.Wrap(router)
    ...

编译运行后访问 http://localhost:4500/debug/pprof/ 查看采样统计指标, 通常重点关注`profile`cpu 与`heap`内存占用这两个指标

1. profile: CPU profile. 
2. heap: A sampling of memory allocations of live objects. (**not including gc bytes**)
3. allocs: A sampling of all past memory allocations (**including garbage-collected bytes**)
4. block: Stack traces that led to blocking on synchronization primitives
5. cmdline: The command line invocation of the current program
6. goroutine: Stack traces of all current goroutines
7. mutex: Stack traces of holders of contended mutexes
8. threadcreate: Stack traces that led to the creation of new OS threads
9. trace: A trace of execution of the current program. 

点击`full goroutine stack dump`，可看到所有 goroutine 的调用栈。

点击对应的 profile 可以查看具体信息，通过浏览器查看的数据不能直观反映程序性能问题，go tool pprof 命令行工具提供了丰富的工具集:

    # 下载 cpu profile，默认从当前开始收集 30s 的 cpu 使用情况，需要等待 30s
    go tool pprof -http=:4550 http://localhost:4500/debug/pprof/profile
    # wait 120s
    go tool pprof http://localhost:4500/debug/pprof/profile?seconds=120     
    go tool pprof -seconds=120 http://localhost:4500

    # 下载 heap profile
    go tool pprof http://localhost:4500/debug/pprof/heap

    # 下载 goroutine profile
    go tool pprof http://localhost:4500/debug/pprof/goroutine

    # 下载 block profile
    go tool pprof http://localhost:4500/debug/pprof/block

    # 下载 mutex profile
    go tool pprof http://localhost:4500/debug/pprof/mutex

#### http模式分析prof 文件
点击 profile 和 trace 则会在后台进行一段时间的数据采样，采样完成后，返回给浏览器一个 profile 文件，之后在本地通过 go tool pprof 工具进行分析:

    go tool pprof [-http=":4501"] [binary] <profile
    go tool pprof -http=:4501   /Users/ahui/pprof/pprof.samples.cpu.005.pb.gz

### pprof CPU 分析
先执行压测试

    $ echo "GET http://localhost:4500/cpu/5" | vegeta attack  -rate=10000  -duration=10s |vegeta report
    Running 50s test @ http://localhost:4500/cpu/5
    50 goroutine(s) running concurrently

为了分析 CPU 热点代码。 执行下面采集 30s 的 profile 数据，30s之后进入终端交互模式，输入 top 指令, `top -cum`。

    $ go tool pprof http://localhost:4500 ;# 简写
    $ go tool pprof http://localhost:4500/debug/pprof/profile
    Saved profile in /Users/ahui/pprof/pprof.samples.cpu.010.pb.gz
    Type: cpu
    Entering interactive mode (type "help" for commands, "o" for options)
    (pprof) top
          flat  flat%   sum%        cum   cum%
       158.35s 88.75% 88.75%    177.85s 99.67%  ginapp/server.longRun
        14.03s  7.86% 96.61%     14.03s  7.86%  runtime.asyncPreempt
         5.47s  3.07% 99.67%      5.47s  3.07%  runtime.walltime1
             0     0% 99.67%    177.89s 99.70%  ginapp/server.cpuFunc
             0     0% 99.67%    177.89s 99.70%  github.com/gin-gonic/gin.(*Context).Next
             0     0% 99.67%    177.89s 99.70%  github.com/gin-gonic/gin.(*Engine).ServeHTTP
             0     0% 99.67%    177.89s 99.70%  github.com/gin-gonic/gin.(*Engine).handleHTTPRequest
             0     0% 99.67%    178.28s 99.92%  net/http.(*conn).serve
             0     0% 99.67%    177.89s 99.70%  net/http.serverHandler.ServeHTTP
             0     0% 99.67%      5.47s  3.07%  runtime.walltime (inline)

解释下： https://stackoverflow.com/questions/32571396/pprof-and-golang-how-to-interpret-a-results

    flat 是函数自身的cpu 占用
    sum% 之前累加每一行flat%的累加（见top方法）
    cum 包含函数调用的时间，比如cpuFunc 就包含了longRun 的时间

#### profile: view peek/source
点source 可以查看top点的源码
点peek 可以查看top点的调用栈及路径(calls% 表示cum消耗 在所在函数中的比分比)

    ----------------------------------------------------------+-------------
        0.63MB  5.54% |   github.com/swaggo/files.init.16 /github.com/swaggo/files@v1.0.1/b0xfile__swagger-ui.css.map.go:21
        0.57MB  5.03% |   github.com/swaggo/files.init.15 /github.com/swaggo/files@v1.0.1/b0xfile__swagger-ui.css.go:21
   11.40MB  0.49% 99.83%    11.40MB  0.49%                | golang.org/x/net/webdav.(*memFile).Write /golang.org/x/net@v0.10.0/webdav/file.go:601

#### profile: http 查看火焰图 
http 用法有:

    go tool pprof [-http=":4501"] [binary] <profile
    go tool pprof -http=:4501   ~/pprof/pprof.samples.cpu.005.pb.gz
    go tool pprof -http=:4501  'http://localhost:9090/debug/pprof/heap?seconds=30'
    go tool pprof -http=:4502 -inuse_space  'http://localhost:9090/debug/pprof/heap?seconds=30'

然后点击: `view->flamegraph` 访问火焰图: `http://localhost:4501/ui/flamegraph`

说明：

    graph:
        节点连线表示函数调用，如果是虚线表示省略了一些节点
        带有inline字段表示该函数被内联进了调用方

##### profile: web 生成调用关系图

    $ go tool pprof --seconds 10 http://localhost:9090/debug/pprof/profile
    Please wait... (10s)
    (pprof) web

这样我们可以得到一个完整的程序调用性能采样profile的输出,如下图：
![](/img/go/profile/pprof-simple.png)

### pprof mem 分析
    go tool pprof -http=:4503 -inuse_space  http://m:8085/debug/pprof/heap
    go tool pprof -http=:4503 -alloc_space  http://m:8085/debug/pprof/heap

pprof 支持内存分析，找出内存消耗大的代码:

    $ go tool pprof -http=:4501 http://localhost:4500/debug/pprof/heap
    Saved profile in ~/pprof/pprof.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz
    Type: alloc_space
    Time: Jun 1, 2021 at 4:14pm (CST)
    Entering interactive mode (type "help" for commands, "o" for options)
    (pprof) top
    Showing nodes accounting for 15.32MB, 79.79% of 19.21MB total
    Showing top 10 nodes out of 48
        flat    flat%   sum%        cum   cum%
        2.50MB  13.02% 13.02%     2.50MB 13.02%  net/http.Header.Clone
        2.31MB  12.04% 25.06%     2.31MB 12.04%  runtime/pprof.StartCPUProfile
        2MB     10.44% 35.50%       2MB 10.44%  bufio.NewWriterSize
        1.50MB  7.81% 43.32%     1.50MB  7.81%  net/textproto.(*Reader).ReadMIMEHeader
        1.50MB  7.81% 51.13%        2MB 10.41%  context.WithCancel
        1.50MB  7.81% 58.94%     1.50MB  7.81%  context.WithValue
        1MB     5.23% 64.16%        1MB  5.23%  bufio.NewReaderSize
        1MB     5.21% 69.37%        1MB  5.21%  github.com/gin-gonic/gin/render.writeContentType
        1MB     5.21% 74.58%        3MB 15.62%  net/http.readRequest
        1MB     5.21% 79.79%        1MB  5.21%  net/http.(*Server).newConn
    (pprof)

#### 关于alloc/inuse 显示
释放data 内存后:(示例参考 golib/gonic/ginapp/server/stat/stat-os.go), alloc/inuse 不同的工具看到的结果不一样 

1. debug/pprof/heap?debug=1 会看到 heapAlloc/heapInuse 减少(实时)
2. go tool pprof debug/pprof/heap 则看到 Alloc_space 未减少，而heap_space 减少(有采样延时，要等一下看到)

指标说明, 可以在Sample菜单中切换`inuse_space/inuse_objects/alloc_space`, alloc 包含所有被释放的内存, inuse是指正在使用的内存

    -inuse_space      Display in-use memory size(important)
    -inuse_objects    Display in-use object counts
    -alloc_space      Display allocated memory size
    -alloc_objects    Display allocated object counts

命令行中, 可直接这样切换：

    > sample_index=alloc_objects
    > sample_index=alloc_space
    > top -cum 

## Memory leak(内存泄露分析)
参考【大彬】的[实战Go内存泄露]https://segmentfault.com/a/1190000019222661
主要有两种方法

### 通过pprof -base 对比
思路是先生成两个时间点的pprof 文件，然后利用`go tool pprof -base`对比两个时间的内存消耗:

    go tool pprof -base app.20210101.001.pb.gz app.20210102.002.pb.gz
    (pprof) list main  (对比变化)
    (pprof) top

### 观察goroutine 阻塞
http://ip:port/debug/pprof/goroutine?debug=1 可查看阻塞数`goroutine profile: total 107`

    goroutine profile: total 107 (当前goroutine阻塞数量)
    40 @ 0x42f7cf 0x42aeda 0x42a4c6 0x4c482b 0x4c563b 0x4c561c 0x527b4f 0x53c9b9 0x6f5797 0x5557bf 0x55591f 0x6f745a 0x6fb02d 0x45cf71 (40个goroutine停止在这个调用栈, 一个常见的原因是读写chan 死锁或者网络等待)
    #	0x42a4c5	internal/poll.runtime_pollWait+0x55		/usr/local/go/src/runtime/netpoll.go:182
    #	0x4c482a	internal/poll.(*pollDesc).wait+0x9a		/usr/local/go/src/internal/poll/fd_poll_runtime.go:87

http://ip:port/debug/pprof/goroutine?debug=2 可查看阻塞原因、阻塞多久:

    goroutine 1 [chan receive, 1406 minutes]:(阻塞了1406 分钟)
    main.main() /go/src/app/cmd/main.go:39 +0x29f

# benchmark 生成profile
源码 https://github.com/ahuigo/playflame/tree/slow/stats

go test -bench 支持几个参数: 

    -cpuprofile=$FILE
    -memprofile=$FILE, -memprofilerate=N #调整记录速率为原来的 1/N。
    -blockprofile=$FILE

## bench -cpuprofile
先生成cpu.pprof

    git clone https://github.com/ahuigo/playflame
    cd playflame/stats
    git checkout slow
    $ go test -bench . -benchmem -cpuprofile=cpu.pprof
    BenchmarkAddTagsToName-4   	 1000000	      2138 ns/op	     487 B/op	      18 allocs/op

分析一下cpu.pprof, 注意2138ns/op ，说明很慢

    $ go tool pprof stats.test  cpu.pprof
    Entering interactive mode (type "help" for commands, "o" for options)
    (pprof) top10
      flat  flat%   sum%        cum   cum%
      90ms 10.34% 10.34%       90ms 10.34%  regexp/syntax.(*Inst).MatchRunePos
      90ms 10.34% 20.69%      240ms 27.59%  runtime.mallocgc
      80ms  9.20% 29.89%      240ms 27.59%  regexp.(*Regexp).tryBacktrack
      50ms  5.75% 35.63%       50ms  5.75%  runtime.heapBitsSetType
      50ms  5.75% 41.38%       50ms  5.75%  runtime.nextFreeFast
      50ms  5.75% 47.13%      860ms 98.85%  stats.addTagsToName
      40ms  4.60% 51.72%      580ms 66.67%  regexp.(*Regexp).ReplaceAllString
      40ms  4.60% 56.32%       40ms  4.60%  regexp.(*inputString).step
      30ms  3.45% 59.77%      380ms 43.68%  regexp.(*Regexp).backtrack
      30ms  3.45% 63.22%       50ms  5.75%  regexp.(*bitState).push

从排行榜看到，大概regexp很大关系，但这不好看出真正问题，需要再用别的招数

我们在(pprof)后，输入list addTagsToName， 分析基准测试文件中具体的方法

    (pprof) list addTagsToName
    Total: 870ms
    ROUTINE ======================== stats.addTagsToName in /Users/ahui/go/src/github.com/ahuigo/playflame/stats/reporter.go
        50ms      860ms (flat, cum) 98.85% of Total
            .          .     34:}
            .          .     35:
            .          .     36:func addTagsToName(name string, tags map[string]string) string {
            .          .     37:	var keyOrder []string
            .          .     38:	if _, ok := tags["host"]; ok {
        20ms       40ms     39:		keyOrder = append(keyOrder, "host")
            .          .     40:	}
            .       50ms     41:	keyOrder = append(keyOrder, "endpoint", "os", "browser")
            .          .     42:
        10ms       10ms     43:	parts := []string{name}
            .          .     44:	for _, k := range keyOrder {
            .       20ms     45:		v, ok := tags[k]
            .          .     46:		if !ok || v == "" {
            .          .     47:			parts = append(parts, "no-"+k)
            .          .     48:			continue
            .          .     49:		}
        20ms      710ms     50:		parts = append(parts, clean(v))
            .          .     51:	}
            .          .     52:
            .       30ms     53:	return strings.Join(parts, ".")
            .          .     54:}
            .          .     55:
            .          .     56:var specialChars = regexp.MustCompile(`[{}/\\:\s.]`)
            .          .     57:
            .          .     58:func clean(value string) string {

可以看到两个时间: selfTime(自身的时间) cumTime. 说明clean 占用时间最多

    (pprof) list clean
    Total: 870ms
    ROUTINE ======================== stats.clean in /Users/hilojack/go/src/github.com/ahuigo/playflame/stats/reporter.go
        10ms      590ms (flat, cum) 67.82% of Total
            .          .     54:}
            .          .     55:
            .          .     56:var specialChars = regexp.MustCompile(`[{}/\\:\s.]`)
            .          .     57:
            .          .     58:func clean(value string) string {
        10ms      590ms     59:	return specialChars.ReplaceAllString(value, "-")
            .          .     60:}

既然正则最慢，那我们还是用普通字符替换吧！

    func clean(value string) string {
        newStr := make([]byte, len(value))
        for i := 0; i < len(value); i++ {
            switch c := value[i]; c {
            case '{', '}', '/', '\\', ':', ' ', '\t', '.':
                newStr[i] = '-'
            default:
                newStr[i] = c
            }
        }
        return string(newStr)
    }

再压测，性能提升到765ns/op 了

    $ go test -bench . -benchmem -cpuprofile prof.cpu
    BenchmarkAddTagsToName-4   	 2000000	       765 ns/op	     400 B/op	      14 allocs/op

注意我们的内存分配次数14allocs/op, 下面我们再优化下mem

## bench -memprofile
生成memProfile 

    go test -bench . -benchmem -memprofile prof.mem
    14 allocs/op

分析mem:

    $ go tool pprof --alloc_objects  stats.test prof.mem
    Entering interactive mode (type "help" for commands)
    (pprof) top
    Showing nodes accounting for 27739275, 100% of 27739275 total
          flat  flat%   sum%        cum   cum%
      14992237 54.05% 54.05%   27739275   100%  stats.addTagsToName
       9732244 35.08% 89.13%    9732244 35.08%  stats.clean
       3014794 10.87%   100%    3014794 10.87%  strings.(*Builder).grow

    (pprof) list addTagsToName
    Total: 27739275
    ROUTINE ======================== stats.addTagsToName in /Users/hilojack/go/src/github.com/ahuigo/playflame/stats/reporter.go
      14992237   27739275 (flat, cum)   100% of Total
             .          .     34:func addTagsToName(name string, tags map[string]string) string {
             .          .     35:	var keyOrder []string
             .          .     36:	if _, ok := tags["host"]; ok {
       2621480    2621480     37:		keyOrder = append(keyOrder, "host")
             .          .     38:	}
       2916530    2916530     39:	keyOrder = append(keyOrder, "endpoint", "os", "browser")
             .          .     40:
             .          .     41:	parts := []string{name}
             .          .     42:	for _, k := range keyOrder {
             .          .     43:		v, ok := tags[k]
             .          .     44:		if !ok || v == "" {
             .          .     45:			parts = append(parts, "no-"+k)
             .          .     46:			continue
             .          .     47:		}
       9454227   19186471     48:		parts = append(parts, clean(v))
             .          .     49:	}
             .          .     50:
             .    3014794     51:	return strings.Join(parts, ".")
             .          .     52:}

原方案是采用slice存放字符串元素，最后通过string.join()来拼接， 我们多次调用了append方法，而在go里面slice其实如果容量不够的话，就会触发分配. 我们可优化为预先分配：

    parts := make([]string, 1, 50)

不过，strings 做join 比较慢，我们可以采用:

1. buffer 优化代替string 拼接：
2. 进一步，利用buffer 池，减少内存分配

代码参考: /playflame/stats/reporter.go

    var bufPool = sync.Pool{
        New: func() interface{} {
            return &bytes.Buffer{}
        },
    }

    func addTagsToName(name string, tags map[string]string) string {
        ....
        buf := bufPool.Get().(*bytes.Buffer)
        defer bufPool.Put(buf)
        buf.Reset()
        buf.WriteString(name)
        ....
        return buf.String()
    }

# 实例
## 踩坑记： go 服务内存暴涨
https://www.v2ex.com/t/666257#reply94
## futex大量占用cpu 30%
系统空闲，并没有别的goroutine可供调度，协程调度反复高频出现, Go的scheduler就必须让这个M去sleep，而这个操作是较重的且有锁，最终futex的syscall被调用
https://zhuanlan.zhihu.com/p/45959147


# 参考
- [Go代码调优利器-火焰图](https://lihaoquan.me/2017/1/1/Profiling-and-Optimizing-Go-using-go-torch.html) 
- [极客兔兔 pprof性能分析]: https://geektutu.com/post/hpg-pprof.html
