---
title: React portal
date: 2019-11-25
private: true
---
# React portal
Portal 提供了一种将子节点渲染到存在于父组件以外的 DOM 节点, 并且让事件冒泡到父节点的优秀的方案。

    //import ReactDOM from 'react-dom';
    import ReactDOM from 'react-dom/client';

    const child = <div/>
    // 类似　ReactDOM.render(child, container)
    ReactDOM.createRoot(container).render(child)

注意：portal 作为React.Element 需要内嵌入ReactDOM, render 则不用

    {ReactDOM.createPortal(child, container)}
    ReactDOM.createRoot(container).render(child)

## 实现一个Render 版gmodal
demo: umi-demo/react/gmodal.tsx

## 通过 Portal 进行事件冒泡
demo: umi-demo/react/portal-event.tsx


# Portal 包示例
包地址： https://github.com/ahuigo/react-portal?organization=ahuigo&organization=ahuigo

    <Portal node={document && document.getElementById('san-francisco')}>
        This text is portaled into San Francisco!
    </Portal>

## 自定义onClick onClose ....
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
