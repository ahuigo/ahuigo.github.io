---
title: css react
date: 2019-05-05
private:
---
# css react
https://codeburst.io/4-four-ways-to-style-react-components-ac6f323da822

# CSS Stylesheet
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

# inline styling object

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

# className
var withStyles:

    import { withStyles } from 'material-ui/styles';

    const styles = {
        root: { backgroundColor: 'red', },
    };

    class MyComponent extends React.Component {
        render () {
            return <div className={this.props.classes.root} />;
        }
    }
    export default withStyles(styles)(MyComponent);

# element inside
    shopForm: {
        textAlign : 'center',
    '& input' :{
        width: '60%',
        color:'grey'
    },
    '& label':{
        fontSize:'15px'
    }

so you have to find which element you want to style first and then give style to parent's class.

    <Grid item lg={4} className={classes.shopForm} >
        <Field name="name" type="text" label="name">

# hover css

    const style = {
        color: '#000000'
        ':hover': {
            color: '#ffffff'
        }
    };

# .scss
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