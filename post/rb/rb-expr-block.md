---
title: Ruby Block
date: 2020-03-04
private: 
---
# Ruby Block
block 形式：`{}`或者 `do ...end`两种

    block_name{ |arg1,arg2,...|
        statement1
        statement2
        ..........
    }
    do [|arg1,arg2|]
        statement1
        statement2
    end

## block vs dict
    p {k:1} #block
    p ({k:1}) #dict

## BEGIN/END 初始语句

    END {
        puts "这是end"
    }
 
    puts "这是主 Ruby 程序"
    
    BEGIN {
        puts "初始化 Ruby 程序"
    }

## yield 调用block
yield 可以将值传给block 执行

    def test
       puts "init"
       yield
       puts "在 test 方法内"
       yield 100
    end
    test {|i| puts "你在块 #{i} 内"}

以上实例运行结果为：

    init
    你在块  内
    在 test 方法内
    你在块 100 内

### yield 传递多个参数

    yield a, b

此时，块如下所示：

    test {|a, b| statement}

### 函数传参+do block
必须写成`函数调用 + do-block`形式

    def test(j)
        p j
        yield 5
        puts "在 test 方法内"
        yield 100
    end
    #test(1) do |i|  也合法
    test 1 do |i| 
        puts "你在块 #{i} 内"
    end

相当于python的`for i in test(1): block(i)`, output:

    1
    你在块 5 内
    在 test 方法内
    你在块 100 内

以下形式：

    # 合法
    test(10) {|i| puts "你在块 #{i} 内"}
    # 只有这个不合法
    test 10 {|i| puts "你在块 #{i} 内"}


## block作函数参数
如果方法的最后一个参数前带有`&`，那么您可以向该方法传递一个块

    def test(&block)
        block.call
    end
    test{ puts "Hello World!"}
