---
title: React profile
date: 2019-09-08
---
# React Build
构建参考：https://zh-hans.reactjs.org/docs/optimizing-performance.html

## Create React App
如果你的代码 是Create React App 生成的

    # react-scripts build
    npm run build ; # 生成生产环境代码 build/ 
            $ yarn global add serve; serve -s build

    # react-scripts start
    npm start; # 执行开发模式

## 单文件构建
    <script src="https://unpkg.com/react@16/umd/react.production.min.js"></script>
    <script src="https://unpkg.com/react-dom@16/umd/react-dom.production.min.js"></script>

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
在生产模式下，Webpack v4+ 将默认对代码进行压缩：

    const TerserPlugin = require('terser-webpack-plugin');

    module.exports = {
      mode: 'production'
      optimization: {
        minimizer: [new TerserPlugin({ /* additional options here */ })],
      },
    };


# React performance
Refer: https://zh-hans.reactjs.org/docs/optimizing-performance.html

## Chrome Performance 标签分析
## Chrome react profile 分析
## 按需渲染
### 虚拟化长列表
如果你的应用渲染了长列表（上百甚至上千的数据），我们推荐使用“虚拟滚动”技术。这项技术会在有限的时间内仅渲染有限的内容.

1. react-window 和 react-virtualized 是热门的虚拟滚动库。 它们提供了多种可复用的组件，用于展示列表、网格和表格数据

### 虚拟DOM
React 只更新改变了的 DOM 节点. 那什么时候触发render 呢？
答案是当一个组件的 props 或 state 变更， 通过shouldComponentUpdate 判断是否触发render

其默认实现总是返回 true(即使prop/state 并没有真的变`setState({})`)：

    shouldComponentUpdate(nextProps, nextState) {
        return true;
    }

### shouldComponentUpdate与React.PureComponent
你可以改写 shouldComponentUpdate:

    shouldComponentUpdate(nextProps, nextState) {
        if(nextState.a==this.state.a){
            return false
        }
        return true;
    }

在大部分情况下，你可以继承 React.PureComponent 以代替手写 shouldComponentUpdate()。它用当前与之前 props 和 state 的浅比较覆写了 shouldComponentUpdate() 的实现。

### immutable不可变数据作为props/state
如果使用 React.PureComponent， 下面的words 变量没有被替换，导致不更新

    const words = this.state.words;
    words.push('marklar');
    this.setState({words: words});

好的做法是，不要改变原来的变量words, 而是生成新的words

    this.setState(state => ({
        words: state.words.concat(['marklar'])
        //或者 
        words: [...state.words, 'marklar'],
    }));

# Profiler API
你可以在React 任何地方 插入profiler 分析点

    <Profiler id="Navigation" onRender={callback}>
      <Navigation {...props} />
    </Profiler>
    <Profiler id="Main" onRender={callback}>
      <Main {...props} />
    </Profiler>

嵌套Profiler:

    <App>
        <Profiler id="Panel" onRender={callback}>
         <Panel {...props}>
           <Profiler id="Content" onRender={callback}>
             <Content {...props} />
           </Profiler>
           <Profiler id="PreviewPane" onRender={callback}>
             <PreviewPane {...props} />
           </Profiler>
         </Panel>
        </Profiler>
    </App>