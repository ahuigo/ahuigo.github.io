---
title: React state
date: 2019-05-28
private:
---
# React state
https://medium.com/@wereHamster/beware-react-setstate-is-asynchronous-ce87ef1a9cf3

    this.state.a=10;
    // 相当于this.setState({a:12}, ...)  state = {...state, ...{a:12}}
    this.setState({a:this.state.a+2}, e=>{console.log(this.state)})
    // 相当于this.setState({a:11}, ...)  state = {...state, ...{a:12}, ...{a:11}}
    this.setState({a:this.state.a+1}, e=>{console.log(this.state)})

少用forceUpdate, 尽量用setState({}) 代替合并render

    this.setState({})

## render
下列字符不可显示

    {undefined||null||false||true}
