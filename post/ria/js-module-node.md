---
date: 2018-08-18
title: Node import/export 支持
---
# Node import/export 支持
Node10 已经支持es6 的import/export, 


    echo 'export default "ahuigo"; ' > name.js
    cat <<-'MM' > hello.js
        import name from './name.js'
        console.log(`Hello, ${name}!`)
    MM

    node  --experimental-modules --loader ~/loader.mjs hello.js

其中 loader.mjs 内容参考: https://github.com/ChenShenhai/blog/issues/24

    import url from 'url';
    import path from 'path';
    import process from 'process';
    import fs from 'fs';
    const baseURL = new URL('file://');


    // 从package.json中
    // 的dependencies、devDependencies获取项目所需npm模块信息
    const ROOT_PATH = process.cwd();
    const PKG_JSON_PATH = path.join( ROOT_PATH, 'package.json' );
    const PKG_JSON_STR = fs.readFileSync(PKG_JSON_PATH, 'binary');
    const PKG_JSON = JSON.parse(PKG_JSON_STR);
    // 项目所需npm模块信息
    const allDependencies = {
      ...PKG_JSON.dependencies || {},
      ...PKG_JSON.devDependencies || {}
    }

    //Node原生模信息
    const builtins = new Set(
      Object.keys(process.binding('natives')).filter((str) =>
        /^(?!(?:internal|node|v8)\/)/.test(str))
    );

    // 文件引用兼容后缀名
    const JS_EXTENSIONS = new Set(['.js', '.mjs']);
    const JSON_EXTENSIONS = new Set(['.json']);


    export function resolve(specifier, parentModuleURL=baseURL, defaultResolve) {
      // 判断是否为Node原生模块
      if (builtins.has(specifier)) {
        return {
          url: specifier,
          format: 'builtin'
        };
      }

      // 判断是否为npm模块
      if ( allDependencies && typeof allDependencies[specifier] === 'string' ) {
        return defaultResolve(specifier, parentModuleURL);
      }

      // 如果是文件引用，判断是否路径格式正确
      if (/^\.{0,2}[/]/.test(specifier) !== true && !specifier.startsWith('file:')) { 
        throw new Error(
          `imports must begin with '/', './', or '../'; '${specifier}' does not`);
      }

      // 判断是否为*.js、*.mjs、*.json文件
      const resolved = new url.URL(specifier, parentModuleURL);
      const ext = path.extname(resolved.pathname);
      if (!JS_EXTENSIONS.has(ext) && !JSON_EXTENSIONS.has(ext)) {
        throw new Error(
          `Cannot load file with non-JavaScript file extension ${ext}.`);
      }

      // 如果是*.js、*.mjs文件
      if (JS_EXTENSIONS.has(ext)) {
        return {
          url: resolved.href,
          format: 'esm'
        };
      }
      
      // 如果是*.json文件
      if (JSON_EXTENSIONS.has(ext)) {
        return {
          url: resolved.href,
          format: 'json'
        };
      }

    }

# require 补全
require ('../../../controller.js') 写法:
1. 相对路径
2. 支持：IDE 路径补全 进而 代码补全

## NODE_PATH 支持项目目录
我们常常希望将app 根目录放到: NODE_PATH

    npm root -g 
    export NODE_PATH='dir1:dir2'; # 默认为空

PWD 固定：

    $ export NODE_PATH=$PWD && node main/index.js

PWD不固定:

    // app.js
    process.env.NODE_PATH = require('path').resolve(__dirname, '../') ;
    require('module').Module._initPaths();

    let utils = require('utils/utils'); // app/utils/utils.js

## 绝对路径补全
根目录 `jsconfig.json`(不是.js!)

    {
        "compilerOptions": {
            "target": "es6",
            "module": "commonjs",
            "baseUrl": "./", //IDE vscode 路径/代码补全
        },
        "exclude": [
            "node_modules"
        ]
    }

## Reference
1. https://juejin.im/post/5add67986fb9a07ab83da106 by bestswifter 

# Node: CommonJS
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