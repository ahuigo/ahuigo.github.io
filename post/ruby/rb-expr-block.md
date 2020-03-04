---
title: Ruby Block
date: 2020-03-04
private: 
---
# Ruby Block
block 形式：

    block_name{
        statement1
        statement2
        ..........
    }

## yield 调用block
    
    def test
       yield
       puts "在 test 方法内"
       yield 100
    end
    test {|i| puts "你在块 #{i} 内"}

以上实例运行结果为：

    你在块  内
    在 test 方法内
    你在块 100 内

### yield 传递多个参数

    yield a, b

此时，块如下所示：

    test {|a, b| statement}

## block作参数
如果方法的最后一个参数前带有`&`，那么您可以向该方法传递一个块

    def test(&block)
        block.call
    end
    test{ puts "Hello World!"}

## BEGIN/END 初始语句

    END {
        puts "这是end"
    }
 
    puts "这是主 Ruby 程序"
    
    BEGIN {
        puts "初始化 Ruby 程序"
    }

## 函数参数+block

    def test(j)
        p j
        yield 5
        puts "在 test 方法内"
        yield 100
    end
    test 1 do |i| 
        puts "你在块 #{i} 内"
    end

相当于python的`for i in test(1): block`, output:

    1
    你在块 5 内
    在 test 方法内
    你在块 100 内