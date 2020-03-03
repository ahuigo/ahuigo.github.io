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


# BEGIN/END 初始语句

    END {
        puts "停止 Ruby 程序"
    }
 
    puts "这是主 Ruby 程序"
    
    BEGIN {
        puts "初始化 Ruby 程序"
    }

# Ruby Block
写brew cask 包时遇到奇怪的语法`Cask "package-name" do ... end`，原来这就是ruby 的block 呀！

    def test(j)
        p j
        yield 5
        puts "在 test 方法内"
        yield 100
    end
    test 1 do |i| 
        puts "你在块 #{i} 内"
    end

`test 1`产生迭代器, `do |i|` 相当于python的`for i in test(1)`, output:

    1
    你在块 5 内
    在 test 方法内
    你在块 100 内