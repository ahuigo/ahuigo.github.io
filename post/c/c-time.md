---
layout: page
title:	c time
category: blog
description:
---
# Time
unix有两种时间类型：

    time_t 
        UTC时间(1970.1.1开始)
    clock_t
        进程时间，以时钟计算。sysconf函数可获取每秒滴答n个时钟

进程时间又分三种：

    时钟时间= 用户cpu时间 + 系统内核cpu时间

可以用time 检测时钟时间：

    $ time sleep 1
    0.00s user 0.00s system 0% cpu 1.011 total