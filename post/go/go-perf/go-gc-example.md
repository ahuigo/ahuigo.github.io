---
title: golang gc
date: 2023-09-01
private: true
---
# gc 示例
> 释放data 内存后:(示例参考 golib/gonic/ginapp/server/stat/stat-os.go), alloc/inuse 不同的工具看到的结果不一样 

curl 'm:4500/stat/gc?act=large-memory' 后，
再 debug/pprof/heap?debug=1 会看到 heapAlloc/heapInuse 减少(会触发一次gc)
再go tool pprof -http=:4501 -alloc_space m:4500/debug/pprof/heap 

    TotalAlloc = 2,428791168
    Sys = 2490762072
    Lookups = 0
    Mallocs = 36382
    Frees = 23494
    HeapAlloc = 2,426764664
    HeapIdle = ,11,403,264
    HeapInuse = 2,429,026,304
    HeapReleased = ,10,469376
    HeapObjects = 12888
    Stack = 655360 / 655360
    MSpan = 167840 / 179520
    MCache = 12000 / 15600
    BuckHashSys = 1450481
    GCSys = 46082840
    OtherSys = 1948703
    NextGC = 11932863240
    LastGC = 1693554580854103000

curl 'm:4500/stat/gc?act=gc' gc 后:

    TotalAlloc = 2,429,005864 (total不变)
    Sys = 2491089752
    Lookups = 0
    Mallocs = 38145
    Frees = 25162
    HeapAlloc = ,10,860,768 (alloc: down)
    HeapIdle = 2,427281408 (idle: up, idle 包含未释放给os的)
    HeapInuse = ,13,115392  (inuse: down)
    HeapReleased = ,10,756096
    HeapObjects = 12983
    Stack = 688128 / 688128
    MSpan = 167840 / 179520
    MCache = 12000 / 15600
    BuckHashSys = 1451113
    GCSys = 46197672
    OtherSys = 2160919

curl 'm:4500/stat/gc?act=gc&type=os' gc+os release后:

    FreeOSMemory 后
    TotalAlloc = 2,429215784
    Sys = 2,491,089752
    Lookups = 0
    Mallocs = 40073
    Frees = 27230
    HeapAlloc = 10788096
    HeapIdle = 2,427,363328
    HeapInuse = 13066240
    HeapReleased = 2,426863616 (release: up)
    HeapObjects = 12843
    Stack = 655360 / 655360
    MSpan = 167840 / 179520
    MCache = 12000 / 15600
    BuckHashSys = 1451113