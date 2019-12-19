---
title: css react
date: 2019-05-05
private:
---
# css react
https://codeburst.io/4-four-ways-to-style-react-components-ac6f323da822
https://blog.bitsrc.io/5-ways-to-style-react-components-in-2019-30f1ccc2b5b

根据node_modules/react-scripts/config/webpack.config.js 显示， React 内置webpack 提供了对css/module.css/scss 的支持：

    // style files regexes
    const cssRegex = /\.css$/;
    const cssModuleRegex = /\.module\.css$/;
    const sassRegex = /\.(scss|sass)$/;
    const sassModuleRegex = /\.module\.(scss|sass)$/;

# style.module.css
因为react 内置了css-loader

    npm install css-loader --save-dev
    And add it to loaders in your webpack configs:

    module.exports = {
      module: {
        loaders: [
          { test: /\.css$/, loader: "style-loader!css-loader" },
          // ...
        ]
      }
    };

使用：

    import styles from "./style.module.css";

# 2. inline styling object

    const divStyle = {
      margin: '40px',
      border: '5px solid pink'
    };
    const pStyle = {
      fontSize: '15px',
      textAlign: 'center'
    };
    
    const Box = () => (
      <div style={divStyle}>
        <p style={pStyle}>Get started with inline style</p>
      </div>
    );

# 3. make style(material.io)
    const classes = makeStyles({
        root: {
            width: 500,
            '&:hover':{background:'red'}
        },
    });

# less
config/webpack.config.js 找到sassRegex 后添加

    const lessRegex = /\.less$/;
    const lessModuleRegex = /\.module\.less$/;
    .....
    // Less 解析配置
    {
        test: lessRegex,
        exclude: lessModuleRegex,
        use: getStyleLoaders(
            {
                importLoaders: 2,
                sourceMap: isEnvProduction && shouldUseSourceMap,
            },
            'less-loader'
        ),
        sideEffects: true,
    },
    {
        test: lessModuleRegex,
        use: getStyleLoaders(
            {
                importLoaders: 2,
                sourceMap: isEnvProduction && shouldUseSourceMap,
                modules: true,
                getLocalIdent: getCSSModuleLocalIdent,
            },
            'less-loader'
        )
    },


# .scss
https://facebook.github.io/create-react-app/docs/adding-a-sass-stylesheet

    npm run eject 

config/webpack.config.js

    module: {
        loaders: [
            {test: /\.scss$/, loaders: ["style", "css", "sass"]},
            {test: /\.css$/, loader: ExtractTextPlugin.extract("style-loader", "css-loader")},
            {test   : /\.woff|\.woff2|\.svg|.eot|\.ttf|\.png/, loader : 'url?prefix=font/&limit=10000&name=/assets/fonts/[name].[ext]'
        }
    ]

card.scss:

    .layout {
        img {
            display: block;
            max-width: 372px;
            max-height: 372px;
            height: auto;
            width: auto;
        }
    }

    .card {
        width: 370px;
        height: 550px;
    }

card.jsx

    import React, { Component } from 'react';
    import classes from './Card.scss';

    export class Card extends Component {

        render () {
            return (
                <div className={`${classes.layout} col`}>
                    <div className={`${classes.card} card`}>
                        <div className="card-image">
                            <ProviderImage />
                        </div>
                    </div>
                </div>
            );
        }
    }

    export default Card;
