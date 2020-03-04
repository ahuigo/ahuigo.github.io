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

## 实例
    cust1 = Customer.new
    cust2 = Customer. new
    cust3 = Customer. new(arg1,arg2)

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

Note: 除了局部变量/常量之外的其它变量, 在字符串中的拼接时不用加`{}`

    puts "#@cust_id #@@no_of_customers"


### 访问成员属性
默认不可以直接访问成员变量, 只能这样

    obj = Hello.new
    p obj.instance_variable_get(:@hello) #nil

如果想以`obj.name`的方式访问成员属性，可以这样

    class Hello
        attr_reader :name
        def initialize
            @name='ahui'
        end
    end
    obj = Hello.new
    p obj.name

### 冻结对象
让对象只读

    # 让我们冻结该对象
    box.freeze
    if( box.frozen? )
        puts "Box object is frozen object"
    else
        puts "Box object is normal object"
    end


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

    class Accounts
        def Accounts.return_date(str)
            puts "return #{str}"
        end
    end
    Accounts.return_date('hello')

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

### 方法重载
改写父类的方法

    # 定义子类
    class BigBox < Box
       # 改变已有的 getArea 方法
       def getArea
          @area = @width * @height
          puts "Big box area is : #@area"
       end
    end

### 运算符重载
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
    p b


### todo
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

## meta 类信息
self在ruby 指的是类，不是实例

    class Box
        # 输出类信息
        puts "Class of self = #{self.class}"
        puts "Name of self = #{self.name}"
    end

输出

    Class of self = Class
    Name of self = Box
