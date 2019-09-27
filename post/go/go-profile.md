---
title: Go profile
date: 2019-08-23
private:
---
# Go profile
本文为 [Go代码调优利器-火焰图](https://lihaoquan.me/2017/1/1/Profiling-and-Optimizing-Go-using-go-torch.html) 笔记

### Go profiler 指标
使用Go 内置的profiler我们能获取以下的样本信息：

    CPU profiles
    Heap profiles
    block profile、traces等

### go profiling常用的分析工具
1. 基准测试文件：例如使用命令go test . -bench . -cpuprofile prof.cpu 生成采样文件后，再通过命令 `go tool pprof [binary] prof.cpu` 来进行分析。(有点类似php的xhprof 的调用关系图，调用关系复杂就不直观了)

2. `import _ net/http/pprof`：如果我们的应用是一个web服务，我们可以在http服务启动的代码文件(eg: main.go)添加 import _ net/http/pprof，这样我们的服务 便能自动开启profile功能，有助于我们直接分析采样结果。

3. 通过在代码里面调用 `runtime.StartCPUProfile`或者`runtime.WriteHeapProfile`

更多调试的使用，建议可以阅读The Go Blog的 Profiling Go Programs

## go-torch 火焰
### install
首先，我们要配置FlameGraph的脚本 FlameGraph 是profile数据的可视化层工具

    git clone https://github.com/brendangregg/FlameGraph.git
    cp flamegraph.pl ~/bin
    flamegraph.pl -h
    USAGE: /usr/local/bin/flamegraph.pl [options] infile > outfile.svg


安装go-torch很简单(用于go-torch展示profile的输出)

    go get -v github.com/uber/go-torch
    $ go-torch -h
    Usage:
    go-torch [options] [binary] <profile source>

### 调优实例
1. 下载 [demo](https://github.com/domac/playflame/tree/slow) 代码
2. 运行：$ go run main.go -printStats

#### pprof profile 调用关系图
接下来我们用go-wrk （或者ab、siege）压测advanced 接口

    go-wrk  -n=100000 -c=500  http://localhost:9090/advance

在上面的压测过程中，我们再新建一个终端窗口输入以下命令，生成我们的profile文件：

    $ go tool pprof --seconds 10 http://localhost:9090/debug/pprof/profile

命令中，我们设置了10秒的采样时间，当看到(pprof)的时候，我们输入 web, 表示从浏览器打开

    Fetching profile from http://localhost:9090/debug/pprof/profile?seconds=25
    Please wait... (25s)
    Saved profile in /Users/ahui/pprof/pprof.localhost:9090.samples.cpu.014.pb.gz
    Entering interactive mode (type "help" for commands)
    (pprof) web

这样我们可以得到一个完整的程序调用性能采样profile的输出,如下图：
![](/img/go/profile/pprof-simple.png)

调用图太不直观了，我们需要简单的火焰图

#### Flame 图
先压测：

    $ go-wrk  -n=100000 -c=500  http://localhost:9090/advance

压测过程中用 go-torch来生成采样报告, 30s后出报告:

    $ go-torch -u http://localhost:9090 -t 30
    INFO[08:47:10] Run pprof command: go tool pprof -raw -seconds 30 http://localhost:9090/debug/pprof/profile
    INFO[08:47:41] Writing svg to torch.svg

火焰图的y轴表示cpu调用方法的先后，x轴表示在每个采样调用时间内，方法所占的时间百分比，越宽代表占据cpu时间越多

