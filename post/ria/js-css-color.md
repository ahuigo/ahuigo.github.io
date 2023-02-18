---
title: css color, linear-gradient
date: 2023-02-17
private: true
---
# linear-gradient
## 语法

    Formal grammar: linear-gradient(  [ <angle> | to <side-or-corner> ,]? <color-stop> [, <color-stop>]+ )
    								  \---------------------------------/ \----------------------------/
    									Definition of the gradient line         List of color stops

    					  where <side-or-corner> = [left | right] || [top | bottom]
    						and <color-stop> = <color> [ <percentage> | <length> ]?
    linear-gradient( 45deg, blue, red );           /* A gradient on 45deg axis starting blue and finishing red */
    linear-gradient( to left top, blue, red);      /* A gradient going from the bottom right to the top left starting blue and
    												  finishing red */
    linear-gradient( 0deg, blue, green 40%, red ); /* A gradient going from the bottom to top, starting blue, being green after 40%
    												  and finishing red */

## angle or to side-or-corner
第一个参数可选，可以是angle 顺时针旋转角度。 默认是0deg是从下到上。90deg是从左到右。

    <style>
        #eg1{
            background: linear-gradient( 90deg, red, blue);
            height:100px;width:100px;
        }
    </style>
    <div id="eg1">e.g. 1</div>

也可以是 `to <side-or-corner>`

    background: linear-gradient( to left top, blue, red)
        //from the bottom right to the top left 

## 控制渐变快慢: color-stop points

    color stop, color stop, color stop, ...

以下等价：

    linear-gradient(90deg, red, blue)
    linear-gradient(90deg, red 0%, blue 100%)
        表是0％位置是red，100%位置变成纯blue
    linear-gradient(90deg, red 0%, 50%, blue 100%)
        表是0％位置是red，50%变成red+blue的混合色，100%位置变成纯blue

    linear-gradient(90deg, red, green, blue)
    linear-gradient(90deg, red 0%,green 50%, blue 100%)
        表是0％位置是red，50%变成green, 100%位置变成blue

refer to:
https://developer.mozilla.org/en-US/docs/Web/CSS/gradient/linear-gradient

## 无渐变
    linear-gradient(
        to right, red 20%,
        orange 20% 40%,
        yellow 40% 60%,
        green 60% 80%,
        blue 80%
    );


## background-clip: text
    background-clip: border-box| padding-box| content-box| text;

这个属性为text，background将只作为文字背景(文字必须透明) 

    <style>
        #eg1{
            background: linear-gradient( to left, blue, red);
            height:100px;
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            width:100px;
        }
    </style>
    <h1 id="eg1">1234567</h1>

## image
e.g. https://codepen.io/handsomeone/pen/Kgmbqg?editors=0100