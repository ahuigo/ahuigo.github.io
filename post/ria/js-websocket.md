---
title: Socket.io
date: 2018-10-04
---
# Socket.io
ws 和 wss 均为 WebSocket 协议的 schema，一个是非安全的，一个是安全的tcp + ws as ws，tcp + tls + ws as wss 
Socket.IO 支持: ：WebSocket, Adobe Flash Socket, AJAX long polling, AJAX multipart streaming, Forever Iframe, JSONP Polling

# websocket
廖雪峰老师课程笔记: https://www.liaoxuefeng.com/wiki/001434446689867b27157e896e74d51a89c25cc8b43bdb3000/0014727922914053479c966220f47da91991fa9c27ac3ea000
代码: 
1. js-lib/net/websoket.server.js client
2. php: https://github.com/ahuigo/php-websockets

## 性能优化实战：百万级WebSockets和Go语言
https://segmentfault.com/a/1190000011162605

## 协议原理
websocket 利用了HTTP协议来建立连接。
HTML5 的WebSocket 真正的实现了双向全双工(bi-directional, full-duplex)通信，它是基于tcp 的socket 套接字. 它所使用的是WebSocket protocol.

首先，WebSocket连接必须由浏览器发起，因为请求协议是一个标准的HTTP请求，格式如下：

    GET ws://localhost:3000/chat HTTP/1.1
    Host: localhost
    Upgrade: websocket
    Connection: Upgrade
	Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==
	Sec-WebSocket-Protocol: chat, superchat
    Sec-WebSocket-Version: 13
    Origin: http://localhost:3000

该请求和普通的HTTP请求有几点不同：

1. GET请求的地址不是类似/path/，而是以ws://开头的地址；
2. 请求头`Upgrade: websocket和Connection: Upgrade`表示这个连接将要被转换为WebSocket连接；
3. `Sec-WebSocket-Key` 是用于标识这个连接，并非用于加密数据；
4. `Sec-WebSocket-Version` 指定了WebSocket的协议版本。 版本号和子协议规定了双方能理解的数据格式，以及是否支持压缩等等。

随后，服务器如果接受该请求，就会返回如下响应：

    HTTP/1.1 101 Switching Protocols
    Upgrade: websocket
    Connection: Upgrade
    Sec-WebSocket-Accept: server-random-string

1. 该响应代码101表示本次连接的HTTP协议即将被更改，
2. 更改后的协议就是`Upgrade: websocket`指定的WebSocket协议。

## server
js-lib/net/websocket.server.js

    // 导入WebSocket模块:
    const WebSocket = require('ws');
    const WebSocketServer = WebSocket.Server;

    // 实例化:
    const wss = new WebSocketServer({
        port: 3000
    });

    //响应
    wss.on('connection', function (ws, upgradeReq) {
        ws.upgradeReq = upgradeReq
        console.log(`[SERVER] connection()`);
        console.log(upgradeReq.url);
        url.parse(ws.upgradeReq.url, true);
        for(let k in upgradeReq){
            //console.log(k,upgradeReq[k])
        }
        ws.on('message', function (message) {
            console.log(`[SERVER] Received: ${message}`);
            ws.send(`ECHO: ${message}`, (err) => {              //可多次
                if (err) {
                    console.log(`[SERVER] error: ${err}`);
                }
            });
        })
    });

### ws.upgradeReq
`IncomingMessage=ws.upgradeReq` 是http request

    ws.upgradeReq.url
    ws.upgradeReq.headers
    ws.upgradeReq.headers.cookie string

    cookies = new Cookies(ws.upgradeReq, null);
    cookies.get('key')

### cookie/session
http 有session或者cookie，但是，在响应WebSocket请求时，如何识别用户身份？

在koa中，可以使用middleware解析Cookie，把用户绑定到ctx.state.user上。

    app.use(async (ctx, next) => {
        ctx.state.user = parseUser(ctx.cookies.get('name') || '');
        await next();
    });

