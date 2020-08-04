---
title: Golang 的结构体
date: 2019-03-24
---
# 定义
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

### init nil
    var a *Node
    a == nil //true

但是这个nil 是有类型的nil：

    (*main.Node)(nil)

## define:

    type Node struct {
        _    int
        id   int
        data *byte
        next *Node
    }

Node 是结构体名，不是数据，不能访问的：

    //非法
    Node.id

## 用类型名作为属性名

    type A struct { int }
    var a=A{}
    a.int = 1
    fmt.Println(a)

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
# 传值、访问、指针
## access

	v := Vertex{1, 2}
	v.X = 4
	&v.X = 4
	Vertex{1, 2}.X

## 按值传递
struct 是值类型，slice 是引用类型(指针), 以下赋值方法是按值的

    type A struct{x int; b string}
    a:=A{}
    b:=A{}
    fmt.Printf("%p,%p\n", &a,&b)  //not same
    b = a                           //按值传递
    fmt.Printf("%p,%p\n", &a,&b)  //not same

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
        //不复制 Email2
        copier.Copy(&req, &user)
        fmt.Println("RegistrationRequest :",req.Name, *req.Email, *req.Username, *req.Password)
    }

## compare struct
结构体是可以直接比较的: (但是 time类型不能比较，见go-lib/time/time-compare.go)

    a := User{"ahui"}
    b := User{"ahui2"}
    fmt.Printf("%v", a==b) //true


## 面向对象
go struct 仅支持封装，没有继承、多态

- Anonymous 可以实现继承
- Interface 可以实现多态

### extend package method
    // Context a
    type Context gin.Context

    // Resp
    func (c *Context) Resp(code int, obj interface{}) {
        (*gin.Context)(c).JSON(code, obj)
        (*gin.Context)(c).Abort()
    }

### 动态修改method
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

    func main() {
        p := &Pet{
            name: name,
        }
        p.speaker = p.Speak
        fmt.Println(p.speaker()) //Speak
        fmt.Println(p.Speak())  //Speak
    }

### Anonymous field(继承)
匿名字段的类型就是 同名类型

    type User struct{
        age int
     }
    type Class struct{
        User
        id int
    }

    c := Class{User:User{age:0}, id:0}
    c := Class{User{age:0}, 0}
    //如果定义为 struct{User User} 那么使用c.age就是非法
    c.age == c.User.age  //true

assgin embedded

    c.User == User{age:15}

不能同时嵌⼊入某⼀一类型和其指针类型，因为它们名字相同会有冲突

    type Manager struct {
        User
        *User
        title string 
    }

### 继承props+method
User继承 Model 所有属性， 包括gorm.Model.ID、方法

    type User struct {
        gorm.Model
        title string 
    }
    user:=User{Model:gorm.Model{ID:1}}  # ok
    user:=User{Model:{gorm.Model{ID:1}}} # missing type in composite literal

    // 完全等价
    user.ID=1
    user.Model.ID=1
    pf("%#v,%#v\n", user, user.ID==user.Model.ID)

e.g: go-lib/object/inherit.go

### interface 
interface 是通用类型，可以是指针、 非指针类型

    type A interface{
        Say()
    }
    func Test(o A){
    }

    func (d Dog) Say() { }
    Test(&Dog{}) //ok
    Test(Dog{}) //ok

注意interface 会严格检查method

    // struct 作为参数
    func (d *Dog) Say() { }
    (&Dog{}).Say() //ok
    (Dog{}).Say() //not ok

    // interface 作为参数
    func Test(o A){
        o.Say()
    }
    Test(&Dog{}) //ok
    Test(Dog{}) //not ok: Dog does not implement A(Say has pointer receiver)


