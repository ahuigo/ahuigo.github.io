---
title: try-catch
date: 2018-10-04
---
# try-catch
    try {
        r1 = s.length; // 此处应产生错误
        r2 = 100; // 该语句不会执行
         throw new Error('输入错误');
    } catch (e) {
         if (e instanceof TypeError) 
        console.log('出错了：' + e);
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