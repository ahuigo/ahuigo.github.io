---
title: Lua 的变量
date: 2019-02-05
---
# Lua 变量

## 类型

    nil	这个最简单，只有值nil属于该类，表示一个无效值（在条件表达式中相当于false）。
    boolean	包含两个值：false和true。
    number	表示双精度类型的实浮点数
    string	字符串由一对双引号或单引号来表示
    function	由 C 或 Lua 编写的函数
    userdata	表示任意存储在变量中的C数据结构
    thread	表示执行的独立线路，用于执行协同程序
    table	Lua 中的表（table）其实是一个"关联数组"（associative arrays），数组的索引可以是数字或者是字符串。
        在 Lua 里，table 的创建是通过"构造表达式"来完成，最简单构造表达式是{}，用来创建一个空表。

type

    print(type("Hello world"))      --> string
    print(type(10.4*3))             --> number
    print(type(print))              --> function
    print(type(type))               --> function
    print(type(true))               --> boolean
    print(type(nil))                --> nil
    print(type(type(X)))            --> string

### String
不区分single/double quote

    print("a\nb")
    print('a\nb')

可以用 2 个方括号 `[[]]` 来表示"一块"字符串。

    doc = [[
        string
    ]]
    doc = [[ string ]]

#### string length
`#`返回字符串或表的长度。

    print(#"str len")
    print(#[[str len]])

#### concat

    str1 .. str2

other

    string.upper(str):
    > string.find("Hello Lua user", "Lua", 1) 
    7    9
    > string.reverse("Lua")

format

    print(string.format("日期格式化 %02d/%02d/%03d", date, month, year))
    print(string.format("%.4f",1/3))

7	string.char(arg) 和 string.byte(arg[,int])
char 将整型数字转成字符并连接， byte 转换字符为整数值(可以指定某个字符，默认第一个字符)。

    > string.char(97,98,99,100)
    abcd
    > string.byte("ABCD",4)
    68
    > string.byte("ABCD")
    65

9	string.rep(string, n)
返回字符串string的n个拷贝

    > string.rep("abcd",2)
    abcdabcd

#### 匹配
在模式匹配中有一些特殊字符，他们有特殊的意义，Lua中的特殊字符如下：

    ( ) . % + - * ? [ ^ $

单个字符(除 `^$()%.[]*+-?` 外): 与该字符自身配对

    .(点): 与任何字符配对
    %a: 与任何字母配对
    %c: 与任何控制符配对(例如\n)
    %d: 与任何数字配对
    %l: 与任何小写字母配对
    %p: 与任何标点(punctuation)配对
    %s: 与空白字符配对
    %u: 与任何大写字母配对
    %w: 与任何字母/数字配对
    %x: 与任何十六进制数配对
    %z: 与任何代表0的字符配对
    %x(此处x是非字母非数字字符): 与字符x配对. 如：%% %$ %^ 
    [数个字符类]: 与任何[]中包含的字符类配对. 例如[%w_]与任何字母/数字, 或下划线符号(_)配对
    [^数个字符类]: 与任何不包含在[]中的字符类配对. 例如[^%s]与任何非空白字符配对

上述的字符类用大写书写时, 表示与非此字符类的任何字符配对. 例如, %S表示与任何非空白字符配对.例如，'%A'非字母的字符:

    > print(string.gsub("hello, up-down!", "%A", "."))
    hello..up.down.    4

    > string.gsub("aaaa","a","z",3);
    zzza    3

string.gmatch(str, pattern)
回一个迭代器函数，每一次调用这个函数，返回一个在字符串 str 找到的下一个符合 pattern 描述的子串。如果参数 pattern 描述的字符串没有找到，迭代函数返回nil。

    > for word in string.gmatch("Hello Lua user", "%a+") do print(word) end
    Hello
    Lua
    user

string.match(str, pattern, init)
string.match()只寻找源字串str中的第一个配对. 参数init可选, 指定搜寻过程的起点, 默认为1。 
在成功配对时, 函数将返回配对表达式中的所有捕获结果; 如果没有设置捕获标记, 则返回整个配对字符串. 当没有成功的配对时, 返回nil。

    > = string.match("I have 2 questions for you.", "%d+ %a+")
    2 questions

    > = string.format("%d, %q", string.match("I have 2 questions for you.", "(%d+) (%a+)"))
    2, "questions"


### Number
    > print("2" + 6)
    8.0
    > print("2" + "6")
    8.0
    > print("2 + 6")
    2 + 6
    > print("-2e2" * "6")
    -1200.0

### table dict
#### loop dict with pairs

    tab1 = { key1 = "val1", key2 = "val2", "val3" }
    for k, v in pairs(tab1) do
        print(k .. " - " .. v)
    end

out:

    1 - val3
    key1 - val1
    key2 - val2

#### key from 1
数字索引是不能指定key= 的，而且从1开始：

    > a = {2,3,4}
    > print(a[0])
    nil
    > print(a[1])
    2
    > print(a["1"])
    nil

#### key access

    t["key"]
    t.key
    t[1]

#### nil 可销毁key和变量

    b=nil
    tab1.key1 = nil
    for k, v in pairs(tab1) do
        print(k .. " - " .. v)
    end

#### join

    table.concat (table [, sep [, start [, end]]]):
    table.concat()函数列出参数中指定table的数组部分从start位置到end位置的所有元素, 元素间以指定的分隔符(sep)隔开。

    table.insert (table, [pos,] value):
    在table的数组部分指定位置(pos)插入值为value的一个元素. pos参数可选, 默认为数组部分末尾.

    table.remove (table [, pos])
    返回table数组部分位于pos位置的元素. 其后的元素会被前移. pos参数可选, 默认为table长度, 即从最后一个元素删起。

    table.sort (table [, comp])
    对给定的table进行升序排序

## iterator
### 无状态iter

    function square(iteratorMaxCount,currentNumber)
       if currentNumber<iteratorMaxCount
       then
          currentNumber = currentNumber+1
       return currentNumber, currentNumber*currentNumber
       end
    end

    for i,n in square,3,0
    do
       print(i,n)
    end

ipairs 的内部实现：

    function iter (a, i)
        i = i + 1
        local v = a[i]
        if v then
           return i, v
        end
    end
    
    -- for i,v in iter, a, 0
    function ipairs (a)
        return iter, a, 0
    end

iter, a, i中每次传单个状态i

### 多状态的迭代器
很多情况下，迭代器需要保存多个状态信息而不是简单的状态常量和控制变量，最简单的方法是使用闭包，
还有一种方法就是将所有的状态信息封装到table内，将table作为迭代器的状态常量，因为这种情况下可以将所有的信息存放在table内，所以迭代函数通常不需要第二个参数。

以下实例我们创建了自己的迭代器：

    array = {"Lua", "Tutorial"}

    function elementIterator (collection)
       local index = 0
       local count = #collection
       -- 闭包函数
       return function ()
          index = index + 1
          if index <= count
          then
             --  返回迭代器的当前元素
             return collection[index]
          end
       end
    end

    for element in elementIterator(array)
    do
       print(element)
    end

## function
    function factorial1(n)
        if n == 0 then
            return 1
        else
            return n * factorial1(n - 1)
        end
    end

匿名:

    function(key,val)--匿名函数
        return key.."="..val;
    end

### local

    local function func()
    end

### return 多值
    > s, e = string.find("www.runoob.com", "runoob") 
    > print(s, e)
    5    10

### 可变参数
    function add(...)  
    local s = 0  
      print("总共传入 " .. select("#",...) .. " 个数")
      for i, v in ipairs{...} do   --> {...} 表示一个由所有变长参数构成的数组  
        s = s + v  
      end  
      return s  
    end  
    print(add(3,4,5,6,7))  --->25

第n个参数：

    select(n, …)  -- n 是数字


## thread
thread 中执行的是corotine, 不像thread 能同时执行

## userdata
可以将任意 C/C++ 的任意数据类型的数据（通常是 struct 和 指针）存储到 Lua 变量中调用

## 注释

    --单行注释

    --[[
    多行注释
    多行注释
    --]]

## 全局与局部
默认全局

    > print(b)
    nil
    > b=10
    > print(b)
    10

local:

    do 
        local a = 6     -- 局部变量
        b = 6           -- 对局部变量重新赋值
        print(a,b);     --> 6 6
    end

## 赋值

    x, y = y, x                     -- swap 'x' for 'y'
    a, b, c = 0, 1
        print(a,b,c)             --> 0   1   nil

## 循环
do while

    repeat
        statements
    until( condition )

while

    while( true )
    do
        print("执行下去")
        break;
    end

for:

    -- step 步长默认1
    for i=10,1,-1 do
        print(i)
    end

## if

    --[ 0 为 true ]
    if(0)
    then
        print("0 为 true")
    elseif(0==3)
    else
    end



# 参考
http://www.runoob.com/lua/lua-data-types.html