---
title: golang map reduce
date: 2021-11-21
private: true
---
# golang map reduce
## 简单版 Generic Map
我们来看一下一个非常简单不作任何类型检查的泛型的Map函数怎么写。

    package main
    import "fmt"
    import "reflect"
    import "strings"

    func Map(data interface{}, fn interface{}) []interface{} {
        vfn := reflect.ValueOf(fn)
        vdata := reflect.ValueOf(data)
        result := make([]interface{}, vdata.Len())
        for i := 0; i < vdata.Len(); i++ {
            rfParams:=[]reflect.Value{vdata.Index(i)}
            result[i] = vfn.Call(rfParams)[0].Interface()
        }
        return result
    }

    func main(){
        strs := []string{"Hao", "Chen", "MegaEase"}
        upstrs := Map(strs, strings.ToUpper);
        fmt.Println(upstrs)
    }

# 参考
- https://coolshell.cn/articles/21164.html