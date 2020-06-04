---
title: Ruby class
date: 2020-03-02
private: true
---
# Ruby class

## 类定义与实例

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
    
Note: 除了局部变量/常量之外的其它变量, 在字符串中的拼接时不用加`{}`

    puts "#@cust_id #@@no_of_customers"

### 类实例
    cust1 = Customer.new
    cust2 = Customer. new
    cust3 = Customer. new(arg1,arg2)
    cust1=Customer.new("1", "John", "Wisdom Apartments, Ludhiya")
    cust2=Customer.new("2", "Poul", "New Empire road, Khandala")

### 访问成员属性
默认不可以直接访问成员变量, 只能这样访问

    obj = Hello.new
    p obj.instance_variable_get(:@hello) 

如果想以`obj.name`的方式访问成员属性，可以这样`attr_reader`创建`getter`

    class Hello
        attr_reader :name
        def initialize
            @name='ahui'
        end
    end
    obj = Hello.new
    p obj.name

Calling `attr_accessor` will create a `getter` AND a `setter` for the given variable:

    attr_accessor :name

### 冻结对象
让对象只读

    # 让我们冻结该对象
    box.freeze
    if( box.frozen? )
        puts "Box object is frozen object"
    else
        puts "Box object is normal object"
    end

## 类常量

    MR_COUNT = 0        # 定义在主 Object 类上的常量
    module Foo
      ::MR_COUNT = 1    # 设置全局计数为 1
      MR_COUNT = 2      # 设置局部计数为 2
    end
    puts MR_COUNT       # 这是全局常量
    puts Foo::MR_COUNT  # 这是 "Foo" 的局部常量

## 类变量 vs instance var
Ruby 提供了5种类型的变量：

    一般小写字母、下划线开头：变量（Variable）。
    $开头：全局变量（Global variable）。
    @开头：实例变量（Instance variable）。 类似this.@xx
    @@开头：类变量（Class variable）类变量被共享在整个继承链中
    大写字母开头：常数（Constant）

特殊的self 就像是php中的self+this结合体：可以访问静态动态(`def self.method, def method`)的方法、变量

类变量与实例变量的用法：
https://stackoverflow.com/questions/15773552/ruby-class-instance-variable-vs-class-variable

### instance var on class
access `instance var` via `class/self.class method`:

    class Parent
        @ths = []
        def self.things
          @ths
        end
        def things
          self.class.things
        end
      end
  
    class Child < Parent
        @ths = []
    end

    Parent.things << :car
    Child.things  << :doll
    mom = Parent.new
    chi = Child.new

    p Parent.things #=> [:car]
    p Child.things  #=> [:doll]
    p mom.things    #=> [:car]
    p chi.things    #=> [:doll]

### 类变量
access `class var` via `class/instance method`:

    class Parent
      @@ths = []
      def self.things
        @@ths
      end
      def things
        @@ths
      end
    end

    class Child < Parent
    end

    Parent.things << :car
    Child.things  << :doll

    p Parent.things #=> [:car,:doll]
    p Child.things  #=> [:car,:doll]
    p Parent.new.things  #=> [:car,:doll]
    p Child.new.things  #=> [:car,:doll]

### class/instance 是不同对象
class 与实例本质都是对象

    class A
      @name="ahui"
      def echo
        p @name
      end
      def self.echo
        p @name
      end
      def mod
        @name = 'hilo'
      end
    end
    a = A.new
    A.echo #=> ahui
    a.echo #=> nil
    a.mod 
    a.echo #=> hilo

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

### 类方法(静态方法)
类方法使用 def self.methodname() 定义

    class Account
        def self.return_date(str)
            puts "return #{str}"
        end
    end
    Account.return_date('hello')

### setter/getter
    class Box
       def initialize(w,h)
          @width, @height = w, h
       end
    
       def getWidth
          @width
       end
    
       def setWidth=(value)
          @width = value
       end
    end
    
    # 创建对象
    box = Box.new(10, 20)
    box.setWidth = 30
    
    # 使用访问器方法
    p box.getWidth()

## 类生命周期
    class Foo
        p "1. before new instance....."
        def self.make_hello_method
            class_eval do
            p "3.生成实例方法hello..."
                def hello
                    puts "HELLO"
                end
            end
        end
    end

    p "2.生成实例方法hello...outer"
    Bar.make_hello_method
    p '4.exec hello'
    Bar.new.hello
    Bar.new().hello


### to_s(toString)
    class Box
       # 构造器方法
       def initialize(w,h)
          @width, @height = w, h
       end
       # 定义 to_s 方法
       def to_s
          "(w:#@width,h:#@height)"  # 对象的字符串格式
       end
    end
    
    box = Box.new(10, 20)
    
    # 自动调用 to_s 方法
    puts "String representation of box is : #{box}"

