---
title: React Start
date: 2019-06-23
---
# React Runtime
React 运行时，需要引入运行时

## CDN runtime
阮一峰的demo 中的例子: React + ReactDom + babel

    <head>
        <meta charset="UTF-8" />
        <script src="../build/react.development.js"></script>
        <script src="../build/react-dom.development.js"></script>
        <script src="../build/babel.min.js"></script>
    </head>
    <body>
        <div id="example"></div>
        <script type="text/babel">
        ReactDOM.render(
            <h1>Hello, world!</h1>,
            document.getElementById('example')
        );
        </script>
    </body>

## create-react-app
$ cnpm install -g create-react-app
$ create-react-app my-app
$ cd my-app/
$ npm start

可以看到创建的public/index.html 会调用`src/index.js`:

    import React from 'react';
    import ReactDOM from 'react-dom';
    ReactDOM.render(<App />, document.getElementById('root'));

