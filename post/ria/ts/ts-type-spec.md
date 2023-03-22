---
title: ts expression
date: 2020-08-19
private: true
---
# 基本 expression
## not null
    let s = e!.name;  // Assert that e is non-null and access name

## & 交叉类型注意点
如果相同key但是类型不同，则该key为never。

    interface Eg1 {
      name: string,
      age: number,
    }
    
    interface Eg2 {
      color: string,
      age: string,
    }
    
    /**
     * T的类型为 {name: string; age: never; color: string}
     * 注意，age因为Eg1和Eg2中的类型不一致，所以交叉后age的类型是never
     */
    type T = Eg1 & Eg2


# Reference
- TS挑战通关技巧总结，助你打通TS奇经八脉 @度123 https://juejin.cn/post/7000560464786620423
- 22个示例深入讲解Ts https://juejin.cn/post/6994102811218673700?utm_source=gold_browser_extension
