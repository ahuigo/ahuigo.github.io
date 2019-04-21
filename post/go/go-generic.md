---
title: Go Generic
date: 2019-04-11
private:
---
# Go Generic
http://coyee.com/article/10700-dealing-with-the-lack-of-generics-in-go
2.  Interface （with method）
    1.  好处 无需三方库，代码干净而且通用。
    2.  缺点 需要一些额外的代码量，以及也许没那么夸张的运行时开销。 
3.  Use type assertions
    1.  好处 无需三方库，代码干净。
    2.  缺点 需要执行类型断言，接口转换的运行时开销，没有编译时类型检查。  
4. Reflection
   好处 干净
   缺点  相当大的运行时开销，没有编译时类型检查。  
5. Code generation
   好处 非常干净的代码(取决工具)，编译时类型检查（有些工具甚至允许编写针对通用代码模板的测试），没有运行时开销。
   缺点 构建需要第三方工具，如果一个模板为不同的目标类型多次实例化，编译后二进制文件较大。

作者：达 链接：https://www.zhihu.com/question/62991191/answer/342121627


## interface poly
接口范型的实现主要示例为: go-lib/go-poly (工厂)
interface 实现工厂多态

## type assertion generic
    type Container []interface{}
    func (c *Container) Put(elem interface{}) {
        *c = append(*c, elem)
    }
    func (c *Container) Get() interface{} {
        elem := (*c)[0]
        *c = (*c)[1:]
        return elem
    }

    // The calling code does the type assertion when retrieving an element.
    func assertExample() {
        intContainer := &Container{}
        intContainer.Put(7)
        intContainer.Put(42)
        elem, ok := intContainer.Get().(int) // assert that the actual type is int
        if !ok {
            fmt.Println("Unable to read an int from intContainer")
        }
        fmt.Printf("assertExample: %d (%T)\n", elem, elem)
    }
