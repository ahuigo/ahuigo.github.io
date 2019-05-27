---
title: 3d WebGL
date: 2019-05-25
private:
---
# WebGL & three.js
1. WebGL 太底层了，要学习的东西很多, 需要自己画点、线、光线、视角转动处理...。
2. three.js 是对webGL 库，类似jquery, 主要是封装了底层复杂的数据结构、render 细节。但是门槛也挺高, 要自己加载模型、调光

可参考:
1. three.js 现学现卖： https://aotu.io/notes/2017/08/28/getting-started-with-threejs/index.html
2. webgl 指南: http://taobaofed.org/blog/2015/12/21/webgl-handbook/

也可以用更高层的3d/2d 库
- mapbox 比three.js 更上层, 基于webGL 实现了3d/2d 地图可视化库。
- idEditor 是基于SVG 的3d 地图可视化库. 它与mapbox 来自同一家公司
- ThingJs 比three.js 更上层（它是loT 界的mapbox），不关心渲染、光线、mesh 的概念。封装了事件、移动、放大缩小、着色、勾边

相关可视化案例：
http://minedata.com.cn/case
https://parallel.co.uk/ 基于mapboxGL

