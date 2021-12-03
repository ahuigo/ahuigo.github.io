---
title: decorator
date: 2021-11-23
private: true
---
# decorator
## 单层装饰器
    type SumFunc func(int64, int64) int64

    func getFunctionName(fn interface{}) string {
      return runtime.FuncForPC(reflect.ValueOf(fn).Pointer()).Name()
    }

    func timedSumFunc(f SumFunc) SumFunc {
      return func(start, end int64) int64 {

        defer func(t time.Time) {
          fmt.Printf("--- Time Elapsed (%s): %v ---\n", 
              getFunctionName(f), time.Since(t))
        }(time.Now())

        return f(start, end)
      }
    }

## pipeline 装饰器
写一个工具函数——用来遍历并调用各个 decorator：

    type HttpHandlerDecorator func(http.HandlerFunc) http.HandlerFunc
    func Handler(h http.HandlerFunc, decors ...HttpHandlerDecorator) http.HandlerFunc {
        for i := range decors {
            d := decors[len(decors)-1-i] // iterate in reverse
            h = d(h)
        }
        return h
    }

然后，我们就可以像下面这样使用了。

    http.HandleFunc("/v4/hello", Handler(hello, WithServerHeader, WithBasicAuth, WithDebugLog))

## 泛型装饰器
上面的decorator 有个问题，都需要指定类型 http.HandlerFunc、SumFunc

来一个泛型版本的：

    func Decorator(decoPtr, fn interface{}) (err error) {
        var decoratedFunc, targetFunc reflect.Value
        decoratedFunc = reflect.ValueOf(decoPtr).Elem()
        targetFunc = reflect.ValueOf(fn)
        v := reflect.MakeFunc(targetFunc.Type(), func(in []reflect.Value) (out []reflect.Value) {
                    fmt.Println("before")
                    out = targetFunc.Call(in)
                    fmt.Println("after")
                    return
                })
        decoratedFunc.Set(v)
        return
    }

使用：

    func foo(a, b, c int) int {
        fmt.Printf("%d, %d, %d \n", a, b, c)
        return a + b + c
    }

    wrapFoo:=foo
    Decorator(&wrapFoo, foo)
    wrapFoo(1, 2, 3)