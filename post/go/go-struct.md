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

按值传递: 不会改变q

    func (q Queue) Push(n Message) {
        q.db[q.tail] = n
    }

按值传递: 

    func (q *Queue) Push(n Message) {
        q.db[q.tail] = n
    }

总结一下:

    func (s *MyStruct) pointerMethod() { } // method on pointer
    func (s MyStruct)  valueMethod()   { } // method on value

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

    Task{Model:model.Model{ID:task.ID}}

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

### 继承interface
go-lib/struct/embed-interface.go

### 继承chains
    type User struct {
        gorm.Model
        ID int
    }
    // 可以不等价
    user.ID=1
    user.Model.ID=2
    pf("%#v,%#v\n", user, user.ID==user.Model.ID)

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


# struct 内存
## 为什么一个结构体类型的最后一个字段类型的尺寸为零时会影响此结构体的尺寸？
一个可寻址的结构值的所有字段都可以被取地址。 如果非零尺寸的结构体值的最后一个字段的尺寸是零，那么取此最后一个字段的地址将会返回一个越出了为此结构体值分配的内存块的地址。 这个返回的地址可能指向另一个被分配的内存块。 在目前的官方Go标准运行时的实现中，如果一个内存块被至少一个依然活跃的指针引用，那么这个内存块将不会被视作垃圾因而肯定不会被回收。 所以只要有一个活跃的指针存储着此非零尺寸的结构体值的最后一个字段的越界地址，它将阻止垃圾收集器回收另一个内存块，从而可能导致内存泄漏。

为避免上述问题，标准的Go编译器会确保取一个非零尺寸的结构体值的最后一个字段的地址时，绝对不会返回越出分配给此结构体值的内存块的地址。 Go标准编译器通过在需要时在结构体最后的零尺寸字段之后填充一些字节来实现这一点。

如果一个结构体的全部字段的类型都是零尺寸的(因此整个结构体也是零尺寸的)，那么就不需要再填充字节，因为标准编译器会专门处理零尺寸的内存块。

    一个例子：
    package main
    
    import (
    	"unsafe"
    	"fmt"
    )
    
    func main() {
    	type T1 struct {
    		a struct{}
    		x int64
    	}
    	fmt.Println(unsafe.Sizeof(T1{})) // 8
    
    	type T2 struct {
    		x int64
    		a struct{}
    	}
    	fmt.Println(unsafe.Sizeof(T2{})) // 16
    }