---
title: Go profiler
date: 2019-08-23
private:
---
# Go block 采样
## 先开启 block 采样

    import _ "net/http/pprof"
    import "net/http"
    func main(){
        go func() {
            log.Println(http.ListenAndServe("localhost:4500", nil))
        }()
        ...
    }
    // 开启阻塞分析
    runtime.SetBlockProfileRate(1)

## 开始采样
访问 debug/pprof/block?debug=1

    go tool pprof -http=:8004 m:9090/debug/pprof/block

## 分析采样