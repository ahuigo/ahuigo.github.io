---
title: Ruby class
date: 2020-03-02
private: true
---
# Ruby class
静态方法与动态方法

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