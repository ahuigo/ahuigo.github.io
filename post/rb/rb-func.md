---
title: Ruby function
date: 2020-03-03
private: 
---
# Ruby function
## default arguments
    def method_name [( [arg [= default]]...[, * arg [, &expr ]])]
        expr..
        [return] val
    end
## block argument
如果方法的最后一个参数前带有`&`，那么您可以向该方法传递一个块: rb-expr-block

    def test(&block)
        block.call
    end
    test{ puts "Hello World!"}

## return 可以省略
这个返回的值是最后一个语句的值

    def test
        j = 10
        k = 100
    end
    v=test #100

如果给出超过两个的表达式，包含这些值的数组将是返回值。如果未给出表达式，nil 将是返回值。

    return
    return 12
    return 1,2,3

## 可变数量参数

    def sample (*test)
       puts "参数个数为 #{test.length}"
       for i in 0...test.length
          puts "参数值为 #{test[i]}"
       end
    end

## function as argument
### func name as value
直接传func name是会被解释执行的：

    def add(a,b)
        a+b
    end
    # 以下三个等价
    p add 1,2
    p(add 1,2)
    p(add(1,2))

    # syntax error(ruby也不认识了)
    p 3,add 1,2

所以下面传的func 实际是执行后的结果

    def add(*args)
        args.sum
    end
    p(add,1,2)
    p(add(),1,2)

### func symbol as value
如果想传func 本身，只能传符号

    def first_option
        puts "space jam"
    end

    def receives_function(func)
        # method 通过func symbol找到函数定义, 返回一个 Method 对象，代表名字为 func 的方法；
        # .call 则是调用这个 Method 对象代表的方法。
        method(func).call
    end

    receives_function(:first_option)

## exec function
参数之间用`,`间隔：

    def echo(str="1", str2="2")
        p str,str2
        return true
    end
    echo    #无参数
    echo('hello1','hello2')
    echo 'hello3','hello4'
    echo 'hello3', 'hello4'

# print function
参考 rb/var-format-print.md
