---
title: React HMR
date: 2019-10-28
private: 
---
# React HMR
https://webpack-gatsby.netlify.com/how-to/set-up-hmr-with-react/

## Install
To use HMR, you'll need the following dependencies:

    npm install --save-dev babel@6.5.2 babel-core@6.13.2 babel-loader@6.2.4 babel-preset-es2015@6.13.2 babel-preset-react@6.11.1 babel-preset-stage-2@6.13.0 css-loader@0.23.1 postcss-loader@0.9.1 react-hot-loader@3.0.0-beta.1 style-loader@0.13.1 webpack@2.1.0-beta.20 webpack-dev-server@2.1.0-beta.0

    npm install --save react@15.3.0 react-dom@15.3.0

## Babel Config
Your .babelrc file should look like the following:

    {
      "presets": [
        ["es2015", {"modules": false}],
        //Webpack understands the native import syntax, and uses it for tree shaking

        "stage-2",
        //Specifies what level of language features to activate.
        //Stage 2 is "draft", 4 is finished, 0 is strawman.
        //See https://tc39.github.io/process-document/

        "react"
        //Transpile React components to JS
      ],
      "plugins": [
        "react-hot-loader/babel"
        //Enables React code to work with HMR.
      ]
    }

## Webpack config
While there's many ways of setting up your Webpack config - via API, via multiple or single config files, etc - here is the basic information you should have available.

    const { resolve } = require('path');
    const webpack = require('webpack');

    module.exports = env => {
      return {
        entry: [
          'react-hot-loader/patch',
          //activate HMR for React

          'webpack-dev-server/client?http://localhost:8080',
          //bundle the client for webpack dev server
          //and connect to the provided endpoint

          'webpack/hot/only-dev-server',
          //bundle the client for hot reloading
          //only- means to only hot reload for successful updates


          './index.js'
          //the entry point of our app
        ],
        output: {
          filename: 'bundle.js',
          //the output bundle

          path: resolve(__dirname, 'dist'),

          publicPath: '/'
          //necessary for HMR to know where to load the hot update chunks
        },

        context: resolve(__dirname, 'src'),

        devtool: 'inline-source-map',

        devServer: {
          hot: true,
          //activate hot reloading

          contentBase: '/dist',
          //match the output path

          publicPath: '/'
          //match the output publicPath
        },

        module: {
          loaders: [
            { test: /\.js$/,
              loaders: [
                'babel',
              ],
              exclude: /node_modules/
            },
            {
              test: /\.css$/,
              loaders: [
                'style',
                'css-loader?modules',
                'postcss-loader',
              ],
            },
          ],
        },

        plugins: [
          new webpack.HotModuleReplacementPlugin(),
          //activates HMR

          new webpack.NamedModulesPlugin(),
          //prints more readable module names in the browser console on HMR updates
        ],
      };
    };

## code

    // ./src/index.js
    import React from 'react';
    import ReactDOM from 'react-dom';

    import { AppContainer } from 'react-hot-loader';
    // AppContainer is a necessary wrapper component for HMR

    import App from './components/App';

    const render = () => {
      ReactDOM.render(
        <AppContainer>
          <App/>
        </AppContainer>,
        document.getElementById('root')
      );
    };

    render();

    // Hot Module Replacement API
    if (module.hot) {
      module.hot.accept('./components/App', render);
    }

## package.json
Package.json

    {
    "scripts" : {
        "start" : "webpack-dev-server --env.dev"
    }
    }