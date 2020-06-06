---
title: ruby expr
date: 2020-03-02
private: true
---
# 语法块
## 语句结束：
分号、或换行就是语句结束flag

## 函数调用 vs 表达式
    a + b 被解释为 a+b （这是一个局部变量）
    a  +b 被解释为 a(+b) （这是一个方法调用）

## 注释
    # 单行
    =begin
    这是注释。
    这是注释。
    =end

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

## 逻辑

    not 1 , !1
    and &&
    or ||
    if !1

    a = 1 unless false
    a = 1 if not false

## 并行赋值
并行赋值在交换两个变量的值时也很有用：

    a, b = b, c
    a,b,c=1,2,3

## Ruby defined? 运算符
返回表达式的描述字符串，如果表达式未定义则返回 nil。

    用法 1
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
2. 如果 `::` 前的表达式为类或模块名称，则返回该类或模块内对应的常量值

下面是两个实例：

    MR_COUNT = 0        # 定义在主 Object 类上的常量
    module Foo
      ::MR_COUNT = 1    # 设置全局计数为 1
      MR_COUNT = 2      # 设置局部计数为 2
    end
    puts MR_COUNT       # 这是全局常量
    puts Foo::MR_COUNT  # 这是 "Foo" 的局部常量

# 表达式
## if
注意: `''`与`0`都是true

    if conditional [then]
        code...
    [elsif conditional [then]
        code...]...
    [else
        code...]
    end

若想在一行内写出完整的 if 式，则必须以 then 隔开条件式和程式区块。如下所示:

    if a == 4 then a = 7 end

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

## case when else
    case expr0
    when expr1, expr2,expr3....
       stmt1
    when expr11, expr12,....
       stmt2
    else
       stmt3
    end

e.g.

    $age =  5
    case $age
    when 0 .. 2
        puts "婴儿"
    when 3 .. 6
        puts "小孩"
    else
        puts "其他年龄段的"
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
