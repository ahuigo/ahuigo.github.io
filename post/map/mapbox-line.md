---
title: mapbox line
date: 2023-07-17
private: true
---
# mapbox line
## highlight

在 Mapbox 中，你可以通过监听 'mouseenter' 和 'mouseleave' 事件来改变线的宽度。假设你已经添加了一个名为 'your-line-layer' 的线层，你可以使用以下代码：

    // 当鼠标进入 'your-line-layer' 层时
    map.on('mouseenter', 'your-line-layer', function () {
        map.setPaintProperty('your-line-layer', 'line-width', 5); // 设置线宽为5
    });

    // 当鼠标离开 'your-line-layer' 层时
    map.on('mouseleave', 'your-line-layer', function () {
        map.setPaintProperty('your-line-layer', 'line-width', 2); // 设置线宽回到2（或者你设置的任何初始值）
    });