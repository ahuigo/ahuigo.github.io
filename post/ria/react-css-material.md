---
title: css react material
date: 2019-05-05
private:
---
# css react material
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
