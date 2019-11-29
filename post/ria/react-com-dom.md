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


# 定制一个addCom
message.success('msg')

    function success(msg){ 
        const Com = (props)=>{
            return <div>{props.msg}</div>
        }
        AddCom.addCom(Com, {msg})
    }

    class AddCom {
        static addCom(Com, props={}) {
            const div = document.createElement('div');
            document.body.appendChild(div);
            div.onclick = (e)=>{
                ReactDOM.unmountComponentAtNode(div);
                div.parentNode.removeChild(div);
            }
            // onClick是多余的
            ReactDOM.render(<div onClick={e => {
                ReactDOM.unmountComponentAtNode(div);
                div.parentNode.removeChild(div);
            }}>
                <Com {...props}/>
            </div>, div);
        }
    }

参考核心源码：
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