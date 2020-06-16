---
title: React hook
date: 2019-09-08
private:
---
# hooks动机
> 参考ruanyifeng: http://www.ruanyifeng.com/blog/2019/09/react-hooks.html
Hook 是 让你在不编写 class 的情况下使用 state 以及其他的 React 特性。过去的Class有自己的局限：

## 在组件之间复用状态逻辑很难
有时候我们会想要在组件之间重用一些`状态逻辑`。目前为止，有两种主流方案来解决这个问题：`高阶组件和 render props`。自定义 Hook 可以让你在不增加组件的情况下达到同样的目的。
1. Class 不能很好的将可复用性行为“附加”到组件(比如 把组件连接到 store）. 由 providers，consumers，高阶组件，render props 等其他抽象层组成的组件会形成“嵌套地狱”
2. 我们可以使用 Hook 从组件中提取状态逻辑，使得这些逻辑可以单独测试并复用。**Hook 使你在无需修改组件结构(中间件)的情况下复用状态逻辑**。

## 组件难以理解
例如
1. 组件常常在 componentDidMount 和 componentDidUpdate 中获取相同逻辑的数据。
2. 但是，同一个 componentDidMount 中可能也包含很多其它的逻辑，如设置事件监听，而之后需在 componentWillUnmount 中清除。
3. **相互关联且需要对照修改的代码被进行了拆分，而完全不相关的代码却在同一个方法中组合在一起。**

通过使用 Hook，你可以**把组件内相关的副作用组织在一起（例如创建订阅及取消订阅）**，而不要把它们拆分到不同的生命周期函数里。

# Hook 列表
## state hook
多次click，每次执行`useState(0)`, 读取到的count 是不一样的

    import React, { useState } from 'react';
    render(){
        const [count, setCount] = useState(0);
        return  <button onClick={() => setCount(count + 1)}> Click me </button>
    }

### useState
只用setC 才能改变count, Math.random 不可以改变count.

    const [count, setC] = useState(Math.random(10));

### setState 函数式

    <button onClick={() => setCount(initialCount)}>Reset</button>
      <button onClick={() => setCount(prevCount => prevCount + 1)}>+</button>

### useState 函数式
    // ✅ createRows() 只会被调用一次
    const [rows, setRows] = useState(() => createRows(props.count));

### useState本质
1. gc: 在函数退出后变量就就会”消失”，而 this.state 中的变量会被 React 保留。
2. useState 只在组件首次渲染的时候被创建state。在下一次重新渲染时，useState 返回给我们当前的 state。
3. immutable: 不像 class 中的 this.setState，更新 state 变量总是替换它而不是合并它。

## hook effect

### effect 本质
Effect Hook 是在渲染后执行某些操作。相当于didMount+didUpdate

每次 useEffect 会创建新回调函数，方便通过闭包访问count

    useEffect(() => {
        document.title = `You clicked ${count} times`;
    });

如果需要async 则：

    useEffect(() => {
      async function fetchData() {
        // You can await here
        const response = await MyAPI.getData(someId);
        // ...
      }
      fetchData();
    }, [someId]);

### clean effect
与componentWillUnmount 类似，effect 也提供清理(除了首次渲染，render 函数内都会先执行clean effect再执行effect)

在这个示例中，React 会在组件**销毁时取消对 ChatAPI 的订阅**. 

    function FriendStatus(props) {
      const [isOnline, setIsOnline] = useState(null);
      console.log(1)

      useEffect(() => {
        console.log(3)
        ChatAPI.subscribeToFriendStatus(props.friend.id, handleStatusChange);

        return function cleanup() {
            console.log(2)
            ChatAPI.unsubscribeFromFriendStatus(props.friend.id, handleStatusChange);
        };
      });
      return isOnline ? 'Online' : 'Offline';
    }

### 跳过 Effect 进行性能优化
默认所有的render 都会导致effect 执行, 其实我们也可以控制render 频率

    componentDidUpdate(prevProps, prevState) {
      if (prevState.count !== this.state.count) {
        document.title = `You clicked ${this.state.count} times`;
      }
    }

    useEffect(() => {
        document.title = `You clicked ${count} times`;
    }, [count]); // 仅在 count 更改时更新

### 只执行一次
如果想执行只运行一次的 effect（仅在组件挂载和卸载时执行），可以传递一个空数组`[]`

    useEffect(() => {
        document.title = `You clicked ${count} times`;
    }, []); // 只运行一次effect. 默认是每次render 都运行

### useLayoutEffect vs useEffect
https://blog.logrocket.com/useeffect-vs-uselayouteffect/
1. The `useLayoutEffect` function is triggered synchronously, `before` the DOM mutations are painted. 
2. However, the `useEffect` function is called `after` the DOM mutations are painted.
Ref 只能用于useEffect


## 自定义hook
> 自定义hook终以 use 开头，这样react hook 不会将useHook 列为setCount 要触发的回调函数

抽取到一个叫做 useFriendStatus 的自定义 Hook ：
它将 friendID 作为参数，并返回该好友是否在线：

    import React, { useState, useEffect } from 'react';

    function useFriendStatus(friendID) {
      const [isOnline, setIsOnline] = useState(null);

      function handleStatusChange(status) {
        setIsOnline(status.isOnline);
      }

      useEffect(() => {
        ChatAPI.subscribeToFriendStatus(friendID, handleStatusChange);
        return () => {
          ChatAPI.unsubscribeFromFriendStatus(friendID, handleStatusChange);
        };
      },[]);

      return isOnline;
    }

### 使用上面自定义hook
> 来一个例子： https://dev.to/n8tb1t/tracking-scroll-position-with-react-hooks-3bbj
现在我们可以在组件中使用它：

    function FriendStatus(props) {
        const isOnline = useFriendStatus(props.friend.id); //自动订阅-查看friend的状态
        return isOnline ? 'Online' : 'Offline';
    }

或者：

    function FriendListItem(props) {
      const isOnline = useFriendStatus(props.friend.id);
      return <li style={{ color: isOnline ? 'green' : 'black' }}> {props.friend.name} </li>
    }

这两个组件的 state 是完全独立的。
1. Hook 是一种复用状态逻辑的方式，它不复用 state 本身。
2. 事实上 Hook 的每次调用都有一个完全独立的 state —— 因此你可以在单个组件中多次调用同一个自定义 Hook。

### useReducer(examle)
比如编写一个 useReducer 的 Hook，使用 reducer 的方式来管理组件的内部 state 呢？其简化版本可能如下所示：

    function useReducer(reducer, initialState) {
      const [state, setState] = useState(initialState);

      function dispatch(action) {
        const nextState = reducer(state, action);
        setState(nextState);
      }

      return [state, dispatch];
    }

在组件中使用它，让 reducer 驱动它管理 state：

    function Todos() {
      const [todos, dispatch] = useReducer(todosReducer, []);

      function handleAddClick(text) {
        dispatch({ type: 'add', text });
      }
    }

### 封装useEffect

    const useTitle = title=>{
        useEffect(()=>{
            window.document.title = title;
        }, [title])
    }

使用：

    function Com(props){
        useTitle();
        return <div/>
    }

## context hook(避免嵌套)
useContext 让你不使用组件嵌套就可以订阅 React 的 Context。

    function Example() {
      const localeValue = useContext(LocaleContext);
      const theme = useContext(ThemeContext);
      // ...
    }

推荐的替代方案是通过 context 用 useReducer 往下传一个 dispatch 函数：

    // context.js
    const TodosDispatch = React.createContext(null);

    // app.js
    function TodosApp() {
      // 提示：`dispatch` 不会在重新渲染之间变化
      const [todos, dispatch] = useReducer(todosReducer);

      return (
        <TodosDispatch.Provider value={dispatch}>
          <DeepTree todos={todos} />
        </TodosDispatch.Provider>
      );
    }

TodosApp 内部组件树里的任何子节点都可以使用 dispatch 函数来向上传递 actions 到 TodosApp：

    import TodosDispatch from 'context.js'
    function DeepChild(props) {
      // 如果我们想要执行一个 action，我们可以从 context 中获取 dispatch。
      const dispatch = useContext(TodosDispatch);
    
      function handleClick() {
        dispatch({ type: 'add', text: 'hello' });
      }
    
      return (
        <button onClick={handleClick}>Add todo</button>
      );
    }

## Reducer hook
另外 useReducer 可以让你通过 reducer 来管理组件本地的复杂 state。

    function Todos() {
    const [todos, dispatch] = useReducer(todosReducer);
    // ...

## receiveProps for hook
change state if props change

    import React, { useState } from 'react';

    const App = ({ count }) => {
        const [derivedCounter, setDerivedCounter] = useState(
            count > 100 ? 100 : count
        );

        useEffect(() => {
            setDerivedCounter(count > 100 ? 100 : count);
        }, [count]); // this line will tell react only trigger if count was changed

        return <div>Counter: {derivedCounter}</div>;
    };

# Hook API
1. useCallback Hook 允许你在`重新渲染之间`保持对相同的回调引用
1. useMemo Hook 使得控制`具体子节点何时更新`变得更容易，减少了对纯组件的需要。
2. useReducer Hook 减少了`对深层传递回调`的依赖，正如下面解释的那样

## useCallback
    useCallback(fn, deps) 相当于 useMemo(() => fn, deps)。

useCallback Hook 允许你在重新渲染之间保持对相同的回调引用以使得 shouldComponentUpdate 继续工作：

    // 除非 `a` 或 `b` 改变，否则不会变
    const memoizedCallback = useCallback(() => {
        doSomething(a, b);
    }, [a, b]);

## useMemo: 取代shouldComponentUpdate
把“创建”函数和依赖项数组作为参数传入 useMemo，`它仅会在某个依赖项改变时才重新计算 memoized 值`。这种优化有助于避免在每次渲染时都进行高开销的计算。
返回一个 memoized 值。

    // Only re-rendered if `a` changes:
    const child1 = useMemo(() => <Child1 a={a} />, [a]);
    return <> {child1} </>

    // only if [a,b] changes
    const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);


这行代码
1. 会调用 computeExpensiveValue(a, b)。但如果依赖数组 [a, b] 自上次赋值以来没有改变过，useMemo 会跳过二次调用，只是简单复用它上一次返回的值。
> 记住，传入 useMemo 的函数会在`渲染期间执行`。请不要在这个函数内部执行与渲染无关的操作，诸如副作用这类的操作属于 useEffect 的适用范畴，而不是 useMemo。
> `[a,b]`依赖不会作为参数传进去

### React.memo 也可代替shouldComponentUpdate
你可以用 React.memo 包裹一个组件来对它的 props 进行浅比较：

    //export var CreatorExamine = React.memo(CreatorExamineRaw)
    const Button = React.memo((props) => {
        // 你的组件
    });

### useMemo 避免计算
    const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);

