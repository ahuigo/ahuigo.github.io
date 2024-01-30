#!/usr/bin/ruby -w
class Bar
    p "1. before new instance....."
    def self.make_hello_method
        class_eval do
            p "3.生成实例方法hello..."
            def hello
                p "HELLO"
            end
        end
    end
end

class Foo <Bar
end

p "2.生成实例方法hello...outer"
Foo.make_hello_method
p '4.exec hello'
Foo.new.hello
Foo.new().hello

Bar.new.hello
