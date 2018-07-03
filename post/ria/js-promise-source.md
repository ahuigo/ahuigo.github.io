# 如何实现一个 Promise 

## 什么是Promise?
Promise 是在es6/7 中出现的，在此之前，jquery 已经实现过类似于 promise的defered  `defered = $.Defered()`了。

在过去我们写异步调用时往往要通过层层回调，这会导致回调地狱(callback hell)问题，callback hell 会导致难以编码和调试的问题, 这对于复杂页面来说是无法忍受的。

Promise 的出现正是为了避免callback hell, 而用链式调用取而代之。

## ES6 的promise 用法
我们以前写异步调用往往是层层回调:

        callback = console.log.bind(console)
        setTimeout(v=>{
            callback(v)
        }, 1000, 'success');

通过promise 我们可以将callback 提出来:

    new Promise((resolve, reject)=>{
        setTimeout(v=>{
            resolve(v)
        }, 1000, 'success');
    }).then(callback)

## Promise 的实现
先来分析下Promise 需要支持的语法
1. then/catch 链式调用: 用来代替callback hell
2. resolve/reject 暂存异步调用结果：当我们执行异步调用并得到返回结果后, 这个结果值必须暂存起来，这个值未来还要被传给链式调用
3. fire 执行: 当异步调用结果暂存起来后, 我们需要fire 执行已经绑定的then/catch 回调函数

### Promise 的构造函数
首先，Promise 属性中肯定需要一个 status 代表状态, fire 会在不同状态下执行不同的回调函数:
1. pending : 当异步调用没有返回时的状态
2. resolved: 当异步调用返回成功时的状态
3. rejected: 当异步调用返回失败时的状态

其次, 还需要一个`this.children_*` 数组, 存放次级Promise。什么时候用到这个数组呢？看到下面这代码你就明白了

    p = new Promise(r=>setTimeout(r(10), 5000));
    child1 = p.then(v=>console.log(v+1))
    child2 = p.then(v=>console.log(v+2))

最后，再加上其他必要的属性，我们就可以完成Promise 的构造器了：

    class MyPromise {
        constructor(task) {
            this.firing = false
            this.status = 'pending'
            this.v = undefined
            this.children_resolved = []

            if (task) {
                this.children_rejected = []
                task(this.resolve.bind(this), this.reject.bind(this))
            }
        }

    }



### then/catch 链式回调
then/catch 的链式回调要做几件事：
1. 绑定fnDone/fnFail 函数
2. 由于`then(fnDone)`支持串行的链式结构，所以它还需要返回次级 promise: `child_p`
3. 如果此时已经有异步返回值了，那么就是执行`fire` 的时机了

最终then 的实现代码如下：

    then(fnDone, fnFail) {
        var child_p;
        if (typeof (fnDone) === 'function' || typeof (fnFail) === 'function') {

            if (typeof (fnDone) === 'function' ){
                child_p = this.createChild()

                child_p.fnDone = fnDone
                this.children_resolved.push(child_p)

                if ( (this.isDone && child_p.fnDone)) {
                    child_p.fire(this.v, this.status)
                }
            }else{
                var root = this.findCatchRoot()
                if(root){
                    child_p = this.createChild()
                    child_p.fnFail = fnFail
                    root.children_rejected.push(child_p)

                    if ( (this.isFail && child_p.fnFail)) {
                        child_p.fire(this.v, this.status)
                    }
                }

                //this.root['fnFail'] = fnFail
            }
        }
        return child_p ? child_p : this
    }

### resolve/reject 暂存调用返回
当调用返回值后，我们要：
1. 通过resolve/reject 将返回值和状态存起来; 
2. 然后判断是否存在fnDone/fnFail, 如果有就立即执行fire

实现:

    resolve(v) {
        if (this.status !== 'pending') return
        this.status = 'resolved'
        this.v = v

        if (!this.firing && this.isDone) {
            for(let child_p of this.children_resolved){
                child_p.fire(this.v, this.status)
            }
        }
    }

    reject(v) {
        if (this.status !== 'pending') return
        this.status = 'rejected'
        this.v = v

        if (!this.firing && this.isFail) {
            for(let child_p of this.children_rejected){
                child_p.fire(this.v, this.status)
            }
        }
    }


### fire 执行回调函数
fire 负责:
1. 执行then/catch 链式绑定的回调函数
2. 将回调函数的返回值`child_v`, 传给次级的promise(`child_p`)
3. 如果次级的promise 已经准备好了，就执行次级的fire: `child_p.fire()`

实现：

    /**
     */
    fire(v, status) {
        this.firing = true
        if(this.parent.isDone){
            this.v= this.fnDone(v)
        }else{
            this.v = this.fnFail(v)
        }
        this.status = 'resolved'
        
        //var children = this.isDone? this.children_resolved : this.root.children_rejected
        for (let child_p of this.children_resolved) {
            child_p.fire(this.v, this.status)
        }

        this.firing = false
    }

### eventLoop
虽然js 的异步模型是基于eventLoop+callback 机制的，

由于js 是单线程的，所以eventLoop 没有线程安全的问题啊,  不会导致变量冲突。

    p = new Promise((resolve,reject)=>
        setTimeout(v=>resolve(22),0)     // 只有当主线程空闲后才执行 event callback
    )
    log = v=>console.log(v+1)
    p.then(log);
    for(i of Array(2000)){console.log(i)}; //这里耗时较长，会阻塞其他的event task

### 最终的源代码
[mypromise](https://github.com/ahuigo/js-lib/blob/master/es6/mypromise.js)
