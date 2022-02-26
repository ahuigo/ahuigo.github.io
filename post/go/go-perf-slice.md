---
title: go slice perf
date: 2022-02-26
private: true
---
# go slice perf
## slice vs copy
- 返回`s[:2]` 返回后，底层有引用不会释放
- 返回 `copy(newS, s[:2])`，底层会释放

后者更节省内存: 测试代码见 `go-lib/perf/slice-vs-copy_test.go`

    go test -run=^TestLastChars -count=1  -v .
    === RUN   TestLastCharsBySlice
        slice-vs-copy_test.go:47: 100.15 MB
    --- PASS: TestLastCharsBySlice (0.27s)
    === RUN   TestLastCharsByCopy
        slice-vs-copy_test.go:48: 0.16 MB
    --- PASS: TestLastCharsByCopy (0.26s)

# reference
- 切片(slice)性能及陷阱 https://geektutu.com/post/hpg-slice.html