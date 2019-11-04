---
title: css react material
date: 2019-05-05
private:
---
# css react material
material css 原则：
https://material-ui.com/zh/guides/api/#spread
1. className属性应用于根

## nested selector
实现`.root p span`

    const useStyles = makeStyles({
      root: {
        padding: 16,
        color: 'red',
        '& p': {
          color: 'green',
          '& span': {
            color: 'blue'
          }
        }
      },
    });

## 属性的样式

    '&$checked': { color: green[500], },


# props

## 子组件的样式
material 遵守：
1. 他们自己的`xxxProps`属性，例如，在内部使用input的组件上公开`inputProps`和`InputProps`属性。
2. 他们自己的xxxComponent属性，用于执行组件注入。
3. 当用户可能需要执行命令性操作时，他们自己的`xxxRef`属性， 例如，公开`inputRef`属性以访问input组件上的native input。

## inputProps
可以使用 inputProps (和 inputProps, InputLabelProps 属性) 来控制原生组件的属性。

可以直接传对象或者回调函数

    const useStylesReddit = makeStyles(theme => ({
      root: {
        border: '1px solid #e2e2e1',
        overflow: 'hidden',
        borderRadius: 4,
        backgroundColor: '#fcfcfb',
        transition: theme.transitions.create(['border-color', 'box-shadow']),
        '&:hover': {
          backgroundColor: '#fff',
        },
        '&$focused': {
          backgroundColor: '#fff',
          boxShadow: `${fade(theme.palette.primary.main, 0.25)} 0 0 0 2px`,
          borderColor: theme.palette.primary.main,
        },
      },
      focused: {},
    }));

    function RedditTextField(props) {
      const classes = useStylesReddit();

      return <TextField InputProps={{ classes, disableUnderline: true }} {...props} />;
    }

还有:

    SelectProps={{ native: true, className: "space-bot", style: { color: 'white', border: '1px white solid', background: 'rgb(0,0,0,0)' } }}

## xxxProps
可以使用 inputProps (和 inputProps, InputLabelProps 属性) 来控制原生组件的属性。

可以直接传对象或者回调函数

    const useStylesReddit = makeStyles(theme => ({
      root: {
        border: '1px solid #e2e2e1',
        overflow: 'hidden',
        borderRadius: 4,
        backgroundColor: '#fcfcfb',
        transition: theme.transitions.create(['border-color', 'box-shadow']),
        '&:hover': {
          backgroundColor: '#fff',
        },
        '&$focused': {
          backgroundColor: '#fff',
          boxShadow: `${fade(theme.palette.primary.main, 0.25)} 0 0 0 2px`,
          borderColor: theme.palette.primary.main,
        },
      },
      focused: {},
    }));

    function RedditTextField(props) {
      const classes = useStylesReddit();

      return <TextField InputProps={{ classes, disableUnderline: true }} {...props} />;
    }

还有:

    SelectProps={{ native: true, className: "space-bot", style: { color: 'white', border: '1px white solid', background: 'rgb(0,0,0,0)' } }}

# Material breakpoints
vi node_modules/@material-ui/core/styles/createBreakpoints.js

    values = _breakpoints$values === void 0 ? {
        xs: 0,
        sm: 600,
        md: 960,
        lg: 1280,
        xl: 1920
    } : _breakpoints$values,

## Drawer
    const sidebarStyle = theme => ({
        drawerPaper: {
            width: drawerWidth,
            [theme.breakpoints.up('lg')]: {
                width: drawerWidth,
                position: 'fixed',
                height: '100%'
            },

    <Drawer
        anchor="left"
        <!-- variant="temporary" -->
        variant="permanent"
        open={props.open}
        classes={{
            paper:classes.drawerPaper
        }}
    >

## Hidden
https://material-ui.com/zh/components/hidden/

    innerWidth  |xs      sm       md       lg       xl
                |--------|--------|--------|--------|-------->
    width       |   xs   |   sm   |   md   |   lg   |   xl

    smUp        |   show | hide
    mdDown      |                     hide | show