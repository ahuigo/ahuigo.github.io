---
title: How to set up React, webpack, and Babel 7 from scratch
date: 2019-05-12
---
# How to set up React, webpack, and Babel
> 本文参考的是：How to set up React, webpack, and Babel 7 from scrath
https://www.valentinog.com/blog/babel/

## Create react app
create-react-app 内置了webpack. 可以查看到：

     vi node_modules/react-scripts/config/webpack.config.js

如果想回退到原生的webpack :

    npm run reject

# install
## install webpack
Let’s install it by running:

    npm i webpack --save-dev
    npm i webpack-cli --save-dev

Next up add the webpackcommand inside package.json:

    "scripts": {
        "build": "webpack --mode production"
        "start": "webpack-dev-server --open --mode development",
    }

## install babel 
here:
1. `babel preset env`: for compiling Javascript `ES6 code` down to ES5 (please note that babel-preset-es2015 is now deprecated)
2. `babel preset react` for compiling `JSX and other stuff` down to Javascript

so install:

    npm i @babel/core babel-loader @babel/preset-env @babel/preset-react --save-dev

Create a new file named `.babelrc` 

    {
    "presets": ["@babel/preset-env", "@babel/preset-react"]
    }

Create a file named `webpack.config.js` and fill it like the following:

    module.exports = {
      module: {
        rules: [
          {
            test: /\.(js|jsx)$/,
            exclude: /node_modules/,
            use: {
              loader: "babel-loader"
            }
          }
        ]
      }
    };

## install react and props

    npm i react react-dom
    npm i prop-types --save-dev

    mkdir -p src/js/components/{container,presentational}

# write jsx
## write compoent with prop types
index.js 

    $ vi src/index.js
    import FormContainer from "./js/components/container/FormContainer.jsx";
    const wrapper = document.getElementById("create-article-form");
    wrapper ? ReactDOM.render(<FormContainer />, wrapper) : false;

FormContainer.jsx

    $ vi "./js/components/container/FormContainer.jsx"
    import React, { Component } from "react";
    import ReactDOM from "react-dom";
    import Input from "../presentational/Input.jsx";
    .....
    export default FormContainer;

Input.jsx

    $ cat src/js/components/presentational/Input.jsx
    import React from "react";
    import PropTypes from "prop-types";
    const Input = ({ label, text, type, id, value, handleChange }) => (
      <div className="form-group">
        <label htmlFor={label}>{text}</label>
        <input
          type={type}
          className="form-control"
          id={id}
          value={value}
          onChange={handleChange}
          required
        />
      </div>
    );
    Input.propTypes = {
      label: PropTypes.string.isRequired,
      text: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
      id: PropTypes.string.isRequired,
      value: PropTypes.string.isRequired,
      handleChange: PropTypes.func.isRequired
    };
    export default Input;


## build react
    $ npm run build
    generat.... dist/main.js

# the HTML webpack plugin
The resulting bundle will be placed inside a script tag.

    npm i html-webpack-plugin html-loader --save-dev

edit webpack.config.conf

    const HtmlWebPackPlugin = require("html-webpack-plugin");
    module.exports = {
      module: {
        rules: [
          {
            test: /\.(js|jsx)$/,
            exclude: /node_modules/,
            use: {
              loader: "babel-loader"
            }
          },
          {
            test: /\.html$/,
            use: [
              {
                loader: "html-loader"
              }
            ]
          }
        ]
      },
      plugins: [
        new HtmlWebPackPlugin({
          template: "./src/index.html",
          filename: "./index.html"
        })
      ]


With webpack html-loader,
 there’s no need to include your Javascript inside the HTML file: the bundle will be automatically injected into the page.

    $ npm run build
    gen.... dist/main.js
    gen.... dist/index.html