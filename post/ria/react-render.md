---
title: React Start
date: 2019-06-23
private:
---
# Ele 表示
以下两种示例代码完全等效：

## JSX 语法

    const element = (
      <h1 className="greeting">
        Hello, world!
      </h1>
    );

### 短语法

    <>
    <td>1</td>
    </>

如果带key, 就不能省略`React.Fragment`, 且目前`key` 是唯一可以传递给 Fragment 的属性

    {props.items.map(item => (
        <React.Fragment key={item.id}>
          <dt>{item.term}</dt>
        </React.Fragment>
    ))}

## JSX 本质
实际上，JSX 仅仅只是 React.createElement(component, props, ...children) 函数的语法糖。如下 JSX 代码：

    <MyButton color="blue" shadowSize={2}>
        Click Me
    </MyButton>

会编译为：

    React.createElement(
      MyButton,
      {color: 'blue', shadowSize: 2},
      'Click Me'
    )

还比如 CreateElement

    const element = React.createElement(
      'h1',
      {className: 'greeting'},
      'Hello, world!'
    );

React.createElement() 创建了一个这样的对象：

    // 注意：这是简化过的结构
    const element = {
      type: 'h1',
      props: {
        className: 'greeting',
        children: 'Hello, world!'
      }
    };

## form 语法支持
### Input select 支持value
不用`<option selected>`:

    <select value="C">
        <option value="A">A</option>
        <option value="B">B</option>
        <option value="C">C</option>
    </select>

defaultValue defaultChecked

    <input type="text" defaultValue="Hello" ref={input => this.input = input} />

## List 语法支持
### List array
    var arr = [
        <h1>Hello world!</h1>,
        <h2>React is awesome</h2>,
    ];
    ReactDOM.render(
        <div>{arr}</div>,
        document.getElementById('example')
    );

### List Key(按需更新)
React 是根据key 按需更新的
1. 如果不指定显式的 key 值，那么 React 将默认使用索引用作为列表项目的 key 值。
2. key 会传递信息给 React ，但不会传递给你的组件

列表render 需要给每个item 一个key 区分（key 不会作为prop传给组件）

    const listItems = numbers.map((number, index) => {
        return <li key={index}>{number}</li>
    });

## 布尔类型、Null 以及 Undefined 将会忽略
下列字符不可显示

    {undefined||null||false||true}

# Render 
append ele to root

    ReactDOM.render(element, document.getElementById('root'));

## render lifecycle
React 分两个阶段工作：

1. 渲染 阶段会确定需要进行哪些更改，比如 DOM。在此阶段的最后，React 调用 render，然后将结果与上次渲染的结果进行比较。
2. 提交 阶段发生在当 React 应用变化时。（对于 React DOM 来说，会发生在 React 插入，更新及删除 DOM 节点的时候。）在此阶段，React 还会调用 componentDidMount 和 componentDidUpdate 之类的生命周期方法。
提交阶段通常会很快，但渲染过程可能很慢。因此，

当组件的 props 或 state 发生变化时会触发更新。组件更新的生命周期调用顺序如下：https://zh-hans.reactjs.org/docs/react-component.html#getsnapshotbeforeupdate
![](/img/ria/react-lifecycle.png)

### 1.getDerivedStateFromProps

    static getDerivedStateFromProps(nextProps, prevState)

初始挂载、后续更新时都会被调用, 它只有一个目的：让组件在 props 变化时更新 state
1. 它是静态方法，不可用于实例
1. 它应返回一个对象来更新 state，如果返回 null 则不更新。
2. 如果只想在 prop 更改时重新计算某些数据(不改state)，请使用 memoization helper 代替。

Note: getDerivedStateFromProps 不支持async fetch data. 请使用componentDidUpdate+componentDidMount, 或者直接在render中使用
https://github.com/facebook/react/issues/13541

#### memoization
https://zh-hans.reactjs.org/blog/2018/06/07/you-probably-dont-need-derived-state.html#what-about-memoization

