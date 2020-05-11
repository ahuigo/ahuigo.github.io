---
title: lua func
date: 2020-05-05
private: true
---
# lua function
    function factorial1(n)
        if n == 0 then
            return 1
        else
            return n * factorial1(n - 1)
        end
    end

## call func{}??

    function f(a,b)
        print(a,b)
    end
    f{2,3}

## 匿名:

    function(key,val)--匿名函数
        return key.."="..val;
    end

## local

    local function func()
    end

## return 多值
    function f()
        return 5,10
    end
    > s, e = f()
    > print(s, e)
    5    10
## return nil

    function f()
    end
    f()==nil

## 参数
### 默认参数
    function f(name, age)
        age = age or 20
        if name == nil then
            name = 'default'
        end
        print(a,b)
    end
    f(2,3)
### 可变参数
`...`与c语言一样，表示可变参

#### 变参传给下一函数
类似python `f(*args)`

    function fwrite(fmt, ...)  ---> 固定的参数fmt
        return io.write(string.format(fmt, ...))    
    end

    fwrite("%d%d\n", 1, 2) 

#### ipairs 与变参

    function add(...)  
        local s = 0  
        print("总共传入 " .. select("#",...) .. " 个数")
        for i, v in ipairs{...} do   --> {...} 表示一个由所有变长参数构成的数组  
            s = s + v  
        end  
        return s  
    end  
    print(add(3,4,5,6,7))  --->25

#### 变参变table

   local arg={...}    --> arg 为一个表，局部变量
   for i,v in ipairs(arg) do
      result = result + v
   end

#### select 变参
第n个参数：

    select(n, …)  -- n 是数字

变参个数

    select('#', …) 