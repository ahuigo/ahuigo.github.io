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
### props string
可以将字符串字面量赋值给 prop. 如下两个 JSX 表达式是等价的：

    <MyComponent message="hello world" />
    <MyComponent message={'hello world'} />

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


# 参考
- React精髓！一篇全概括(急速) 张不怂 https://juejin.im/post/5cd9752f6fb9a03247157b6d