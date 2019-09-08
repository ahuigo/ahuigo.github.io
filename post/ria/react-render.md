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

## render() 函数
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

## render 中子树卸载
由于子树在`a>=2` 会被卸载，如果对div 的background 临时做的修改会被清理, 在`a>5` 时不会再看到这个background

    {(state.a<2 ||state.a>5) &&( <div>{state.a}</div>)}

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