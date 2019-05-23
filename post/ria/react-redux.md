---
title: React 
date: 2019-05-21
private:
---
# 父子组件通信
react 本身是单向数据流，不过
子组件可以通过this.props.parentHandle 反向改变父组件 state

    parentHandle(name){
        this.setState({value:name})
    }

    <Component onChange={this.parentHandle}>

还是用redux 解决更好
1. redux是的诞生是为了给 React 应用提供「可预测化的状态管理」机制。
1. Redux会将整个应用状态(其实也就是数据)存储到到一个地方，称为store
1. 这个store里面保存一棵状态树(state tree)
1. 组件改变state的唯一方法是通过调用store的dispatch方法，触发一个action，这个action被对应的reducer处理，于是state完成更新
1. 组件可以派发(dispatch)行为(action)给store,而不是直接通知其它组件
1. 其它组件可以通过订阅store中的状态(state)来刷新自己的视图

# 步骤
创建reducer

    可以使用单独的一个reducer,也可以将多个reducer合并为一个reducer，即：combineReducers()
    action发出命令后将state放入reucer加工函数中，返回新的state,对state进行加工处理

创建action

    用户是接触不到state的，只能有view触发，所以，这个action可以理解为指令，需要发出多少动作就有多少指令
    action是一个对象，必须有一个叫type的参数，定义action类型


创建的store，使用createStore方法

    store 可以理解为有多个加工机器的总工厂
    提供subscribe，dispatch，getState这些方法。

## 例子
npm install redux -S // 安装

    import { createStore } from 'redux' // 引入

    const reducer = (state = {count: 0}, action) => {
        switch (action.type){
            case 'INCREASE': return {count: state.count + 1};
            case 'DECREASE': return {count: state.count - 1};
            default: return state;
        }
    }

    const actions = {
        increase: () => ({type: 'INCREASE'}),
        decrease: () => ({type: 'DECREASE'})
    }

    const store = createStore(reducer); //---------->⑶

    store.subscribe(() =>
        console.log(store.getState())
    );

    store.dispatch(actions.increase()) // {count: 1}
    store.dispatch(actions.increase()) // {count: 2}
    store.dispatch(actions.increase()) // {count: 3}
    store.dispatch({ type: 'DECREASE' });

# react redux
react 把store直接集成到React应用的顶层props里面. 顶层组件叫Provider

    <Provider store = {store}>
        <App />
    <Provider>

## connect
    connect(mapStateToProps, mapDispatchToProps)(MyComponent)


## mapStateToProps

    //sate 映射 props
    const mapStateToProps = (state) => {
      return {
        foo: state.bar
      }
    }

然后渲染的时候就可以使用this.props.foo

    class Foo extends Component {
        constructor(props){
            super(props);
        }
        render(){
            return(
                // 这样子渲染的其实就是state.bar的数据了
                <div>this.props.foo</div>
            )
        }
    }
    Foo = connect()(Foo);
    export default Foo;

## mapDispatchToProps
 mapDispatchToProps 就是用来向父组件传值的

    const mapDispatchToProps = (dispatch) => { // 默认传递参数就是dispatch
        return {
            onClick: () => {
                dispatch({
                    type: 'increatment'
                    //data: {xxx}
                });
            }
        };
    }

    // 组件
    class Foo extends Component {
        constructor(props){
            super(props);
        }
        render(){
            return(
                
                <button onClick = {this.props.onClick}>点击increase</button>
            )
        }
    }
    Foo = connect()(Foo);
    export default Foo;

直接通过this.props.onClick，来调用dispatch,这样子就不需要在代码中来进行store.dispatch了

# 参考
链接：https://juejin.im/post/5ce0ae0c5188252f5e019c2c