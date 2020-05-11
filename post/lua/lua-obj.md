---
title: lua object
date: 2020-05-08
private: true
---
# lua object
## 对象
lua 的对象基于table(类名), setmetatable扩展的. 
冒号方法内self 指向 table原型。下例的self 指向Shape

    -- 元类
    Shape = {area = 0}

    -- 基础类方法 new
    function Shape:new (o,side)
      o = o or {}
      -- setmetatable(o, {__index=self})
      setmetatable(o, self)
      self.__index = self
      side = side or 0
      self.area = side*side;
      return o
    end

    -- 基础类方法 printArea
    function Shape:printArea ()
      print("面积为 ",self.area)
    end

    -- 创建对象
    myshape = Shape:new(nil,10)
    myshape:printArea()
    print(Shape.area) -- 原型也被改了

## Lua 继承
继承是指一个对象直接使用另一对象的属性和方法。可用于扩展基础类的属性和方法。

接下来的实例，Square 对象继承了 Shape 类:

    Square = Shape:new()            -- Square 的meta还是Shape
    function Square:new (o,side)
      o = o or Shape:new(o,side)    -- 先继承Shape
      setmetatable(o, self)         -- 
      self.__index = self           -- 改为继承self=Square, 
                                    -- Square 的meta还是Shape
      return o
    end

    -- 创建对象
    mysquare = Square:new(nil,10)
    mysquare:printArea()

完整的例子：demo/lua-lib/lua-interit.lua