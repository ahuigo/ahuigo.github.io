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