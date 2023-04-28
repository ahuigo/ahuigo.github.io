---
title: css mask
date: 2023-04-08
private: true
---
# css mask
> Refer to: https://www.zhangxinxu.com/wordpress/2017/11/css-css3-mask-masks/#mask-clip

mask 与background 类似，不过他是遮蔽蒙板层. 类似background-position/background-size, 它也有mask-position, mask-size, mask-repeat

## mask-image
    <img class="two" src="https://cdn.glitch.com/04eadd2b-7dd4-43fc-af3d-cff948811986%2Fballoons.jpg?" 
    style="
        -webkit-mask-image: url(https://cdn.glitch.com/04eadd2b-7dd4-43fc-af3d-cff948811986%2Fstar-mask-gradient.png?v=1597757011489);
        object-fit: cover;
        -webkit-mask-size: cover;
    "/>

## mask-origin
mask-origin属性性质上和background-origin类似， 支持属性值如下：

    mask-origin: content-box;
    mask-origin: padding-box;
    mask-origin: border-box;
    mask-origin: fill-box;
    mask-origin: stroke-box;
    mask-origin: view-box;
## mask-position
> 类似background-position

webkit-mask-image 有4个，那么设定 mask-position 也应该有4个才有效

    -webkit-mask-image: linear-gradient(45deg, #000000 25%, rgba(0,0,0,0.2) 25%), linear-gradient(-45deg, #000000 25%, rgba(0,0,0,0.2) 25%), linear-gradient(45deg, rgba(0,0,0,0.2) 75%, #000000 75%), linear-gradient(-45deg, rgba(0,0,0,0.2) 75%, #000000 75%);
    -webkit-mask-size: 20px 20px;
    -webkit-mask-position: 0 0, 0 10px, 10px -10px, -10px 0px;

## mask-composite
表示当同时使用多个图片进行遮罩时候的混合方式。支持属性值包括：

可参考：https://www.canvasapi.cn/CanvasRenderingContext2D/globalCompositeOperation

    -webkit-mask-composite: (Note: 半透明重叠，就做半透明处理)
        source-over
            原图上叠加
        source-in
            原图不要。重叠: 绘制新图，不重叠:不绘制
        source-out
            原图不要. 重叠:不绘制，不重叠:显示新图, 与source-in相反.
        source-atop
            重叠: 显示新图. 不重叠：显示原图。
        destination-*系列 和source-*系列的区别就是动作的主体是新内容还是原内容。
            source-*系列是新内容，而destination-*系列动作主体是元内容。
            例如destination-over表示原内容在上方，也就是新内容在原图的下方绘制。
            虽然Canvas中并没有类似CSS的z-index概念，但是我们还是可以借助destination-over来改变Canvas元素默认的层级关系。
        copy
           只显示新内容。
        xor
           互相重叠的区域是透明的。重叠：不显示，不重叠：显示新图

demo: https://ahuigo.github.io/demo/html/border-color-animation.html