## useRef
useRef 会在每次渲染时返回同一个 ref 对象。类似CreateRef

    const inputEl = useRef(initialValue);
    const inputEl = useRef(null);
    // inputEl.current === initialValue
    <input ref={inputEl} type="text" />

### useRef with ts

    const htmlRef = React.useRef<HTMLElement>(null);

    // <div> reference type
    const divRef = React.useRef<HTMLDivElement>(null);

    // <button> reference type
    const buttonRef = React.useRef<HTMLButtonElement>(null);

    // <br /> reference type
    const brRef = React.useRef<HTMLBRElement>(null);

    // <a> reference type
    const linkRef = React.useRef<HTMLLinkElement>(null);

### 实时Ref
要想测量一个 DOM 节点的位置或是尺寸，你可以使用 callback ref。每当 ref 被附加到一个另一个节点，React 就会调用 callback。这里有一个 小 demo:

    function MeasureExample() {
      const [height, setHeight] = useState(0);
    
      const measuredRef = useCallback(node => {
        if (node !== null) {
          setHeight(node.getBoundingClientRect().height);
        }
      }, []);
    
      return (
        <>
          <h1 ref={measuredRef}>Hello, world</h1>
          <h2>The above header is {Math.round(height)}px tall</h2>
        </>
      );
    }

