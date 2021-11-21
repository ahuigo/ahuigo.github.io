---
title: Go Sync.Pool
date: 2019-10-02
---

# 性能tips
参考coolshell 的文章
1. 使用`StringBuffer` 或是`StringBuild` 来拼接字符串，会比使用 `+ 或 +=` 性能高三到四个数量级。
2. 使用 I/O缓冲，I/O是个非常非常慢的操作，使用 bufio.NewWrite() 和 bufio.NewReader() 可以带来更高的性能。(参考[/p/go/go-file.md])
2. 使用 lock-free的操作，避免使用 mutex，尽可能使用 sync/Atomic包。 （关于无锁编程的相关话题，可参看《无锁队列实现》或《无锁Hashmap实现》）
3. 对于在for-loop里的固定的正则表达式，一定要使用 regexp.Compile() 编译正则表达式。性能会得升两个数量级。
4. 如果你需要更高性能的协议，你要考虑使用 protobuf 或 msgp 而不是JSON，因为JSON的序列化和反序列化里使用了反射。
5. 你在使用map的时候，使用整型的key会比字符串的要快，因为整型比较比字符串比较要快。

## 其它性能提升的文章
还有很多不错的技巧，下面的这些参考文档可以让你写出更好的Go的代码，必读！

- Effective Go
https://golang.org/doc/effective_go.html
- Uber Go Style
https://github.com/uber-go/guide/blob/master/style.md
- 50 Shades of Go: Traps, Gotchas, and Common Mistakes for New Golang Devs
http://devs.cloudimmunity.com/gotchas-and-common-mistakes-in-go-golang/
- Go Advice
https://github.com/cristaloleg/go-advice
- Practical Go Benchmarks
https://www.instana.com/blog/practical-golang-benchmarks/
- Benchmarks of Go serialization methods
https://github.com/alecthomas/go_serialization_benchmarks
- Debugging performance issues in Go programs
https://github.com/golang/go/wiki/Performance
- Go code refactoring: the 23x performance hunt
https://medium.com/@val_deleplace/go-code-refactoring-the-23x-performance-hunt-156746b522f7

# Go sync.Pool
避免在热代码中进行内存分配，这样会导致gc很忙。尽可能的使用 sync.Pool 来重用内存空间: 可以是连接池、字符串等
1. 通过Get() 取资源
1. 通过Put() 把不用的资源放回去

e.g.

    var bufPool = sync.Pool{
        New: func() interface{} {
            return &bytes.Buffer{}
        },
    }

    func addTagsToName(name string, tags map[string]string) string {
        ....
        buf := bufPool.Get().(*bytes.Buffer)
        defer bufPool.Put(buf)

        buf.Reset()
        buf.WriteString(name)
        ....
        return buf.String()
    }