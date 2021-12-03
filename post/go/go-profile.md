---
title: Go profiler
date: 2019-08-23
private:
---
# Go profiler

## Go profiler 指标
使用Go 内置的profiler我们能获取以下的样本信息：

    CPU profiles
    Heap profiles
    block profile、traces等

## go profiling相关的分析工具
主要有以下几种工具
1. `go test` 基准测试文件：比如使用命令`go test . -bench=. -cpuprofile prof.cpu` 生成采样文件后，再通过命令 `go tool pprof [binary] prof.cpu` 来进行分析。
2. `runtime` 工具：通过在代码里面调用 `runtime.StartCPUProfile`或者`runtime.WriteHeapProfile`等能方便的采集程序运行的`堆栈、goroutine、内存分配和占用、io 等信息`并生成 `.prof` 文件.
3. `net/http/pprof`：用于分析http 服务的性能瓶颈. 其实其内部调用的就是`runtime`

> 更多调试的使用，可以阅读The Go Blog的 Profiling Go Programs

# go tool pprof分析
> 参考：深度解密Go语言之pprof https://segmentfault.com/a/1190000020964967
`go tool pprof` 可以实现分析 `.prof` 文件、下载prof并分析. 下面具体总结一下

## runtime/pprof
如果程序不是http server, 就用[go-lib/gotest/pprof/runtime-pprof.go](https://github.com/ahuigo/go-lib/blob/master/test/pprof/runtime-pprof.go)

运行程序后可以得到 cpu.prof 和 mem.prof 文件，使用 go tool pprof 分析。

    go tool pprof [binary] cpu.prof
    go tool pprof [binary] mem.prof

example:

    $ go run runtime-pprof.go
    $ go tool pprof cpu.prof
    (pprof) top
    (pprof) web

### 分析时可包含可执行文件
比如`hello`：

    $ go build -o hello runtime-pprof.go
    $ go tool pprof hello cpu.prof

### 将分析输出为 pdf 格式文件：

    go tool pprof --pdf hello cpu.prof > cpu.pprof.pdf

## net/http/pprof
> 示例：github.com/ahuigo/go-lib/gonic/ginapp/gin-pprof.go
如果程序为 web 服务， 我们则可借助`net/http/pprof`包 来完成profile 采样:

如果是`http` server, 只需要引入`import _ "net/http/pprof"` 就可监控性能请求

    // src/net/http/pprof/pprof.go
    func init() {
        http.Handle("/debug/pprof/", http.HandlerFunc(Index))
        http.Handle("/debug/pprof/cmdline", http.HandlerFunc(Cmdline))
        http.Handle("/debug/pprof/profile", http.HandlerFunc(Profile))
        http.Handle("/debug/pprof/symbol", http.HandlerFunc(Symbol))
        http.Handle("/debug/pprof/trace", http.HandlerFunc(Trace))
    }

如果是gonic, 由于它没有使用`http`, 我们要手动注册路由.

### gonic pprof
以gonic 为例, 我们需要增加几个路由实际回传profile 采样: 

    import "net/http/pprof"

    router := gin.Default()
	router.Handle("GET", "/debug/pprof/", func(ctx *gin.Context) {
        pprof.Index(ctx.Writer, ctx.Request)
    })
	router.Handle("GET", "/debug/pprof/profile", func(ctx *gin.Context) {
        pprof.Profile(ctx.Writer, ctx.Request)
    })
	router.Handle("GET", "/debug/pprof/heap", func(ctx *gin.Context) {
        pprof.Handler("heap").ServeHTTP(ctx.Writer, ctx.Request)
    })
    ....

实际上 https://github.com/DeanThompson/ginpprof 为我们提供了上述代码的封装：

    import "github.com/DeanThompson/ginpprof"
    ...
    router := gin.Default()
    ginpprof.Wrap(router)
    ...

编译运行后访问 http://localhost:4500/debug/pprof/ 查看采样统计

    count profiles: 
    0     profile  cpu占用采样
    4     heap      堆上内存采样
    4     allocs    内存分配采样
    0     mutex     锁竞争采样
    62    goroutine 协程调用栈
    0     block     阻塞操作采样
    12    threadcreate 线程创建采样
    full goroutine stack dump

allocs 和 heap 采样的信息一致，不过前者是所有对象的内存分配，而 heap 则是活跃对象的内存分配。

> The difference between the two is the way the pprof tool reads there at start time. Allocs profile will start pprof in a mode which displays the total number of bytes allocated since the program began (including garbage-collected bytes).

关于 goroutine 的信息有两个链接，`goroutine 和 full goroutine stack dump`，前者是一个汇总的消息，可以查看 goroutines 的总体情况，后者则可以看到每一个 goroutine 的状态。页面具体内容的解读可以参考【大彬】的文章:https://segmentfault.com/a/1190000019222661

点击对应的 profile 可以查看具体信息，通过浏览器查看的数据不能直观反映程序性能问题，go tool pprof 命令行工具提供了丰富的工具集:

    # 下载 cpu profile，默认从当前开始收集 30s 的 cpu 使用情况，需要等待 30s
    go tool pprof http://localhost:4500/debug/pprof/profile
    # wait 120s
    go tool pprof http://localhost:4500/debug/pprof/profile?seconds=120     

    # 下载 heap profile
    go tool pprof http://localhost:4500/debug/pprof/heap

    # 下载 goroutine profile
    go tool pprof http://localhost:4500/debug/pprof/goroutine

    # 下载 block profile
    go tool pprof http://localhost:4500/debug/pprof/block

    # 下载 mutex profile
    go tool pprof http://localhost:4500/debug/pprof/mutex


点击 profile 和 trace 则会在后台进行一段时间的数据采样，采样完成后，返回给浏览器一个 profile 文件，之后在本地通过 go tool pprof 工具进行分析:

    go tool pprof [-http=":4501"] [binary] <profile
    go tool pprof -http=:4501   /Users/ahui/pprof/pprof.samples.cpu.005.pb.gz

### pprof CPU 分析
采集 profile 数据之后，可以分析 CPU 热点代码。 先执行压测试

    $ go-wrk  -d=50 -c=50  http://localhost:4500/cpu/5
    Running 50s test @ http://localhost:4500/cpu/5
    50 goroutine(s) running concurrently

再执行下面采集 30s 的 profile 数据，30s之后进入终端交互模式，输入 top 指令, `top -cum`。

    $ go tool pprof http://localhost:4500 ;# 简写
    $ go tool pprof http://localhost:4500/debug/pprof/profile
    Fetching profile over HTTP from http://localhost:4500/debug/pprof/profile
    Saved profile in /Users/ahui/pprof/pprof.samples.cpu.010.pb.gz
    Type: cpu
    Time: Jun 1, 2021 at 4:10pm (CST)
    Duration: 30s, Total samples = 420ms ( 1.40%)
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

#### profile: http 查看火焰图 
http 用法有:

    go tool pprof [-http=":4501"] [binary] <profile
    go tool pprof -http=:4501   /Users/ahui/pprof/pprof.samples.cpu.005.pb.gz
    go tool pprof -http=:4501  'http://localhost:9090/debug/pprof/heap?seconds=30'
    go tool pprof -http=:4502 -inuse_space  'http://localhost:9090/debug/pprof/heap?seconds=30'

然后点击: `view->flamegraph` 访问火焰图: `http://localhost:4501/ui/flamegraph`

#### profile: web 生成调用关系图

    $ go tool pprof --seconds 10 http://localhost:9090/debug/pprof/profile
    Please wait... (10s)
    (pprof) web

这样我们可以得到一个完整的程序调用性能采样profile的输出,如下图：
![](/img/go/profile/pprof-simple.png)

### pprof mem 分析
pprof 支持内存分析，找出内存消耗大的代码

--inuse_space 分析常驻内存

    $ go tool pprof -inuse_space http://localhost:4500/debug/pprof/heap

--alloc_objects 分析临时内存

    $ go tool pprof -alloc_space http://localhost:4500/debug/pprof/heap
    Saved profile in /Users/ahui/pprof/pprof.alloc_objects.alloc_space.inuse_objects.inuse_space.002.pb.gz
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

### go-torch 火焰图分析
go-torch 是一款非官方的profile 分析工具. 功能已经集成到官方的`go tool pprof`了

    go get -v github.com/uber/go-torch
    $ go-torch -h
    Usage:
    go-torch [options] [binary] <profile source>

用法示例:

    # cpu 火焰图
    go-torch -u http://localhost:4500 
    go-torch -u http://localhost:9090 -t 30

    # inuse_space 火焰图
    go-torch -inuse_space http://localhost:4500/debug/pprof/heap --colors=mem
    # alloc_space 火焰图
    go-torch -alloc_space http://localhost:4500/debug/pprof/heap --colors=mem

# 官方的bench工具：go test -bench
源码 https://github.com/ahuigo/playflame/tree/slow/stats

## bench cpu
我们来压测下stats 这个目录

    git clone https://github.com/ahuigo/playflame
    cd playflame/stats
    $ go test -bench . -benchmem -cpuprofile prof.cpu
    BenchmarkAddTagsToName-4   	 1000000	      2138 ns/op	     487 B/op	      18 allocs/op

注意2138ns/op ，说明很慢

    $ go tool pprof stats.test  prof.cpu
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

### bench mem
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

代码参考: go-lib/master/stats/reporter.go

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
