---
title: Golang Notes: method
date: 2019-03-24
---
# Golang Notes: method
⽅方法总是绑定对象实例，并隐式将实例作为第⼀一实参 (receiver)。
• 只能为当前包内命名类型定义⽅方法。
• 参数 receiver 可任意命名。如⽅方法中未曾使⽤用，可省略参数名。
• 参数 receiver 类型可以是 T 或 *T。基类型 T 不能是接口或指针。 
• 不⽀支持⽅方法重载，receiver 只是参数签名的组成部分。
• 可⽤用实例 value 或 pointer 调⽤用全部⽅方法，编译器⾃动转换。

method 也是函数，不可以嵌套nested

    type Queue struct {
        elements []interface{}
    }
    func NewQueue() *Queue {
        return &Queue{make([]interface{}, 10)}
    }
    
    // receiver ignore
    func (*Queue) Push(e interface{}) error {
        panic("not implemented")
    }

    // receiver 可以任意指定(self,this,...)，这里是self
    func (self *Queue) length() int {
        return len(self.elements)
    }

## pointer vs value

    type Data struct{
        x int
    }
    func (self Data) ValueTest() {
        fmt.Printf("Value  : %p\n", &self)
    }
    func (self *Data) PointerTest() {
        fmt.Printf("Pointer: %p\n", self)
    }

    func main() {
        d := Data{}
        p := &d
        fmt.Printf("Data: %p\n", p) 

        d.ValueTest()   // ValueTest(d)
        d.PointerTest() // PointerTest(&d)

        p.ValueTest()   // ValueTest(*p)
        p.PointerTest() // PointerTest(p)
    }

ValueTest 传的是值的copy, 所以值不一样

    Data:    0xc0000140f8
    Value  : 0xc000014108
    Pointer: 0xc0000140f8
    Value  : 0xc000014110
    Pointer: 0xc0000140f8

## 匿名字段(类似继承)
anonymous field 的方法可以像字段成员那样访问

    type User struct{}
    func (*User) Test(){ 
        println("test")
    } 
    func main(){
        // (&struct{User}{}).Test()
        manager = &struct{
            User
        }{}
        manager.Test()
    }

## 方法集 
每个类型都有与之关联的方法集，这会影响到接⼝口实现规则。
• 类型 T ⽅方法集包含全部 receiver T ⽅方法。
• 类型 `*T` ⽅方法集包含全部 `receiver T + *T` ⽅方法。
• 如类型 S 包含匿名字段 T，   则 S ⽅法集包含 T ⽅方法。 
• 如类型 S 包含匿名字段 `*T`，则 S 方法集包含 `T + *T` ⽅方法。 
• 不管嵌入 `T 或 *T`，`*S` ⽅方法集总是包含 `T + *T` ⽅方法。

    type User struct{}
    func (*User) Test(){ 
        println("test")
    } 

    func main() {
        // ok
        (*User).Test(&User{})

        // error: no *T
        (User).Test(&User{})

    }

用实例 value 和 pointer 调用⽅方法 (含匿名字段) 不受⽅方法集约束，编译器总是查找全部 ⽅方法，并⾃自动转换 receiver 实参。

    //ok
    m := struct{User}{}
    m.Test()

不过匿名实例value/pointer 仍然被约束

    //---------- 下面两种 method value 也有方法集约束
    // ok
    (struct{*User}{}).Test()

    // error: 不含有`*T`
    (struct{User}{}).Test()

## 表达式
根据调⽤用者不同，⽅方法分为两种表现形式: 

    instance.method(args...) ---> <type>.func(instance, args...)

前者称为 method value，后者 method expression(显式传参)

    u := User{1, "Tom"}
    u.Test()

    mValue := u.Test             // 隐式传递 receiver
    mValue()

    mExpression := (*User).Test // 显式传递 receiver
    mExpression(&u)             

注意，method value 会复制 receiver T(`*T`则不会)

    type User struct { id   int; name string }
    func (self User) Test() {
        fmt.Println(self)
    }
    func main() {
        u := User{1, "Tom"}
        mValue := u.Test        //⽴立即复制 receiver，因为不是指针类*T
        u.id, u.name = 2, "Jack"
        u.Test()                //2 Jack
        mValue()                //1 Tome
    }

方法集复制

    fun := User.TestValue           // receiver value copy
    fun(u)

    fun := (*User).TestPointer      // receiver value ref
    fun(&u)

    // 签名变为 func TestValue(self *User)。  实际依然是 receiver value copy。 
    fun := (*User).TestValue        // receiver value copy
    fun(&u)
    fun(u)                          // error: 也签名不符合

在汇编层，method value 和闭包的实现⽅方式相同，实际返回 FuncVal 类型对象。 

    FuncVal { method_address, receiver_copy }




# Reference
- 雨痕的学习笔记