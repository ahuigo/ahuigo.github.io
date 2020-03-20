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
    //相当于
    const [,setUpdate] = React.useState()
    const forceUpdate: () => void = setUpdate.bind(null, {}) 


2.useReducer

    const forceUpdate = React.useReducer(() => ({}), {})[1] as () => void

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
