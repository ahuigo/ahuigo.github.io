---
title: golang atom 使用
date: 2020-07-25
private: true
---
# golang atom 使用

    func main() {
        var TotalAmount int64
        var wg sync.WaitGroup

        for i := 0; i < 9999999; i++ {
            wg.Add(1)
            go atomicPlus()
        }

        wg.Wait()
        println(TotalAmount)
    }

    func atomicPlus() {
        defer wg.Done()
        atomic.AddInt64(&TotalAmount, 1)
    }