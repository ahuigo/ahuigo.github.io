---
title: golang 面试题
date: 2021-03-04
private: true
---
# golang 面试题
go gc: https://zhuanlan.zhihu.com/p/352871607
# 无锁链表的实现
# 时间轮算法实现

# 判断团队的技术
    1. 单元测试是怎么做的
        1. 后端unittest
            3. server/service 怎么做功能测试? 依赖的api/db 要mock吗
            1. http 怎么mock
            2. db 怎么mock
        2. 前端的unittest
            1. SSR 怎么测试? 
                1. server mock随机的端口（"127.0.0.1:0") 还是直接启动？
            2. CSR 怎么测试点击操作
    2. cicd 用的什么？
        1. deploy 到不同的环境，需要重新build image吗？
        2. 项目的配置管理方案: viper/ etcd
        3. 线上项目的密钥怎么管理?
