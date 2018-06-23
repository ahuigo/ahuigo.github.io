---
layout: page
title:	ria module
category: blog
description:
---
# Perface
## 防止变量污染
1. 'use strict';//es6 默认
2. var v=1; //适用于 commandJS 

    //commandjs
    (function(exports, require, module, __filename, __dirname) {
        var v=1;
    })();

## path + global

    //app.js
    ROOT_DIR=__dirname;
    global.ROOT_DIR=__dirname; //不要用 const ROOT_DIR=xxx

    // module.js
    let users = require(ROOT_DIR+'/conf/users')
    let users = require(global.ROOT_DIR+'/conf/users')
    let users = require('../conf/users')

## module storage

    //a.js
    require('./config')['name']='ahui'
    //b.js
    require('./config')['name']==='ahui'

## module this
module `this` is `{}`, not `global===window`

# 模块的定义(对象定义)
本文参考阮一峰的: [js 模块化](http://www.ruanyifeng.com/blog/2012/10/javascript_module.html)

## 直接定义对象

	obj = {count:1, incr:function(){return ++this.count;}};
	obj.incr();

但是以上两种定义方法的成员变量会受到污染，比如`mod.count` 是暴露的.

## 放大模式
如果一个模块很大，必须分成几个部分，或者一个模块需要继承另一个模块，这时就有必要采用"放大模式"（augmentation）。
用匿名函数放大一个module

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

## 模块规范
js 的模块规范有两种： CommonJs 和 AMD js

### CommonJS 规范
node.js的模块系统，就是参照CommonJS规范实现的。在CommonJS中，有一个全局性方法require()，用于加载模块。假定有一个数学模块math.js，就可以像下面这样加载。

	var math = require('math');
	math.add(5,6)

在node 服务器端，这样引入模块没有问题。
但是在浏览器环境下，require 可能花很长时间(直到onload)，这段时间内浏览器会处于假死状态。

所以在浏览器端，不能使用同步加载(Synchronous), 只能使用“异步加载”(Asynchronous), 这就是AMD 规范.

### AMD(Asynchronous Module Definition)
AMD 规范采用异步加载模块，加载不影响后面的语句运行。AMD 也使用require 加载模块，但是它不同于CommonJS, 它需要两个参数：

	require([module], callback);

Example:

	require(['math'], function(math){
		math.add(2,3);//异步
	});

主要有两个Javascript库实现了AMD规范：require.js和curl.js。

# Es6 module
- export 定义值
- import 引入

## export
profile.js

    // 写法一
    export var m = 1;

    // 写法二
    var m = 1;
    export {m};

    // 写法三
    var n = 1;
    export {n as m};

变量foo，值为bar，500 毫秒之后变成baz。

    export var foo = 'bar';
    setTimeout(() => foo = 'baz', 500);

这一点与 CommonJS 规范完全不同。CommonJS 模块输出的是值的缓存，不存在动态更新

## import 
1. import vs node require: https://cnodejs.org/topic/5a0f2da5f9de6bb0542f090b
2. 默认只能是`*.mjs`，通过Loader Hooks可以自定义配置规则支持`*.js,*.json`等Node原有支持文件
    1. node --experimental-modules ./index.mjs

    // ES6模块
    import 'fs';
    import {stat} from 'fs';
    import { stat as st, exists, readFile } from 'fs';

    import A from './a?v=2017'
        ./a.js
        a.js
        a

profile.js

    export var foo = 'bar';
    export var area = 'China';

main.js(babel)

    import {foo} from './profile.js';
    import {foo} from './profile';
    import * from './profile';
    import * from 'profile';
    import * as profile from './profile';

注意，`export *` 命令会忽略模块的default方法

## export default 命令
export default命令用于指定模块的默认输出。
1. 因此export default命令只能使用一次。
2. import命令后面才不用加大括号，因为只可能唯一对应export default命令。

    // profile.js
    export default function () {
        console.log('foo');
    }

    //main.js
    import say from './profile';
    say()

因为export default命令的本质是将后面的值，赋给default变量，所以它后面不能跟变量声明语句

    // 正确
    var a = 1;
    export default a;
    export default 42;

    // 错误
    export default var a = 1;

default 与其他变量混用

    import _, { each, each as forEach } from 'lodash';

## export 与 import 的复合写法 

    export { foo, bar } from 'my_module';

    // 可以简单理解为
    import { foo, bar } from 'my_module';
    export { foo, bar };

    export * from 'my_module';
    export { es6 as default } from './someModule';


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

# Node: CMD
## Create module
hello module: hello.js

    function greet(name) {
        console.log(s + ', ' + name + '!');
    }

    //暴露变量
    module.exports = greet;

## 加载模块

    // 引入./hello.js模块,
    var s = 'Hello';
    var greet = require('./hello');
    greet('Michael'); // Hello, Michael!

如果没有`.`或者`绝对路劲`, Node会依次在内置模块、全局模块和当前模块下查找hello.js, 但是不会在当前目录查找

    var greet = require('hello');

### 模块全局变量污染
全局变量在模块间是共享的！

    var s= 'hello'

### module.exports怎么实现？
这个也很容易实现，Node可以先准备一个对象module：

    // 准备module对象:
    var module = {
        id: 'hello',
        exports: {}
    };

    var load = function (exports, module) {
        // 读取的hello.js代码:
        function greet(name) {
            console.log('Hello, ' + name + '!');
        }

        module.exports = greet;
        // hello.js代码结束
        return module.exports;
    };
    // 保存module:
    exported = load(module.exports, module);
    // 保存module:
    save(module, exported);


多个变量暴露可以用`exports.var=xxx`:
1. 但是不可以直接覆盖exports, 导致module.exports不会指向exports
2. 直接对module.exports对象赋值, 适合返回所有类型: func/obj/arr

    module.exports = {
        hello: hello,
        greet: greet
    };
    exports.hello = hello;
    exports.greet = greet;




# Package, 打包
http://www.ruanyifeng.com/blog/2014/09/package-management.html

- Bower - 不打包，只是install/update..: 
    　　# 模块的名称
    　　$ bower install jquery
    　　# github用户名/项目名
    　　$ bower install jquery/jquery
- Browserify - 将多个require('js') 合并
    - browserify robot.js > bundle.js
- dao: package both js/css
- Gulp: 一个新的基于流的`管道式构建工具`，用于代替过时的Grunt。 类似于java 的Maven
    - http://javascript.ruanyifeng.com/tool/gulp.html
    - https://segmentfault.com/a/1190000002491282

- webpack: 静态模块打包器(module bundler): js/css/png/font/..., 整合了gulp的优
- parcel: 比webpack 更快先进
- rollup: es2015 Rollup 是下一代的 javascript 打包器，它使用 tree-shaking 的技术使打包的结果只包括实际用到的 exports。 使用它打包的代码，基本没有冗余的代码，减少了很多的代码体积

## dao
将js/css 合并

    $ cat index.css
    @import 'necolas/normalize.css';
    @import './layout/layout.css';
　　
　　 body {
　　  color: teal;
　　  background: url('./background-image.jpg');
　　 }
    
    $ duo index.css > build.css