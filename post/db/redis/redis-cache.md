---
title: cache 穿透问题
date: 2019-03-02
---
# cache 失效问题

## 缓存穿透
Q: 不存在的Key， 导致访问穿透到DB
A： 将存在的key 用bloomfilter 档一下，再访问DB

## 缓存雪崩
Q: 大量key同时失效 失效引发
A：为key 设定随机的过期时间

## 缓存失效
Q：某一个热门数据key 失效的瞬间，此key访问 击穿到DB
A：两种
1. 每次访问key, 就延长有效期
2. 每次访问利用前setnx(set if not exists) `setnx key "lock"` 加一把锁。访问结束再删除。（并发变串行，性能较差）