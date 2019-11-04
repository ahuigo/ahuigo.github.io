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

# 1. CSS Stylesheet(global)
css stylesheet:

    .DottedBox {
      margin: 40px;
      border: 5px dotted pink;
    }

    .DottedBox_content {
      font-size: 15px;
      text-align: center;
    }

e.g.

    import 'mapbox-gl/dist/mapbox-gl.css'
    import './DottedBox.css';

    const DottedBox = () => (
    <div className="DottedBox">
        <p className="DottedBox_content">Get started with CSS styling</p>
    </div>
    );

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

# 4. make style(material.io)
    const classes = makeStyles({
        root: {
            width: 500,
            '&:hover':{background:'red'}
        },
    });

# 5. jss （css in js）
> https://segmentfault.com/q/1010000012687223

Material-UI 中默认支持的jss

    import { withStyles } from 'material-ui/styles';
    const styles = { root: { width: '100%' } };
    export default withStyles(styles)(MyComponent);

withStyles(stypes) 步骤的完整代码是：withStyles(stypes)(Component) ：

    return (Component) => (props) => (<Component {...props} classes={classes} />);
    <div classNames={`this.props.classes.root`}>

## element inside
Rerfer to:
https://stackoverflow.com/questions/50368417/styling-element-inside-class-material-ui

    shopForm: {
        textAlign : 'center',
        '& input' :{
            width: '60%',
            color:'grey'
        },
    }

so you have to find which element you want to style first and then give style to parent's class.

    <Grid item lg={4} className={classes.shopForm} >
        <Field name="name" type="text" label="name">

## 伪类支持

    /* Button.jsx */
    var styles = {
      button: {
        backgroundColor: 'black',

        ':hover': {
          backgroundColor: 'grey'
        }
      }
    };

# .scss
https://facebook.github.io/create-react-app/docs/adding-a-sass-stylesheet

webpack:

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
