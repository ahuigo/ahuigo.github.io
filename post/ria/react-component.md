---
title: React Component
date: 2019-05-02
private:
---
# React Component
> 参考ruanyifeng: http://www.ruanyifeng.com/blog/2015/03/react.html

# component

## defeine
组件类的第一个字母必须大写，否则会报错. 有两种

function component


    function Welcome (props) {
        return <h1>Hello, {props.name}</h1>;;
    }

      <Welcome name="John" />,

class component

    class Welcome extends React.Component {
        render () {
            return <h1>Hello, {this.props.name}<h1>;
        }
    }
    ReactDOM.render(
      <Welcome name="John" />,
      document.getElementById('example')
    );

添加组件属性，有一个地方需要注意，就是 class 属性需要写成 className ，for 属性需要写成 htmlFor ，这是因为 class 和 for 是 JavaScript 的保留字。

## multiple div
    const App = () => (
    <>
        <p>React 16 can return multiple elements ❤️</p>
        <p>React 16 can return multiple elements ❤️</p>
        <p>React 16 can return multiple elements ❤️</p>
    </>
    );

## props
### props 与render
1. props 的更新, 会导致子组件render, 子组件重新生成 新的Dom . `dom`修改会丢失
1. state 的更新, 会导致本组件render, 本组件只会更新Dom . `dom`修改不会丢失

### props type 只读
props 属性在react 必须是只读的

    var MyTitle = React.createClass({
      propTypes: {
        title: React.PropTypes.string.isRequired,
      },

      render: function() {
         return <h1> {this.props.title} </h1>;
       }
    });

### single props 默认为true

    <Sidebar newprops/>
    <Sidebar newprops="true"/>

### getDefaultProps
此外，getDefaultProps 方法可以用来设置组件属性的默认值。

    var MyTitle = React.createClass({
      getDefaultProps : function () {
        return {
          title : 'Hello World'
        };
      },

      render: function() {
         return <h1> {this.props.title} </h1>;
       }
    });

### props children
    var NotesList = function(props) {
        return (
          <ol>
          {
            React.Children.map(this.props.children, function (child) {
              return <li>{child}</li>;
            })
          }
          </ol>
        );
    }

    ReactDOM.render(
      <NotesList>
        <span>hello</span>
        <span>world</span>
      </NotesList>,
      document.body
    );

### pass component via props

    <Com key=value {...obj} />

as component(with out instantiate)

    const Label = props => <span>{props.children}</span>
    const Button = props => {
        const Inner = props.inner; // Note: variable name _must_ start with a capital letter 
        return <button><Inner>Foo</Inner></button>
    }
    const Page = () => <Button inner={Label} {...obj}/>

as react dom:

    const Label = props => <span>{props.content}</span>
    const Tab = props => <div>{props.content}</div>
    const Page = () => <Tab content={<Label content='Foo' />} />

https://stackoverflow.com/questions/39652686/pass-react-component-as-props

## Container Components(js in jsx)

    const CommentList = props =>
        <ul>
            {props.comments.map(c => (
            <li>{c.body}—{c.author}</li>
            ))}
        </ul>

    render() {
        return <CommentList comments={this.state.comments} />;
        //return React.createElement(CommentList, { comments: this.state.comments })
    }

## 非受控组件
如果在constructor 中没有明确写`this.state ={value:1}` 那下面的组件是非爱控组件
(`setState`or `this.state.name=value+thisforceUpdate`能让它转为受控)

    <input type="text" name={this.state.name} onChange={this.handleChange} />

否则就是受控组件, value 作为input 的唯一数据源

# com example
## slect multiple

    <select multiple={true} value={['B', 'C']}>

# event
    <button onClick={increment}>ADD</button>

    function handleClick (e) {
        e.preventDefault();
        alert('Hello, world!');
    }
     handleInputChange (event) {
        const target = event.target;
        const value = target.type==='checkbox' ? target.checked : target.value;
        const name = target.name;
        this.setState({
            [name]: value
        });
    }

# form
## react select 支持value
不用`<option selected>`:

    <select value="C">
        <option value="A">A</option>
        <option value="B">B</option>
        <option value="C">C</option>
    </select>

defaultValue defaultChecked

    <input type="text" defaultValue="Hello" ref={input => this.input = input} />

# 生命周期
React 为每个状态都提供了两种处理函数，will 函数在进入状态之前调用，did 函数在进入状态之后调用，三种状态共计五种处理函数。

    componentWillMount()
    componentDidMount()
    componentWillUpdate(object nextProps, object nextState)
    componentDidUpdate(object prevProps, object prevState)
    componentWillUnmount()

此外，React 还提供两种特殊状态的处理函数。

    componentWillReceiveProps(object nextProps)：已加载组件收到新的参数时调用
    shouldComponentUpdate(object nextProps, object nextState)：组件判断是否重新渲染时调用

## this
除了构造函数和生命周期钩子函数里会自动绑定this为当前组件外，其他的都不会自动绑定this的指向为当前组件

## null 不会被render
这里 null null不会影响组件生命周期的触发，如componentWillUpdate和componentDidUpdate仍然会被调用

    function LogBtn (props) {
        return null;
    }


## state

1. this.setState()会自动覆盖this.state里相应的属性，并触发render()重新渲染。
2. 状态更新可能是异步的 React可以将多个setState()调用合并成一个调用来提升性能。
   
