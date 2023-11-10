---
title: golang tool trace
date: 2023-08-29
private: true
---
# golang tool trace
## todo
https://about.sourcegraph.com/blog/go/an-introduction-to-go-tool-trace-rhys-hiltner
https://mp.weixin.qq.com/s/I9xSMxy32cALSNQAN8wlnQ

## 背景
go tool pprof 在 CPU profile 中是看不到以下函数操作
> time.Sleep 函数让当前的 goroutine 进入休眠状态，这种情况下 CPU 将不会执行任何操作，profile 不会有记录
> 例如，竞争和逻辑冲突

可以使用 runtime/trace 工具:
1. go tool trace是调试并发问题的强大工具。


# 生成trace.out
## web 生成
    curl localhost:8181/debug/pprof/trace?seconds=10 > trace.out

## cli 生成
    // golib/perf/pprof/runtime-pprof.go
    f, _ := os.Create("trace.out")
    defer f.Close()

    trace.Start(f)
    defer trace.Stop()


