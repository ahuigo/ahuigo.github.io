# Promise
Promise: resove-then, reject-catch
实现异步串行写法

## ajax
ajax函数将返回Promise对象:

    function ajax(method, url, data) {
        var request = new XMLHttpRequest();
        return new Promise(function (resolve, reject) {
            request.onreadystatechange = function () {
                if (request.readyState === 4) {
                    if (request.status === 200) {
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
    var p = ajax('GET', '/api/categories');
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

## 并行
Promise.all()实现如下：

    var p1 = new Promise(function (resolve, reject) {
        setTimeout(resolve, 500, 'P1');
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