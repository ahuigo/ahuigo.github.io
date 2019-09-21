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


