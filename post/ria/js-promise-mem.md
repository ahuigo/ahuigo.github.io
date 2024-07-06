---
title: 没有resolve也没有reject的Promise会造成内存泄露吗
date: 2024-06-29
private: true
---
# 没有resolve也没有reject的Promise会造成内存泄露吗
> queryObjects()可以遍历出 V8 堆上以某对象为原型的对象们，而且执行前会先做一次垃圾回收

不会。

    let i= 0;
    while(i++<100){
        new Promise((resolve)=>{
            setTimeout(()=>resolve(1), 10*1000)
        })
    }
    queryObjects(Promise); // 100 个被setTimeout/resolve引用,10秒后才回收


    let i= 0;
    while(i++<100){
        new Promise((resolve)=>{
            document.body.addEventListener('click', resolve)
        })
    }
    queryObjects(Promise); // 100 个被click/resolve引用

    let i= 0;
    while(i++<100){
        new Promise((resolve)=>{
        })
    }
    queryObjects(Promise); // 0 个resolve引用

## 查询引用
Safari 的 DevTools 刚刚实现了一个叫 queryHolders(target)的函数，它可以找到某个对象被哪些对象所引用了：

    d = new Date()
    a = {d}
    b = {d}
    queryHolders(d)