仅在输入变化时，重新计算 render 需要使用的值————这个技术叫做 memoization。其实就函数调用缓存

    import memoize from "memoize-one";

    class Example extends Component {
      // state 只需要保存当前的 filter 值：
      state = { filterText: "" };

      // 在 list 或者 filter 变化时，重新运行 filter：
      filter = memoize(
        (list, filterText) => list.filter(item => item.text.includes(filterText))
      );

      handleChange = event => {
        this.setState({ filterText: event.target.value });
      };

      render() {
        // 计算最新的过滤后的 list。
        // 如果和上次 render 参数一样，`memoize-one` 会重复使用上一次的值。
        const filteredList = this.filter(this.props.list, this.state.filterText);

        return (
          <Fragment>
            <input onChange={this.handleChange} value={this.state.filterText} />
            <ul>{filteredList.map(item => <li key={item.id}>{item.text}</li>)}</ul>
          </Fragment>
        );
      }
    }

### 2.shouldComponentUpdate() yes/no
当 props 或 state 发生变化时，shouldComponentUpdate() 会在渲染执行之前被调用. 默认true

    shouldComponentUpdate(nextProps, nextState) {
        console.log('shouldComponentUpdate',nextState, this.state)
        if(nextState.a===3){
            return false
        }
        return true;
    }

返回 false，则不会调用 UNSAFE_componentWillUpdate()，render() 和 componentDidUpdate()
一般，你应该考虑使用内置的 PureComponent 组件，而不是手动编写

### 3.render()
返回Dom

### 4.getSnapshotBeforeUpdate
1. 在最近一次渲染输出（提交到 DOM 节点）之前调用。它使得组件能在发生更改之前从 DOM 中捕获一些信息（例如，滚动位置）。
2. 此生命周期的任何返回值将作为参数传递给 componentDidUpdate()。
getSnapshotBeforeUpdate() 

    getSnapshotBeforeUpdate(prevProps, prevState) {
        // 我们是否在 list 中添加新的 items ？
        // 捕获滚动​​位置以便我们稍后调整滚动位置。
        if (prevProps.list.length < this.props.list.length) {
          const list = this.listRef.current;
          return list.scrollHeight - list.scrollTop;
        }else{
            return null;
        }
      }

      componentDidUpdate(prevProps, prevState, snapshot) {
        // 如果我们 snapshot 有值，说明我们刚刚添加了新的 items，
        // 调整滚动位置使得这些新 items 不会将旧的 items 推出视图。
        //（这里的 snapshot 是 getSnapshotBeforeUpdate 的返回值）
        if (snapshot !== null) {
          const list = this.listRef.current;
          list.scrollTop = list.scrollHeight - snapshot;
        }
      }


### 5.componentDidMount() or componentDidUpdate()
1. componentDidMount() 里可以直接调用 setState() (注意死循环)。。它将触发额外渲染，但此渲染会发生在浏览器更新屏幕之前。如此保证了即使在 render() 两次调用的情况下，用户也不会看到中间状态
    1. 依赖于 DOM 节点的初始化应该放在这里。如需通过网络请求获取数据，此处是实例化请求的好地方。
1. componentDidUpdate() 可直接调用 setState()(注意死循环)。


## render() 函数的触发
React Ele元素是不可变对象。一旦被创建不可更改。除非用render重新创建, 

    function tick() {
      const element = (
        <div>
          <h1>Hello, world!</h1>
          <h2>It is {new Date().toLocaleTimeString()}.</h2>
        </div>
      );
      ReactDOM.render(element, document.getElementById('root'));
    }

    // 强制用render 更新element
    setInterval(tick, 1000);

其它更新方式(原理都是重新执行render 函数)：

    com.forceUpdate
    com.setState({})

## React 只更新需要更新的部分

    render(){
        this.t+='t3'
        const element = <h1 onClick={this.handle}>t:{this.t}</h1>
        console.log(element)
        return element
    }

上面的render 生成的element, 在更新时，只更新变量`{var}`: 

    $$typeof: Symbol(react.element)
    key: null
    props:
        children: Array(3)
            1: "t:"
            2: "t2t3"
    ref: null
    type: "h1"

如果在chrome 直接修改element style或者删除props.children的`"t:"` ，重新render 更新时这些修改都被保留

## render 执行函数，但是不更新
    const [a,setA] = useState(0);
    return <h1 onClick={e=>{ setA(1) }} >
        a: {a}; 
        {(e=>{console.log('执行但不render');return Math.random()})()}
    </h1> 

## render 中子树卸载
由于子树在`a>=2` 会被卸载，如果对div 的background 临时做的修改会被清理, 在`a>5` 时不会再看到这个background

    {(state.a<2 ||state.a>5) &&( <div>{state.a}</div>)}

