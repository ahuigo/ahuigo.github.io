---
title: React HOC 高阶组件
date: 2019-09-08
---
# React HOC 高阶组件
具体而言，高阶组件是参数为组件，返回值为新组件的函数。

    const EnhancedComponent = higherOrderComponent(WrappedComponent);

## 自定义组件名
为了方便调试时知道组件是经过包装的

    function withSubscription(WrappedComponent) {
      class WithSubscription extends React.Component {/* ... */}
      WithSubscription.displayName = `WithSubscription(${getDisplayName(WrappedComponent)})`;
      return WithSubscription;
    }

    //Chrome 会获取Com.displayName
    function getDisplayName(WrappedComponent) {
      return WrappedComponent.displayName || WrappedComponent.name || 'Component';
    }

## Note
### 不要在 render 方法中使用 HOC
React 的 diff 算法（称为协调）使用`组件标识`来确定它是应该更新现有子树还是将其丢弃并挂载新子树。 
1. 如果从 render 返回的组件与前一个渲染中的组件相同（===），则 React 通过将子树与新子树进行区分来递归更新子树。 
2. 如果它们不相等，则完全卸载前一个子树。

通常，你不需要考虑这点。但对 HOC 来说这一点很重要，因为这代表着你不应在组件的 render 方法中对一个组件应用 HOC：

    render() {
      // 每次调用 render 函数都会创建一个新的 EnhancedComponent
      // EnhancedComponent1 !== EnhancedComponent2
      const EnhancedComponent = enhance(MyComponent);
      // 这将导致子树每次渲染都会进行卸载，和重新挂载的操作！: 导致该组件及其所有子组件的状态丢失。
      return <EnhancedComponent />;
    }

如果在组件之外创建 HOC，这样一来组件只会创建一次。因此，每次 render 时都会是同一个组件。

### 别忘记复制静态方法
新HOC组件没有原始组件的任何静态方法`Com.staticMethod`, 需要手动复制过去

    function enhance(WrappedComponent) {
      class Enhance extends React.Component {/*...*/}
      // 必须准确知道应该拷贝哪些方法 :(
      Enhance.staticMethod = WrappedComponent.staticMethod;
      // 或者使用 hoist-non-react-statics 自动拷贝所有非 React 的静态方法:
      hoistNonReactStatic(Enhance, WrappedComponent);

      return Enhance;

### ref 不被传递
参考react-ref
