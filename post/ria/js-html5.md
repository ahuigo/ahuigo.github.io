---
layout: page
title:	html5
category: blog
description:
---
# Tag

## Forms
属性

	autocomplete(自动完成)
		autocomplete="off" //默认自动完成是on
	multiple(多选)
		<input type="file" name="img" multiple="multiple" />

## Input

	<input type="input" readonly name="creator" value="hilo">
	email:	<input type="email" name="xxx" />
	url:	<input type="url" name="xxx" />
	number:	<input type="number" name="points" min="1" max="10" />
	range: <input type="range" name="points" min="1" max="10" />
	date:
		month, week, time
		<input type="time" />

### placeholder

	placeholder="Input you password here"

### Datalist-Option

	Select-Option

	<select name="browser">
		<option value="firefox">Firefox</option>
		<option value="chrome">Chrome</option>
		<option value="opera">Opera</option>
		<option value="safari">Safari</option>
	</select>

Datalist-Option:
1. 需要id与list绑定
1. 用户可做任意修改数据

	<input type=text list=browsers>
	<datalist id=browsers>
		<option value="Firefox">
		<option value="Chrome">
		<option value="Opera">
		<option value="Safari">
	</datalist>

##　video

	node.play();
	node.pause();
	node.load();

	  <video id="video1" width="420" style="margin-top:15px;">
		<source src="/example/html5/mov_bbb.mp4" type="video/mp4" />
		<source src="/example/html5/mov_bbb.ogg" type="video/ogg" />
		Your browser does not support HTML5 video.
	  </video>

## radio

## drag
	<img draggable="true" />
### 拖动什么 - ondragstart 和 setData()
	ondragstart = function drag (ev){
		ev.dataTransfer.setData("Text",ev.target.id);
	}

### 目标区行为ondragover
	//否则目标区不会接受drop行为
	ondragover="allowDrop(event)"
	function allowDrop(ev) {
		ev.preventDefault();
	}
### 开始放置drop
	ondrop = function drop(ev){
		ev.preventDefault();
		var data=ev.dataTransfer.getData("Text");
		ev.target.appendChild(document.getElementById(data));
	}

