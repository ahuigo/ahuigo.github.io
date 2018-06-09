# Promise
实现异步串行写法
2. generator
1. Promise: resove-then, reject-catch
2. async-await: 基于Promise的封装简化

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

Promise.then(f1).then(f2):
1. 执行Promise(f0) 中绑定的f0()==resolve(v0)
1. resolve(v0).then(f1) 执行f1(v0)
    1. f1 返回Promise, 再异步调用resove(v1)
1. resolve(v1).then(f2) 执行f2(v1)
    1. f2 返回Promise, 再异步调用resove(v2)

也可以自动包装

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
        console.log(results); // 获得一个Array: ['P1', 'P2']
    });

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
