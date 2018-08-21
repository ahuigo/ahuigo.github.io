---
date: 2018-03-04
---
# JS AMD 模块规范
由于浏览器同步加载js 会阻塞，AMD 的出现时为了异步加载. (es6 将代替这一规范)

# RequireJs: AMD
以下js 加载是按顺序加载的，它有两个问题:

1. 依赖最大的js 必须放到最后
2. 加载是同步的，这会导致后面的代码因加载则阻塞；浏览器也会停止渲染

requireJS 解决了：
1. 异步加载
2. 解决模块依赖问题

## 原理
require(ids, factory(ids){})

1. loadScript+load
2. 每次load 都检查下是不是所有ids都加载成功(args.length)
3. 所有ids加载完毕, 就执行: factory(args)

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
	$ = require('jquery');// 此时是同步加载

## AMD 模块的加载
主模块的依赖模块是`['jquery', 'underscore', 'backbone']`, require 会默认加载的模块和main.js 都在同一目录`js/` 下。可以通过require.config() 设定加载模块的路径（paths）:

	require.config({
		paths: {
		　　"jquery": "lib/jquery.min",
		　　"underscore": "/other/js/underscore.min",
		　　"backbone": "http://hilo.com/js/backbone.min"
		}
	});

如果大部分的js 模块都在`js/lib` 下，则可以将基目录`baseUrl` 从main.js 的根目录改成其它的`baseUrl`:

	require.config({
		baseUrl: "js/lib",
		paths: {
		　　"jquery": "jquery.min",
		　　"underscore": "underscore.min",
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

js.onlad=callback

	define(['myLib'], function(myLib){
	　　function foo(){
	　　　　myLib.doSomething();
	　　}
	　　return {
	　　　　foo : foo
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
