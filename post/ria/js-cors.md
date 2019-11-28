---
title: 浏览器同源政策及其规避方法
date: 2018-10-04
---
# 浏览器同源政策及其规避方法
http://www.ruanyifeng.com/blog/2016/04/same-origin-policy.html
http://www.ruanyifeng.com/blog/2016/04/cors.html

# 同源策略

## 同源
协议相同 域名相同 端口相同

## 限制范围

（1） Cookie、LocalStorage 和 IndexDB 无法读取。
（2） DOM 无法获得。
（3） AJAX 请求不能发送。

# ajax cors
有三种:

1. jsonp
2. WebSocket
3. CORS [ajax cors](/p/js-ajax-cors)

# Cookie
子域名共享有两种:

    Set-Cookie: key=value; domain=.example.com; path=/
    document.domain = 'example.com';

适用于Cookie 和 iframe 窗口

# window 同源策略
iframe窗口和window.open方法打开的窗口，它们与父窗口无法通信。

    document.getElementById("myIFrame").contentWindow.document
    // Uncaught DOMException: Blocked a frame from accessing a cross-origin frame.
    window.parent.document.body
    // 报错

只是二级域名不同，那么设置上一节介绍的document.domain属性，就可以规避同源政策，拿到DOM。

对于完全不同源的网站，目前有三种方法，可以解决跨域窗口的通信问题。

    片段识别符（fragment identifier）
    window.name
    跨文档通信API（Cross-document messaging）

## 片段标识符（fragment identifier）
父窗口可以把信息，写入子窗口的片段标识符。

    var src = originURL + '#' + data;
    document.getElementById('myIFrame').src = src;

子窗口通过监听hashchange事件得到通知。

    window.onhashchange = checkMessage;
    function checkMessage() {
      var message = window.location.hash;
      // ...
    }

同样的，子窗口也可以改变父窗口的片段标识符。

    parent.location.href= target + "#" + hash;

## window.name
这个属性的最大特点是，无论是否同源，只要在*同一个窗口*里，*前一个网页* 设置了这个属性，*后一个网页* 可以读取它。

父窗口先打开一个子窗口，载入一个不同源的网页，该网页将信息写入window.name属性。

    window.name = data;

接着，子窗口跳回一个 *与主窗口同域*的网址(必须)。

    location = 'http://parent.url.com/xxx.html';

然后，主窗口就可以读取子窗口的window.name了。

    var data = document.getElementById('myFrame').contentWindow.name;

这种方法的优点是，*window.name容量很大*，可以放置非常长的字符串；缺点是必须监听子窗口window.name属性的变化，影响网页性能。

## window.postMessage
上面两种方法都属于破解，HTML5为了解决这个问题，引入了一个全新的API：跨文档通信 API（Cross-document messaging）。

这个API为window对象新增了一个window.postMessage方法，允许跨窗口通信，不论这两个窗口是否同源。

### postMessage

    otherWindow.postMessage(message, targetOrigin, [transfer]);
    otherWindow.postMessage(message, otherWindow, [transfer]);

举例来说，父窗口http://aaa.com向子窗口http://bbb.com发消息，调用postMessage方法就可以了。

    var popup = window.open('http://bbb.com', 'title');
    popup.postMessage('Hello World!', 'http://bbb.com');
    // window.opener.postMessage('Nice to see you', 'http://aaa.com');

postMessage方法的:

1. 第一个参数是具体的信息内容，
2. 第二个参数是接收消息的窗口的源（origin），即"协议 + 域名 + 端口"。也可以设为`*`，表示不限制域名，向所有窗口发送

子窗口向父窗口传值：

    window.opener.postMessage('msg','*')

### receiveMessage
父窗口和子窗口都可以通过message事件，监听对方的消息。

    window.addEventListener('message', function(e) {
      console.log(e.data);
    },false);

message事件的事件对象event，提供以下三个属性。

    event.source：发送者的窗口
    event.origin: 发送者的网址
    event.data: 消息内容

event.origin属性可以过滤非法的发送者

    windowbbb.addEventListener('message', receiveMessage);
    function receiveMessage(event) {
      if (event.origin !== 'http://aaa.com') return;
      if (event.data === 'Hello World') {
          event.source.postMessage({'msg':'收到信息了', errno:0}, event.origin);
      } else {
        console.log(event.data);
      }
    }

## LocalStorage
通过window.postMessage，读写其他窗口的 LocalStorage:

    window.onmessage = function(e) {
      if (e.origin !== 'http://bbb.com') {
        return;
      }
      var payload = JSON.parse(e.data);
      localStorage.setItem(payload.key, JSON.stringify(payload.data));
    };