---
title: golang 原子队列实现(无锁)
date: 2020-07-22
private: true
---
# golang 原子队列实现(无锁)
本文参考：
    // cas vs mutex 性能https://github.com/golang/go/issues/17604
    // 无锁队列的实现 https://coolshell.cn/articles/8239.html
    // 原子操作 https://studygolang.com/articles/19638
    MPE

相关代码：
1. go-lib/goroutine/cas/atom-cas.go