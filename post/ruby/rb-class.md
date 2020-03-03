---
title: Ruby class
date: 2020-03-02
private: true
---
# Ruby class

## 变量
Ruby 提供了5种类型的变量：

    一般小写字母、下划线开头：变量（Variable）。
    $开头：全局变量（Global variable）。
    @开头：实例变量（Instance variable）。
    @@开头：类变量（Class variable）类变量被共享在整个继承链中
    大写字母开头：常数（Constant）

### 类变量实例

    class Customer
       @@no_of_customers=0
       def initialize(id, name, addr)
          @cust_id=id
          @cust_name=name
          @cust_addr=addr
       end
       def display_details()
          puts "Customer id #@cust_id"
          puts "Customer name #@cust_name"
          puts "Customer address #@cust_addr"
       end
       def total_no_of_customers()
          @@no_of_customers += 1
          puts "Total number of customers: #@@no_of_customers"
       end
    end
    
    # 创建对象
    cust1=Customer.new("1", "John", "Wisdom Apartments, Ludhiya")
    cust2=Customer.new("2", "Poul", "New Empire road, Khandala")

note, 除了局部变量/常量， 其它变量在字符串中的拼接时，不用加`{}`

    puts "#@cust_id #@@no_of_customers"

## new instance
    cust1 = Customer.new
    cust2 = Customer. new


## method
方法名总是`以小写字母`开始

### 构造方法 initialize
    class Customer
        @@no_of_customers=0
        def initialize(id, name, addr)
            @cust_id=id
            @cust_name=name
            @cust_addr=addr
        end
    end
    cust1=Customer.new("1", "John", "Wisdom Apartments, Ludhiya")


### 静态方法与动态方法

    class A
        def self.func1
            puts "static func1"
        end
        def func2
            puts "new.func2"
        end
    end

    A.func1
    A.new.func2

## class extend
下面两个例子snippet 等价， 都将打印“HELLO”(生成class时就执行)。 `make_hello_method`是静态方法

    class Foo
        def self.make_hello_method
            class_eval do
                def hello
                    puts "HELLO"
                end
            end
        end
    end

    class Bar < Foo # snippet 1
        puts "exec before new"
        make_hello_method
    end

    class Bar < Foo; end # snippet 2

比较下静态和动态方法

    Bar.make_hello_method
    Bar.new.hello
    Bar.new.func2

class_eval方法也接受一个String，所以当创建一个类时，可以随时创建方法，它基于传入的参数具有不同的语义。