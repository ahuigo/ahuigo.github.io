---
title: lua 协程
date: 2020-05-08
private: true
---
# lua 协程基本语法
refer: https://www.runoob.com/lua/lua-coroutine.html

    方法	描述
    coroutine.create()	创建 coroutine，返回 coroutine， 参数是一个函数，当和 resume 配合使用的时候就唤醒函数调用
    coroutine.resume()	重启 coroutine，和 create 配合使用
    coroutine.yield()	挂起 coroutine，将 coroutine 设置为挂起状态，这个和 resume 配合使用能有很多有用的效果
    coroutine.status()	查看 coroutine 的状态
        注：coroutine 的状态有三种：dead，suspended，running，具体什么时候有这样的状态请参考下面的程序
    coroutine.wrap（）	创建 coroutine，返回一个函数，一旦你调用这个函数，就进入 coroutine，和 create 功能重复
    coroutine.running()	返回正在跑的 coroutine，一个 coroutine 就是一个线程，当使用running的时候，就是返回一个 corouting 的线程号

## 示例

    -- coroutine_test.lua 文件
    co = coroutine.create(
        function(i)
            print(i);
        end
    )
    
    coroutine.resume(co, 1)   -- 1
    print(coroutine.status(co))  -- dead
    
    print("----------")
    
    co = coroutine.wrap(
        function(i)
            print(i);
        end
    )
    
    co(1) -- 1
    print("----------")
    
    co2 = coroutine.create(
        function()
            for i=1,10 do
                print(i)
                if i == 3 then
                    print(coroutine.status(co2))  --running
                    print(coroutine.running()) --thread:XXXXXX
                end
                coroutine.yield()
            end
        end
    )
    
    coroutine.resume(co2) --1
    coroutine.resume(co2) --2
    coroutine.resume(co2) --3
    
    print(coroutine.status(co2))   -- suspended
    print(coroutine.running())
    
    print("----------")

## yield/send 示例
    function foo (a)
        print("foo 函数输出", a)
        return coroutine.yield(2 * a) -- 返回  2*a 的值
    end
    
    co = coroutine.create(function (a , b)
        print("第一次协同程序执行输出", a, b) -- co-body 1 10
        local r = foo(a + 1)
        
        print("第二次协同程序执行输出", r)
        local r, s = coroutine.yield(a + b, a - b)  -- a，b的值为第一次调用协同程序时传入
        
        print("第三次协同程序执行输出", r, s)
        return b, "结束协同程序"                   -- b的值为第二次调用协同程序时传入
    end)
        
    print("main", coroutine.resume(co, 1, 10)) -- true, 4
    print("--分割线----")
    print("main", coroutine.resume(co, "r")) -- true 11 -9
    print("---分割线---")
    print("main", coroutine.resume(co, "x", "y")) -- true 10 end
    print("---分割线---")
    print("main", coroutine.resume(co, "x", "y")) -- cannot resume dead coroutine
    print("---分割线---")

## 生产者-消费者问题
现在我就使用Lua的协同程序来完成生产者-消费者这一经典问题。

    local newProductor

    function productor()
        local i = 0
        while true do
            i = i + 1
            send(i)     -- 将生产的物品发送给消费者
        end
    end

    function consumer()
        while true do
            local i = receive()     -- 从生产者那里得到物品
            print(i)
        end
    end

    function receive()
        local status, value = coroutine.resume(newProductor)
        return value
    end

    function send(x)
        coroutine.yield(x)     -- x表示需要发送的值，值返回以后，就挂起该协同程序
    end

    -- 启动程序
    newProductor = coroutine.create(productor)
    consumer()