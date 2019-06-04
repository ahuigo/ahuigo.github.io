---
title: Material
date: 2019-05-20
private:
---
# Material
vi node_modules/@material-ui/core/styles/createBreakpoints.js

    values = _breakpoints$values === void 0 ? {
        xs: 0,
        sm: 600,
        md: 960,
        lg: 1280,
        xl: 1920
    } : _breakpoints$values,



# Drawer
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

# Hidden
https://material-ui.com/zh/components/hidden/

    innerWidth  |xs      sm       md       lg       xl
                |--------|--------|--------|--------|-------->
    width       |   xs   |   sm   |   md   |   lg   |   xl

    smUp        |   show | hide
    mdDown      |                     hide | show