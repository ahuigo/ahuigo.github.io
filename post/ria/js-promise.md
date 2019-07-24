---
title: JS Promise
date: 2018-10-04
---
# 递归promise
Promise 是递归的，Reject 不是

    const onResolved = e => console.log('resolve , ', e );
    const onRejected = e => console.log('reject , ', e );

    new Promise( ( resolve , reject ) => {
        resolve( new Promise( ( resolve , reject ) => {
            resolve(42);
        } ) );
    } ).then( onResolved , onRejected );

    new Promise( ( resolve , reject ) => {
        resolve( new Promise( ( resolve , reject ) => {
            reject(42);
        } ) );
    } ).then( onResolved , onRejected );

    new Promise( ( resolve , reject ) => {
        reject( new Promise( ( resolve , reject ) => {
            resolve(42);
        } ) );
    } ).then( onResolved , onRejected );

    new Promise( ( resolve , reject ) => {
        reject( new Promise( ( resolve , reject ) => {
            reject(42);
        } ) );
    } ).then( onResolved , onRejected );

# JS Promise
实现异步串行写法
1. generator
1. Promise: resolve-then, reject-catch
2. async-await: 
    1. sync: `result = await promise` 
    2. async: `promise.then(r=>{result=r})`+block

## eventloop
js 是单线程的，通过eventloop 调度，所以回调函数是安全的。

如果想在eventloop 前后插入task，可以通过nextTick/setImmedite:

    log=console.log
    setImmediate(r=>log('4.0 setImmediate'));
    setImmediate(r=>log('4.1 setImmediate'));
    setTimeout(r=>log('3. TIMEOUT FIRED'), 0)
    process.nextTick(r=>log('1.1 nextTick'));
    process.nextTick(r=>log('1.2 nextTick'));

## promise status
执行态和完成态(undefied/rejected/resolved)

    Promise { <pending> }
    Promise { undefined }
    Promise { resolved/resolved }

create instantiated promise

    var promise = Promise.resolve(100);
    var promise = new Promise(r=>r(100));

    new Promise(resolve => setTimeout(resolve, ms));


## ajax
ajax函数将返回Promise对象:

    function ajax(method, url, data) {
        var request = new XMLHttpRequest();
        return new Promise(function (resolve, reject) {
            request.onreadystatechange = function () {
                if (request.readyState === 4) {
                    if (request.status === 200) {
                        console.log(request.responseText)
                        resolve(request.responseText);
                    } else {
                        reject(request.status);
                    }
                }
            };
            request.open(method, url);
            request.send(data);
        });
    }
    var log = document.getElementById('test-promise-ajax-result');
    var p = ajax('GET', '/api/categories'); //stop at resolve/reject
    p.then(function (text) { // 如果AJAX成功，获得响应内容
        log.innerText = text;
    }).catch(function (status) { // 如果AJAX失败，获得响应代码
        log.innerText = 'ERROR: ' + status;
    });

## catch
catch 会捕获exception

    (new Promise(()=>{throw new Exception('aaaaa');})).catch(r=>console.log({r:r}))

then+catch:

    Promise.reject(1).then(
        v=>console.log([v]), 
        e=>console.log(e)
    )

## 串行

    // 5秒后返回input*input的计算结果:
    function multiply(input) {
        return new Promise(function (resolve, reject) {
            log('calculating ' + input + ' x ' + input + '...');
            setTimeout(resolve, 5000, input * input);//resolve(input*input)
        });
    }

    // 5秒后返回input+input的计算结果:
    function add(input) {
        return new Promise(function (resolve, reject) {
            log('calculating ' + input + ' + ' + input + '...');
            setTimeout(resolve, 5000, input + input);
        });
    }

    var p = new Promise(function (resolve, reject) {
        log('start new Promise...');
        resolve(123);
    });

    p.then(multiply)
    .then(add)
    .then(multiply)
    .then(add)
    .then(function (result) {
        log('Got value: ' + result);
    });

promise.then(f1).then(f2), 对于then/catch 而言： 
1. 如果promise 中没有resolve, promise 正常执行，但是`.then(func)` 永远没有机会执行，
2. f1(),f2() 可以是return promise(就是resolve 返回的参数)，
3. 可以是return value. (value 直接作为参数传递)
4. 但是resolve 不能用于then, 它只能被Promise 包装！Promise 会抛弃return 值

也可以func 返回

    var p = new Promise(function (resolve, reject) {
        console.log('start new Promise2...');
        resolve(124); //Promise.resolve(124)
    }).then(e=>{return e+1}).
        then(e=>console.log(e)); // second
    console.log({p}); // first 

Another example

    fetch('http://localhost:5001').then(response=>response.json()).then(json=>{
        this.products=json.products
    })

## 并行
Promise.all()实现如下：

    var p1 = new Promise(function (resolve, reject) {
        saetTimeout(resolve, 500, 'P1');
    });
    var p2 = new Promise(function (resolve, reject) {
        setTimeout(resolve, 600, 'P2');
    });
    // 同时执行p1和p2，并在它们都完成后执行then:
    Promise.all([p1, p2]).then(function (results) {
        // 获得一个Array: ['P1', 'P2']
        console.log('results：',results); 
    });

