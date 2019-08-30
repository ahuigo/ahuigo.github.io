---
title: React Start
date: 2019-06-23
private:
---
# Ele 表示
以下两种示例代码完全等效：

## JSX

    const element = (
      <h1 className="greeting">
        Hello, world!
      </h1>
    );

## CreateElement
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

## return null
下列字符不可显示

    {undefined||null||false||true}

# Render 
append ele to root

    ReactDOM.render(element, document.getElementById('root'));

## Render 更新
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
    com.setState()

## React 只更新需要更新的部分

    render(){
        this.t+='t3'
        const element = <h1 onClick={this.handle}>t:{this.t}</h1>
        console.log(element)
        return element
    }

上面的render 生成的element: 

    $$typeof: Symbol(react.element)
    key: null
    props:
        children: Array(3)
            1: "t:"
            2: "t2t3"
    ref: null
    type: "h1"

如果在chrome 直接修改element style或者删除props.children的`"t:"` ，重新render 更新时这些修改都被保留

## List and Key(按需更新)
React 是根据key 按需更新的
1. 如果不指定显式的 key 值，那么 React 将默认使用索引用作为列表项目的 key 值。
2. key 会传递信息给 React ，但不会传递给你的组件

e.g.

   <li key={index}>
     {todo.text}
   </li>