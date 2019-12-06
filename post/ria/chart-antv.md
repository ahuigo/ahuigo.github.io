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

    <Axis name="value" label={
        { formatter: val => { return (val / 10000).toFixed(1) + "k"; } }
    } />

先map 后fold

    dv.transform({
        type: 'map',
        callback(row) {
            row.ave_execution_time /= 3600;
            row.ave_queue_wait_time /= 3600;
            return row;
        }
    });
    dv.transform({
        type: 'fold',
        fields: ['ave_execution_time', 'ave_queue_wait_time'],
        key: 'type',
        value: 'value',
    })

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