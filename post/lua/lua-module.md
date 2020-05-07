---
title: lua module
date: 2019-01-06
---
# 定义module.lua

    -- 文件名为 module.lua
    -- 定义一个名为 module 的模块
    module = {}
    
    -- 定义一个常量
    module.constant = "这是一个常量"
    
    -- 定义一个函数
    function module.func1()
        io.write("这是一个公有函数！\n")
    end
    
    local function func2()
        print("这是一个私有函数！")
    end
    
    function module.func3()
        func2()
    end
    
    return module

# require module

    require("<模块名>")
    -- 或者
    require "<模块名>
    print(module.constant)

别名

    local m = require("module")
    print(m.constant)

## 加载机制：
1.先在全局变量 package.path（由LUA_PATH 定义）找lua，如果找过目标文件，则会调用 package.loadfile 来加载模块。

    export LUA_PATH="~/lua/?.lua;;"
    # 文件路径以 ";" 号分隔，最后的 2 个 ";;" 表示新加的路径后面加上原来的默认路径。
    # ~/lua/?.lua;./?.lua;

2.否则，就找从全局变量 package.cpath 获取(LUA_CPATH) 找?.so 或 ?.dll 类型的c程序库

## 加载c包
C包在使用以前必须首先加载并连接so/dll

    local path = "/usr/local/lua/lib/libluasocket.so"
    -- 所有c 包需要加载和连接，连接一般用初始化的函数luaopen_socket
    local f = loadlib(path, "luaopen_socket")
    -- 真正执行连接函数
    f()


