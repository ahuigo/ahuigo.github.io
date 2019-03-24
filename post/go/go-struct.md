---
title: Golang Notes: struct
date: 2019-03-24
---
# Golang Notes: struct
struct 是值类型，slice 是引用类型(指针), 不过以下方法是按引用传值的

    type A struct{x int}
    a:=A{}
    b:=A{}
    fmt.Printf("%p,%p\n", &a,&b)  //not same
    b = a
    fmt.Printf("%p,%p\n", &a,&b)  //not same


## define:

    type Node struct {
        _    int
        id   int
        data *byte
        next *Node
    }

### struct with tag
可定义字段标签，⽤用反射读取。标签是类型的组成部分, 是不同的类型

    func main() {
        type D struct {
            s string `tag3`
            x   int `tag2`
        }
        var d D
        fmt.Printf("%#v\n", d)
    }

### null struct
null struct 不占用空间，用来实现set

    var null struct{}
    set := make(map[string]struct{})
    set["a"] = null

### 匿名struct
    var attr = struct {
        perm  int
        owner int
    }{2, 0755}

### Anonymous field
匿名字段的类型就是 同名类型

    type User struct{ }
    type Class struct{
        User
        id int
    }

编译器从外向内逐级查找所有层次的匿名字段

    type Resource struct {
        id int
    }
    type User struct {
        Resource
        name string 
    }
    type Manager struct {
        User
        title string 
    }
    var m Manager
    m.id = 1
    m.name = "Jack"
    m.title = "Administrator"

Note: 相同层次的同名字段也会让编译器⽆无所适从, 应该用显式的字段

不能同时嵌⼊入某⼀一类型和其指针类型，因为它们名字相同

    type Manager struct {
        User
        *User
        title string 
    }

## 面向对象
go struct 仅支持封装，没有继承、多态

## init 
init 时必须包含全部字段

     n0 := Node{0,1,nil,nil}
     n0 := Node{0,1,nil,nil,}
     n0 := Node{0,1} //error: too few args

否则用key:value 形式就不用包含全部字段了

     n1 := Node{}       //default: id:0,data:nil,next:nil
     n2 := Node{
        id:   2,
        data: nil,
        next: &n1,
    }
    fmt.Println(n1,n2)

## access

	v := Vertex{1, 2}
	v.X = 4
	&v.X = 4
	Vertex{1, 2}.X

## pointer to structs
struct pointer:

    v := Vertex{1, 2}
	p := &v
	p.X = 1e9

copy:

    v_copy := v
