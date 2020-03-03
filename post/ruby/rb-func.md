---
title: Ruby function
date: 2020-03-03
private: 
---
# Ruby function
    def method_name [( [arg [= default]]...[, * arg [, &expr ]])]
        expr..
    end

## 可变数量参数

    def sample (*test)
       puts "参数个数为 #{test.length}"
       for i in 0...test.length
          puts "参数值为 #{test[i]}"
       end
    end

## exec function

    def echo(str1, str2="2")
        p str
        return true
    end
    echo('hello1','hello2')
    echo 'hello1', 'hello2'

