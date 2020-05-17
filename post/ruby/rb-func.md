---
title: Ruby function
date: 2020-03-03
private: 
---
# Ruby function
    def method_name [( [arg [= default]]...[, * arg [, &expr ]])]
        expr..
        [return] val
    end

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

## exec function

    def echo(str="1", str2="2")
        p str,str2
        return true
    end
    echo    #无参数
    echo('hello1','hello2')
    echo 'hello1', 'hello2'

