---
title: lua object
date: 2020-05-08
private: true
---

# lua object

## 对象

lua 的对象基于table(类名), setmetatable 扩展的. 参考lua-dict-meta.md

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
    myshape:printArea() -- 注意如果是使用 myshape.printArea(), 那么self 为nil
    print(Shape.area) -- 原型也被改了 100

用`o.area = side*side`改进

    -- 元类
    Shape = {area = 0}

    -- 基础类方法 new
    function Shape:new (o,side)
      o = o or {}
      -- setmetatable(o, {__index=self})
      setmetatable(o, self)
      self.__index = self
      side = side or 0
      o.area = side*side;
      return o
    end

    -- 基础类方法 printArea
    function Shape:printArea ()
      print("面积为 ",self.area)
    end

    -- 创建对象
    myshape = Shape:new(nil,10)
    myshape:printArea() -- 注意不是 myshape.printArea()
    print(Shape.area) -- 原型不会改 0

### 属性

    local Auth = { env = 'dev'}
    function Auth:new()
        local o = {age = 3 }
        setmetatable(o, {__index=self})
        o.name = 'yxh'
        return o
    end


    function Auth:echo()
        print("this is nil:",self.envx) -- nil
        print('prototype env:',self.env)
        print('name:',self.name)
        print('age:',self.age)
    end

    o = Auth:new()
    o:echo() -- 不是o.ehco()

### self 的不同

```lua
--[[
-- 正确的代码如下
local test = {}

function test:new()
    self.__index = self
    return setmetatable({}, self)
end

function test:say()
    print("111")
end

local t1 = test:new()
t1.say()

local t2 = t1:new()
t2.say()
--]]

local test2 = {}

test2.__index = test2

-- 相当于test2.new = function
function test2:new()
    print('new:',self==test2) -- true <- test2.new() | false <- t3.new()
    return setmetatable({}, self)    -- 试试将self 替换成 test2, 就不会报错
end

function test2:say()
    print("222")
end

local t3 = test2:new() -- getmetatable(t3) == self==test2
t3.say() -- 实际访问的是： test2.__index.say() == test2.__index.say() == test2.say()

local t4 = t3:new() -- getmetatable(t4) == self==t3
t4.say() -- 实际访问的是t3.__index.say(), 但是不存在`t3.__index`, 除非加t3.__index = t3
```

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
