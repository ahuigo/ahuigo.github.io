---
title: css color, linear-gradient
date: 2023-02-17
private: true
---
# linear-gradient(渐变)
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
第一个参数可选，可以是angle 顺时针旋转角度。 

默认是0deg是从下到上。90deg是从左到右。

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
        0％-100%: 从red到纯blue
    linear-gradient(90deg, red 0%, 50%, blue 100%)
        表是0％位置是red，50%变成red+blue的混合色，100%位置变成纯blue

    linear-gradient(90deg, red, green, blue)
    linear-gradient(90deg, red 0%,green 50%, blue 100%)
        表是0％位置是red，50%变成green, 100%位置变成blue

refer to:
https://developer.mozilla.org/en-US/docs/Web/CSS/gradient/linear-gradient

## 渐变色起点－终点
渐变起点:

    linear-gradient( 90deg, red 10%,  green 50%, blue 75%)

渐变起点＋终点: 

    // 示例为无渐变
    linear-gradient(
        to right, red 20%,
        orange 20% 40%,
        yellow 40% 60%,
        green 60% 80%,
        blue 80%
    );

## 渐变色中心

    linear-gradient( 90deg, red 10%, green 10%,90%, blue);
        0-10%: red
        10-90%: green 到　green-blue渐变中心混合色
        90%-100%: green-blue渐变中心混合色 到　blue


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

## multiple linear
e.g. https://codepen.io/handsomeone/pen/Kgmbqg?editors=0100

```css
<style>
body {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background-color: #48a;
  background-image:
    linear-gradient(rgba(0, 0, 0, 0) 49px, rgba(0, 0, 0, .1) 49px, rgba(0, 0, 0, .1) 50px), 
    linear-gradient(90deg, rgba(0, 0, 0, 0) 49px, rgba(0, 0, 0, .1) 49px, rgba(0, 0, 0, .1) 50px);
  background-size: 50px 50px, 50px 50px;
  background-position: center center;
}
</style>
```
## 网格 repeating-linear-gradient
网格有3种：
1. 利用repeat background-size: `50%`或`50px`
2. 利用repeating-linear-gradient重复

e.g. repeating-linear-gradient

    background-image: repeating-linear-gradient(red, yellow 10%, green 25%); /*重复4段*/

# radial-gradient
辐射渐变

    radial-gradient( [ <ending-shape> || <size> ]? [ at <position> ]? , <color-stop-list> )  
        ending-shape: circle|ellipse
        size: closest-side|closest-corner|farthest-side|farthest-corner
            closest-side: 渐变结束的环，与渐变中心最近的边相切
            closest-corner: 渐变结束的环，与渐变中心最近的角相交
            farthest-side: 渐变结束的环，与渐变中心最远的边相切
            farthest-corner: 渐变结束的环，与渐变中心最远的角相交(default)
        position: 
            50% 50%; 默认是中心点
            left top;

e.g.

    background: radial-gradient(#e66465, #9198e5);
    background: radial-gradient(closest-side, #3f87a6, #ebf8e1, #f69d3c);
    background: radial-gradient(circle at 100%, #333, #333 50%, #eee 75%, #333 75%);
    background: radial-gradient(ellipse at top, #e66465, transparent),
                radial-gradient(ellipse at bottom, #4d9f0c, transparent);

## 渐变色的起点
    background-image: radial-gradient(cyan 0%, transparent 20%, salmon 40%);
        0-20%: cyan 到 transparent
        20-40%: transparent 到salmon

## 渐变边缘的size
https://www.w3schools.com/css/tryit.asp?filename=trycss3_gradient-radial_size

```css
<style>
#grad1 {
  height: 150px;
  width: 150px;
  background-color: red; /* For browsers that do not support gradients */
  background-image: radial-gradient(closest-side at 60% 55%, red, yellow, black);
}

#grad2 {
  height: 150px;
  width: 150px;
  background-color: red; /* For browsers that do not support gradients */
  background-image: radial-gradient(farthest-side at 60% 55%, red, yellow, black);
}

#grad3 {
  height: 150px;
  width: 150px;
  background-color: red; /* For browsers that do not support gradients */
  background-image: radial-gradient(closest-corner at 60% 55%, red, yellow, black);
}

#grad4 {
  height: 150px;
  width: 150px;
  background-color: red; /* For browsers that do not support gradients */
  background-image: radial-gradient(farthest-corner at 60% 55%, red, yellow, black);
}
</style>            
```

## 重复激变
    #grad1 {
        height: 150px;
        width: 200px;
        background-color: red; /* For browsers that do not support gradients */
        background-image: repeating-radial-gradient(red, yellow 10%, green 15%);
    }


# conic-gradient
旋转渐变
## syntax
    conic-gradient([from angle] [at position,] color [degree], color [degree], ...);
        angle: 定义顺时针方向的渐变初始角（默认0点位置）
            1turn == 3.1415926rad = 360deg = 400grad
        position: 定义旋转中心, 默认是50%,50%

    conic-gradient(red, orange, yellow, green, blue);
    conic-gradient(from 0.25turn at 50% 30%, #f69d3c, 10deg, #3f87a6, 350deg, #ebf8e1);
    conic-gradient(from 3.1416rad at 10% 50%, #e66465, #9198e5);
    conic-gradient(red 6deg, orange 6deg 18deg, yellow 18deg 45deg,   green 45deg 110deg, blue 110deg 200deg, purple 200deg);

## 渐变中心

    conic-gradient(red .1turn, 0.2turn, blue 0.9turn)
        0-10%: red
        10-20%: red 渐变成red+blue的混合色（变化中心点）
        20-90%: 渐变成blue
        90%-: 纯blue

## 网格
利用background-size:

    background: conic-gradient(#fff 90deg, #000 0.25turn 0.5turn, #fff 0.5turn 0.75turn, #000 0.75turn);
    width: 100px;
    background-size: 50% 50%;
    height: 100px;
