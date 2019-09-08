---
title: React Error 边界
date: 2019-09-07
---
# React Error 边界
React 提供Error 捕获，但错误边界无法捕获以下场景中产生的错误(本质就是try-catch)：

    事件处理（了解更多）
    异步代码（例如 setTimeout 或 requestAnimationFrame 回调函数）
    服务端渲染
    它自身抛出来的错误（并非它的子组件）

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


# Error

## double construct, 组件重新装载
### excection construct
当发生异常时，如果不捕获，就会double construct

    this.undefined.foo

### Render 不要动态生成Hoc