---
title: React Ref
date: 2019-09-07
---
# React Ref
Ref 是用来绑定dom 或 Component实例 的

## Dom Ref
ref.current 指向 div

    const ref= React.createRef();
    return <div ref={ref}/>

### 回调Refs
你也可以这样用回调Refs 实现精确的控制:

    <div ref={node=>ref.current=node}/>

回调Refs 更新过程中它会被执行两次，第一次传入参数 null，然后第二次会传入参数 DOM 元素。

    ref={node=> console.log('node:',node) }

这是因为:
1. 在每次渲染时会创建一个新的函数实例，所以 React 清空旧的 ref 并且设置新的。(卸载null与创建, 参考react-diff)
2. 通过将 ref 的回调函数定义成 class 的绑定函数的方式可以避免上述问题(大多数情况无关紧要)


## 组件Ref
ref.current 指向 Com3

    <Com3 ref={ref}/>

### 函数组件Ref
你不能在函数组件上传递 ref 属性，因为它们没有实例,
不过你可以通过`React.forwardRef`这样做

    import React from 'react';

    const Com2 = React.forwardRef((props, ref) => {
        console.log({com3:props, ref})
          return <p>
                <button ref={ref} className="FancyButton1">
                    {props.children}
                  </button>
            </p>
    });

    export default class Com extends React.Component{
        constructor(props){
            super(props)
        }
        componentDidMount(nextProps){
            console.log(this.ref) //ref.current point to h1
            console.log(this.subref) //ref.current point to h1
        }


        render(){
            this.subref = React.createRef();
            //任何对象都 可以 的，e.g.: 
            this.ref= React.createRef();
            this.ref = {}

            return <h1 ref={this.ref}>
                <Com2 a="1" b="12" key={2} ref={this.subref}>com2</Com2>
            </h1>
        }
    }

Note:
1. 用 React.forwardRef, 它不可控: 孙子组件如何改变它，破坏它不可控
1. 第二个参数 ref 只在使用 React.forwardRef 定义组件时存在。常规函数和 class 组件不接收 ref 参数，且 props 中也不存在 ref。

### 孙子组件ref
由于ref 只能通过forwardRef 向下传递，中间组件传ref 时需要改成别的名：

    return React.forwardRef((props, ref) => {
        return <MiddleWare {...props} forwardedRef={ref} />;
    });
    function MiddleWare(props){
        const {forwardRef, ...rest} = props;
        return <Sub ref={forwardRef} {...rest}>
    }

## ref 与生命周期
React 会在组件挂载时给 current 属性传入 DOM 元素，并在组件卸载时传入 null 值。
1. ref 会在 `componentDidMount` 或 `componentDidUpdate` 生命周期钩子触发前更新

## 组件自定义名称Com.displayName
React.forwardRef 接受一个渲染函数。React DevTools 使用该函数来决定为 ref 转发组件显示的内容。

例如，以下组件将在 DevTools 中显示为 “anonymouse:ForwardRef”：

    const WrappedComponent = React.forwardRef((props, ref) => {
        return <LogProps {...props} forwardedRef={ref} />;
    });

显示 命名了渲染函数: `“myFunction:ForwardRef”`

    const WrappedComponent = React.forwardRef( function myFunction(props, ref) {
        return <LogProps {...props} forwardedRef={ref} />;
    });

自定义组件的名称 displayName 属性：

    function logProps(Component) {
        function forwardRef(props, ref) {
            return <Component {...props} forwardedRef={ref} />;
        }

        const name = Component.displayName || Component.name;
        forwardRef.displayName = `logProps(${name})`;

        return React.forwardRef(forwardRef);
    }

# Refer
1. https://zh-hans.reactjs.org/docs/forwarding-refs.html