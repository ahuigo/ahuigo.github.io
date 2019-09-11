---
title: React Redux
date: 2019-05-21
private:
---
# 导读
React 组件间通讯
http://taobaofed.org/blog/2016/11/17/react-components-communication/

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

下面代码中，Reducer 函数被拆成了三个小函数，每一个负责生成对应的属性。一个 React 根组件由很多子组件构成, 子组件与子 Reducer 完全可以对应。

    const chatReducer = (state = defaultState, action = {}) => {
      return {
        chatLog: chatLog(state.chatLog, action),
        statusMessage: statusMessage(state.statusMessage, action),
        userName: userName(state.userName, action)
      }
    };


Redux 提供了一个combineReducers方法，用于 Reducer 的合并。

    import { combineReducers } from 'redux';
    const chatReducer = combineReducers({
        chatLog,
        statusMessage,
        userName
    })
    export default todoApp;

你可以把所有子 Reducer 放在一个文件里面，然后统一引入。

    import { combineReducers } from 'redux'
    import * as reducers from './reducers'
    const reducer = combineReducers(reducers)

## redux 工作流

    // 设置监听函数
    // State 一旦有变化，Store 就会调用监听函数。
    store.subscribe(listener);
    store.dispatch(action);
        let nextState = todoApp(previousState, action);
        listeners.forEach(listener => listener());


listener可以通过store.getState()得到当前状态。如果使用的是 React，这时可以触发重新渲染 View。

    function listerner() {
        let newState = store.getState();
        component.setState(newState);   
    }

## 计数器示例
    import React from 'react'
    import ReactDOM from 'react-dom'
    import { createStore } from 'redux'
    import Counter from './components/Counter'
    import counter from './reducers'

    const store = createStore(counter)
    const rootEl = document.getElementById('root')

    const render = () => ReactDOM.render(
      <Counter
        value={store.getState()}
        onIncrement={() => store.dispatch({ type: 'INCREMENT' })}
        onDecrement={() => store.dispatch({ type: 'DECREMENT' })}
      />,
      rootEl
    )

    render()
    store.subscribe(render)

# MiddleWare & Async
middleware 原型：

    let next = store.dispatch;
    store.dispatch = function dispatchAndLog(action) {
        console.log('dispatching', action);
        next(action);
        console.log('next state', store.getState());
    }

React 如果执行了Async Reducer, 需要middleware 实现异步

## middleware 用法

    import { applyMiddleware, createStore } from 'redux';
    import createLogger from 'redux-logger';
    const logger = createLogger();

    const store = createStore(
        reducer,
        applyMiddleware(logger)
    );

也可以支持init_state, 以及多个middleware, （logger 放最后，wrap 前面两个中间件)

    const store = createStore(
        reducer,
        init_state,
        applyMiddleware(thunk, promise, logger)
    );

### middleware 实现
它是 Redux 的原生方法，作用是将所有中间件组成一个数组，依次执行。下面是它的源码。

    export default function applyMiddleware(...middlewares) {
      return (createStore) => (reducer, preloadedState, enhancer) => {
        var store = createStore(reducer, preloadedState, enhancer);
        var dispatch = store.dispatch;
        var chain = [];

        var middlewareAPI = {
          getState: store.getState,
          dispatch: (action) => dispatch(action)
        };
        chain = middlewares.map(middleware => middleware(middlewareAPI));
        dispatch = compose(...chain)(store.dispatch);

        return {...store, dispatch}
      }
    }

## 异步
同步操作只要发出一种 Action 即可，异步操作的差别是它要发出三种 Action。

    操作发起时的 Action
    操作成功时的 Action
    操作失败时的 Action

以向服务器取出数据为例，三种 Action 可以有两种不同的写法。

    // 写法一：名称相同，参数不同
    { type: 'FETCH_POSTS' }
    { type: 'FETCH_POSTS', status: 'error', error: 'Oops' }
    { type: 'FETCH_POSTS', status: 'success', response: { ... } }

    // 写法二：名称不同
    { type: 'FETCH_POSTS_REQUEST' }
    { type: 'FETCH_POSTS_FAILURE', error: 'Oops' }
    { type: 'FETCH_POSTS_SUCCESS', response: { ... } }

除了 Action 种类不同，异步操作的 State 也要进行改造，反映不同的操作状态。下面是 State 的一个例子。

    let state = {
        // ... 
        isFetching: true,
        didInvalidate: true,
        lastUpdated: 'xxxxxxx'
    };

上面代码中，State 的属性isFetching表示是否在抓取数据。didInvalidate表示数据是否过时，lastUpdated表示上一次更新时间。

现在，整个异步操作的思路就很清楚了。

    操作开始时，送出一个 Action，触发 State 更新为"正在操作"状态，View 重新渲染
    操作结束后，再送出一个 Action，触发 State 更新为"操作结束"状态，View 再一次重新渲染

## redux-thunk 中间件
异步操作至少要送出两个 Action：用户触发第一个 Action，这个跟同步操作一样，没有问题；如何才能在操作结束时，系统自动送出第二个 Action 呢？