### public/private
    Public 方法： 默认方法都是 public 的，除了 initialize 方法总是 private 的。
    Private 方法： Private 方法不能从类外部访问或查看。只有类方法可以访问私有成员。
    Protected 方法： Protected 方法只能被类及其子类的对象调用。访问也只能在类及其子类内部进行。

eg.

    # 定义类
    class Box
       # 构造器方法
       def initialize(w,h)
          @width, @height = w, h
       end
    
       # 实例方法默认是 public 的
       def getArea
          getWidth() * getHeight
       end
    
       # 定义 private 的访问器方法
       def getWidth
          @width
       end
       def getHeight
          @height
       end
       # make them private
       private :getWidth, :getHeight
    
       # 用于输出面积的实例方法
       def printArea
          @area = getWidth() * getHeight
          puts "Big box area is : #@area"
       end
       # 让实例方法是 protected 的
       protected :printArea
    end
    
    # 创建对象
    box = Box.new(10, 20)
    
    # 调用实例方法
    a = box.getArea()
    puts "Area of the box is : #{a}"
    
    # 尝试调用 protected 的实例方法
    box.printArea()

## alias 
这个语句用于为方法或全局变量起别名

    alias 新方法名 方法名
    alias 全局变量 全局变量

    alias foo bar
    alias $MATCH $&

取消别名：

    undef 方法名

## 子类
### 继承父类
    # 定义类
    class Box
       # 构造器方法
       def initialize(w,h)
          @width, @height = w, h
       end
       # 实例方法
       def getArea
          @width * @height
       end
    end
    
    # 定义子类
    class BigBox < Box
       # 添加一个新的实例方法
       def printArea
          @area = @width * @height
          puts "Big box area is : #@area"
       end
    end
    
    # 创建对象
    box = BigBox.new(10, 20)
    
    # 输出面积
    box.printArea()

最简单的继承：

    class Bar < Foo; end

#### 继承静态方法的执行

    class Formula
        def self.url(url)
            p url
            @url=url
        end
    end

    class BigBox < Formula
        url "home"
    end



### 方法重载
改写父类的方法

    # 定义子类
    class BigBox < Box
       # 修改父类已有的 getArea 方法
       def getArea
          #@area = @width * @height
          @area = self.getArea
          puts "Big box area is : #@area"
       end
    end

### super vs self
`super` method calls the `parent class/instance method`.
`self` calls the `self class/instance method`.

    class A
      def a
        # do stuff for A
      end
    end

    class B < A
      def self.a
        super # or use super() 
      end
    end
    B.new.a

## 运算符重载
我们希望使用: 
1. 用`+` 运算符执行两个 Box 对象的向量加法，
2. 用 `*` 运算符来把 Box 的 width 和 height 相乘
3. 使用一元运算符 - 对 Box 的 width 和 height 求反。

下面是一个带有数学运算符定义的 Box 类版本：

    class Box
      attr_reader :width 
      attr_reader :height

      def initialize(w,h) # 初始化 width 和 height
        @width,@height = w, h
      end
    
      def +(other)         # 定义 + 来执行向量加法
        Box.new(@width + other.width, @height + other.height)
      end
    
      def -@               # 定义一元运算符 - 来对 width 和 height 求反
        Box.new(-@width, -@height)
      end
    
      def *(scalar)        # 执行标量乘法
        Box.new(@width*scalar, @height*scalar)
      end
    end
    a=Box.new(2,3)
    b=a+Box.new(3,2)
    p b.width


## meta 类信息
下例self指的是类，不是实例

    class Box
        # 输出类信息
        puts "Class of self = #{self.class}"
        puts "Name of self = #{self.name}"
    end

输出

    Class of self = Class
    Name of self = Box

# ::命名空间
双冒号`::`或`module`是定义 namespace 的(https://ruby-china.org/topics/7932)
1. `Foo::Bar`,`Foo::method`: 找一个名字叫 Foo 的 namespace ，然后让它返回它里面的 Bar/method 参数( 可以是个常量，可以是个类，可以是个方法（后两者在 Ruby 中可视为常量）
2. `FooBar.method1` 可访问静态方法。`::` 只能用来找 class method, 而`instance method` 就只能用 `.` 了

比方这样

    class Foo
    Bar = "hello"
    bar = "hello"
    end
    =========
    Foo::Bar  # => "hello"
    Foo::bar  #  => 出错
    Foo.Bar  #  => 出错
    Foo.bar  #  => 出错

另外 :: 在开始位置则表示回到 root namespace ，就是不管前面套了几个 Module ，都算你其实写在最外层。

    module Foo
        class ::FooBar
            def self.method1
                "method1"
            end
        end
    end
    p FooBar::method1
    => "method1"