Note:
1. 我们用useCallback, 没有选择使用 useRef，因为当 ref 是一个对象时它并不会把当前 ref 的值的 变化 通知到我们
2. `[]` 作为 useCallback 的依赖列表。这确保了 ref callback 不会在再次渲染时改变((可能有bug)

可以 把这个逻辑抽取出来作为 一个可复用的 Hook:

    function MeasureExample() {
      const [rect, ref] = useClientRect();
      return (
        <>
          <h1 ref={ref}>Hello, world</h1>
          {rect !== null &&
            <h2>The above header is {Math.round(rect.height)}px tall</h2>
          }
        </>
      );
    }

    function useClientRect() {
      const [rect, setRect] = useState(null);
      const ref = useCallback(node => {
        if (node !== null) {
          setRect(node.getBoundingClientRect());
        }
      }, []);
      return [rect, ref];
    }

### useImperativeHandle
useImperativeHandle 可以让你在使用 ref 时自定义暴露给父组件的实例值

    useImperativeHandle(ref, createHandle, [deps])
    // ref.current = createHandle()

用来给ref.current加方法focus的。

    FancyInput = React.forwardRef( (props, ref)=>{ 
        const inputRef = useRef();
        useImperativeHandle(ref, () => ({
            focus: () => {
                inputRef.current.focus();
            }
        }));
        return <input ref={inputRef} ... />;
    } );

在本例中，渲染 `<FancyInput ref={fancyInputRef} />` 的父组件可以调用 fancyInputRef.current.focus()。

    const fancyInputRef = useRef()
    <FancyInput ref={fancyInputRef} onClick={()=>fancyInputRef.current.focus()}/>

## 如何获取上一轮的 props 或 state？
目前，你可以 通过 ref 来手动实现：

    function Counter() {
      const [count, setCount] = useState(0);

      const prevCountRef = useRef();
      useEffect(() => {
        prevCountRef.current = count;
      });
      const prevCount = prevCountRef.current;

      return <h1>Now: {count}, before: {prevCount}</h1>;
    }

这或许有一点错综复杂，但你可以把它抽取成一个自定义 Hook：

    function Counter() {
      const [count, setCount] = useState(0);
      const prevCount = usePrevious(count);
      return <h1>Now: {count}, before: {prevCount}</h1>;
    }

    function usePrevious(value) {
      const ref = useRef();
      useEffect(() => {
        ref.current = value;
      });
      return ref.current;
    }

注意看这是如何作用于 props， state，或任何其他计算出来的值的。

    function Counter() {
      const [count, setCount] = useState(0);

      const calculation = count * 100;
      const prevCalculation = usePrevious(calculation);
      // ...

考虑到这是一个相对常见的使用场景，很可能在未来 React 会自带一个 usePrevious Hook。

# Hook 使用规则与本质(lifecycle)
https://zh-hans.reactjs.org/docs/hooks-rules.html

使用Hook 它们会有两个额外的规则：
1. 只能在函数最项层或自定义hook中 调用 Hook。不要在循环、条件判断或者子函数中调用。
2. 只能在 React 的函数组件中调用 Hook。不要在其他 JavaScript 函数中调用。

我们发布了一个名为 eslint-plugin-react-hooks 的 ESLint 插件来强制执行这两条规则

    $ npm install eslint-plugin-react-hooks --save-dev
    // 你的 ESLint 配置
    {
        "plugins": [
            // ...
            "react-hooks"
        ],
        "rules": {
            // ...
            "react-hooks/rules-of-hooks": "error", // 检查 Hook 的规则
            "react-hooks/exhaustive-deps": "warn" // 检查 effect 的依赖
        }
    }

## useState/useEffect 的取值
useState 是怎么确定取值的呢？顺序！(所以hook 要放顶层, 如果放条件语句中就会打乱这个顺序)

    // ------------
    // 首次渲染
    // ------------
    useState('Mary')           // 1. 使用 'Mary' 初始化变量名为 name 的 state
    useEffect(persistForm)     // 2. 添加 effect 以保存 form 操作
    useState('Poppins')        // 3. 使用 'Poppins' 初始化变量名为 surname 的 state

    // -------------
    // 二次渲染
    // -------------
    useState('Mary')           // 1. 读取变量名为 name 的 state（参数被忽略）
    useEffect(persistForm)     // 2. 替换保存 form 的 effect
    useState('Poppins')        // 3. 读取变量名为 surname 的 state（参数被忽略）

## setState hook 触发
react 的hook 会监听到setCount 执行，再触发重新渲染
