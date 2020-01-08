---
title: echart 缩放
date: 2020-01-05
private: 
---
# echart 缩放

    options={
        dataZoom: {
            orient: "vertical", //水平显示
            show: true, //显示滚动条
            start: 0, //起始值为20%
            end: 100,  //结束值为60%
            type: 'inside', //inside 是施放zoom, 默认slider是滚动条zoom
        },
    }