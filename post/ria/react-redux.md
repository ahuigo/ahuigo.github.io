---
title: React Redux
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

redux 出现就是为了解决组件间的状态同步
1. redux是的诞生是为了给 React 应用提供「可预测化的状态管理」机制。
1. Redux会将整个应用状态(其实也就是数据)存储到到一个地方，称为store
1. 这个store里面保存一棵状态树(state tree)
1. 组件改变state的唯一方法是通过调用store的dispatch方法，触发一个action，这个action被对应的reducer处理，于是state完成更新
1. 组件可以派发(dispatch)行为(action)给store,而不是直接通知其它组件
1. 其它组件可以通过订阅store中的状态(state)来刷新自己的视图

# Redux 基础
## state and store
store and state: 一个 State 对应一个 View

    import { createStore } from 'redux';
    const store = createStore(fn);
    const state = store.getState();

## Action
用户接触不到state/store, 只能接到view, view 可以通过发出Action 通知 改变state

    const action = {
        type: 'ADD_TODO',
        payload: 'Learn Redux'
    };

## dispatch
dispatch 发出Action 

    store.dispatch({
      type: 'ADD_TODO',
      payload: 'Learn Redux'
    });

## Reducer
Store 收到 Action 以后，必须给出一个新的 State，这样 View 才会发生变化。这种 State 的计算过程就叫做 Reducer。

Reducer 是一个函数(相当于array.reduce)，它接受 Action 和当前 State 作为参数，返回一个新的 State。


    const reducer = function (state, action) {
        // ...
        return new_state;
    };

eg. 执行reducer

    const defaultState = 0;
    const reducer = (state = defaultState, action) => {
      switch (action.type) {
        case 'ADD':
          return state + action.payload;
        default: 
          return state;
      }
    };

    const state = reducer(1, { type: 'ADD', payload: 2 });

实际的reducer 执行不需要手动调用，而是store.dispatch 触发的. store 需要知道reducer:

    import { createStore } from 'redux';
    const store = createStore(reducer);

reducer 是纯函数，没有副作用, 所以要满足：
1. 不能改写参数和IO
2. 不能调用datetime, Math.random

纯函数reducer 保证相同的state 返回相同的newState 得到相同的View. 
最好把 State 对象设成只读, 只能返回全新的newState

    // State 是一个对象
    function reducer(state, action) {
      return Object.assign({}, state, { thingToChange });
      // 或者
      return { ...state, ...newState };
    }

    // State 是一个数组
    function reducer(state, action) {
      return [...state, newItem];
    }

## store.subscribe()
Store 允许使用store.subscribe方法设置监听函数，一旦 State 发生变化，就自动执行这个函数。


    import { createStore } from 'redux';
    const store = createStore(reducer);

    store.subscribe(listener);

显然，只要把 View 的更新函数（对于 React 项目，就是组件的render方法或setState方法）放入listen，就会实现 View 的自动渲染。

store.subscribe方法返回一个函数，调用这个函数就可以解除监听。

    let unsubscribe = store.subscribe(() =>
        console.log(store.getState())
    );
    unsubscribe();

# Store 的实现
上一节介绍了 Redux 涉及的基本概念，可以发现 Store 提供了三个方法。

    store.getState()
    store.dispatch()
    store.subscribe()

    import { createStore } from 'redux';
    let { subscribe, dispatch, getState } = createStore(reducer);

createStore 方法还可以接受第二个参数，表示 State 的最初状态。这通常是服务器给出的。

    let store = createStore(todoApp, window.STATE_FROM_SERVER)

上面代码中，window.STATE_FROM_SERVER就是整个应用的状态初始值。注意，如果提供了这个参数，它会覆盖 Reducer 函数的默认初始值。

下面是createStore方法的一个简单实现，可以了解一下 Store 是怎么生成的

    const createStore = (reducer) => {
      let state;
      let listeners = [];

      const getState = () => state;

      const dispatch = (action) => {
        state = reducer(state, action);
        listeners.forEach(listener => listener());
      };

      const subscribe = (listener) => {
        listeners.push(listener);
        return () => {
          listeners = listeners.filter(l => l !== listener);
        }
      };

      dispatch({});

      return { getState, dispatch, subscribe };
    };

## Reducer 的拆分
Reducer 函数负责生成 State。由于整个应用只有一个 State 对象，包含所有数据，对于大型应用来说，这个 State 必然十分庞大，导致 Reducer 函数也十分庞大。

请看下面的例子。

    const chatReducer = (state = defaultState, action = {}) => {
      const { type, payload } = action;
      switch (type) {
        case ADD_CHAT:
          return Object.assign({}, state, {
            chatLog: state.chatLog.concat(payload)
          });
        case CHANGE_STATUS:
          return Object.assign({}, state, {
            statusMessage: payload
          });
        case CHANGE_USERNAME:
          return Object.assign({}, state, {
            userName: payload
          });
        default: return state;
      }
    };

上面代码中，三种 Action 分别改变 State 的三个属性。

    ADD_CHAT：chatLog属性
    CHANGE_STATUS：statusMessage属性
    CHANGE_USERNAME：userName属性

这三个属性之间没有联系，这提示我们可以把 Reducer 函数拆分。不同的函数负责处理不同属性，最终把它们合并成一个大的 Reducer 即可。

    const chatReducer = (state = defaultState, action = {}) => {
      return {
        chatLog: chatLog(state.chatLog, action),
        statusMessage: statusMessage(state.statusMessage, action),
        userName: userName(state.userName, action)
      }
    };

上面代码中，Reducer 函数被拆成了三个小函数，每一个负责生成对应的属性。

这样一拆，Reducer 就易读易写多了。而且，这种拆分与 React 应用的结构相吻合：一个 React 根组件由很多子组件构成。这就是说，子组件与子 Reducer 完全可以对应。

Redux 提供了一个combineReducers方法，用于 Reducer 的拆分。你只要定义各个子 Reducer 函数，然后用这个方法，将它们合成一个大的 Reducer。


import { combineReducers } from 'redux';

const chatReducer = combineReducers({
  chatLog,
  statusMessage,
  userName
})

export default todoApp;
上面的代码通过combineReducers方法将三个子 Reducer 合并成一个大的函数。

这种写法有一个前提，就是 State 的属性名必须与子 Reducer 同名。如果不同名，就要采用下面的写法。


const reducer = combineReducers({
  a: doSomethingWithA,
  b: processB,
  c: c
})

// 等同于
function reducer(state = {}, action) {
  return {
    a: doSomethingWithA(state.a, action),
    b: processB(state.b, action),
    c: c(state.c, action)
  }
}
总之，combineReducers()做的就是产生一个整体的 Reducer 函数。该函数根据 State 的 key 去执行相应的子 Reducer，并将返回结果合并成一个大的 State 对象。

下面是combineReducer的简单实现。


const combineReducers = reducers => {
  return (state = {}, action) => {
    return Object.keys(reducers).reduce(
      (nextState, key) => {
        nextState[key] = reducers[key](state[key], action);
        return nextState;
      },
      {} 
    );
  };
};
你可以把所有子 Reducer 放在一个文件里面，然后统一引入。


import { combineReducers } from 'redux'
import * as reducers from './reducers'

const reducer = combineReducers(reducers)


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