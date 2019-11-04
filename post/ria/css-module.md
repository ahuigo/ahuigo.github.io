---
title: css module
date: 2019-11-02
private: 
---
# css module
> http://www.ruanyifeng.com/blog/2016/06/css_modules.html
> https://github.com/ruanyf/css-modules-demos.git (fetch)

## react with css module

    /* Thumbnail.css */
    .image {
        border-radius: 3px;
    }
    #menu .image {
        border-radius: 3px;
    }

    /* Thumbnail.jsx */
    import styles from './Thumbnail.css';
    console.debug(styles)
    render() { return (<img id={styles.menu} className={styles.image}/>) }

## webpack
react 内置webpack 支持了css module. create-react-app 默认需要`App.module.css`

如果想css 默认解析用css, 并且用hash 作为编译的类名，配置：

     //webpack.config.js file:
    {
        test: /\.css$/,
        loader: 'style!css-loader?modules&importLoaders=1&localIdentName=[name]__[local]___[hash:base64:5]' 
        loader: "style-loader!css-loader?modules&localIdentName=[path][name]---[local]---[hash:base64:5]"
    }

完整的webpack.config.js 示例。

    module.exports = {
      entry: __dirname + '/index.js',
      output: {
        publicPath: '/',
        filename: './bundle.js'
      },
      module: {
        loaders: [
          {
            test: /\.jsx?$/,
            exclude: /node_modules/,
            loader: 'babel',
            query: {
              presets: ['es2015', 'stage-0', 'react']
            }
          },
          {
            test: /\.css$/,
            loader: "style-loader!css-loader?modules"
          },
        ]
      }
    };

上面代码中，关键的一行是style-loader!css-loader?modules，它在css-loader后面加了一个查询参数modules，表示打开 CSS Modules 功能。

## 全局作用域
CSS Modules 允许使用:global(.className)的语法，声明一个全局规则。凡是这样声明的class，都不会被编译成哈希字符串。

    .title {
        color: red;
    }

    :global(.title) {
        color: green;
    }

subclass 正确用法是 global

    //error
    .menu a:.active { background-color: #3887be; color: #ffffff; }
    //success
    .menu a:global(.active) { background-color: #3887be; color: #ffffff; }

App.js使用普通的class的写法，就会引用全局class。

    import React from 'react';
    import styles from './App.css';

    export default () => {
        return (
            <h1 className="title">
            Hello World
            </h1>
        );
    };

## Class 的组合
为"组合"（"composition"）。
composes: 对于样式复用，CSS Modules 只提供了唯一的方式来处理：composes 组合

    /* components/Button.css */
    .base { /* 所有通用的样式 */ }

    .normal {
      composes: base;
      /* normal 其它样式 */
    }

    .disabled {
      composes: base;
      /* disabled 其它样式 */
    }

    /* Profile.css */
    .description {
      composes: primaryColor from './Colors.css';
    }

    <h1 className={style.normal}> Hello World </h1>

## 输入其他模块
选择器也可以继承其他CSS文件里面的规则。

    //another.css
    .className {
        background-color: blue;
    }

    //App.css
    .title {
        composes: className from './another.css';
        color: red;
    }

## 输入变量
CSS Modules 支持使用变量，不过需要安装 PostCSS 和 postcss-modules-values。

    $ npm install --save postcss-loader postcss-modules-values

把postcss-loader加入webpack.config.js。


    var values = require('postcss-modules-values');

    module.exports = {
      entry: __dirname + '/index.js',
      output: {
        publicPath: '/',
        filename: './bundle.js'
      },
      module: {
        loaders: [
          {
            test: /\.jsx?$/,
            exclude: /node_modules/,
            loader: 'babel',
            query: {
              presets: ['es2015', 'stage-0', 'react']
            }
          },
          {
            test: /\.css$/,
            loader: "style-loader!css-loader?modules!postcss-loader"
          },
        ]
      },
      postcss: [
        values
      ]
    };

接着，在colors.css里面定义变量。

    @value blue: #0c77f8;
    @value red: #ff0000;
    @value green: #aaf200;

App.css可以引用这些变量。

    @value colors: "./colors.css";
    @value blue, red, green from colors;

    .title {
        color: red;
        background-color: blue;
    }