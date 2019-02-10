---
title: Node 的定时器
date: 2019-02-08
private:
---
# Node 定时器

    // 下面两行，次轮循环执行
    setTimeout(() => console.log(1));
    setImmediate(() => console.log(2));
    // 下面两行，本轮循环执行: nextTickQueue->microQueue
    process.nextTick(() => console.log(3));
    Promise.resolve().then(() => console.log(4));

# 参考
- Node 的定时器详情 http://www.ruanyifeng.com/blog/2018/02/node-event-loop.html
