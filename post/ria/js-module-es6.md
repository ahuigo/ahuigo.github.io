---
title: ES6 Modudle 使用
date: 2018-04-05
---
# js load
## defer vs async

    <script src="async.js" async></script>
    <script src="async.js" defer></script>

1. defer: guarantees the order of execution in which they appear. (after html parsed done)
    1. defer: html 解析完成后, 顺序阻塞, 一定在 `DOMContentLoaded`/onload前, 
2. async: excute as soon as loaded(no order, 无序)
    2. async: 非阻塞异步，可能在 `DOMContentLoaded` 事件前后，但是一定在`window.onload 事件`之前

onready:  DomContentLoaded
onload: inlude dom+pic

# global variable
Module: don't use globals in my applications.

    // es5
    ROOT_DIR=__dirname;  // 不要用 const, var(es5)

    // es6
    (global||window).ROOT_DIR=__dirname;

    // module.js
    let users = require(ROOT_DIR+'/conf/users')
    let users = require(global.ROOT_DIR+'/conf/users')
    let users = require('../conf/users')

## module storage
ES6 recommend import global module:

    //a.js
    require('./config')['name']='ahui'
    //b.js
    require('./config')['name']==='ahui'

in webpack, use definePlugin to config new consants:

    /* Webpack configuration */
    const webpack = require('webpack');
    new webpack.DefinePlugin({
        'VALUE_1': 123,
        'VALUE_2': 'abc'
    });

    /* SomeComponent.js */
    if (VALUE_1 === 123) {
        // do something
    }

## module this
module `this` is `{}`, not `global===window`

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
    export {n};
    export {n as m};

变量foo，值为bar，500 毫秒之后变成baz。

    export var foo = 'bar';
    setTimeout(() => foo = 'baz', 500);

这一点与 CommonJS 规范完全不同。CommonJS 模块输出的是值的缓存，不存在动态更新

### export default 命令
因为export default命令的本质是将后面的值，赋给default变量，所以它后面不能跟变量声明语句

    // 正确
    var a = 1;
    export default a; //default = a
    export default 42; //default = 42
    export {a as default}

    // 错误
    export default var a = 1; // default = var a=1
    export default a = 1;      // default = a = 1 // a is not defined(strict)

default 与其他变量混用

    import AnyDefaultName, { each, each as forEach } from 'lodash';

### export *
    // lib/mathplusplus.js
    export * from "lib/math";
    export var e = 2.71828182846;
    export default function(x) {
        return Math.exp(x);
    }
    // app.js
    import exp, {pi, e} from "lib/mathplusplus";
    console.log("e^π = " + exp(pi));

## import 
1. import vs node require: https://cnodejs.org/topic/5a0f2da5f9de6bb0542f090b
2. 默认只能是`*.mjs`，通过Loader Hooks可以自定义配置规则支持`*.js,*.json`等Node原有支持文件
    1. node --experimental-modules ./index.mjs

es6 eg.

    // ES6模块
    import 'fs';
    import {stat} from 'fs';
    import { stat as st, exists, readFile } from 'fs';

    import A from './a?v=2017'
        ./a.js
        a.js
        a

profile.js

    export var foo = 'bar';     //export.foo = ...
    export var area = 'China';  //export.area = ...

main.js(babel)

    import {foo} from './profile.js';
    import {foo} from './profile';
    import * from './profile';
    import * from 'profile';
    import * as profile from './profile';

注意，`export *` 命令会忽略模块的default方法

## import index.js
`import ./module` 代表`module/index.js`:

    import {Foo} from './module'

## export 与 import 的复合写法 

    export { foo, bar } from 'my_module';

    // 可以简单理解为
    import { foo, bar } from 'my_module';
    export { foo, bar };

    export * from 'my_module';
    export { es6 as default } from './someModule';

# Package, 打包
http://www.ruanyifeng.com/blog/2014/09/package-management.html

old:
- Bower - 不打包，只是install/update..: YeoMan和Grunt 建立在Bower基础之上
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

new:
- webpack: 静态模块打包器(module bundler): js/css/png/font/..., 整合了gulp的优
- parcel: 比较webpack 属于0配置，专注也web，不能用于打包npm
- rollup: Facebook出品的es2015 Rollup 是下一代的 javascript 打包器，它使用 tree-shaking 的技术使打包的结果只包括实际用到的 exports。 使用它打包的代码，基本没有冗余的代码，减少了很多的代码体积
    1. https://w3ctech.com/topic/1996
    2. http://www.rollupjs.com

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
