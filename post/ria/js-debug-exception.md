---
title: try-catch
date: 2018-10-04
---
# try-catch
## throw any type
    throw "string"
    throw {message:"msg"}
    e = Error('msg')
        e.message
        e.stack
    e = ReferenceError('undefined')

## custom exception

    function UserException(message) {
        this.message = message;
        this.name = "UserException";
    }
    UserException.prototype = new Error();

    e = new UserException("msg")
    e.stack string
    e.message
    e.name

## catch specific exception

    // ...
    try {
        throw new SpecificError;
    } catch (e) {
        if (e instanceof SpecificError) {
            // specific error
        } else {
            throw e; // let others bubble up
        }
    }

## ReferenceError:

    undefined_func()

exception: Error

    try {
        r1 = s.length; // 此处应产生错误
        r2 = 100; // 该语句不会执行
         throw new Error('输入错误');
    } catch (e) {
        console.log(e instanceof ReferenceError) 
        console.log('出错了：' + e);
        console.log('出错了：' + e.message);
    } finally {
        console.log('finally');
    }

自定义：

    function getRectArea(width, height) {
        if (isNaN(width) || isNaN(height)) {
            throw "Parameter is not a number!";
        }
    }

    try {
        getRectArea(3, 'A');
    } catch(e) {
        console.log(e);
        // expected output: "Parameter is not a number!"
    }

## 异步错误处理
异步处理(即使js这种单线程异步), 异常不会抛出到主代码。内部需要自己try-catch

    async function f(){
        throw "f error"
    }
    try{
        f()
    }catch(e){
        console.log("error:", e)
    }

报：UnhandledPromiseRejectionWarning: f error