---
title: React Ref
date: 2019-09-07
---
# React Ref
Ref 是用来绑定dom 的

## Native Dom with Ref

    <div ref={node=>this.div=node}/>

或者创建一个ref


    const ref= React.createRef();
    return <div ref={ref}/>
    //本质上是： 
    <div ref={node=>ref.current=node}/>

## 子组件Ref
如果父组件想获取子组件的dom, 可以通过`React.forwardRef`这样做

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
            this.ref= React.createRef();//任何对象都 可以 的，e.g.: this.ref = {}

            return <h1 ref={this.ref}>
                <Com2 a="1" b="12" key={2} ref={this.subref}>com2</Com2>
            </h1>
        }
    }

对于com2 中的this.subref: 以下是对上述示例发生情况的逐步解释：

1. 我们通过调用 React.createRef 创建了一个 React ref 并将其赋值给 subref 变量。
1. 我们通过指定 ref 为 JSX 属性，将其向下传递给 `<FancyButton ref={subref}>`。
1. React 传递 ref 给 fowardRef 内函数 (props, ref) => ...，作为其第二个参数。
1. 我们向下转发该 ref 参数到 `<button ref={ref}>`，将其指定为 JSX 属性。
1. 当 ref 挂载完成，ref.current 将指向 `<button>` DOM 节点

## React.forwardRef
Note:
1. 尽量不用 React.forwardRef, 它不可控: 子组件如何改变它，破坏它不可控
1. 第二个参数 ref 只在使用 React.forwardRef 定义组件时存在。常规函数和 class 组件不接收 ref 参数，且 props 中也不存在 ref。

由于ref 只能通过forwardRef 向下传递，中间组件把ref 改成别的名：

    return React.forwardRef((props, ref) => {
        return <MiddleWare {...props} forwardedRef={ref} />;
    });
    function MiddleWare(props){
        const {forwardRef, ...rest} = props;
        return <Sub ref={forwardRef} {...rest}>
    }

## 组件自定义名称
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