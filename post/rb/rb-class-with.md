---
title: ruby class with and prototype
date: 2020-06-04
private: true
---
# with and prototype
`<<obj` 类似python 的`with obj:`, 
`<<self`则提供了类似js 改写prototype的方便方法

    class String
        class << self
            def value_of obj
                obj.to_s
            end
        end
    end
    String.value_of 42   # => "42"

This can also be written as a shorthand:

    class String
        def self.value_of obj
            obj.to_s
        end
    end

Or even shorter:

    def String.value_of obj
        obj.to_s
    end
