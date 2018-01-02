# Preface
从最早的Less、SASS，到后来的 PostCSS，再到最近的 CSS in JS，都是为了解决这个问题。

# less
http://lesscss.org/

## inherit one or more other classes?

  /*LESS*/
  .rounded_corners {
    border-radius: 8px;
  }

  #header {
    .rounded_corners;
  }

  #footer {
    .rounded_corners;
  }

## var

    @color: #4D926F;

    #header {
        color: @color;
    }
    h2 {
        color: @color;
    }

## 嵌套

    #heaer h1
    #heaer p
    #header {
      h1 {
        font-size: 26px;
        font-weight: bold;
      }
      p { font-size: 12px;
        a { text-decoration: none;
          &:hover { border-width: 1px }
        }
      }
    }

## 函数 & 运算
运算提供了加，减，乘，除操作；我们可以做属性值和颜色的运算，这样就可以实现属性值之间的复杂关系。LESS中的函数一一映射了JavaScript代码，如果你愿意的话可以操作属性值。

    // LESS
    @the-border: 1px;
    @base-color: #111;
    @red:        #842210;

    #header {
      color: @base-color * 3;
      border-left: @the-border;
      border-right: @the-border * 2;
    }
    #footer {
      color: @base-color + #003300;
      border-color: desaturate(@red, 10%);
    }

## 在客户端使用
引入你的 .less 样式文件的时候要设置 rel 属性值为 “stylesheet/less”:

    <link rel="stylesheet/less" type="text/css" href="styles.less">
    <script src="less.js" type="text/javascript"></script>


### 监视模式
监视模式是客户端的一个功能，这个功能允许你当你改变样式的时候，客户端将自动刷新。

1. 要使用它，只要在URL后面加上'#!watch'，然后刷新页面就可以了。
2. 另外，你也可以通过在终端运行less.watch()来启动监视模式。

## 在服务器端使用
在服务器端安装 LESS 的最简单方式就是通过 npm(node 的包管理器), 像这样:

    $ npm install less
    # 如果你想下载最新稳定版本的 LESS，可以尝试像下面这样操作:
    $ npm install less@latest

只要安装了 LESS，就可以在Node中像这样调用编译器:

    var less = require('less');
    less.render('.class { width: 1 + 1 }', function (e, css) {
        console.log(css);
    });

上面会输出

    .class {
      width: 2;
    }

你也可以手动调用解析器和编译器:

    var parser = new(less.Parser);
    parser.parse('.class { width: 1 + 1 }', function (err, tree) {
        if (err) { return console.error(err) }
        console.log(tree.toCSS());
    });

配置 你可以向解析器传递参数:

    var parser = new(less.Parser)({
        paths: ['.', './lib'], // Specify search paths for @import directives
        filename: 'style.less' // Specify a filename, for better error messages
    });

    parser.parse('.class { width: 1 + 1 }', function (e, tree) {
        tree.toCSS({ compress: true }); // Minify CSS output
    });

## 在命令行下使用
你可以在终端调用 LESS 解析器:

    $ lessc styles.less

上面的命令会将编译后的 CSS 传递给 stdout, 你可以将它保存到一个文件中:

    $ lessc styles.less > styles.css

如何你想将编译后的 CSS 压缩掉，那么加一个 -x 参数就可以了.

# css modules
http://www.ruanyifeng.com/blog/2016/06/css_modules.html

CSS Modules 有所不同:

1. 只加入了局部作用域和模块依赖，
2. CSS Modules 很容易学，因为它的规则少，同时又非常有用，可以保证某个组件的样式，不会影响到其他组件
3. 只支持React
