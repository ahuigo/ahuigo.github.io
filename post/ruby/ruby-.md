---
title: Ruby
date: 2019-02-17
private:
---
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

output:

    1
    你在块 5 内
    在 test 方法内
    你在块 100 内

# hash
string key

    grades = { "Jane Doe" => 10, "Jim Doe" => 6 }

symbol key

    options = { font_size: 10, font_family: "Arial" }
    options = { :font_size => 10, :font_family => "Arial" }
    options[:font_size]

symbol value:

    options = {:key=>:value}
    options[:key]==:value

# class 
静态方法与动态方法

    class A
        def self.func1
            puts "func1"
        end
        def func2
            puts "func2"
        end
    end

    A.new.func1
    A.func2

## class extend
下面两个例子snippet 等价， 都将打印“HELLO”。 `make_hello_method`是静态方法

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
    Bar.make_hello_method

    Bar.new.hello
    Bar.new.func2

class_eval方法也接受一个String，所以当创建一个类时，可以随时创建方法，它基于传入的参数具有不同的语义。