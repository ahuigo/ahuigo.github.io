---
title: React Error 边界
date: 2019-09-07
---
# React Error 边界
> refer: https://blog.logrocket.com/react-error-handling-react-error-boundary/#error-boundaries-in-react

React 提供Error 捕获，但错误边界无法捕获以下场景中产生的错误(本质就是try-catch)：

    Event handlers
    Asynchronous code (e.g., setTimeout or requestAnimationFrame callbacks)
    Server-side rendering
    Errors thrown in the error boundary itself (rather than its children)

## ErrorBoundary
如果一个 class 组件中定义了 `static getDerivedStateFromError() 或 componentDidCatch()` 这两个生命周期方法中的任意一个（或两个）时，
那么它就变成一个错误边界。

当抛出错误后，请使用 static getDerivedStateFromError() 渲染备用 UI ，使用 componentDidCatch() 打印错误信息。

    class ErrorBoundary extends React.Component {
      constructor(props) {
        super(props);
        this.state = { hasError: false };
      }

      static getDerivedStateFromError(error) {
        // 更新 state 使下一次渲染能够显示降级后的 UI
        return { hasError: true };
      }

      componentDidCatch(error, errorInfo) {
        // 你同样可以将错误日志上报给服务器
        logErrorToMyService(error, errorInfo);
      }

      render() {
        if (this.state.hasError) {
          // 你可以自定义降级后的 UI 并渲染
          return <h1>Something went wrong.</h1>;
        }

        return this.props.children; 
      }
    }

然后你可以将它作为一个常规组件去使用：

    <ErrorBoundary>
        <MyWidget />
    </ErrorBoundary>

# StrictMode 严格模式
> 严格模式仅在开发模式下运行

是一个用来突出显示应用程序中潜在问题的工具。与 Fragment 一样，StrictMode 不会渲染任何可见的 UI。它为其后代元素触发额外的检查和警告。

    <Header />
    <React.StrictMode>
        <div>
          <ComOne />
          <ComTwo />
        </div>
    </React.StrictMode>

以上，Header 不被 strict 检查，ComOne/ComTwo 会被 strcitMode 检查

## 作用
    识别不安全的生命周期
    关于使用过时字符串 ref API 的警告
    关于使用废弃的 findDOMNode 方法的警告
        在给定 class 实例的情况下在树中搜索 DOM 节点, 返回第一个子节点。
        通常你不需要这样做，因为你可以将 ref 直接绑定到 DOM 节点。
    检测意外的副作用
    检测过时的 context API

## 幅作用
严格模式不能自动检测到你的副作用，但它可以帮助你发现它们，使它们更具确定性。通过故意重复调用以下方法来实现的该操作：

    class 组件的 constructor 方法
    render 方法
    setState 更新函数 (第一个参数）
    静态的 getDerivedStateFromProps 生命周期方法

> 默认开发模式下，当发生未捕获异常时，也会double 执行 constructor

# Error 问题

## double construct, 组件重新装载
### excection construct
当发生异常时，如果不捕获，就会double construct(即组件卸载、并重新render)

    this.undefined.foo

### Render 不要动态生成Hoc
render 内生成动态高阶组件，将导致高阶组件频繁生成、卸载，无法应用diff 算法

## memory leak
> Warning: Can't perform a React state update on an unmounted component. This is a no-op, but it indicates a memory leak in your application. To fix, cancel all subscriptions and asynchronous tasks in the componentWillUnmount method

一般都是因为fetch ajax 请求还没有结束