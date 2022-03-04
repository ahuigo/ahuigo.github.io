---
title: golang object visitor mode
date: 2021-11-23
private: true
---
# golang object visitor mode
本文参考总结了：https://coolshell.cn/articles/21263.html
源码实现：[go-lib/reflect/object_visitor_decorator_test.go]

Kubernetes 的 kubectl 命令中的使用到到的一个编程模式 – Visitor(其实，kubectl 用到了Builder、Visitor模式)
这个模式是一种将算法与操作对象的结构分离的一种方法: 
1. 这种分离的实际结果是能够在不修改结构的情况下向现有对象结构添加新操作，是遵循开放/封闭原则的一种方法。

本文将看一下 kubelet 中是怎么使用函数式的方法来实现这个模式的。

## 一个简单示例
我们还是先来看一个简单设计模式的Visitor的示例。

我们的代码中有一个Visitor的函数定义，还有一个Shape接口，其需要使用 Visitor函数做为参数。

我们的实例的对象 Circle和 Rectangle实现了 Shape 的接口的 accept() 方法，这个方法就是等外面给我传递一个Visitor。

    package main
    import (
        "encoding/json"
        "encoding/xml"
        "fmt"
    )
    type Visitor func(shape Shape)
    type Shape interface {
        accept(Visitor)
    }
    type Circle struct {
        Radius int
    }
    func (c Circle) accept(v Visitor) {
        v(c)
    }
    type Rectangle struct {
        Width, Heigh int
    }
    func (r Rectangle) accept(v Visitor) {
        v(r)
    }

然后，我们实现两个Visitor，一个是用来做JSON序列化的，另一个是用来做XML序列化的

    func JsonVisitor(shape Shape) {
        bytes, err := json.Marshal(shape)
        if err != nil {
            panic(err)
        }
        fmt.Println(string(bytes))
    }
    func XmlVisitor(shape Shape) {
        bytes, err := xml.Marshal(shape)
        if err != nil {
            panic(err)
        }
        fmt.Println(string(bytes))
    }

下面是我们的使用Visitor这个模式的代码

    func main() {
      c := Circle{10}
      r :=  Rectangle{100, 200}
      shapes := []Shape{c, r}
      for _, s := range shapes {
        s.accept(JsonVisitor)
        s.accept(XmlVisitor)
      }
    }

其实，这段代码的目的就是想解耦 数据结构和 算法，使用 Strategy 模式也是可以完成的，而且会比较干净。但是在有些情况下，多个Visitor是来访问一个数据结构的不同部分，这种情况下，数据结构有点像一个数据库，而各个Visitor会成为一个个小应用。 kubectl就是这种情况。

## k8s相关背景
接下来，我们再来了解一下相关的知识背景：

对于Kubernetes，其抽象了很多种的Resource，比如：Pod, ReplicaSet, ConfigMap, Volumes, Namespace, Roles …. 种类非常繁多，这些东西构成为了Kubernetes的数据模型（点击 Kubernetes Resources 地图 查看其有多复杂）

kubectl 是Kubernetes中的一个客户端命令，操作人员用这个命令来操作Kubernetes。kubectl 会联系到 Kubernetes 的API Server，API Server会联系每个节点上的 kubelet ，从而达到控制每个结点。

kubectl 主要的工作是处理用户提交的东西（包括，命令行参数，yaml文件等），然后其会把用户提交的这些东西组织成一个数据结构体，然后把其发送给 API Server。
相关的源代码在 src/k8s.io/cli-runtime/pkg/resource/visitor.go 中（源码链接）
kubectl 的代码比较复杂，不过，其本原理简单来说，它从命令行和yaml文件中获取信息，通过Builder模式并把其转成一系列的资源，最后用 Visitor 模式模式来迭代处理这些Reources。

下面我们来看看 kubectl 的实现，为了简化，我用一个小的示例来表明 ，而不是直接分析复杂的源码。

