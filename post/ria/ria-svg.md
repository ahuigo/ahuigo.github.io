---
title: SVG 语法
date: 2019-05-20
---
# SVG 标签
SVG 代码都放在顶层标签<svg>之中。下面是一个例子

width属性和height属性，指定了 SVG 图像在 HTML 元素中所占据的宽度和高度。除了相对单位，也可以采用绝对单位（单位：像素）。如果不指定这两个属性，SVG 图像默认大小是300像素（宽） x 150像素（高）。

    <svg width="100%" height="100%">
    <circle id="mycircle" cx="50" cy="50" r="50" />
    </svg>

如果只想展示 SVG 图像的一部分，就要指定viewBox属性。
属性的值有四个数字，分别是左上角的横坐标和纵坐标、视口的宽度和高度。上面代码中，SVG 图像是100像素宽 x 100像素高，viewBox属性指定视口从(50, 50)这个点开始。所以，实际看到的是右下角的四分之一圆。 放大了四倍。

    <svg width="100" height="100" viewBox="50 50 50 50">
        <circle id="mycircle" cx="50" cy="50" r="50" />
    </svg>

如果不指定width属性和height属性，只指定viewBox属性，则相当于只给定 SVG 图像的长宽比。这时，SVG 图像的默认大小将等于所在的 HTML 元素的大小。

## circle标签
<circle>标签代表圆形。cx/cy 是偏移


    <svg width="300" height="180">
    <circle cx="30"  cy="50" r="25" />
    <circle cx="90"  cy="50" r="25" class="red" />
    <circle cx="150" cy="50" r="25" class="fancy" />
    </svg>

class属性用来指定对应的 CSS 类。


    .red {
        fill: red;
    }

    .fancy {
        fill: none;
        stroke: black;
        stroke-width: 3pt;
    }

SVG 的 CSS 属性与网页元素有所不同。

    fill：填充色
    stroke：描边色
    stroke-width：边框宽度

## <line>标签

    <svg width="300" height="180">
        <line x1="0" y1="0" x2="200" y2="0" style="stroke:rgb(0,0,0);stroke-width:5" />
    </svg>

## <polyline>标签
<polyline>标签用于绘制一根折线。


    <svg width="300" height="180">
        <polyline points="3,3 30,28 3,53" fill="none" stroke="black" />
    </svg>

points属性指定了每个端点的坐标，横坐标与纵坐标之间与逗号分隔，点与点之间用空格分隔。

## rect标签
rect 标签用于绘制矩形。 width属性和height属性指定了矩形的宽度和高度（单位像素）。

    <svg width="300" height="180">
        <rect x="0" y="0" height="100" width="200" style="stroke: #70d5dd; fill: #dd524b" />
    </svg>

## ellipse标签: 绘制椭圆。

    <svg width="300" height="180">
        <ellipse cx="60" cy="60" ry="40" rx="20" stroke="black" stroke-width="5" fill="silver"/>
    </svg>

cx属性和cy属性，指定了椭圆中心的横坐标和纵坐标（单位像素）；rx属性和ry属性，指定了椭圆横向轴和纵向轴的半径（单位像素）。

## polygon 标签
<polygon>标签用于绘制多边形。

    <svg width="300" height="180">
    <polygon fill="green" stroke="orange" stroke-width="1" points="0,0 100,0 100,100 0,100 0,0"/>
    </svg>

points属性指定了每个端点的坐标，横坐标与纵坐标之间与逗号分隔，点与点之间用空格分隔。

## path 标签
<path>标签用于制路径。

    <svg width="300" height="180">
    <path d="
    M 18,3
    L 46,3
    L 46,40
    L 61,40
    L 32,68
    L 3,40
    L 18,40
    Z
    "></path>
    </svg>

<path>的d属性表示绘制顺序，它的值是一个长字符串，每个字母表示一个绘制动作，后面跟着坐标。

    M：移动到（moveto）
    L：画直线到（lineto）
    A: 
    Z：闭合路径

## text标签

    <svg width="300" height="180">
    <text x="50" y="25">Hello World</text>
    </svg>

<text>的x属性和y属性，表示文本区块基线（baseline）起点的横坐标和纵坐标。文字的样式可以用class或style属性指定。

## use标签: 复制一个形状
<use>标签用于复制一个形状。

    <svg viewBox="0 0 30 10" xmlns="http://www.w3.org/2000/svg">
        <circle id="myCircle" cx="5" cy="5" r="4"/>
        <use href="#myCircle" x="10" y="0" fill="blue" />
        <use href="#myCircle" x="20" y="0" fill="white" stroke="blue" />
    </svg>

<use>的href属性指定所要复制的节点，x属性和y属性是 use 左上角的坐标。另外，还可以指定width和height坐标。

## g标签: Group
g标签用于将多个形状组成一个组（group），方便复用。


    <svg width="300" height="100">
        <g id="myCircle">
            <text x="25" y="20">圆形</text>
            <circle cx="50" cy="50" r="20"/>
        </g>

        <use href="#myCircle" x="100" y="0" fill="blue" />
        <use href="#myCircle" x="200" y="0" fill="white" stroke="blue" />
    </svg>

## defs 标签: 自定义形状
<defs>标签用于自定义形状，它内部的代码不会显示，仅供引用。


    <svg width="300" height="100">
        <defs>
            <g id="myCircle">
            <text x="25" y="20">圆形</text>
            <circle cx="50" cy="50" r="20"/>
            </g>
        </defs>

        <use href="#myCircle" x="0" y="0" />
        <use href="#myCircle" x="100" y="0" fill="blue" />
        <use href="#myCircle" x="200" y="0" fill="white" stroke="blue" />
    </svg>

