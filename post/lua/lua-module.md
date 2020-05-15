---
title: lua module
date: 2019-01-06
---
# 定义module.lua

    -- 文件名为 mymath.lua
    local mymath =  {}

    -- 定义一个常量
    mymath.constant = "这是一个常量"
    
    local function func2()
        print("这是一个私有函数！")
    end

    function mymath.add(a,b)
        print(a+b)
    end

    function mymath.sub(a,b)
    print(a-b)
    end

    function mymath.mul(a,b)
    print(a*b)
    end

    function mymath.div(a,b)
    print(a/b)
    end

    return mymath

old way lua modle in 5.1 5.0 不用return 

    module("mymath", package.seeall)
    function mymath.sub(a,b)
        ...
    end

# require module

    require("<模块名>")
    require "<模块名>"
    -- e.g
    require "mymath"
    print(mymath.version)

别名

    local m = require("mymath")
    print(m.constant)

## 加载机制：
1.先在全局变量 LUA_PATH + package.path 找lua，如果找过目标文件，则会调用 package.loadfile 来加载模块。

    export LUA_PATH="path1;path2;~/lua/?.lua;;"
    # 文件路径以 ";" 号分隔，最后的 2 个 ";;" 表示新加的路径后面加上原来的默认路径。
    # ~/lua/?.lua;./?.lua;

2.否则，就找从全局变量 package.cpath 获取(LUA_CPATH) 找?.so 或 ?.dll 类型的c程序库

### package.path：

    > print(package.path)
    ./?.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;/usr/lib64/lua/5.1/?.lua;/usr/lib64/lua/5.1/?/init.lu
    > print(package.cpath)
    ./?.so;/usr/lib64/lua/5.1/?.so;/usr/lib64/lua/5.1/loadall.so

修改path:

    package.path = './path/?.lua;'.. package.path

## 加载c包
C包在使用以前必须首先加载并连接so/dll

    local path = "/usr/local/lua/lib/libluasocket.so"
    -- 所有c 包需要加载和连接，连接一般用初始化的函数luaopen_socket
    local f = loadlib(path, "luaopen_socket")
    -- 真正执行连接函数
    f()


# 第三方 module: luarocks

    brew install luarocks

## install pkg
    $ luarocks install md5

代码：

    local md5 = require "md5"

