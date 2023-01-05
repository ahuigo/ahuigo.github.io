---
title: react ssr hydrate
date: 2022-12-21
private: true
---
# react ssr hydrate
通常, CSR环境中我们渲染组件会使用：

    ReactDOM.render(element, container[, callback])

但是在SSR 环境下，我们会先用`ReactDOMServer.renderToString()/renderToStaticMarkup()` to render components to static markup(html).
再用 hydrate 复用static markup(html), 并加上事件(attach event listeners)

    ReactDOM.hydrate(element, container[, callback])
    // 新的
    const root = ReactDOM.hydrateRoot(container, <App name="Saeloun blog" />);

https://blog.saeloun.com/2021/12/16/hydration.html
>This process of rendering our components and attaching event handlers is known as “hydration”.