## pattern 标签
<pattern>标签用于自定义一个形状，该形状可以被引用来平铺一个区域。

    <svg width="500" height="500">
      <defs>
        <pattern id="dots" x="0" y="0" width="100" height="100" patternUnits="userSpaceOnUse">
          <circle fill="#bee9e8" cx="50" cy="50" r="35" />
        </pattern>
      </defs>
      <rect x="0" y="0" width="100%" height="100%" fill="url(#dots)" />
    </svg>

上面代码中，pattern 标签将一个圆形定义为dots模式。patternUnits="userSpaceOnUse"表示<pattern>的宽度和长度是实际的像素值。然后，指定这个模式去填充下面的矩形。

## image 标签
image 标签用于插入图片文件。

    <svg viewBox="0 0 100 100" width="100" height="100">
    <image xlink:href="path/to/image.jpg"
        width="50%" height="50%"/>
    </svg>

## animate 标签
<animate>标签用于产生动画效果。

    <svg width="500px" height="500px">
    <rect x="0" y="0" width="100" height="100" fill="#feac5e">
        <animate attributeName="x" from="0" to="500" dur="2s" repeatCount="indefinite" />
    </rect>
    </svg>

上面代码中，矩形会不断移动，产生动画效果。

<animate>的属性含义如下。

    attributeName：发生动画效果的属性名。
    from：单次动画的初始值。
    to：单次动画的结束值。
    dur：单次动画的持续时间。
    repeatCount：动画的循环模式。

可以在多个属性上面定义动画。

    <animate attributeName="x" from="0" to="500" dur="2s" repeatCount="indefinite" />
    <animate attributeName="width" to="500" dur="2s" repeatCount="indefinite" />

## animateTransform标签
<animate>标签对 CSS 的transform属性不起作用，如果需要变形，就要使用<animateTransform>标签。


    <svg width="500px" height="500px">
      <rect x="250" y="250" width="50" height="50" fill="#4bc0c8">
        <animateTransform attributeName="transform" type="rotate" begin="0s" dur="10s" from="0 200 200" to="360 400 400" repeatCount="indefinite" />
      </rect>
    </svg>

上面代码中，<animateTransform>的效果为旋转（rotate），这时from和to属性值有三个数字，第一个数字是角度值，第二个值和第三个值是旋转中心的坐标。from="0 200 200"表示开始时，角度为0，围绕(200, 200)开始旋转；to="360 400 400"表示结束时，角度为360，围绕(400, 400)旋转。

## transform
translate 是相对的：

    <svg width="350" height="160">
      <g class="layer" transform="translate(60,10)">
        <circle r="5" cx="0"   cy="105" />
        <circle r="5" cx="90"  cy="90"  />
        <circle r="5" cx="180" cy="60"  />
        <circle r="5" cx="270" cy="0"   />

        <g class="y axis">
          <line x1="0" y1="0" x2="0" y2="120" />
          <text x="-40" y="105" dy="5">$10</text>
          <text x="-40" y="0"   dy="5">$80</text>
        </g>
        <g  transform="translate(0, 120)">
          <line x1="0" y1="0" x2="270" y2="0" />
          <text x="-30"   y="20">January 2014</text>
          <text x="240" y="20">April</text>
        </g>
      </g>
    </svg>

# JS 操作
## DOM
svg 可以嵌入到html

    <svg id="mysvg" viewBox="0 0 800 600" preserveAspectRatio="xMidYMid meet" >
    <circle id="mycircle" cx="400" cy="300" r="50" />
    <svg>

然后用js 控制 r

    var mycircle = document.getElementById('mycircle');
    mycircle.addEventListener('click', function(e) {
        console.log('circle clicked - enlarging');
        mycircle.setAttribute('r', 60);
    }, false);

也可以用css 

    circle:hover {
        stroke-width: 5;
        stroke: #090;
        fill: #fff;
    }

## svg dom
### 获取 SVG DOM
使用`<object>、<iframe>、<embed>`标签插入 SVG 文件，可以获取 SVG DOM。


var svgObject = document.getElementById('object').contentDocument;
var svgIframe = document.getElementById('iframe').contentDocument;
var svgEmbed = document.getElementById('embed').getSVGDocument();

注意，如果使用`<img>`标签插入 SVG 文件，就无法获取 SVG DOM。

### 读取 SVG 源码
由于 SVG 文件就是一段 XML 文本，因此可以
使用XMLSerializer实例的serializeToString()方法，获取 SVG 元素的代码。

    var svgString = new XMLSerializer().serializeToString(document.querySelector('svg'));

### SVG 图像转为 Canvas 图像
首先，需要新建一个Image对象，将 SVG 图像指定到该Image对象的src属性。

    var img = new Image();
    var svg = new Blob([svgString], {type: "image/svg+xml;charset=utf-8"});

    var DOMURL = self.URL || self.webkitURL || self;
    var url = DOMURL.createObjectURL(svg);

    img.src = url;

然后，当图像加载完成后，再将它绘制到<canvas>元素。


    img.onload = function () {
        var canvas = document.getElementById('canvas');
        var ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0);
    };



# 参考
- SVG 图像入门：http://www.ruanyifeng.com/blog/2018/08/svg.html