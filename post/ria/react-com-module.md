---
title: React 代码分割
date: 2019-09-03
private:
---
# React 代码分割
React 默认webpack 支持`import()`代码分割

## import()
使用之后：

    // import { add } from './math';
    import("./math").then(math => {
        console.log(math.add(16, 26));
    });

## Async component
异步组件

    const OtherComponent = React.lazy(() => import('./OtherComponent'));

    function MyComponent() {
        return (
            <div>
                <OtherComponent />
            </div>
        );
    }

本质是：

    function lazy(func){
        func().then(r=>{
            this.setState({r:r})
        })
        if(this.state.r){
            return <div>loading</>
        }else{
            const Com = this.state.r
            return <div><Com/> </div>
        }
    }


## Suspense
> https://zhuanlan.zhihu.com/p/57938605
> 在render阶段的所有生命周期函数都应该幂等, suspense 可以有ajax副作用但是要幂等。
Suspense提供了统一的无缝的代码分割（Code Splitting）兼异步加载方法，在v16.6.0就实现了这样的Suspense功能

OtherComponent 的模块还没有被加载完成，我们可以使用加载指示器为此组件做优雅降级。这里我们使用 Suspense 组件来解决。

    import { Suspense, lazy } from 'react';
    const OtherComponent = React.lazy(() => import('./OtherComponent'));

    function MyComponent() {
      return (
        <div>
          <Suspense fallback={<div>Loading...</div>}>
            <OtherComponent />
          </Suspense>
        </div>
      );
    }

可以用一个 Suspense 组件包裹多个懒加载组件。

    <Suspense fallback={<div>Loading...</div>}>
        <section>
          <OtherComponent />
          <AnotherComponent />
        </section>
      </Suspense>

## Error 异常捕获边界:
如果模块加载失败（如网络问题），它会触发一个错误。你可以通过异常捕获边界（Error )

    import MyErrorBoundary from './MyErrorBoundary';
    const OtherComponent = React.lazy(() => import('./OtherComponent'));
    const AnotherComponent = React.lazy(() => import('./AnotherComponent'));

    const MyComponent = () => (
      <div>
        <MyErrorBoundary>
          <Suspense fallback={<div>Loading...</div>}>
            <section>
              <OtherComponent />
              <AnotherComponent />
            </section>
          </Suspense>
        </MyErrorBoundary>
      </div>
    );

## Router Import 
    import { BrowserRouter as Router, Route, Switch } from 'react-router-dom';
    import React, { Suspense, lazy } from 'react';

    const Home = lazy(() => import('./routes/Home'));
    const About = lazy(() => import('./routes/About'));

    const App = () => (
      <Router>
        <Suspense fallback={<div>Loading...</div>}>
          <Switch>
            <Route exact path="/" component={Home}/>
            <Route path="/about" component={About}/>
          </Switch>
        </Suspense>
      </Router>
    );

## Named export 命名导出
React.lazy 目前只支持默认导出（default exports）, 你需要封装一个中间文件(这能保证 Tree Shaking 只导入必要的组件)

    // ManyComponents.js
    export const MyComponent = /* ... */;
    export const MyUnusedComponent = /* ... */;
    // MyComponent.js
    export { MyComponent as default } from "./ManyComponents.js";