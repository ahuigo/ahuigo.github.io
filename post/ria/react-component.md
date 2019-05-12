---
title: React Component
date: 2019-05-02
private:
---
# React Component
> 参考ruanyifeng: http://www.ruanyifeng.com/blog/2015/03/react.html

# props component
组件类的第一个字母必须大写，否则会报错

    var HelloMessage = React.createClass({
      render: function() {
        return <h1>Hello {this.props.name}</h1>;
      }
    });

    ReactDOM.render(
      <HelloMessage name="John" />,
      document.getElementById('example')
    );

添加组件属性，有一个地方需要注意，就是 class 属性需要写成 className ，for 属性需要写成 htmlFor ，这是因为 class 和 for 是 JavaScript 的保留字。

## prop type
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

## Container Components

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
## jsx as value

    var arr = [
        <h1>Hello world!</h1>,
        <h2>React is awesome</h2>,
    ];
    ReactDOM.render(
        <div>{arr}</div>,
        document.getElementById('example')
    );


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
                    <input type="button" value="Focus the text input" onClick={this.handleClick.bind(this)} />
                </div>
            );
        }
    }

也可以通过refs 访问ref
component this.myTextInput.refs.xxx

        <Dialog ref="myTextInput" />
        <Dialog ref={(ref) => this.myTextInput = ref} />