## Canvas
Tutorial: [](http://www.html5canvastutorials.com/tutorials/html5-canvas-text-font-size/)

	<canvas id="my" width="200" height="100"></canvas>

	var c=document.getElementById("my");
	//context 对象
	var cxt=c.getContext("2d");
	//画矩形
	cxt.fillStyle="#FF0000";
	cxt.fillRect(0,0,150,75);
	//画线
	cxt.moveTo(10,10);//提笔移动
	cxt.lineTo(150,50);//执笔画线
	cxt.lineTo(10,50);
	cxt.stroke();//收笔

	//画圆
	cxt.fillStyle="#FF0000";
	cxt.beginPath();
	cxt.arc(70,18,15,0,Math.PI*2,true);
	cxt.closePath();
	cxt.fill();

	//渐变
	var grd=cxt.createLinearGradient(0,0,175,50);
	grd.addColorStop(0,"#FF0000");
	grd.addColorStop(1,"#00FF00");
	cxt.fillStyle=grd;
	cxt.fillRect(0,0,175,50);

	//画片
	var img=new Image()
	img.src="flower.png"
	cxt.drawImage(img,0,0);

### Text

	cxt.fillStyle = "blue";
	cxt.font = "bold 16px Arial";
	cxt.fillText("Zibri", 0, 20);//(0,20)是文字的左下角, 又好像是(0,21)

### clear

	cxt.clearRect(0,0,w,h);

## svg
SVG 意为可缩放矢量图形（Scalable Vector Graphics）

	Canvas
	依赖分辨率
	不支持事件处理器
	弱的文本渲染能力
	能够以 .png 或 .jpg 格式保存结果图像
	最适合图像密集型的游戏，其中的许多对象会被频繁重绘
	SVG
	不依赖分辨率
	支持事件处理器
	最适合带有大型渲染区域的应用程序（比如谷歌地图）
	复杂度高会减慢渲染速度（任何过度使用 DOM 的应用都不快）
	不适合游戏应用

# Location(navigator.geolocation)
	navigator.geolocation.getCurrentPosition(showPos, showErr);
	funciton showPos(pos){
		x = pos.corrds.latitude;
		y = pos.corrds.longtitude;
	}
	function showErr(err){
		switch(err.code){
			case err.PERMISSION_DENIED: break;
			case err.POSITION_UNAVAILABLE: break;
			case err.TIMEOUT: break;
			case err.UNKNOWN_ERROR: break;
		}
	}

其它方法:

	watchPosition() - 返回用户的当前位置，并继续返回用户移动时的更新位置（就像汽车上的 GPS）。
	clearWatch() - 停止 watchPosition() 方法

# web存储
	localStorage.name
	sessionStorage.name

# Web Workers
web worker 是运行在后台的 JavaScript，不会影响页面的性能。

##创建web worker文件

		var i=0;
		function count(){
			i++;
			postMessage(i);
			setTimeout("count()",500);
		}
		count();

## 引入worker

		w = new Worker('worker.js');
		w.onmessage = function(ev){
			console.log(ev.data);
		}
		w.terminate();

>由于 web worker 位于外部文件中，它们无法访问下例 JavaScript 对象：
`window/document/parent`.

# server-sent event 服务器发送事件
Server-Sent 事件指的是网页自动获取来自服务器的更新。
以前也可能做到这一点，前提是网页不得不询问是否有可用的更新。通过服务器发送事件，更新能够自动到达。

SSEs 使用的还是http 协议，不过它封装了：setInterval(retry)+ ajax + event, 它是单向通道(unidirectional channel),

由服务端决定何时响应event+data: 通过retry 指定重试时间(默认3秒)，或者服务器端可以用while(1) + sleep 做连接保持

- Polling: ajax. It's shortcoming is create greater http overhead.
- Long polling (Hanging GET / COMET): 长连接和 iframe 流方式(利用其src属性在服务器和客户端之间建立一条长链接，服务器向iframe传输数据). 将来会被WebSocket 取代

When communicating using SSEs, a server can push data to your app whenever it wants(via retry), without the need to make an initial request. In other words, updates can be streamed from server to client as they happen.

SSEs open a single *unidirectional channel* between server and client.(因为http1.1是单工的sigplex)

## 服务器端a.php

	header('Content-Type: text/event-stream');//务器端事件流 "Content-Type" 报头设置为 "text/event-stream" 服务器端控制轮询间隔
	header('Cache-Control: no-cache');

	$time = date('r');
	echo "data: The server time is: {$time}\n\n";
	flush();

### Data
Multiline Data

	: this is a comment
	data: first line\n
	data: second line\n\n

JSON Data:

	data: {\n
	data: "msg": "hello world",\n
	data: "id": 12345\n
	data: }\n\n

or:

	data: {"msg": "hello world","id": 12345 }\n\n

Associating an ID with an envent:

	id: 12345\n
	data: GOOG\n
	data: 556\n\n

Controlling the Reconnection-timeout in 10 seconds

	retry: 10000\n
	data: hello world\n\n

Specifying an event name

	data: {"msg": "First message"}\n\n
	event: userlogon\n
	data: {"username": "John123"}\n\n
	event: update\n
	data: {"username": "John123", "emotion": "happy"}\n\n

Refer to: http://www.html5rocks.com/en/tutorials/eventsource/basics/

## Client端

	source = new EventSource('/b.php');
	source.onmessage = function(ev){console.log(ev.data);}
	//source.onerror
	//source.onopen
	//source.close();

	source.addEventListener('message', function(e) {
	  console.log(e.data);
	}, false);

	source.addEventListener('open', function(e) {
	  console.log('open');// Connection was opened.
	}, false);

	source.addEventListener('error', function(e) {
	  if (e.readyState == EventSource.CLOSED) {
		// Connection was closed.
	  }
	}, false);

## Security
SSEs 是可以跨域的，server 端应该判断响应的Origin:

	source.addEventListener('message', function(e) {
	  if (e.origin != 'http://example.com') {
		alert('Origin was not http://example.com');
		return;
	  }
	  ...
	}, false);

# WebSocket
HTML5 的WebSocket 真正的实现了双向全双工(bi-directional, full-duplex)通信，它是基于tcp 的socket 套接字. 它所使用的是WebSocket protocol.

WebSockets are a bi-directional, full-duplex, persistent connection from a web browser to a server. Once a WebSocket connection is established the connection stays open until the client or server decides to close this connection. With this open connection, the client or server can send a message at any given time to the other. This makes web programming entirely event driven, not (just) user initiated. It is stateful. As well, at this time, a single running server application is aware of all connections, allowing you to communicate with any number of open connections at any given time.


## Use WebSocket
1. run WebSocket server
2. Once the server is running, your client can connect to it to push messages. The client establishes a WebSocket connection through a process known as the WebSocket handshake.
This process starts with the client sending a regular HTTP request to the server.

An Upgrade header is included in this request that informs the server that the client wishes to establish a WebSocket connection.

	GET /chat HTTP/1.1
	Host: server.example.com
	Upgrade: websocket
	Connection: Upgrade
	Sec-WebSocket-Key: x3JJHMbDL1EzLkh9GBhXDw==
	Sec-WebSocket-Protocol: chat, superchat
	Sec-WebSocket-Version: 13
	Origin: http://example.com

可以通过origin 判断 合法的请求, Response:

	HTTP/1.1 101 Switching Protocols
	Upgrade: websocket
	Connection: Upgrade
	Sec-WebSocket-Accept: HSmrc0sMlYUkAGmm5OPpG2HaGWk=
	Sec-WebSocket-Protocol: chat

Refer to:
http://www.phpbuilder.com/articles/application-architecture/optimization/creating-real-time-applications-with-php-and-websockets.html

## WebSocket Demo
websocket demo for php:

https://github.com/ahui132/php-websockets

## WebSocket Server Library
服务端Php/Python/Ruby 等有丰富的WebSocket 库：
	http://nginx.com/blog/realtime-applications-nginx/

# copy & paste

## copy

### copy text
JavaScript copy to clipboard isn't available because of security which also mean that jQuery isn't able to copy the text to clipboard. You can do it with flash.
Or:

	window.prompt("Copy to clipboard: Ctrl+C, Enter", text);

# history

## pushstate
不刷新页面ajax
http://www.cnblogs.com/xuchengzone/archive/2013/04/18/html5-history-pushstate.html
- help.gitbook.io

Example:

	var stateObj = { foo: "bar" };
	history.pushState(stateObj, title="page 2", "bar2.html");
	//title 可能不生效

## event

	window.onpopstate = function(event) {
		alert("location: " + document.location + ", state: " + JSON.stringify(event.state));
	};

# New

## mvc
AngularJS, Ember.js,
backbone + requireJS + bootstrap3
	amd:
		https://github.com/yanhaijing/lodjs

Worktile http://segmentfault.com/q/1010000000615220
不使用框架？
http://segmentfault.com/blog/bum/1190000002455654

backbong note
http://segmentfault.com/a/1190000002386651

### 前后端分离
http://ued.taobao.org/blog/2014/04/full-stack-development-with-nodejs/

### Qmik
Replace for zepto.js

## nodejs
用generator 免回调地狱
http://huangj.in/765
http://www.jianshu.com/p/a0379bef5913


## TypeScript
JS短板在于缺乏静态类型，做大型工程的时候无法通过编译期静态类型检查来保证质量，这一点用TypeScript就可以了。
TypeScript是JavaScript的一个超集(superset)，并且提供了额外的功能。但是在编译的时候，它又会变回普通的JavaScript。它正在和 google 的Angular2 合作

## coffeeScript
[coffeeScript intro] 是js 的转译语言，受到了Ruby，python 的启发，增加了js 的简洁性

可参考:
- https://ruby-china.org/topics/4789
- [coffeeScript intro] IBM


## nativescript
http://docs.nativescript.org/getting-started
NativeScript，可以用现有的 JavaScript 和 CSS 技术来编写 iOS、Android 和 Windows Phone 原生移动应用程序。由原生平台的呈现引擎呈现界面而不是 WebView，正因为如此，应用程序的整个使用体验都是原生的。

### cross-mobile
http://fex.baidu.com/blog/2015/05/cross-mobile/

### react-native
http://facebook.github.io/react-native/
http://www.zhihu.com/question/27852694

## SEO
如果web前端使用了argular 这样的mvc 框架，爬虫是不能直接获取到有效内容的。这就需要针对爬虫在后端做[prerender](https://github.com/prerender/prerender):

1. 针对含锚点(#)的ajax页面，可以将锚点符号"#"改成"#!", google 爬虫(Googlebot)会把"#!" 转换成"[?&]_escaped_fragment_=", 后端根据这个标识做prerender
2. 其实可以利用history.pushState 实现无锚点的ajax页面, 前端不需要使用"#!", 后端直接根据各搜索引擎的bot(spider)做prerender. 通过history.pushState ,前端可以自己根据url 做路由.

第一种方法缺点太大: 必須修改url, 而且只适用于googlebot. 第二种方法是只适用于IE(>=10), chrome(>=18),Safari(>=6)..

1. 如果是博客这样的应用，如果后端放的是markdown文件，也没有必要用prerender, 直接针对爬虫返回 markdown文件也行

[coffeeScript intro]: http://www.ibm.com/developerworks/cn/web/wa-coffee1/
