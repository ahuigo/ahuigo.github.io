---
title: lua debug
date: 2020-05-08
private: true
---
# lua debug

## error函数(throw exception)
功能：终止正在执行的函数，并返回message的内容作为错误信息(error函数永远都不会返回)
语法格式：

    error (message [, level])

Level参数指示获得错误的位置:

    Level=1[默认]：为调用error位置(文件+行号)
    Level=2：指出哪个调用error的函数的函数
    Level=0:不添加错误位置信息

## pcall 和 xpcall、debug(catch)
Lua中处理错误，可以使用函数pcall（protected call）来包装需要执行的代码。

pcall接收一个函数和要传递给后者的参数，并执行，执行结果：有错误、无错误；返回值true或者或false, errorinfo。

语法格式如下

    if pcall(function_name, ….) then
    -- 没有错误
    else
    -- 一些错误
    end

简单实例：

    > =pcall(function(i,j) print(i+j) end, 30, 3)
    33
    true
   
    > =pcall(function(i) print(i) error('error..') end, 33)
    33
    false        stdin:1: error..

pcall以一种"保护模式"来调用第一个参数，因此pcall可以捕获函数执行中的任何错误。

> 通常在错误发生时，希望落得更多的调试信息，而不只是发生错误的位置。但pcall返回时，它已经销毁了调用桟的部分内容。

## xpcall(catch with err)
Lua提供了xpcall函数，xpcall接收第二个参数——一个错误处理函数，当错误发生时，Lua会在调用桟展开（unwind）前调用错误处理函数，于是就可以在这个函数中使用debug库来获取关于错误的额外信息了。

xpcall 使用实例 2:

    实例
    function myfunction ()
    n = n/nil
    end

    function myerrorhandler( err )
        print( "ERROR:", err )
    end

    status = xpcall( myfunction, myerrorhandler )
    print( status)

执行以上程序会出现如下错误：

    ERROR:    test2.lua:2: attempt to perform arithmetic on global 'n' (a nil value)
    false

## debug(调用栈)
debug库提供了两个通用的错误处理函数:

    debug.debug：提供一个Lua提示符，让用户来检查错误的原因
    debug.traceback：根据调用桟来构建一个扩展的错误消息

### debug+xpcall
    >=xpcall(function(i) print(i) error('error..') end, function() print(debug.traceback()) end, 33)
    33
    stack traceback:
    stdin:1: in function <stdin:1>
    [C]: in function 'error'
    stdin:1: in function <stdin:1>
    [C]: in function 'xpcall'
    stdin:1: in main chunk
    [C]: in ?
    false        nil

### traceback
    traceback ([thread,] [message [, level]]):
        数字可选项 level 指明从栈的哪一层开始回溯 （默认为 1 ，即调用 traceback 的那里）

e.g.

    function myfunction ()
        print(debug.traceback("Stack trace"))
        print("Stack trace end")
        return 10
    end
    myfunction ()

output：

    Stack trace
    stack traceback:
        a.lua:2: in function 'myfunction'
        a.lua:6: in main chunk
        [C]: in ?
    Stack trace end

### getupvalue/setupvalue 局部变量
1. getupvalue(func, 1) 获取第一个局部变量
1. setupvalue(func, 1, 'value') Set第一个局部变量

e.g.

    function newCounter ()
        local n = 0
        local k = 0
        return function ()
            k = n
            n = n + 1
            return n
            end
    end

    counter = newCounter ()
    print(counter())
    print(counter())

    local i = 1

    repeat
        name, val = debug.getupvalue(counter, i)
        if name then
            print ("index", i, name, "=", val)
                if(name == "n") then
                        debug.setupvalue (counter,2,10)
                end
            i = i + 1
        end -- if
    until not name

    print(counter())

执行以上代码输出结果为：

    1
    2
    index    1    k    =    1
    index    2    n    =    2
    11

## getinfo
print function's name
    local function myFunc()
        print(debug.getinfo(1, "n").name);
    end
    myFunc()