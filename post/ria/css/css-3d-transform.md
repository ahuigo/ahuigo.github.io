---
title: css transform
date: 2023-03-30
private: true
---
# transform
transform 各变换示例
2d: demo/html/transform.html
3d demo: https://garden.bradwoods.io/notes/css/3d
## rotate
旋转

    transform:
    rotateX(39deg); //围绕x轴方向(水平向右)，顺时旋转39度
    rotateY(39deg); //围绕Y轴(垂直向下)，顺时旋转39度
    rotateZ(39deg); //绕Z轴(面向你的眼睛)，顺时针旋转39度

    rotate3d(x,y,z,angle)	//围绕(x,y,z)轴转动
    rotate(39deg); //绕几何中心(z)，顺时针旋转39度

## translate
平移....

    transform: 
    translateX(15px)  水平右移15px
    translate(xpx, ypx); 右下移动x,ypx
    translateZ(15px)  
    translate3d(xpx, ypx,zpx); 

## scale 放大
    scale(2, 4); 水平扩大两倍, 垂直扩大4倍
    scale(2); == scale(2,2);
    scaleX(2)
    scaleY(2)

## skew 倾斜
> 需要注意的是，这里采用的是笛卡尔坐标系.另外:其中x轴向右(正值)，y轴向下（正值）。

默认原点在中心：`transform-origin: center center;` 沿x轴或y轴旋转指定角度.

    skew(ax)
        point(x, y) -> point(x+y*tan(ax), y)
    skew(ay)
        point(x, y) -> point(x, x*tan(ax)+y)
    skew(ax, ay)
        point(x, y) -> point(x+y*tan(ax), x*tan(ax)+y)
    transform: skewX(ax) skewY(ay); 跟skew(ax, ay) 不一样

围绕中心倾斜

    skew(30deg,20deg) 围绕 X 轴把元素倾斜 30 度，围绕 Y 轴倾斜 20 度。

## matrix
    matrix() 方法把所有 2D 转换方法组合在一起[matrix].
        matrix(1, 0, 0, 1, e, f) -> (1*x+0*y+e, 0*x+1*y+f) -> (x+e, y+f) -> translate(epx, fpx)
        matrix(cosθ,sinθ,-sinθ,cosθ,0,0) -> (x*cosθ-y*sinθ, x*sinθ+y*cosθ) -> rotate(θ);
        matrix(1,tan(θy),tan(θx),1,0,0) -> (x+y*tan(θx), x*tan(θy)+y) -> skew(θxdeg, θydeg);

## mutiple

    transform: rotate(15deg) translate(-20px,0px);
    transform: rotate(15deg) translate(-20,0);
# 3d
## perspective
3d效果有几个要求：

    z平面(屏幕)
    三维元素(实物)
    观察者(人眼)
        perspective 观察者与z平面的距离
        三维元素在观察者后面的部分不会绘制出来，即 z 轴坐标值大于 perspective 属性值的部分。


### 观察者的位置 perspective
perspective: 观察者的z坐标. 
perspective-origin: 观察者x,y坐标（眼睛）

    perspective-origin: center center; /*默认*/
    perspective-origin: top; 
    perspective-origin: 500% 200%;

Note:

    perspective origin:
        is the point in space from where you are looking at the element
    transform origin: 
        sets the point about which you are translating/rotating an object.

透视原理：
![](/img/css/3d/perspective-translateZ.svg)

translate3d/translateZ 和perspective　同时设定才有透视的效果

    // 3d透视: 观察者与z平面视距
    perspective: 12px;
    // 物体与z平面的距离
    transform: translateZ(-12px);

perspective example:

    // refer: https://garden.bradwoods.io/notes/css/3d
    <style>
        .c{
            perspective: 24px;
            margin:100px;
            width: 200px; aspect-ratio: 2/1;
            border: 1px solid red;
        }
        .item{
            transform: translate3d(0px, 0px, -12px);
            background: black;
            width: 100%;height: 100%;
        }
    </style>
    <div class="c">
        <div class="item"></div>
    </div>

### perspective vs perspective();
perspective()用于单个元素独立的三维透视: transform 顺序不一样，透视效果就很不一样（一般不这样做）
一般使用　perspective, 即父容器上的透视属性，创建一个由其所有子元素共享的三维空间;

    perspective: 61px; //on parent element, apply to every child
    transform: rotate3d(1, 1, 1, 89deg) perspective(61px); //on the individual elements

##  transform-style
> 由于这个属性不会被继承，因此必须为元素的所有非叶子子元素设置它。

默认选择平面，旋转、透视时，元素的子元素将不会有 3D 的遮挡、分层关系

    flat
        设置元素的子元素位于该元素的平面中。
    preserve-3d
        指示元素的子元素应位于 3D 空间中。

开启3d分层：

    //https://garden.bradwoods.io/notes/css/3d
    <div id="main" style=" transform-style: preserve-3d; ">
        <div class="grandChild" style="transform: translateZ(20px);"></div>
        <div class="grandChild" style="transform: translateZ(40px);"></div>
        <div class="grandChild" style="transform: translateZ(60px);"></div>
    </div>
