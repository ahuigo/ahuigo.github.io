---
title: lua dict
date: 2020-05-05
private: true
---
# lua table
## define table
table 就跟php 的一样，dict+list混合
### table dict+list

    tab1 = {key1="val1", key2 = "val2", "val3"}
    for k, v in pairs(tab1) do
        print(k .. " -> " .. v)
    end

out:

    1 -> val3
    key1 -> val1
    key2 -> val2

### table: key from 1
数字索引是不能指定key=str 的，而且从1开始：

    > a = {2,3,4}
    > print(a[0])
    nil
    > print(a[1])
    2
    > print(a["1"])
    nil

## access
### key access

    t["key"]
    t.key
    t[1]

### length table

    #t

当我们获取 table 的长度的时候无论是使用 # 还是 table.getn 其都会在索引中断的地方停止计数，而导致无法正确取得 table 的长度。
可以使用以下方法来代替：

    function table_leng(t)
        local leng=0
        for k, v in pairs(t) do
            leng=leng+1
        end
        return leng;
    end


## assign and nil
### nil 可销毁key和变量

    b=nil
    tab1.key1 = nil
    for k, v in pairs(tab1) do
        print(k .. " - " .. v)
    end

### join

    table.concat (table [, sep [, start [, end]]]):
    table.concat()函数列出参数中指定table的数组部分从start位置到end位置的所有元素, 元素间以指定的分隔符(sep)隔开。

    table.insert (table, [pos,] value):
    在table的数组部分指定位置(pos)插入值为value的一个元素. pos参数可选, 默认为数组部分末尾.

    table.remove (table [, pos])
    返回table数组部分位于pos位置的元素. 其后的元素会被前移. pos参数可选, 默认为table长度, 即从最后一个元素删起。

    table.sort (table [, comp])
    对给定的table进行升序排序

# iterator
## 泛型 for 迭代器
泛型 for 在自己内部保存迭代函数，实际上它保存三个值：迭代函数、状态常量、控制变量。

    array = {"Google", "Runoob"}
    for key,value in ipairs(array)
    do
        print(key, value)
    end

### 无状态iter
不保留任何状态的迭代器

    function square(iteratorMaxCount,currentNumber)
       if currentNumber<iteratorMaxCount
       then
          currentNumber = currentNumber+1
       return currentNumber, currentNumber*currentNumber
       end
    end

    -- square即是函数，也是迭代器
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
