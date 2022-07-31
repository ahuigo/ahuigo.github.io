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
1. Redux会将整个应用状态(其实也就是数据)存储到到一个地方，称为store
1. 组件可以派发(dispatch)行为(action)给store,而不是直接通知其它组件
1. 其它组件可以通过订阅store中的状态(state)来刷新自己的视图

# Redux Basic

    import { createStore } from 'redux'

    // reducer handler
    function counterReducer(state = { value: 0 }, action) {
      switch (action.type) {
        case 'counter/incremented':
          return { value: state.value + 1 }
        case 'counter/decremented':
          return { value: state.value - 1 }
        default:
          return state
      }
    }

    // Create a Redux store holding the state of your app.
    let store = createStore(counterReducer)

    // subscribe() to response to state changes.
    store.subscribe(() => console.log(store.getState()))

    // The only way to mutate the internal state is to dispatch an action.
    // The actions can be serialized, logged or stored and later replayed.
    store.dispatch({ type: 'counter/incremented' })
    // {value: 1}
    store.dispatch({ type: 'counter/incremented' })
    // {value: 2}
    store.dispatch({ type: 'counter/decremented' })
    // {value: 1}


## Redux Toolkit 示例
Redux Toolkit 简化了编写 Redux 逻辑和设置 store 的过程。
使用 Redux Toolkit，相同的逻辑如下所示：

    import { createSlice, configureStore } from '@reduxjs/toolkit'

    const counterSlice = createSlice({
      name: 'counter',
      initialState: {
        value: 0
      },
      reducers: {
        incremented: state => {
          state.value += 1
        },
        decremented: state => {
          state.value -= 1
        }
      }
    })

    export const { incremented, decremented } = counterSlice.actions

    const store = configureStore({
      reducer: counterSlice.reducer
    })

    // Can still subscribe to the store
    store.subscribe(() => console.log(store.getState()))

    // Still pass action objects to `dispatch`, but they're created for us
    store.dispatch(incremented())
    // {value: 1}
    store.dispatch(incremented())
    // {value: 2}
    store.dispatch(decremented())
    // {value: 1}

# Redux 基础
## state and store
store and state: 一个 State 对应一个 View

    import { createStore } from 'redux';
    const store = createStore(reducer_fn);
    const state = store.getState();

### createStore:

    store = createStore(reducer, [preloadedState], enhancer)

Store enhancer 是一个组合 store creator 的高阶函数，返回一个新的强化过的 store creator

### Store Creator
Store creator 是一个创建 Redux store 的函数(createStore 是base store creator):

    type StoreCreator = (reducer: Reducer, initialState: ?State) => Store

### Store enhancer
Store enhancer 是一个组合 store creator 的高阶函数，返回一个新的强化过的 store creator
它也允许你通过复合函数改变 store 接口

    type StoreEnhancer = (next: StoreCreator) => StoreCreator

## compose
compose 是这样的：

    var compose = (f,g)=> {
        return (x) => f(g(x));
    };

要使用多个 store 增强器的时候，你可能需要使用 compose

    const middleware = [thunk, routerMiddleware(history)];
    const store = compose(
        applyMiddleware(...middleware_list),
        ...enhancers
    )(createStore)(rootReducer);

或者把enhancer 放到createStore 的第二个参数

    const store = createStore(
        reducer,
        compose(
            applyMiddleware(thunk),
            DevTools.instrument()
        )
    )

## Action
用户接触不到state/store, 只能接到view, view 可以通过发出Action 通知 改变state

    const action = {
        type: 'ADD_TODO',
        payload: 'Learn Redux'
    };

在下面的计数器demo 中，你会发现 createStore创建store 时，会初始化：`disption(action={type:'init'})`

## dispatch
dispatch 发出Action 

    store.dispatch({
      type: 'ADD_TODO',
      payload: 'Learn Redux'
    });

### dispatch 同步异步
dispath 本身是同步的（直接触发reducer 执行）

dispatch 传action 字典, 它会返回原有的action

    var action = dispatch(action={type:'Add',...})

dispatch 传callback, 它会返回原有的callback 的执行的值

    var num = dispatch((dispatch, getState)=>{
        const state = getState();
        return 100
    })

dispatch 传async callback 时，会返回promise:

    const promise = dispatch(async (dispatch, getState)=>{ 
        console.log(dispatch, getState, 'getstate');
        return 100
    });
    console.log(await promise)


## Reducer 计数器
    import React,{useState,useEffect} from 'react';
    import { createStore, applyMiddleware, compose } from 'redux';
    import { useSelector, useDispatch } from 'react-redux';
    //[thunk,routerMiddleware(createHistory())]
    import { routerMiddleware } from 'react-router-redux';
    import { Provider } from 'react-redux';
    import thunk from 'redux-thunk';
    /**
     * reducer
     */
    const roadProductInitialState = {count:0}
    const roadProductReducer = (
        state = roadProductInitialState,
        action
    ) => {
        console.log('exec reducer type:', action.type)
        switch (action.type) {
            case 'Add':
                state = {...state, count:state.count + 1}
                return state
            default:
                return state
        }
    }
    // 可以再加 reducers=Immutable.Map(reducers)
    const reducers = {
        // incrementMerge: incrementMergeReducer,
        roadProduct: roadProductReducer
    };
    
    /**
     * combine reducers
     */
    const combinedReducer = (rootState, action) => Object.entries(reducers).reduce(
        (state, [ name, reducer]) => {
            return {...state, [name]: reducer(state[name], action)}},
        rootState
    );
    
    /**
     * root reducer(柯里化)
     */
    const initialState = {};
    const rootReducer = function (
        rootState = initialState,
        action
    ) {
        return combinedReducer(rootState, action)
    };
    
    // create store
    const store = compose(
        applyMiddleware(thunk),
    )(createStore)(rootReducer);
    
    function Child (props){
        console.log('render Child')
        const count = useSelector(state => state.roadProduct);
        const dispatch = useDispatch();
        
        return <div onClick={e=>{
            dispatch({ type: 'Add', index:1 });
        }}>count:{count.count}</div>
    }
    
    class App extends React.Component{
        constructor(props){
            super(props)
            this.state={a:1}
        }
    
        render(){
            return (<Provider store={store}>
                <div>
                    <h1 onClick={e=>{ this.setState({a:this.state.a+1}) }}
                    >a: {this.state.a}</h1>
                    {this.state.a<5 && <Child a={1} /> }
                </div>
            </Provider>)
        }
    }
    
    export default App;

## redux-thunk 中间件
上面代码使用redux-thunk中间件，改造store.dispatch，使得后者可以接受函数作为参数。

    import { createStore, applyMiddleware } from 'redux';
    import thunk from 'redux-thunk';
    import reducer from './reducers';

    const store = createStore(
        reducer,
        applyMiddleware(thunk)
    );

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