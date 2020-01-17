---
title: React CreateElement
date: 2019-11-27
private: true
---
# CreateElement

    React.createElement(
        type,
        [props],
        [...children]
    )

    React.createElement(
        'div',
        [props],
        [...children]
    )

# CloneElement
    React.cloneElement(
      element,
      [props],
      [...children]
    )

React.cloneElement() 几乎等同于：

    <element.type {...element.props} {...props}>{children}</element.type>

# AppendCom
appendCom(Com, props) 

    appendCom(Com, props)
    appendCom(<Com {...props}/>)

## 例子
例子1 message.success('msg') 

    function success(msg){ 
        const Com = (props)=>{
            return <div>{props.msg}</div>
        }
        appendCom(Com, {msg})
    }

    function appendCom(Com, props = {}) {
        const div = document.createElement('div');
        document.body.appendChild(div);
        div.onclick = (e) => {
            ReactDOM.unmountComponentAtNode(div);
            div.parentNode.removeChild(div);
        }
        let dom = Com;
        if (typeof Com === 'function') {
            dom = <div onClick={e => {
                ReactDOM.unmountComponentAtNode(div);
                div.parentNode.removeChild(div);
            }}>;
            <Com {...props} />
            </div>
        }
        ReactDOM.render(dom, div);
    }

例子2: https://www.npmjs.com/package/rc-notification 

    notification.notice({
        content: <span>closable</span>,
        duration: null,
        onClose() {
            console.log('closable close');
        },
        closable: true,
        onClick() {
            console.log('clicked!!!');
        },
    });

更多参考核心源码：
https://github.com/ant-design/ant-design/blob/master/components/message/index.tsx
https://github.com/react-component/notification/blob/master/src/Notification.jsx

    Notification.newInstance = function newNotificationInstance(properties, callback) {
      const { getContainer, ...props } = properties || {};
      const div = document.createElement('div');
      if (getContainer) {
        const root = getContainer();
        root.appendChild(div);
      } else {
        document.body.appendChild(div);
      }
      let called = false;
      function ref(notification) {
        if (called) {
          return;
        }
        called = true;
        callback({
          notice(noticeProps) {
            notification.add(noticeProps);
          },
          removeNotice(key) {
            notification.remove(key);
          },
          component: notification,
          destroy() {
            ReactDOM.unmountComponentAtNode(div);
            div.parentNode.removeChild(div);
          },
        });
      }
      ReactDOM.render(<Notification {...props} ref={ref} />, div);
    };

# portal
Portal 提供了一种将子节点渲染到存在于父组件以外的 DOM 节点的优秀的方案。
它的本质就是AppendCom to container
参考：react-com-portal.md