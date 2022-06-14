---
layout: page
title:	ria optimize
category: blog
description: 
private:
---
# todo
[性能工具](http://web.jobbole.com/82548/)
[性能监控系统](http://fex.baidu.com/blog/2014/05/build-performance-monitor-in-7-days/)

## Dom
页面重绘和回流以及优化
http://www.css88.com/archives/4996

## JS performance
JavaScript 的性能优化：加载和执行
http://www.ibm.com/developerworks/cn/web/1308_caiys_jsload/

## Css
CSS 优化、提高性能的方法有哪些
http://www.zhihu.com/question/19886806

# memory chrome
## Memory Heap Snap
行头

    Summary：摘要视图
    Comparison：对比视图，与其它快照对比，看增、删、Delta数量及内存大小
    Containment：俯瞰视图，自顶向下看堆的情况，根节点包括window对象，GC root，原生对象等等

列头

    Shallow Size   ： 对象本身占用的内存
    Retained Size ： 对象本身及其引用总共占用的内存
    Distance ：当前对象到根的引用层级距离
    Alloc. Size : 新分配的内存
    Freed  Size ： 释放的内存