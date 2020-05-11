---
title: lua gc
date: 2020-05-08
private: true
---
# lua gc
Refer:
https://www.runoob.com/lua/lua-garbage-collection.html

## 回收原理
Lua 实现了一个增量标记-扫描收集器。 它使用这两个数字来控制垃圾收集循环： 

**垃圾收集器间歇率**: 控制着收集器需要在开启新的循环前要`等待多久`。 增大这个值会减少收集器的积极性。 当这个值比 100 小的时候，收集器在开启新的循环前不会有等待。 设置这个值为 200 就会让收集器等到总内存使用量达到 之前的两倍时才开始新的循环。


    collectgarbage("setpause", 200) ： 内存增大 2 倍（200/100）时自动释放一次内存 （200 是默认值）。

**垃圾收集器步进倍率**: 控制着收集器运作速度相对于`内存分配速度的倍率`。 增大这个值不仅会让收集器更加积极，还会增加每个增量步骤的长度。 不要把这个值设得小于 100 ， 那样的话收集器就工作的太慢了以至于永远都干不完一个循环。 默认值是 200 ，这表示收集器以内存分配的"两倍"速工作。

    collectgarbage("setstepmul", 200) ：收集器单步收集的速度相对于内存分配速度的倍率，设置 200 的倍率等于 2 倍（200/100）。（200 是默认值）


## 垃圾回收器函数
Lua 提供了以下函数collectgarbage ([opt [, arg]])用来控制自动内存管理:

    collectgarbage("collect"): 做一次完整的垃圾收集循环。通过参数 opt 它提供了一组不同的功能：

    collectgarbage("count"): 以 K 字节数为单位返回 Lua 使用的总内存数。 这个值有小数部分，所以只需要乘上 1024 就能得到 Lua 使用的准确字节数（除非溢出）。

    collectgarbage("restart"): 重启垃圾收集器的自动运行。

    collectgarbage("setpause"): 将 arg 设为收集器的 间歇率。 返回 间歇率 的前一个值。

    collectgarbage("setstepmul"): 返回 步进倍率 的前一个值。

    collectgarbage("step"): 单步运行垃圾收集器。 步长"大小"由 arg 控制。 传入 0 时，收集器步进（不可分割的）一步。 传入非 0 值， 收集器收集相当于 Lua 分配这些多（K 字节）内存的工作。 如果收集器结束一个循环将返回 true 。

    collectgarbage("stop"): 停止垃圾收集器的运行。 在调用重启前，收集器只会因显式的调用运行。

## 一个简单的垃圾回收实例:
    mytable = {"apple", "orange", "banana"}

    print(collectgarbage("count"))

    mytable = nil

    print(collectgarbage("count"))

    print(collectgarbage("collect"))

    print(collectgarbage("count"))

执行以上程序，输出结果如下(注意内存使用的变化)：

    20.9560546875
    20.9853515625
    0
    19.4111328125