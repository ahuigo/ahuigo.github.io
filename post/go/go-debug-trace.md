---
title: go debug trace
date: 2021-07-05
private: true
---
# go debug trace
## call stack
    // go-lib/go-debug/trace/trace_test.go
    import(
    "runtime/debug"
    )
    ...    
    debug.PrintStack()

## err trace

    fmt.Printf("%+v\n", err)