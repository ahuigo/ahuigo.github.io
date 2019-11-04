---
layout: page
title: js-react
category: blog
description: 
date: 2018-10-04
---
# code demo
github.com/ahuigo/webpack-react-tutorial

# component vs createClass
component 是es6 语法
https://segmentfault.com/a/1190000005863630#articleHeader0

# start
包含了webpack

    npx create-react-app my-app

https://codepen.io/gaearon/pen/aWWQOG?editors=0010

# .env
react 的环境变量

    $ cat .env
    NODE_PATH=src
    REACT_APP_MODE=dev


# React Build
Refer: https://zh-hans.reactjs.org/docs/optimizing-performance.html
## Create React App
如果你的代码 是Create React App 生成的

    # react-scripts build
    npm run build ; # 生成生产环境代码 build/ 
        $ yarn global add serve; serve -s build

    # react-scripts start
    npm start; # 执行开发模式

## 单文件构建
阮一峰的demo 中的例子: React + ReactDom + babel

    <head>
        <meta charset="UTF-8" />
        <script src="../build/react.development.js"></script>
        <script src="../build/react-dom.development.js"></script>
        <script src="../build/babel.min.js"></script>
    </head>
    <body>
        <div id="example"></div>
        <script type="text/babel">
        ReactDOM.render(
            <h1>Hello, world!</h1>,
            document.getElementById('example')
        );
        </script>
    </body>

## Rollup 构建
为了最高效的 Rollup 生产构建，需要安装一些插件：

    # 如果你使用 npm
    npm install --save-dev rollup-plugin-commonjs rollup-plugin-replace rollup-plugin-terser

    # 如果你使用 Yarn
    yarn add --dev rollup-plugin-commonjs rollup-plugin-replace rollup-plugin-terser

为了创建生产构建，确保你添加了以下插件 （顺序很重要）：
1. replace 插件确保环境被正确设置。
1. commonjs 插件用于支持 CommonJS。
1. terser 插件用于压缩并生成最终的产物。

配置

    plugins: [
        // ...
        require('rollup-plugin-replace')({
            'process.env.NODE_ENV': JSON.stringify('production')
        }),
        require('rollup-plugin-commonjs')(),
        require('rollup-plugin-terser')(),
        // ...
    ]

请注意，你只需要在生产构建时用到它。你不需要在开发中使用 terser 插件或者 replace 插件替换 'production' 变量，因为这会隐藏有用的 React 警告信息并使得构建速度变慢。

## Webpack 构建
https://juejin.im/post/5aa26c106fb9a028d936c357

    create-react-app my-app
    npm run eject 

在生产模式下，Webpack v4+ 将默认对代码进行压缩：

    const TerserPlugin = require('terser-webpack-plugin');

    module.exports = {
      mode: 'production'
      optimization: {
        minimizer: [new TerserPlugin({ /* additional options here */ })],
      },
    };

## babel 与jsx
babel 使用`react-app/prod` 编译jsx

    npm i babel
    npx babel --watch src --out-dir . --presets react-app/prod 