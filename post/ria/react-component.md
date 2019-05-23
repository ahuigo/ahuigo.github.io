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


## props type
props 属性在react 必须是只读的

    var MyTitle = React.createClass({
      propTypes: {
        title: React.PropTypes.string.isRequired,
      },

      render: function() {
         return <h1> {this.props.title} </h1>;
       }
    });

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

## props children
    var NotesList = React.createClass({
      render: function() {
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
    });

    ReactDOM.render(
      <NotesList>
        <span>hello</span>
        <span>world</span>
      </NotesList>,
      document.body
    );

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

# baseComponent

    export default (ComposedComponent) => {
      class MyComponent extends React.Component {
        constructor(props, state) {
          super(props, state);
          this.state = {
            val: ''
          };
        }
                    value: this.state[name],
            requestChange: (value) => {
                this.setState({[name]: value})
            }
          };
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

## array

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
        <li key={index}>{number}</li>
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


# 参考
- React精髓！一篇全概括(急速) 张不怂 https://juejin.im/post/5cd9752f6fb9a03247157b6d