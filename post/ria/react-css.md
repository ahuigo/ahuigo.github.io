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

# 0. React.CSSComponent
todo: https://medium.com/@jviereck/modularise-css-the-react-way-1e817b317b04

    class MyNotification extends React.CSSComponent {
      render() {
        var styleMap = this.mountStyles`
          @media (min-width: 600px) {
            .notification {
              padding: 15px;
            }
          }
          .notification {
            border: 10px solid ${this.props.color};
            padding: 10px;
            color: #333;
          }
          /* ".notification span" is rejected by ModularCSS as it
           * contains a nested CSS selectors. Therefore, need to
           * use a new class name instead. */  
          .notification-hint {
            font-style: italic;
          }`;
        return (
          <div className={styleMap.notification}>
            {this.props.prompt}
            <span className={styleMap.notificationHint}>
              {this.props.hint}
            </span>
          </div>);
      }
    }

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

# 3. CSS modules
> https://medium.com/@pioul/modular-css-with-react-61638ae9ea3e
http://www.ruanyifeng.com/blog/2016/06/css_modules.html
https://blog.pusher.com/css-modules-react/

react 内置webpack 支持了css module. create-react-app 默认支持`App.module.css`， `.module.scss`, `.module.less`

    /* Thumbnail.css */
    .image {
        border-radius: 3px;
    }
    #menu .image {
        border-radius: 3px;
    }

    /* Thumbnail.jsx */
    import styles from './Thumbnail.css';
    console.debug(styles)
    render() { return (<img id={styles.menu} className={styles.image}/>) }

subclass 正确用法是 global

    //error
    .menu a:.active { background-color: #3887be; color: #ffffff; }
    //success
    .menu a:global(.active) { background-color: #3887be; color: #ffffff; }

composes: 对于样式复用，CSS Modules 只提供了唯一的方式来处理：composes 组合

    /* components/Button.css */
    .base { /* 所有通用的样式 */ }

    .normal {
      composes: base;
      /* normal 其它样式 */
    }

    .disabled {
      composes: base;
      /* disabled 其它样式 */
    }

    /* Profile.css */
    .description {
      composes: primaryColor from './Colors.css';
    }

global:

    /* Constants.css – imported in app entry point */
    :global(:root) {
      --primary-color: #333;
    }

    /* Profile.css */
    .description {
      color: var(--primary-color);
    }

local:

    :local(.container) {
       margin: 40px;
       border: 5px dashed pink;
     }
     :local(.content) {
       font-size: 15px;
       text-align: center;
     }

如果不想`.module.css`为扩展名:

    $ npm run eject
    $ vi webpack.config.js file 增加`modules:true`
    {
      loader: require.resolve('css-loader'),
      options: {
        importLoaders: 1,
        modules: true,
        localIdentName: "[name]__[local]___[hash:base64:5]"  
      },
    }

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

-> CSS :

    ComponentName-root_0 { width: 100%; };

-> classes

    const classes = { root: 'ComponentName-root_0' };

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