如果有多个错误，all.catch 只能捕获一个错误: 

    var p1 = async ()=> {
        console.log('p11111')
        return 'p1'; //same as resolve('p1')
    };
    var error1= async () =>{
        return Promise.reject('Error1')
    };
    var error2= async () =>{
        throw 'Error2 Value with no trace'
        throw new Error('Error2 Exception')
    };
    Promise.all([p1(), error1(),error2()]).then(function (results) {
        console.log('results：',results); 
    }).catch(e=>console.log({'error':e}));


同时向两个URL读取用户的个人信息，只需要获得先返回的结果即可。这种情况下，用Promise.race()实现：

    var p1 = new Promise(function (resolve, reject) {
        setTimeout(resolve, 500, 'P1');
    });
    var p2 = new Promise(function (resolve, reject) {
        setTimeout(resolve, 600, 'P2');
    });
    Promise.race([p1, p2]).then(function (result) {
        console.log(result); // 'P1'
    });

# async-await
1. then: async
2. await: sync

##
    fetch(this.url, this.options).then(async (response) => {
            throw (res)
    }).catch(e => {
        this.error(e.message || e, e);
    })

## await catch data
await 不能捕获exceptio/reject

但是 await 可以通过catch 得到exception/reject 的值

    f=async ()=>{
        p=await (new Promise(()=>{throw new Exception('aaaaa');}).catch(r=>100)); 
        //100
        console.log(p)
    }
    f()

await reject:

    f = async ()=>{
        //UnhandledPromiseRejectionWarning
        await Promise.reject(1)

        //2
        await Promise.reject(1).catch(r=>r+1)

        //pending
        await new Promise(r=>{})
    }
    f()

## catch async exception
只有用await 才能catch 到async 发出的 exception

    try{
        await f()
    } catch(e){
        console.log(e)
    }


## throw vs catch
    new Promise(function() {
        setTimeout(function() {
            throw 'or nah';
            //return Promise.reject('or nah'); //also won't work
        }, 1000);
    }).catch(function(e) {
        console.log([e]); // doesn't happen
    });

## try catch 
catch err+data

    export function catchEm(promise) {
      return promise.then(data => [null, data])
        .catch(err => [err]);
    }

    const [err, data] = await catchEm(asyncFunction(arg1, arg2));


async is used to await promise:

    var p = new Promise(resolve => {
        setTimeout(() => resolve('resolved'), 2000);
    });

    async function asyncCall() {
        console.log('start');
        var result = await p;
        console.log(result); // expected output: "resolved"
        return 'real end!';
    }
    asyncCall(); // not 'real end', but promise
    console.log('not end!');

Notice: 
1. 即使没有await, 程序也要等promise 执行完毕才能退出！
2. `await p` 阻塞局部，但是`async` 不会阻塞整体, 所以两者要`成对存在`

await async: 输出2

    async function f(){return 1}
    (
        async ()=>console.log(1+await f())
    )()

## asyncFunc() is promise
1. As promoise support both: then/catch/await
2. AsyncFunc's `return` is passed to sub promise's `resolve`

e.g.:

    asyncFunc().then(v=>console.log(v));
    v = await asyncFunc().then(v=>(v));// 同步阻塞

1. await/then 只接受`resolve`, catch 只接受`reject`:
    1.  没有resolve, await/then 就不会执行. await 也会阻塞后面的语句. promise 正常执行
    2.  没有reject, catch 则不执行

    var p = new Promise((resolve,reject) => {
        setTimeout(() => {
            //resolve('abc')
            console.log('work')
        }, 1000);
    });

    async function A(){
        console.log([await p])
        console.log('not work')
    }
    a=A()
    console.log(a);//pending

    new Promise((resolve,reject) => {
        setTimeout(e => console.log(a), 2000); //a 由于await 永远阻塞pending 状态. 
                                                //但是没有timer runing, 不会阻塞程序的退出
    });

## async in then:
## promise in then:

    fetch(url).then(async response=>await response.json())

## combine await/then/catch
1. catch 不会向后面的 catch 传导, 但是会向后面的then 传值
2. reject(r)、resolve(r) 不会终止函数，但是第一个r 会被promise 传给 catch/then

example:

    (async function a(){
        var p = new Promise((resolve,reject) => {
            reject(0)
            console.log('----work1--------')
            resolve(10)
            console.log('----work2--------')
        });
        console.log('reject:', await p.then(e=>e+1).catch(e=>e+3).catch(e=>e+30)); //reject 3
        console.log('reject:', await p.then(e=>e+1).catch(e=>e+3).then(e=>e+30)); //reject 33(from memory)
        console.log('resolve:', await Promise.resolve(0).then(e=>e+1).catch(e=>e+3).then(e=>e+30)); //reject 31(from memory)
    })()

result:

    ----work1--------
    ----work2--------
    reject: 3
    reject: 33
    resolve: 31