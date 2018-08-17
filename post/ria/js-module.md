---
title:	ES6 Modudle 使用
date: 20180405
---
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
因为export default命令的本质是将后面的值，赋给default变量，所以它后面不能跟变量声明语句

    // 正确
    var a = 1;
    export default a;
    export default 42;

    // 错误
    export default var a = 1;

default 与其他变量混用

    import _, { each, each as forEach } from 'lodash';

## export *
    // lib/mathplusplus.js
    export * from "lib/math";
    export var e = 2.71828182846;
    export default function(x) {
        return Math.exp(x);
    }
    // app.js
    import exp, {pi, e} from "lib/mathplusplus";
    console.log("e^π = " + exp(pi));

## export 与 import 的复合写法 

    export { foo, bar } from 'my_module';

    // 可以简单理解为
    import { foo, bar } from 'my_module';
    export { foo, bar };

    export * from 'my_module';
    export { es6 as default } from './someModule';


# Node: commonJS
## Create module
hello module: hello.js

    //暴露变量
    module.exports = {
        hello: hello,
        greet: greet
    };
    exports.hello = hello;
    exports.greet = greet;

## 加载模块

    // 引入./hello.js模块,
    var s = 'Hello';
    var greet = require('./hello');
    greet('Michael'); // Hello, Michael!

如果没有`.`或者`绝对路劲`, Node会依次在内置模块、全局模块和当前模块下查找hello.js, 但是不会在当前目录查找

    var greet = require('hello');

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
