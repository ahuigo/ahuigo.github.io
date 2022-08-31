---
title: React hook render
date: 2020-01-20
private: true
---
# React hook render

## forceUpdate
> 参考：https://stackoverflow.com/questions/53215285/how-can-i-force-component-to-re-render-with-hooks-in-react
有两种方法：

1.useState:

    const forceUpdate: () => void = React.useState()[1].bind(null, {}) 

2.useReducer

    const forceUpdate = React.useReducer(() => ({}), {})[1] as () => void
    const forceUpdate = React.useReducer(() => ({}))[1]


> useState 内部调用的是useReduce, 源码：https://github.com/facebook/react/blob/16.8.6/packages/react-dom/src/server/ReactPartialRendererHooks.js#L254

### update child with useImperativeHandle
https://stackoverflow.com/questions/55889357/change-react-hook-state-from-parent-component

    const { useState, forwardRef, useRef, useImperativeHandle} = React;

    const Parent = () => {
      const ref = useRef(null);
      return (
         <div>
          <MyComponent ref={ref} />
          <button onClick={() => {ref.current.cleanValue()}} type="button">Reset</button>
         </div>
      )
    }

    const MyComponent = forwardRef((props, ref) => {
      const [value, setValue] = useState(0);
    
       const cleanValue = () => {
        setValue(0);
      };

      useImperativeHandle(ref, () => {
         return {
          cleanValue: cleanValue
         }
      });

      return (<span><button type="button" onClick={()=>setValue(1)}>Increment</button>{value}</span>)
    });
    ReactDOM.render(<Parent />, document.getElementById('app'));


# React setState 多次渲染问题
##  避免子组件重复render
REfer: react-hook.md 中的`React.memo`, 不是`React.useMemo` 哈

## 多次setState 重复render
> setState/useReducer 本质上是触发全局的`currentComponent` 执行render
> function compoment 生命周期的第一阶段，会忽略render。到生命周期的render 阶段再统一渲染

如果脱离react的生命周期，多次调用setState 就会导致多次render, 比如下例的next2

    function Counter() {
      const [count, setCount] = React.useState(0)
      const [c2, setC2] = React.useState(0)
      function next1() {
        setCount(count+1)
        setC2(c2+1)
      }
      function next2() {
        setTimeout(next1,0)
      }
      console.log({count,c2})
      return <div>
        <div onClick={()=>next1()}>count:{count}</div>
        <div onClick={() => next2()}>c2:{c2}</div>
      </div>
    }

async 也会脱离react的 同步生命周期

    const [loading, setLoading] = useState(true);
    const [data, setData] = useState(null);
    useEffect(async () => {
      setLoading(false);
      setData('res');
    }, []);

## unstable_batchedUpdates 避免render
不过可以用 unstable_batchedUpdates 避免这个问题

    import { unstable_batchedUpdates } from 'react-dom';
        unstable_batchedUpdates(() => {
            setData(newData)
            setIsLoading(false)
        })

## 自定义useMergeState
通过合并setState 避免多次render

    const useMergeState = (initialState) => {
        const [state, setState] = useState(initialState);
        const setMergeState = (newState) =>
            setState((prevState) => ({ ...prevState, newState }));
        return [state, setMergeState];
    };

    /* 使用 */
    const [request, setRequest] = useMegeState({ loading: false, data: null});
    useEffect(async () => {
        setRequest({loading: true}); // 旧的data 不会消失
        const data = await axios.get("xxx");
        setRequest({loading: false, data:data}); 
    }, []);

## 使用useReducer合并
React提供了useReducer来管理各个依赖项，(useState本身就是用的useReducer)

    const [request, setRequest] = useReducer(
        (prevState, newState) => ({ ...prevState, newState }),
        { loading: false, data: null }
    );

    useEffect(async () => {
        setRequest({loading: true}); // 旧的data 不会消失
        const data = await axios.get("xxx");
        setRequest({loading: false, data:data}); 
    }, []);

如果想要支持回调函数－获取上一个状态prevState，需要对上面的代码进行改造:

    const [request, setRequest] = useReducer(
        (prevState, newState) => {
            const newWithPrevState = typeof newState === "function" ? newState(prevState) : newState;
            return { ...prevState, newWithPrevState }
        },
        { loading: false, data: null },
    );

    useEffect(async () => {
        setRequest({loading: true}); 
        const data = await axios.get("xxx");
        // 回调函数
        setRequest((prevState) => {
            return { loading: false, data: data }
        });
    }, []);

### typescript 支持
    interface MyState {
        loading: boolean;
        data: any;
        something: string;
    }

    const [state, setState] = useReducer<Reducer<MyState, Partial<MyState>>>(
        (state, newState) => ({...state, ...newState}),
        {loading: true, data: null, something: ''}
    )

# 其它优化
window.requestIdleCallback 空闲时执行， requestAnimationFrame两个api, react17/useSWR 都有用到

    window.requestIdleCallback(()=>console.log(123))

# Rerfer
1. https://segmentfault.com/a/1190000041132302
2. https://stackoverflow.com/questions/53574614/multiple-calls-to-state-updater-from-usestate-in-component-causes-multiple-re-re