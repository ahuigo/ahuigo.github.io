---
title: Mapbox 笔记
date: 2019-05-06
private:
---
# Mapbox 笔记
https://docs.mapbox.com/mapbox-gl-js/example/multiple-geometries/
https://codepen.io/ahuigo/pen/ZNEZYo?editors=1000

用 Mapbox 做 3D 地图，这篇文章快说透了 （技术&案例大盘点）
https://zhuanlan.zhihu.com/p/65980510

## start
地图界的 PS — Mapbox Studio 入门指南（中英文教程合集）
https://mp.weixin.qq.com/s?__biz=MzIwNTU1MDM2Mg==&mid=2247487275&idx=1&sn=2d0c75772112761f1006d72c322eda3b

Mapbox 从入门到放弃 - 赵哲直播实录 https://zhuanlan.zhihu.com/p/64352377
https://mp.weixin.qq.com/s?__biz=MzIwNTU1MDM2Mg==&mid=2247486551&idx=2&sn=479b61a806a3460858e5367795a40adb&chksm=972e6a22a059e334826f636ad4ee5f2765bb63edf59f42fb11100fa842e112623390edfdce1a&scene=21#wechat_redirect

## init
    map.resize()

## event

    map.on('click', 'skeleton', function(e) {
        // via point
        var features = map.queryRenderedFeatures(e.point);

        // via reactangle
        var bbox = [
            [e.point.x - 1, e.point.y - 1],
            [e.point.x + 1, e.point.y + 1]
        ];
        var features = map.queryRenderedFeatures(bbox, { layers: ['skeleton'] });
