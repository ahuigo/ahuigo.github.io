---
title: go build assembly
date: 2020-07-24
private: true
---
# go build assembly
> 相关代码： go-lib/go-debug/assembly/file.go
产生汇编有几种方法: https://www.reddit.com/r/golang/comments/6a5557/how_to_get_assembly_output_from_a_small_go_program/

目标文件的汇编

    go tool compile -S file.go > file.S

最终生成binary 对应的汇编

    go build -gcflags -S file.go 2>& file2.S

从二进制反向汇编：(带有runtime 执行时，非常大)

    go tool objdump executable > disassembly


