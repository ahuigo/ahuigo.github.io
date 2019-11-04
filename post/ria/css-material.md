---
title: css react material
date: 2019-05-05
private:
---
# xxxProps
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