由于this.props和this.state可能是异步更新的，所以不应该依靠它们的值来计算下一个状态。这种情况下，可以给setState传入一个函数，如：

    this.setState((prevState, props) => ({
        counter: prevState.counter + props.increment
    }));

组件react-demos/demo8

      getInitialState: function() {
        return {liked: false};
      },
      handleClick: function(event) {
        this.setState({liked: !this.state.liked});
      },
      render: function() {
        var text = this.state.liked ? 'like' : 'haven\'t liked';
        return (
          <p onClick={this.handleClick}>
            You {text} this. Click to toggle.
          </p>
        );
      }

# ref
ref Allow you to ref a component or dom node

    class MovieItem extends React.Component {
        handleClick() {
            console.log(this); // component 
            this.myTextInput.focus()
        }
        render() {
            return (
                <div>
                    <input type="text" ref={(ref) => {
                        this.myTextInput = ref; //ref is input dom
                        console.log(this); //this is compoent
                    } } />
                    <input type="button" value="Focus the text input" onClick=cthis.handleClick.bind(this)} />
                </div>
            );
        }
    }

注意，
1. 需要： `this.handleClick.bind(this)` :jsx 中的this.handclick() 是没有unbunded this ,  
2. `this.refs[refName]` 需要在didComponentMount 之后

# BaseComponent

    export default (ComposedComponent) => {
      class MyComponent extends React.Component {
        constructor(props, state) {
          super(props, state);
          this.state = {
            val: ''
          };
        }

        handleState(){
            this.setState({[name]: value})
        }

        render() {
          return (
            <ComposedComponent 
              {...this.props}
              {...this.state} 
              bindTwoWay={this.bindTwoWay.bind(this)}
            />
          }
        }
      }

      return MyComponent
    }

And then you define your component where you need some common features

    import compose from 'path-to-composer';

    class TextBox extends React.Component {
        render() {
            return (
            <div>
                <input valueLink={this.props.bindTwoWay('val')}/>
                <div>You typed: {this.props.val}</div>
            </div>
            )
        }
    }

    export default compose(TextBox)

# jsx element

## single

    const element = <h1>Hello, world</h1>;
    const element = (
        <h1 className="greeting">
            Hello, world!
        </h1>
    );

等同于以下的语句的：

    const elem = React.createElement(
        'h1',
        {className: 'greeting'},
        'Hello, world!'
    );

## array Com

    var arr = [
        <h1>Hello world!</h1>,
        <h2>React is awesome</h2>,
    ];
    ReactDOM.render(
        <div>{arr}</div>,
        document.getElementById('example')
    );

列表render 需要给每个item 一个key 区分（key 不会作为prop传给组件）

    const listItems = numbers.map((number, index) => {
        return <li key={index}>{number}</li>
    });

    return (
      <div>
        {[1,2,3].map(function (n) {
          return (
            <div key={n}>
              <h3>{'With key ' + n}</h3>
              <p>{n}</p>
            </div>
          );
        })}
      </div>
    );

without key: 会报错

        <div>
        {[1,2,3].map(function (n) {
          return ([
            <h3>{'Without flatten ' + n}</h3>, // note the comma
            <p>{n}</p>
          ]);
        })}
      </div>

## jsx as props

    <Article aside={
            <h1>这是一个侧栏</h1>
        }>这是一篇文章</Article>

## wrap logic
    function withRepos (Component) {
      return class WithRepos extends React.Component {
        render () {
          return (
            <Component
              {...this.props}
              {...this.state}
            />
          )
        }
      }
    }

# Hook
https://juejin.im/post/5d478b2d518825673a6ae1b9
我们不再需要调用super(props)，不再需要考虑bind方法或this关键字，也不再需要使用类字段。，我们之前讨论的所有“小”问题都会消失。

## 状态hook
useState只接受一个参数，即状态的初始值。它返回的是一个数组，其中第一项是状态块，第二项是更新该状态的函数。

    const [ loading, setLoading ] = React.useState(true) // 👌
    const [ values, setValue] = React.useState({k1:1}) // 👌
    setValue({...values, k1:2})

## 生命周期方法 useEffect
useEffect使我们能在function组件中执行副作用操作。它有两个参数，一个函数和一个可选数组。函数定义要运行的副作用，(可选的)数组定义何时“重新同步”(或重新运行)effect。

    React.useEffect(() => {
        document.title = `Hello, ${username}`
    }, [username])

上面的代码中，传递给useEffect的函数将在用户名发生更改时运行 同步。
现在，我们如何使用代码中的useEffect Hook来同步repos和fetchRepos API请求?

    function ReposGrid ({ id }) {
      const [ repos, setRepos ] = React.useState([])
      const [ loading, setLoading ] = React.useState(true)
    
      React.useEffect(() => {
        setLoading(true)
    
        fetchRepos(id)
          .then((repos) => {
            setRepos(repos)
            setLoading(false)
          })
      }, [id])
    
      if (loading === true) {
        return <Loading />
      }
    
      return (
        <ul>
          {repos.map(({ name, handle, stars, url }) => (
            <li key={name}>
              <ul>
                <li><a href={url}>{name}</a></li>
                <li>@{handle}</li>
                <li>{stars} stars</li>
              </ul>
            </li>
          ))}
        </ul>
      )
    }

# Error

## double construct
当发生异常时，如果不捕获，就会double construct

    this.undefined.foo

# 参考
- React精髓！一篇全概括(急速) 张不怂 https://juejin.im/post/5cd9752f6fb9a03247157b6d