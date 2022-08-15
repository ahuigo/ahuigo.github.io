---
title: react context
date: 2022-08-15
private: true
---
# react context
## context hook(避免嵌套)
useContext 只管理状态共享，但是支持订阅，不过我们可以利用useReducer 创建一个dispatch 来实现一个订阅

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
