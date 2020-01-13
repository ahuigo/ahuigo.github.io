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


# geom

    // 柱形
    <Geom type="interval"/>
    // 面积
    <Geom type="area"/>

柱的大小：

    <Geom type="interval" size={10}/>


# 轴
## 横轴
指定轴的数据是时间、还是线性... lineNear vs time

    scale = {
        year: {
            type: "linear",
            tickInterval: 50
        }

        startDate: {
            type: 'time',
            tickCount: 8,
            mask: 'YYYY-MM',
        },
    }

## 纵轴
给纵轴数据值加 label 单位k, 或者其它（`%`,`km`...）

    <Axis
        name="value"
        label={{
            formatter: val => {
            return (val / 10000).toFixed(1) + "k";
            }
        }}
    />

# 各元素
## yAxis 名
聚合轴名

    const scale = {
        type: {
            formatter: k => {
                return { aveExecutionTime: '执行时长', aveQueueWaitTime: '排队时长' }[k];
            }
        },
        price:{
            alias: '价格'
        }
    };

### Label
Label 一般用于圆饼图标签

        <Geom
            type="intervalStack"
            position="percent"
            tooltip={[
              "item*percent",
              (item, percent) => {
                percent = percent * 100 + "%";
                return {
                  name: item,
                  value: percent
                };
              }
            ]}
          >
            <Label
              content="percent"
              formatter={(val, item) => {
                return item.point.item + ": " + val;
              }}
            />
          </Geom>

## Axis
Axis 是不分纵横的。

    <Axis name="year" title/>
    <Axis name="value" title/>
    <Geom type="areaStack" position="year*value" />


### Axis label
>api: https://bizcharts.net/product/bizcharts/category/7/page/26

formatter + offset

    <Axis name="value" label={
        { 
            formatter: val => { return (val / 10000).toFixed(1) + "k"; },
            offset: 12,
            autoRotate: false,
        }
    } />

label textStyle

    label={ offset:200,
       textStyle: {
            fontSize: '22',
            textAlign: 'right',
            fontWeight: 'bold',
        }, 
    }

### Axis title
> title 的object|string|null 与 Axis.label一样
必须和geom 中的一样指定name：

    const scale = {
        country: { alias: '里程' },
    }

    <Axis name="country" title />
    <Geom type="interval" position="country*population" />


### Axis position

     <Axis name="value" position={'right'} />

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

color 取数据field

## Tooltip
https://www.yuque.com/antv/g2-docs/api-tooltip#tg6xkz
https://bizcharts.net/products/bizCharts/demo/detail?id=area-stacked&selectedKey=%E7%82%B9%E5%9B%BE
悬浮提示

    <Tooltip crosshairs={{ type: "cross" }} />

### tooltip format
https://bizcharts.net/products/bizCharts/api/geom

    <Geom
    tooltip={['sales*city', (sales, city)=>{
        return {
        name:'xxx',
        value:city + ':' + sales
        }
    }]}

### tooltip value format

    // year*value
    const scale = {
      value: {
        alias: "价格",
        formatter: function(val) {
          return "$" + val;
        }
      },
      year: {
        range: [0, 1]
      }
    };

## Legend 图例
多条线fold/或多线, 它是图例
https://bizcharts.net/products/bizCharts/demo/detail?id=area-stacked&selectedKey=%E7%82%B9%E5%9B%BE

    <Legend />