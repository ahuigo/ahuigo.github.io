---
layout: page
title:
category: blog
description:
---
# Preface
canvas 与 SVG 之间的一些不同之处。

    Canvas
        依赖分辨率
        不支持事件处理器
        弱的文本渲染能力
        能够以 .png 或 .jpg 格式保存结果图像
        最适合图像密集型的游戏，其中的许多对象会被频繁重绘
    SVG
        不依赖分辨率
        支持事件处理器
        最适合带有大型渲染区域的应用程序（比如谷歌地图）
        复杂度高会减慢渲染速度（任何过度使用 DOM 的应用都不快）
        不适合游戏应用

# Example

    <svg xmlns="http://www.w3.org/2000/svg" version="1.1" height="190">
       <polygon points="110,10 40,180 190,60 10,60 160,180" style="fill:red;stroke:blue;stroke-width: 2px;fill-rule:evenodd;"></polygon>
    </svg>


![ria-html5-svg-1.png](/img/ria-html5-svg-1.png)

# todo
http://www.runoob.com/svg/svg-tutorial.html