## kubectl的实现方法
### Visitor模式定义
首先，kubectl 主要是用来处理 Info结构体，下面是相关的定义：

    type VisitorFunc func(*Info, error) error
    type Visitor interface {
        Visit(VisitorFunc) error
    }
    type Info struct {
        Namespace   string
        Name        string
        OtherThings string
    }
    func (info *Info) Visit(fn VisitorFunc) error {
      return fn(info, nil)
    }

### Log Visitor
    type LogVisitor struct {
      visitor Visitor
    }
    func (v LogVisitor) Visit(fn VisitorFunc) error {
      return v.visitor.Visit(func(info *Info, err error) error {
        fmt.Println("LogVisitor() before call function")
        err = fn(info, err)
        fmt.Println("LogVisitor() after call function")
        return err
      })
    }

### Name Visitor
这个Visitor 主要是用来访问 Info 结构中的 Name 和 NameSpace 成员

    type NameVisitor struct {
      visitor Visitor
    }
    func (v NameVisitor) Visit(fn VisitorFunc) error {
      return v.visitor.Visit(func(info *Info, err error) error {
        fmt.Println("NameVisitor() before call function")
        err = fn(info, err)
        if err == nil {
          fmt.Printf("==> Name=%s, NameSpace=%s\n", info.Name, info.Namespace)
        }
        fmt.Println("NameVisitor() after call function")
        return err
      })
    }

我们可以看到，上面的代码：

1. 声明了一个 NameVisitor 的结构体，这个结构体里有一个 Visitor 接口成员，这里意味着多态。
2. 在实现 Visit() 方法时，其调用了自己结构体内的那个 Visitor的 Visitor() 方法，这其实是一种修饰器的模式，用另一个Visitor修饰了自己

### 使用方代码
现在我们看看如果使用上面的代码：
```
    func main() {
      info := Info{}
      var v Visitor = &info
      v = LogVisitor{v}
      v = NameVisitor{v}
      loadFile := func(info *Info, err error) error {
        info.Name = "Hao Chen"
        info.Namespace = "MegaEase"
        info.OtherThings = "We are running as remote team."
        return nil
      }
      v.Visit(loadFile)
    }
```
这是一个反洋葱结构, 调用Visit时，才开始wrapFunc：

    visitor -> NameVisitor           wrapName(fn())
        .visitor -> LogVisitor       wrapLog(wrapName(fn()))
            .visitor -> Info         execute

output:

    LogVisitor() before call function
    NameVisitor() before call function
    ==> Name=Hao Chen, NameSpace=MegaEase
    NameVisitor() after call function
    LogVisitor() after call function

Visitor们一层套一层,我们可以看到，上面的代码有以下几种功效：

1. 解耦了数据和程序。
1. 使用了修饰器模式
1. 还做出来pipeline的模式

## Visitor修饰器
下面，我们用修饰器模式来重构一下上面的代码。

    type DecoratedVisitor struct {
      visitor    Visitor
      decorators []VisitorFunc
    }
    func NewDecoratedVisitor(v Visitor, fn ...VisitorFunc) Visitor {
      if len(fn) == 0 {
        return v
      }
      return DecoratedVisitor{v, fn}
    }
    // Visit implements Visitor
    func (v DecoratedVisitor) Visit(fn VisitorFunc) error {
      return v.visitor.Visit(func(info *Info, err error) error {
        if err != nil {
          return err
        }
        if err := fn(info, nil); err != nil {
          return err
        }
        for i := range v.decorators {
          if err := v.decorators[i](info, nil); err != nil {
            return err
          }
        }
        return nil
      })
    }

上面的代码并不复杂，

1. 用一个 DecoratedVisitor 的结构来存放所有的VistorFunc函数
1. NewDecoratedVisitor 可以把所有的 VisitorFunc转给它，构造 DecoratedVisitor 对象。
1. DecoratedVisitor实现了 Visit() 方法，里面就是来做一个for-loop，顺着调用所有的 VisitorFunc

于是，我们的代码就可以这样运作了：

    info := Info{}
    var v Visitor = &info
    v = NewDecoratedVisitor(v, NameVisitor, OtherVisitor)
    v.Visit(LoadFile)

考虑一下改造成gonic middleware 类似的模式: 支持`Next()`?
