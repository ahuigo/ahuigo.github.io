---
title: go heap or stack
date: 2023-12-25
private: true
---
# go heap or stack
fmt 中的id 是放heap or stack？

    package main
    import "fmt"
    import _ "strconv"
    func main(){
        id :=1
        //err:=fmt.Errorf("in foo() called getUser(). id=. err: "+strconv.Itoa(id))  // no escape
        err:=fmt.Errorf("id=%d", id) //esacpe to heap 
        fmt.Println(err)
    }

查看变量是在heap 还是在stack, 用：

    go build -gcflags='-m=3'
    $ go run -gcflags='-m=3'
    //It says "id escapes to heap".

id是一个整数，因此是一个值类型。值类型不能溢出到堆中。您实际看到的是id int装箱为interface{}，它是一种值类型，可以溢出到堆中。fmt.Errorf调用时，interface{}会创建一个包含 的新对象id，这就是溢出到堆中的内容。