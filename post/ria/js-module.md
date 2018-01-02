---
layout: page
title:	ria module
category: blog
description:
---
# Preface
本文参考阮一峰的: [js 模块化](http://www.ruanyifeng.com/blog/2012/10/javascript_module.html)


## 定义一个类

### 用动态的构造加原型定义类

# 模块的定义(对象定义)

## 直接定义对象

	obj = {count:1, incr:function(){return ++this.count;}};
	obj.incr();

但是以上两种定义方法的成员变量会受到污染，比如`mod.count` 是暴露的.

## 使用匿名函数生成对象的局部变量：
通过定义一个匿名函数，创建一个"私有"的命名空间

	module = (function(){
		var count=1;//局部变量与函数
		var incr = function(){
			return ++count;
		}
		return {incr:incr};
	})();
	module.count=100;//和内部count 不同
	module.incr();
	module.incr();

简化下对象封装`mod.*` 写法：

	var count = 200;
	module = (mod = function(){
		var count=1;
		mod.incr = function(){
			return ++count;
		}
		return mod;
	})();
	module.count=100;
	module.incr();
	module.incr();

## 放大模式
如果一个模块很大，必须分成几个部分，或者一个模块需要继承另一个模块，这时就有必要采用"放大模式"（augmentation）。

	var module = (function (mod){
		var count = 1;
		mod.incr = function () {
			return count++;
		};
		return mod;
	})(window.module || {});//之所以加{}，是因为window.module 可能因为module.js 延迟加载，而没有值. 这叫宽松加载
	module.count=100;
	module.incr();

也可以用局部静态变量

# 模块规范
js 的模块规范有两种： CommonJs 和 AMD js

## CommonJS 规范
美国Ryan Dahl 程序员所创造的NodeJs 项目标志着 “JS 模块编程”的诞生

node.js的模块系统，就是参照CommonJS规范实现的。在CommonJS中，有一个全局性方法require()，用于加载模块。假定有一个数学模块math.js，就可以像下面这样加载。

	var math = require('math');
	math.add(5,6)

在node 服务器端，这样引入模块没有问题。
但是在浏览器环境下，require 可能花很长时间(直到onload)，这段时间内浏览器会处于假死状态。

所以在浏览器端，不能使用同步加载(Synchronous), 只能使用“异步加载”(Asynchronous), 这就是AMD 规范.

## AMD(Asynchronous Module Definition)
AMD 规范采用异步加载模块，加载不影响后面的语句运行。AMD 也使用require 加载模块，但是它不同于CommonJS, 它需要两个参数：

	require([module], callback);

Example:

	require(['math'], function(math){
		math.add(2,3);//异步
	});

主要有两个Javascript库实现了AMD规范：require.js和curl.js。

# RequireJs

以下js 加载是按顺序加载的，它有两个问题:

1. 依赖最大的js 必须放到最后
2. 加载是同步的，这会导致后面的代码因加载则阻塞；浏览器也会停止渲染

	<script src="1.js"></script>
	<script src="2.js"></script>
	<script src="3.js"></script>
	<script src="4.js"></script>

requireJS 解决了：

1. 异步加载
2. 解决模块依赖问题

## 引入requireJs
加载RequireJs 本身也会导致浏览器停止渲染。解决的办法是将其放在浏览器底部。或者写成这样：

	<script src="js/require.js" defer async="true" ></script>

async属性表明这个文件需要异步加载，避免网页失去响应。IE不支持这个属性，只支持defer，所以把defer也写上。

加载require.js以后，下一步就要加载我们自己的代码了。假定我们加载js目录下面的 main.js。那么，只需要写成下面这样就行了：

	<script src="js/require.js" data-main="js/main"></script>

data-main属性的作用是，指定网页程序的主模块, 比如本例的: main.js

## 主模块的写法
主模块就像是c 语法的main() 入口。主模块引入其它模块的写法为：

	// main.js
	require(['moduleA', 'moduleB', 'moduleC'], function (moduleA, moduleB, moduleC){
	　　// some code here
	});

Require 会异步加载指定的模块，当所有的模块都加载完毕后就触发回调函数. 另一个例子：

	require(['jquery', 'underscore', 'backbone'], function ($, _, Backbone){
		// some code here
	});
	require(['jquery']);//回调不是必须的, 此时是同步加载？
	$ = require('jquery');// 此时是同步加载

## AMD 模块的加载
主模块的依赖模块是`['jquery', 'underscore', 'backbone']`, require 会默认加载的模块和main.js 都在同一目录`js/` 下。可以通过require.config() 设定加载模块的路径（paths）:

	require.config({
		paths: {
		　　"jquery": "jquery.min",
		　　"underscore": "underscore.min",
		　　"backbone": "backbone.min"
		}
	});

如果jquery 在`/js/lib/` 下，underscore 在`/other/js/` 下, backbone 在`http://hilo.com/js/backbone.min.js`, 我们可以这样写

	require.config({
		paths: {
		　　"jquery": "lib/jquery.min",
		　　"underscore": "/other/js/underscore.min",
		　　"backbone": "http://hilo.com/js/backbone.min"
		}
	});

如果所有的js 模块都在`js/lib` 下，则可以将基目录`baseUrl` 从main.js 的根目录改成其它的`baseUrl`:

	require.config({
		baseUrl: "js/lib",
		paths: {
		　　"jquery": "lib/jquery.min",
		　　"underscore": "/other/js/underscore.min",
		　　"backbone": "http://hilo.com/js/backbone.min"
		}
	});

require.js要求，每个模块是一个单独的js文件. 太多的加载会影响浏览器的性能（http 网络消耗）。require 提供了一个[优化工具](http://requirejs.org/docs/optimization.html)，将多个模块合到一个js 文件中

## AMD 模块的写法
AMD 加载的模块，采用AMD 规范：即模块必须使用define() 函数来定义

	// math.js
	// require 不是必须的
	define(function (require){
		var add = function (x,y){
			return x+y;
		};
		return {add: add};
	});

如果模块还依赖其它的模块

	define(['myLib'], function(myLib){
	　　function foo(){
	　　　　myLib.doSomething();
	　　}
	　　return {
	　　　　foo : foo
	　　};
	});

或者

	define(['myLib'], function(myLib){
	　　return {
	　　　　foo : function(){
				myLib.doSomething();
			}
		};
	});

## 加载非规范的模块
有很多非规范的模块(不支持define), 比如underscore 和 backbone. 在加载这类模块之前，需要用require.config() 为这类模块定义一些它们的特征.

	require.config({
	　　shim: {
	　　　　'underscore':{
	　　　　　　exports: '_'
	　　　　},
	　　　　'backbone': {
	　　　　　　deps: ['underscore', 'jquery'],
	　　　　　　exports: 'Backbone'
	　　　　}
	　　}
	});

require.config() 包括一个shim 属性，这个属性专门用于配置非AMD 规范模块。这类模块要定义：

1. exports 输出的变量名(模块外部调用时的名称)
2. deps 数组，表明该模块的依赖性。

jQuery的插件可以这样定义:

	shim: {
	　　'jquery.scroll': {
	　　　　deps: ['jquery'],
	　　　　exports: 'jQuery.fn.scroll'
	　　}
	}

## require.js插件
比如 domready插件，可以让回调函数在整个DOM 加载完成后运行

	require(['domready!'], function (doc){
	　　// called once the DOM is ready
	});

text和image插件，则是允许require.js加载文本和图片文件。

	define([
	　　'text!review.txt',
	　　'image!cat.jpg'
	　　],
	　　function(review,cat){
	　　　　console.log(review);
	　　　　document.body.appendChild(cat);
	　　}
	);