## render 触发优化
### 虚拟化长列表
如果你的应用渲染了长列表（上百甚至上千的数据），我们推荐使用“虚拟滚动”技术。这项技术会在有限的时间内仅渲染有限的内容.

1. react-window 和 react-virtualized 是热门的虚拟滚动库。 它们提供了多种可复用的组件，用于展示列表、网格和表格数据

### 虚拟DOM
React 只更新改变了的 DOM 节点. 那什么时候触发render 呢？
答案是当一个组件的 props 或 state 变更， 通过shouldComponentUpdate 判断是否触发render

其默认实现总是返回 true(即使prop/state 并没有真的变`setState({})`)：

    shouldComponentUpdate(nextProps, nextState) {
        return true;
    }

### shouldComponentUpdate与React.PureComponent
你可以改写 shouldComponentUpdate:

    shouldComponentUpdate(nextProps, nextState) {
        if(nextState.a==this.state.a){
            return false
        }
        return true;
    }

在大部分情况下，你可以继承 React.PureComponent 以代替手写 shouldComponentUpdate()。它用当前与之前 props 和 state 的浅比较覆写了 shouldComponentUpdate() 的实现。

### immutable不可变数据作为props/state
如果使用 React.PureComponent， 下面的words 变量没有被替换，导致不更新

    const words = this.state.words;
    words.push('marklar');
    this.setState({words: words});

好的做法是，不要改变原来的变量words, 而是生成新的words

    this.setState(state => ({
        words: state.words.concat(['marklar'])
        //或者 
        words: [...state.words, 'marklar'],
    }));

# hook lifecycle执行顺序

    const[a,setA] = useState(0)
    console.log('1!')
    useEffect(()=>{
        console.log('3!')
    },[a])
    return <h1 onClick={e=>{ setA(1) }}>
        {(e=>console.log('2!'))()}
    </h1>

# Portal  
Portal 提供了一种将子节点渲染到存在于父组件以外的 DOM 节点的优秀的方案。

    ReactDOM.createPortal(child, container)

第一个参数（child）是任何可渲染的 React 子元素，例如一个元素，字符串或 fragment。第二个参数（container）是一个 DOM 元素。

## 通过 Portal 进行事件冒泡
通过 Portal ，父Dom可以捕获到不是本Dom 的事件冒泡

假设存在如下 HTML 结构：

    <div id="app-root"></div>
    <div id="modal-root"></div>

在 `#app-root` 里的 Parent 组件能够捕获到未被捕获的从兄弟节点 `#modal-root` 冒泡上来的事件。

    // 在 DOM 中有两个容器是兄弟级 （siblings）
    const appRoot = document.getElementById('app-root');
    const modalRoot = document.getElementById('modal-root');
    
    class Modal extends React.Component {
      constructor(props) {
        super(props);
        this.el = document.createElement('div');
      }
    
      componentDidMount() {
        modalRoot.appendChild(this.el);
      }
    
      componentWillUnmount() {
        modalRoot.removeChild(this.el);
      }
    
      render() {
        return ReactDOM.createPortal(
          this.props.children,
          this.el,
        );
      }
    }
    
    class Parent extends React.Component {
      constructor(props) {
        super(props);
        this.state = {clicks: 0};
        this.handleClick = this.handleClick.bind(this);
      }
    
      handleClick() {
        // 当子元素modal里的按钮被点击时触发， 即使这个按钮在 DOM 中不是直接关联的后代
        this.setState(state => ({
          clicks: state.clicks + 1
        }));
      }
    
      render() {
        return (
          <div onClick={this.handleClick}>
            <p>Number of clicks: {this.state.clicks}</p>
            <p>
              Open up the browser DevTools to observe that the button is not a child of the div with the onClick handler.
            </p>
            <Modal>
              <Child />
            </Modal>
          </div>
        );
      }
    }
    
    function Child() {
      // 这个按钮的点击事件会冒泡到父元素
      // 因为这里没有定义 'onClick' 属性
      return (
        <div className="modal">
          <button>Click</button>
        </div>
      );
    }
    
    ReactDOM.render(<Parent />, appRoot);



# Refer
1. https://zh-hans.reactjs.org/docs/jsx-in-depth.html