奥妙就在 Action Creator 之中。

    class AsyncApp extends Component {
      componentDidMount() {
        const { dispatch, selectedPost } = this.props
        dispatch(fetchPosts(selectedPost))
      }

上面代码是一个异步组件的例子。加载成功后（componentDidMount方法），它送出了（dispatch方法）一个 Action，向服务器要求数据 fetchPosts(selectedSubreddit)。这里的fetchPosts就是 Action Creator。

下面就是fetchPosts的代码，关键之处就在里面。

    const fetchPosts = postTitle => (dispatch, getState) => {
      dispatch(requestPosts(postTitle));
      return fetch(`/some/API/${postTitle}.json`)
        .then(response => response.json())
        .then(json => dispatch(receivePosts(postTitle, json)));
      };
    };

    // 使用方法一
    store.dispatch(fetchPosts('reactjs'));
    // 使用方法二
    store.dispatch(fetchPosts('reactjs')).then(() =>
      console.log(store.getState())
    );

上面代码中，有几个地方需要注意。

    （1）fetchPosts返回了一个函数，而普通的 Action Creator 默认返回一个对象。

    （2）函数的参数是dispatch和getState这两个 Redux 方法，普通的 Action Creator 的参数是 Action 的内容。

    （3）在返回的函数之中，先发出一个 Action（requestPosts(postTitle)），表示操作开始。

    （4）异步操作结束之后，再发出一个 Action（receivePosts(postTitle, json)），表示操作结束。

这样的处理，就解决了自动发送第二个 Action 的问题。但是，又带来了一个新的问题，Action 是由store.dispatch方法发送的。而store.dispatch方法正常情况下，参数只能是对象，不能是函数。

这时，就要使用中间件redux-thunk。

    import { createStore, applyMiddleware } from 'redux';
    import thunk from 'redux-thunk';
    import reducer from './reducers';

    // Note: this API requires redux@>=3.1.0
    const store = createStore(
        reducer,
        applyMiddleware(thunk)
    );

上面代码使用redux-thunk中间件，改造store.dispatch，使得后者可以接受函数作为参数。

因此，异步操作的第一种解决方案就是，写出一个返回函数的 Action Creator，然后使用redux-thunk中间件改造store.dispatch。

## redux-promise 中间件
既然 Action Creator 可以返回函数，当然也可以返回其他值。另一种异步操作的解决方案，就是让 Action Creator 返回一个 Promise 对象。

这就需要使用redux-promise中间件。

    import { createStore, applyMiddleware } from 'redux';
    import promiseMiddleware from 'redux-promise';
    import reducer from './reducers';

    const store = createStore(
      reducer,
      applyMiddleware(promiseMiddleware)
    ); 

这个中间件使得store.dispatch方法可以接受 Promise 对象作为参数。这时，Action Creator 有两种写法。

    //写法一，返回值是一个 Promise 对象。
    const fetchPosts = 
      (dispatch, postTitle) => new Promise(function (resolve, reject) {
         dispatch(requestPosts(postTitle));
         return fetch(`/some/API/${postTitle}.json`)
           .then(response => {
             type: 'FETCH_POSTS',
             payload: response.json()
           });
    });

写法二，Action 对象的payload属性是一个 Promise 对象。这需要从redux-actions模块引入createAction方法，并且写法也要变成下面这样。

    import { createAction } from 'redux-actions';

    class AsyncApp extends Component {
      componentDidMount() {
        const { dispatch, selectedPost } = this.props
        // 发出同步 Action
        dispatch(requestPosts(selectedPost));
        // 发出异步 Action
        dispatch(createAction(
          'FETCH_POSTS', 
          fetch(`/some/API/${postTitle}.json`)
            .then(response => response.json())
        ));
      }

上面代码中，第二个dispatch方法发出的是异步 Action，只有等到操作结束，这个 Action 才会实际发出。注意，createAction的第二个参数必须是一个 Promise 对象。

看一下redux-promise的源码，就会明白它内部是怎么操作的。

    export default function promiseMiddleware({ dispatch }) {
      return next => action => {
        if (!isFSA(action)) {
          return isPromise(action)
            ? action.then(dispatch)
            : next(action);
        }

        return isPromise(action.payload)
          ? action.payload.then(
              result => dispatch({ ...action, payload: result }),
              error => {
                dispatch({ ...action, payload: error, error: true });
                return Promise.reject(error);
              }
            )
          : next(action);
      };
    }

    从上面代码可以看出，如果 Action 本身是一个 Promise，它 resolve 以后的值应该是一个 Action 对象，会被dispatch方法送出（action.then(dispatch)），但 reject 以后不会有任何动作；如果 Action 对象的payload属性是一个 Promise 对象，那么无论 resolve 和 reject，dispatch方法都会发出 Action。


# react redux
react 把store直接集成到React应用的顶层props里面. 顶层组件叫Provider

    <Provider store = {store}>
        <App />
    <Provider>

## connect
    connect(mapStateToProps, mapDispatchToProps)(MyComponent)


## mapStateToProps

    //sate 映射 props, 其实是把Redux中的数据映射到React中的props中去。
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