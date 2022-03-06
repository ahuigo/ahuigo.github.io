---
title: go string perfmance
date: 2022-02-26
private: true
---
# go string perfmance
## string concat
go 中的string 是不是变长，`+`拼接时会不断申请释放内存。

可优化为：
1. make(strings.Builder).WriteString (recommended)
1. bytes.Buffer new(bytes.Buffer).WriteString
1. []byte append

### string.Buffer example

    var s strings.Builder
	for i := 0; i < n; i++ {
		s.WriteString(randomString(n))
	}
    return s.String()



builder 分配分配是指数增长的：

    func TestBuilderConcat(t *testing.T) {
        var str = randomString(10)
        var builder strings.Builder
        cap := 0
        for i := 0; i < 10000; i++ {
            if builder.Cap() != cap {
                fmt.Print(builder.Cap(), " ")
                cap = builder.Cap()
            }
            builder.WriteString(str)
        }
    }
    BenchmarkBuilderConcat-8    8901    0.13 ms/op   0.5 MB/op      23 allocs/op

grow 预先分配优化

    func builderConcat(n int, str string) string {
        var builder strings.Builder
        builder.Grow(n * len(str))
        for i := 0; i < n; i++ {
            builder.WriteString(str)
        }
        return builder.String()
    }

    BenchmarkBuilderConcat-8   16855    0.07 ns/op   0.1 MB/op       1 allocs/op

bytes.Buffer 转化为字符串时重新申请了一块空间，存放生成的字符串变量，而 strings.Builder 直接将底层的 []byte 转换成了字符串类型返回了回来

    // String returns the accumulated string.
    func (b *Builder) String() string {
        return *(*string)(unsafe.Pointer(&b.buf))
    }

# References
- https://geektutu.com/post/hpg-string-concat.html