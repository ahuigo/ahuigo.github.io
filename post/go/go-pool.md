---
title: Go Sync.Pool
date: 2019-10-02
---
# Go sync.Pool
出于性能的考虑，我们经常需要建立：buffer池，连接池。sync.Pool 可以帮助我们这到这点：
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