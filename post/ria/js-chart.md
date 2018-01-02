---
layout: page
title:
category: blog
description:
---
# Preface
http://socialcompare.com/en/comparison/javascript-graphs-and-charts-libraries

# chartjs
http://www.chartjs.org/docs/#line-chart-example-usage

1. canvas 必须指定宽高
2. 必须是window 中的dom
3. 以下几种都可以

    ctx = $('#id')
    ctx = $('#id')[0]
    ctx = $('#id')[0].getContext('2d')
    new chart(ctx, options);

example

    var data = [];
    for(var i in list){
        var item = {x:moment(list[i].rettime) ,y:parseInt(list[i][key])}
        data.push(item);
    }
    var config = {
        type: 'line',
        data: {
            datasets: [{
                label: 'xtitle',
                data: data
            }]
        },
        options: {
            scales: {
                xAxes: [{
                    type: 'time',
                    position: 'bottom'
                }]
            }
        }
    };

    var $ctx = $('<canvas width="400" height="200"></canvas>');
    container.append($ctx);
    new Chart($ctx, config);

## title
ytitle (> 2.0)

    options = {
      scales: {
        yAxes: [{
          scaleLabel: {
            display: true,
            labelString: 'probability'
          }
        }]
    }

# canvasjs
http://canvasjs.com/javascript-charts/

# echarts:
Canvas by baidu, 对手机支持不好
http://echarts.baidu.com/doc/example/line1.html

# D3
SVG 定制性更强，但也更复杂

# highcharts
[hicharts](/p/ria-chart-highcharts)
