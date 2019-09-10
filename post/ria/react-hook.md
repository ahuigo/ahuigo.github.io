---
title: React hook
date: 2019-09-08
private:
---
# todo
> 参考ruanyifeng: http://www.ruanyifeng.com/blog/2019/09/react-hooks.html

# 生命周期
React 为每个状态都提供了两种处理函数，will 函数在进入状态之前调用，did 函数在进入状态之后调用，三种状态共计五种处理函数。

    componentWillMount()
    componentDidMount()
    shouldComponentUpdate(object nextProps, object nextState)：组件判断是否重新渲染时调用
    componentWillUpdate(object nextProps, object nextState)
    componentDidUpdate(object prevProps, object prevState)
    componentWillUnmount()

此外，React 还提供两种特殊状态的处理函数。

    componentWillReceiveProps(object nextProps)：已加载组件收到新的参数时调用

example:

    UNSAFE_componentWillMount(...res){
        console.log('willMount',res)
    }
    componentDidMount(...res){
        console.log('didMount',res)
    }
    UNSAFE_componentWillUpdate(nextProps, nextState,...res){
        console.log('willupdate',nextProps, nextState, res)
    }
    componentDidUpdate(nextProps, nextState,...res){
        console.log('didupdate',nextProps, nextState, res)
    }
    shouldComponentUpdate(nextProps, nextState) {
        console.log('shouldComponentUpdate',nextState, this.state)
        if(nextState.a===3){
            return false
        }
        return true;
    }


## this
除了构造函数和生命周期钩子函数里会自动绑定this为当前组件外，其他的都不会自动绑定this的指向为当前组件
