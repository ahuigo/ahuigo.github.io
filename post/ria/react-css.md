---
title: css react
date: 2019-05-05
private:
---
# css react
https://codeburst.io/4-four-ways-to-style-react-components-ac6f323da822

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
