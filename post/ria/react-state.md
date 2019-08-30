---
title: React state
date: 2019-05-28
private:
---
# React state
https://medium.com/@wereHamster/beware-react-setstate-is-asynchronous-ce87ef1a9cf3

## setState 是异步的
此代码可能会无法更新计数器：

    // Wrong
    this.setState({
        counter: this.state.counter + this.props.increment,
    });

要解决这个问题，可以让 setState() 接收一个函数而不是一个对象。

    // Correct
    this.setState((state, props) => ({
      counter: state.counter + props.increment
    }));

## state 会合并render

    this.state.a=10;
    // 相当于this.setState({a:12}, ...)  state = {...state, ...{a:12}}
    this.setState({a:this.state.a+2}, e=>{console.log(this.state)})
    // 相当于this.setState({a:11}, ...)  state = {...state, ...{a:12}, ...{a:11}}
    this.setState({a:this.state.a+1}, e=>{console.log(this.state)})

尽量用`setState({})` 合并render, 少用forceUpdate 

    this.setState({})

## render
下列字符不可显示

    {undefined||null||false||true}