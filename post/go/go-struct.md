---
title: Golang 的结构体
date: 2019-03-24
---
# Golang Notes: struct
struct 是值类型，slice 是引用类型(指针), 以下赋值方法是按值的

    type A struct{x int}
    a:=A{}
    b:=A{}
    fmt.Printf("%p,%p\n", &a,&b)  //not same
    b = a                           //按值传递
    fmt.Printf("%p,%p\n", &a,&b)  //not same

## 特殊定义

    type A struct { int }
    var a=A{}
    a.int = 1
    fmt.Println(a)

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

partial copy struct

    package main
    import "fmt"
    import "github.com/jinzhu/copier"

    type RegistrationRequest struct {
        Email    *string
        Email2   *string
        Username *string
        Password *string
        Name     string
    }

    type User struct {
        Email    *string
        Username *string
        Password *string
        Name     string
    }

    func main() {
        user := User{}
        req := RegistrationRequest{}
        user.Email, user.Password, user.Username = new(string), new(string), new(string)
        user.Name = "John Doe"
        *user.Email = "a@b.com"
        *user.Password = "1234"
        *user.Username = "johndoe"
        fmt.Println("User :",user.Name, *user.Email, *user.Username, *user.Password)
        copier.Copy(&req, &user)
        fmt.Println("RegistrationRequest :",req.Name, *req.Email, *req.Username, *req.Password)
    }

## define:

    type Node struct {
        _    int
        id   int
        data *byte
        next *Node
    }

不要直接访问：

    //非法
    Node.id

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

再来个例子

    type A struct {
        Body struct {
            Status string `Flag`
        }
    }
    A{struct{Status string `Flag`}{}}.Body.Status
    A{struct{Status string `Flag`}{"str"}}.Body.Status


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

### Anonymous field(继承)
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

### 继承与赋值
    package main
    import  "fmt"

    type Pet struct {
        age int
    }
    type PetX struct {
        Pet
        name string
    }

    func modify(pxp *PetX){
        pxp.name = "name"
        pxp.age = 123
        pxp.Pet = Pet{200}
    }

    func main() {
        px:= PetX{}
        modify(&px)

        fmt.Printf("%#v\n", px)  
        fmt.Printf("%#v\n", px.Pet)  
    }
    <!-- main.PetX{Pet:main.Pet{age:200}, name:"name"}
    main.Pet{age:200} -->


## 面向对象
go struct 仅支持封装，没有继承、多态

- Anonymous 可以实现继承
- Interface 可以实现多态

### Struct method
struct method 是一个值：

    package main
    import  "fmt"

    type Pet struct {
        speaker func() string
        name    string
    }

    func (p *Pet) Speak() string {
        return "Speak"
    }

    func NewPet(name string) *Pet {
        p := &Pet{
            name: name,
        }
        p.speaker = p.Speak
        return p
    }

    func main() {
        d := NewPet("spot")
        fmt.Println(d.speaker()) //Speak
        fmt.Println(d.Speak())  //Speak
    }

注意指针类型匹配，

    type A interface{
        Say()
    }
    func Test(o A){
    }

    func (d Dog) Say() { }
    Test(&Dog{}) //ok
    Test(Dog{}) //ok

not work

    func (d *Dog) Say() { }
    Test(&Dog{}) //ok
    Test(Dog{}) //not ok

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
