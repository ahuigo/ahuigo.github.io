---
title: Go Sync.Pool
date: 2019-10-02
---
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