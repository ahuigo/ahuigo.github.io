---
title: go IoC 控制反转
date: 2021-11-21
private: true
---
# go IoC 控制反转
反转控制IoC(Inversion of Control，也是依赖与注入)的思想是把控制逻辑与业务逻辑分离，不要在业务逻辑里写控制逻辑，这样会让控制逻辑依赖于业务逻辑


## 业务与控制耦合
我们想给IntSet 加入Undo, 由于IntSet与Undo 混合，Undo不可复用

    type UndoableIntSet struct { // Poor style
        IntSet    // Embedding (delegation)
        functions []func()
    }

    func (set *UndoableIntSet) Undo() error {
        if len(set.functions) == 0 {
            return errors.New("No functions to undo")
        }
        index := len(set.functions) - 1
        if function := set.functions[index]; function != nil {
            function()
            set.functions[index] = nil // For garbage collection
        }
        set.functions = set.functions[:index]
        return nil
    }
    ....Add(func)..

## 反转依赖
我们先声明一种Undo函数接口(协议):

    type Undo []func()

    func (undo *Undo) Add(function func()) {
      *undo = append(*undo, function)
    }
    func (undo *Undo) Undo() error {
      functions := *undo
      if len(functions) == 0 {
        return errors.New("No functions to undo")
      }
      index := len(functions) - 1
      if function := functions[index]; function != nil {
        function()
        functions[index] = nil // For garbage collection
      }
      *undo = functions[:index]
      return nil
    }

然后，我们在我们的IntSet里嵌入 Undo，然后，再在 Add() 和 Delete() 里使用上面的方法，就可以完成功能。
这个就是控制反转，不再由 控制逻辑 Undo 来依赖业务逻辑 IntSet，而是由业务逻辑 IntSet 来依赖 Undo 。

    type IntSet struct {
        data map[int]bool
        undo Undo
    }
    
    func (set *IntSet) Undo() error {
        return set.undo.Undo()
    }
    
    func (set *IntSet) Add(x int) {
        if !set.Contains(x) {
            set.data[x] = true
            set.undo.Add(func() { set.Delete(x) })
        } else {
            set.undo.Add(nil)
        }
    }
    
    func (set *IntSet) Delete(x int) {
        if set.Contains(x) {
            delete(set.data, x)
            set.undo.Add(func() { set.Add(x) })
        } else {
            set.undo.Add(nil)
        }
    }


# 参考
- 委托和反转控制 https://coolshell.cn/articles/21214.html