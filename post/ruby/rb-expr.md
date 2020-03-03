---
title: ruby expr
date: 2020-03-02
private: true
---
# 运算符
## 比较
    <=>	
        1<=>2 //-1
        1<=>1 //0
        2<=>1 //1
    ===	用于range include
        (1...10) === 5 返回 true
    .eql?	类型匹配。	
        1 == 1.0 返回 true，但是 1.eql?(1.0) 返回 false。
    equal?	如果接收器和参数具有相同的对象 id，则返回 true。	
        如果 aObj 是 bObj 的副本，那么 aObj == bObj 返回 true，

## 并行赋值
并行赋值在交换两个变量的值时也很有用：

    a, b = b, c
    a,b,c=1,2,3

## Ruby defined? 运算符
返回表达式的描述字符串，如果表达式未定义则返回 nil。

    下面是 defined? 运算符的各种用法：

    用法 1
    defined? variable # 如果 variable 已经初始化，则为 True
    例如：

    foo = 42
    defined? foo    # => "local-variable"
    defined? $_     # => "global-variable"
    defined? bar    # => nil（未定义）

    用法 2
    defined? method_call # 如果方法已经定义，则为 True

    defined? puts        # => "method"
    defined? puts(bar)   # => nil（在这里 bar 未定义）
    defined? unpack      # => nil（在这里未定义）

    用法 3
    # 如果存在可被 super 用户调用的方法，则为 True
    defined? super

## 和双冒号运算符 "::"
> 请记住：在 Ruby 中，类和方法也可以被当作常量。
1. `.`用于访问实例属性
2. 如果 `::` 前的表达式为类或模块名称，则返回该类或模块内对应的常量值；如果 :: 前未没有前缀表达式，则返回主Object类中对应的常量值。 。

下面是两个实例：

    MR_COUNT = 0        # 定义在主 Object 类上的常量
    module Foo
      MR_COUNT = 0
      ::MR_COUNT = 1    # 设置全局计数为 1
      MR_COUNT = 2      # 设置局部计数为 2
    end
    puts MR_COUNT       # 这是全局常量
    puts Foo::MR_COUNT  # 这是 "Foo" 的局部常量

## code if
    code if condition
    code while condition
    code unless conditional
    begin 
        code 
    end while conditional

    print "debug\n" if $debug

## unless
    x=1
    unless x>2
        puts "x 小于 2"
    else
        puts "x 大于 2"
    end

## case
    case expr0
    when expr1, expr2
       stmt1
    when expr3, expr4
       stmt2
    else
       stmt3
    end

## while
语法

    while conditional [do]
       code
    end

或者

    while conditional [:]
       code
    end

## until
    until conditional [do]
        code
    end

# function
    def echo(str)
        p str
    end
    echo('hello1')
    echo 'hello2'

# 多行注释begin/end
    =begin
    这是注释。
    这也是注释。
    这也是注释。
    这还是注释。
    =end

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
