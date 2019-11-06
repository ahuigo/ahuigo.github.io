---
title: TS generic
date: 2019-11-04
private: 
---
# 泛型(generic)
如果想支持多种类型补全提示，可以这样:（或者函数重载）

    function one(a: any) : any{
        if(typeof a === 'number'){
            let r = (a as number)
            return r
        }
    }

有了泛型，我们可以一随便指定T：

    function one<T>(a: T) : T{
        return a;
    }

    let a1 = one<number>(1)
    let a2 = one(520)