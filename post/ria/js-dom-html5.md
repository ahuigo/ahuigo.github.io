---
layout: page
title:	html5
category: blog
description:
---
# Tag

## Forms
属性

    enctype="multipart/form-data"
        default content-type: application/x-www-form-urlencoded
	autocomplete(自动完成)
		autocomplete="off" //默认自动完成是on
    onsubmit="return callback()" //return: true/false
    onsubmit="callback()" //不行！return 才能break

## button
button will auto submit by default  `type="submit"`, change it to:

    <button type="button">My Button</button>

## Input
没有name，form 不会提交

	<input type="input" readonly name="creator" value="hilo">
	email:	<input type="email" name="xxx" />
	url:	<input type="url" name="xxx" />
	number:	<input type="number" name="points" min="1" max="10" />
	range: <input type="range" name="points" min="1" max="10" />
	date:
		date, time, datetime-local, 
        month, week
        <input type="datetime-local" value="2010-12-11T10:00:00">
        <input type="date" value="2015-07-01">
    color:
    image:

multiple(多选)

    <input type="file" name="img" multiple="multiple" />

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

## detail

    this.open = false/true
    <details open>
        <summary>Header</summary>
    </details>

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
https://www.liaoxuefeng.com/wiki/001434446689867b27157e896e74d51a89c25cc8b43bdb3000/00143449990549914b596ac1da54a228a6fa9643e88bc0c000#0

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
>双出了 navigator.serviceWorker.register('/sw-test.js');
> worker 里面是self 不是window: https://www.zhangxinxu.com/wordpress/2017/07/js-window-self/
https://www.zhangxinxu.com/wordpress/2017/07/service-worker-cachestorage-offline-develop/

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

##  Channel Messaging API 
 Channel Messaging API allows two separate scripts running in different browsing contexts attached to the same document (e.g., two IFrames, or the main document and an IFrame,


# copy & paste

## copy

### copy text
JavaScript copy to clipboard isn't available because of security which also mean that jQuery isn't able to copy the text to clipboard. You can do it with flash.
Or:

	window.prompt("Copy to clipboard: Ctrl+C, Enter", text);


# Data

    <tag data-key="abc">

## dataset
html5 的dataset 对象

　　element.dataset.key = string_only;

jquery:

    $(element).data('key', 'value');
    element.dataset.key // undefined

    $(element).attr('data-key', 'value');

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