WS请求也是标准的HTTP请求，所以，服务器也会把Cookie发送过来，这样，我们在用WebSocketServer处理WS请求时，就可以根据Cookie识别用户身份。

    wss.on('connection', function (ws, upgradeReq) {
        // ws.upgradeReq是一个request对象:
        ws.upgradeReq = upgradeReq
        let user = parseUser(ws.upgradeReq);
        if (!user) {
            // Cookie不存在或无效，直接关闭WebSocket:
            ws.close(4001, 'Invalid user');
        }
        // 识别成功，把user绑定到该WebSocket对象:
        ws.user = user;
        // 绑定WebSocketServer对象:
        ws.wss = wss;
    });

    //先把识别用户身份的逻辑提取为一个单独的函数：
    function parseUser(obj) {
        if (!obj) {
            return;
        }
        console.log('try parse: ' + obj);
        let s = '';
        if (obj.headers) {
            let cookies = new Cookies(obj, null);
            s = cookies.get('name');
        }
        if (s) {
            try {
                let user = JSON.parse(Buffer.from(s, 'base64').toString());
                console.log(`User: ${user.name}, ID: ${user.id}`);
                return user;
            } catch (e) {
                // ignore
            }
        }
    }


## client 请求
    ws.onopen
    ws.onclose
    ws.onmessage
    ws.onerror
    ws.send()
    ws.close()

    // 打开一个WebSocket:
    var ws = new WebSocket('ws://localhost:3000/test/ahuigo');

    // 打开WebSocket连接后立刻发送一条消息:
    ws.on('open', function () {
        console.log(`[CLIENT] open()`);
        ws.send('Hello!');
    });

    // 响应onmessage事件:
    ws.onmessage = function(msg) { console.log(msg); };

    // 给服务器发送一个字符串:
    ws.send('Hello!');
    ws.close()

## 同源策略
1. WebSocket协议本身不要求同源策略（Same-origin Policy）。
2. 但是`ws://b.com`连接基于http，浏览器会发送Origin的HTTP头(`同源Cookie`)给服务器，服务器可以根据Origin拒绝这个WebSocket请求(手动拒绝)。

根据同源策略，cookie是区分端口的，但是浏览器实现来说，“cookie区分域，而不区分端口，也就是说，同一个ip下的多个端口下的cookie是共享的！“

## 路由
客户端打开ws://localhost:3000/any/path可以写任意的路径。

    //client
    var ws = new WebSocket('ws://localhost:3000/test/ahuigo?ahui=1');
    //server
    wss.on('connection', function (ws, upgradeReq) {
        console.log(upgradeReq['url']);

# ws+koa
                        |----N-->Koa
    HTTP-->http.server->|is ws?
                        |----Y-->websocket

ws/koa 可以用同一个端口, 比如3000。
1. 3000端口并非由koa监听，而是koa调用Node标准的http模块创建的http.Server监听的。
2. koa只是把响应函数注册到该http.Server中了。
3. 类似，WebSocketServer也可以把自己的响应函数注册到http.Server中

把WebSocketServer绑定到同一个端口的关键代码是先获取koa创建的http.Server的引用，再根据http.Server创建WebSocketServer：

    // koa app的listen()方法返回http.Server:
    const Koa = require('koa')
    const app = new Koa();
    let server = app.listen(3000);

    // 创建WebSocketServer:
    const WebSocketServer = require('ws').Server;
    let wss = new WebSocketServer({
        server: server, //koa
    });

WebSocketServer会首先判断请求是不是WS请求，如果是，它将处理该请求，如果不是，该请求仍由koa处理

## nginx 反向代理

    # 处理WebSocketServer连接: 第一次http
    location ^~ /ws/ {
        proxy_pass         http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection "upgrade";
    }

    # 其他所有请求:
    location / {
        proxy_pass       http://127.0.0.1:3000;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

## wss.broadcast 封装
除了为 WebSocket 绑定ws.onmessage、ws.onclose、ws.onerror等事件处理函数。

对于聊天应用来说，每收到一条消息，就需要把该消息广播到所有ws 连接上

    wss.broadcast = function (data) {
        wss.clients.forEach(function (client) {
            client.send(data);
        });
    };

    // 收到消息后广播
    ws.on('message', function (message) {
        console.log(message);
        if (message && message.trim()) {
            let msg = createMessage('chat', this.user, message.trim());
            this.wss.broadcast(msg);
        }
    });

    // 消息ID:
    var messageIndex = 0;
    function createMessage(type, user, data) {
        messageIndex ++;
        return JSON.stringify({
            id: messageIndex,
            type: type,
            user: user,
            data: data
        });
    }