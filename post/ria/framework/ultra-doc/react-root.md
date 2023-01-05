---
title: react root api
date: 2022-12-21
private: true
---
# react root
> https://blog.saeloun.com/2021/07/15/react-18-adds-new-root-api.html

旧方法

    import ReactDOM from 'react-dom';
    import App from 'App';

    const container = document.getElementById('root');

    //Initial render
    ReactDOM.render(<App name="Saeloun blog" />, container);

    // During an update, React would access the root of the DOM element
    ReactDOM.render(<App name="Saeloun testimonials" />, container);

新方法createRoot,　可以复用container

    import ReactDOM from "react-dom";
    import App from 'App';

    const container = document.getElementById('root');

    // Create a root.
    const root = ReactDOM.createRoot(container);

    // Initial render
    root.render(<App name="Saeloun blog" />);

    // During an update, there is no need to pass the container again
    root.render(<App name="Saeloun testimonials" />);

在新的root api中
In the new root API, hydrate is moved to hydrateRoot API as below -


    import ReactDOM from 'react-dom';
    import App from 'App';

    const container = document.getElementById('root');

    // Create and render a root with hydration.
    const root = ReactDOM.hydrateRoot(container, <App name="Saeloun blog" />);
