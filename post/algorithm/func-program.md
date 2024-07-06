---
title: 函数式编程
date: 2020-05-15
private: true
---
# currying 科里化
currying 也叫部分求值

很多语言都提供了实现currying的函数：如js的bind, python的partial

或者自己通过闭包实现currying

## js 版参数的科里化
实现一个function sum，使

    sum(1)(2)(3)()返回6；
    sum(4)()返回4；
    sum(7)(1)()返回8；

### 通过bind 实现(实时计算)

    f=(v, n)=>{
        if(n===undefined){
            return v;
        }else{
            return f.bind(null, v+n)
        }
    }
    sum=f.bind(null,0)

### 通过闭包实现通用的currying(柯里化):
缓存args

    function sum(...arg1){
        return (...args2)=>{
            if(len(args2) == 0){
                return arg1.reduce((s,a)=>s+a, 0)
            }else{
                return sum(...arg1,...arg2)
            }
        }
    }

    // 或
    function sum(){
        let prev = arguments
        return function rawsum(){
            let args = arguments
            if(args.length==0){
                return prev.reduce((s,b)=>s+b)
                return  Math.sum(prev)
            }
            prev = [...prev, ...args]
            return rawsum
        }
    }

#### 通过call/bind实现通用的currying
将多参数的函数转换成单参数的形式(柯里化), 这时我们用 factorial 为例

    function currying(fn, n) {
        return function (m) {
            return fn.call(this, m, n);
        };
    }

    function tailFactorial(n, total) {
        if (n === 1) return total;
        return tailFactorial(n - 1, n * total);
    }

    const factorial = currying(tailFactorial, 1);
    factorial(5) // 120

## python 实现固定参数的科里化

    def curry(fn, k=None):
        k = k or fn.__code__.co_argcount
        def p(*a):
            l = len(a)
            if l == k:
                return fn(*a)
            elif l < k:
                return curry(lambda *b: fn(*(a + b)), k - l)
            elif l > k:
                raise TypeError('too many arguments', a)

        return p


    @curry
    def fun(x, y, z):
        return x + y + z 

    print(fun(1)(2)(3))
    print(fun(1, 2)(3))
    print(fun(1, 2, 3))

