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

## 合并更新
    componentDidMount() {
        let me = this;
        me.setState({
            count: me.state.count + 1
        });
        console.log(me.state.count);    // 打印出0
        me.setState({
            count: me.state.count + 1
        });
        console.log(me.state.count);    // 打印出0
        setTimeout(function(){
            console.log(me.state.count);   // 打印出1
            me.setState({
                count: me.state.count + 1
            });
            console.log(me.state.count);   // 打印出2
        }, 0);
        setTimeout(function(){
            me.setState({
                count: me.state.count + 1
            });
            console.log(me.state.count);   // 打印出3
        }, 0);
    }

## state vs props 选择
通过问自己以下三个问题:

1. 该数据是否是由父组件通过 props 传递而来的？如果是，那它应该不是 state。
2. 该数据是否随时间的推移而保持不变？如果是，那它应该也不是 state。比如搜索词
3. 你能否根据其他 state 或 props 计算出该数据的值？如果是，那它也不是 state。如搜索词得到的ajax 结果（放子组件的state）

# Formik (todo)
如果你想寻找包含验证、追踪访问字段以及处理表单提交的完整解决方案，使用 Formik 是不错的选择。然而，它也是建立在受控组件和管理 state 的基础之上