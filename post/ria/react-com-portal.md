---
title: React portal
date: 2019-11-25
private: true
---
# React portal
Portal 提供了一种将子节点渲染到存在于父组件以外的 DOM 节点的优秀的方案。

    ReactDOM.createPortal(child, container)

第一个参数（child）是任何可渲染的 React 子元素，例如一个元素，字符串或 fragment。第二个参数（container）是一个 DOM 元素。

## 实现dialog

    import React from 'react';
    import ReactDOM from 'react-dom';

    export default class BodyEnd extends React.Component {

        constructor(props) {
            super(props);
            this.el = document.createElement('div');
            this.el.style.display = 'contents'; // The <div> is a necessary container for our content, but it should not affect our layout. Only works in some browsers, but generally doesn't matter since this is at the end anyway. Feel free to delete this line.
        }

        componentDidMount() {
            document.body.appendChild(this.el);
        }

        componentWillUnmount() {
            document.body.removeChild(this.el);
        }

        render() {
            return ReactDOM.createPortal(
                this.props.children,
                this.el,
            );
        }
    }

使用：

    <BodyEnd>sth. </BodyEnd>

### 第三方实现的portal+close
Refer: https://www.npmjs.com/package/react-portal

    import { PortalWithState } from 'react-portal';
 
    <PortalWithState closeOnOutsideClick closeOnEsc>
    {({ openPortal, closePortal, isOpen, portal }) => (
        <React.Fragment>
        <button onClick={openPortal}>
            Open Portal
        </button>
        {portal(
            <p>
            This is more advanced Portal. It handles its own state.{' '}
            <button onClick={closePortal}>Close me!</button>, hit ESC or
            click outside of me.
            </p>
        )}
        </React.Fragment>
    )}
    </PortalWithState>

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
