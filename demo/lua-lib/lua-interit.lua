-- Meta class
Shape = {area = 0}
-- 基础类方法 new
function Shape:new (o,side)
  o = o or {}
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

Square = Shape:new()
print("3.Square.area经__index指向Shape.area")
-- 派生类方法 new
function Square:new (o,side)
    o = o or Shape:new(o,side)
    print("1.o.area经__index指向Shape.area", o.area, Shape.area)
    setmetatable(o, {__index=self}) -- 继承self=Square, 间接继承 Shape
    print("2.o.area经__index指向Square.area", o.area, Square.area)
    return o
end

-- 派生类方法 printArea
function Square:printArea ()
  print("正方形面积为 ",self.area)
end

-- 创建对象
mysquare = Square:new(nil,10)
mysquare:printArea()
