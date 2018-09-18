---
date: 2018-08-20
---
# 用rollup 代替webpack
Webpack 虽然是最成熟的打包工具，与rollup 相比实在是太笨重了：
1. 转化的代码引入了太多无用的代码，不太可能直接对编译的代码做单步调试
2. 配置相当复杂
3. 从文档建设、插件开发、到底层代码设计，都非常混乱: https://zhuanlan.zhihu.com/p/32148338

Rollup 作为下一代ES2015 的打包器, 这些缺点统统没有
rollup 已经能支持 codeSplitting。还有极其丰富的插件扩展。 截止到现在(2018.08)
1. 没有冗余的代码，方便单步调试
2. 配置及其清晰简单
1. 支持 CommonJS
1. 支持 ES6 Module
1. 自动编译 (watch)
1. CodeSplitting(默认不开启)

不过rollup 还不支持热模块更新(HMR), 但是可以使用liveReload

如果你还没有用过, 推荐看
2. 官方手册: 一天就能看完
1. 入门rollup 实例： https://www.w3cplus.com/javascript/learn-rollup-css.html

如果你还没有用过rollup, 可以看看我这个rollup 实例
- https://coding.net/u/hilojack/p/my-rollup-issue/git (push)

## Watch 自动构建
通过参数`-w/--watch` 就自动实现

    rollup -c -w

## LiveRload
有了 liveRload, 我们就能在热更后自动重启浏览器:

    $ npm i livereload --save-dev
    $ ./node_modules/livereload/bin/livereload.js dist
    或者
    $ npx livereload dist
    Starting LiveReload v0.7.0 for /Users/hilojack/test/my-rollup-project/dist on port 35729.

注意我们要让浏览器监听livereload:

    // index.js
    let s = document.createElement('script')
    s.src = "http://" + (location.host || "localhost").split(":")[0] + ":35729/livereload.js?snipver=1" ; 
    document.head.appendChild(s)

让watch 命令用于打包+热更新：

    "watch":"npx livereload dist & rollup -c -w"

## ES Module 文件
如果想引入es6 module:

    npm i rollup-plugin-node-resolve --save-dev

然后再rollup.config.js 配置

    import resolve from "rollup-plugin-node-resolve";
    ....
    export default{
        plugins:[
            // 这样就简单了，不需要用 { jsnext: true, }
            // https://github.com/rollup/rollup/issues/969 
            resolve({browser: true}),  
            
        ]
    }

## 外部依赖
rollup下可以通过external + globals+paths 配置来标记外部依赖：

    external: ['vue', 'react'],
    output: {
        // 引入全局的: globals should only affect iife or umd build.
      globals: {
        'react': 'React', /
      }
        // 引入remote
      paths: {
        vue: "https://cdn.bootcss.com/vue/2.5.17-beta.0/vue.esm.browser.js",
      }
    }
