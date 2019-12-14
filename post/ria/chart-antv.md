---
layout: page
title: antv and bizcharts
category: blog
description:
---
# Antv & bizcharts

# style
## padding
https://bizcharts.net/products/bizCharts/docs/qa 设置padding 解决留白

    <Chart height={window.innerHeight} width={"100%"} height={130} padding={[0, 0, 0, 0]} data={periodDv} scale={scale} forceFit >

# data set

    const ds = new DataSet();
    const dv = ds.createView().source(aveTime);
    dv.transform({
        type: 'fold',
        fields: ['aveExecutionTime', 'aveQueueWaitTime'],
        key: 'type',
        value: 'value',
    });

# 各元素
## yAxis 名
    const scale = {
        type: {
            formatter: k => {
                return { aveExecutionTime: '执行时长', aveQueueWaitTime: '排队时长' }[k];
            }
        },
        startDate: {
            type: 'time',
            tickCount: 8,
            mask: 'YYYY-MM',
        },
    };

## Axis
Axis 是不分纵横的。

    <Axis name="year" title/>
    <Axis name="value" title/>
    <Geom type="areaStack" position="year*value" color="country" />


### Axis label

    <Axis name="value" label={
        { 
            formatter: val => { return (val / 10000).toFixed(1) + "k"; },
            offset: 12,
        }
    } />

### Axis title
必须和geom 中的一样命名country ：

    const scale = {
        country: { alias: '里程' },
    }

    <Axis name="country" title />
    <Geom type="interval" position="country*population" />



## 分组fold
https://bizcharts.net/products/bizCharts/demo/detail?id=g2-clustered-stacked&selectedKey=%E6%A6%82%E8%A7%88
https://codepen.io/ahuigo/pen/jOEMBed?&editable=true

    const ds = new DataSet();
    const dv = ds.createView().source(data);
    dv.transform({
        type: 'map',
        callback(row) {
            row.ave_execution_time /= 3600;
            row.ave_queue_wait_time /= 3600;
            return row;
        }
    }).transform({
        type: 'fold',
        fields: ['ave_execution_time', 'ave_queue_wait_time'],
        key: 'time',
        value: 'value',
    })


### 根据值分类
像这样：
https://bizcharts.net/products/bizCharts/demo/detail?id=area-stacked&selectedKey=%E7%82%B9%E5%9B%BE
https://codepen.io/ahuigo/pen/YzPGZmr

    const data = [
      {
        country: "Asia",
        year: "1750",
        value: 502
      },
      {
        country: "Asia",
        year: "1800",
        value: 635
      },
      {
        country: "Africa",
        year: "1750",
        value: 106
      },
      {
        country: "Africa",
        year: "1800",
        value: 107
      },
    ]
    <Geom type="line" position="year*value" color="country" />



## Tooltip
https://www.yuque.com/antv/g2-docs/api-tooltip#tg6xkz
悬浮提示

    <Tooltip crosshairs={{ type: "line" }} />

### tooltip value format
    // year*value
    const scale = {
      value: {
        alias: "The Share Price in Dollars",
        formatter: function(val) {
          return "$" + val;
        }
      },
      year: {
        range: [0, 1]
      }
    };

## Legend 图例
    <Legend />