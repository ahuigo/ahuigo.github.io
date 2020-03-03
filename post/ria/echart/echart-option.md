---
title: Echart option
date: 2020-01-21
private: 
---
# Echart option
这里放最常用的option

## xAxis,yAxis
1. type: 支持 time, value, log, category
2. 多个grid 的话，xAxis,yAxis 应该对应提供Array
3. boundaryGap : true, 避免图表出现在边界

demo:

    xAxis: {
        type: 'time',
        splitLine: {
            show: true,
        }
    },
    yAxis: {
        type: 'value',
        boundaryGap: [0, '100%'],
        splitLine: {
            show: false,            
        }
    },

### axisLabel

    xAxis:{
        axisLabel: {show: false},
    }
    yAxis:{
        axisLabel: {show: false},
    }

可以用axisPointer.label 控制label
https://www.echartsjs.com/examples/en/editor.html?c=doc-example/candlestick-axisPointer

    axisPointer: {
        label: {
            formatter: function (params) {
                var seriesValue = (params.seriesData[0] || {}).value;
                return params.value
                + (seriesValue != null
                    ? '\n' + echarts.format.addCommas(seriesValue)
                    : ''
                );
            }
        }
    }

### grid
多个grid时，需要指定
1. gridIndex: xAxis/yAxis 用于哪一个grid, 默认0
2. 提代xAxis的data。也可通过dataset+series.encode.x提供

https://www.echartsjs.com/examples/en/editor.html?c=doc-example/candlestick-axisPointer

    xAxis: [
        { type: 'category', 
            data: data.categoryData,
        },
        {
            type: 'category',
            gridIndex: 1,
            data: data.categoryData,
        }
    ],
    series:[
        {
            name: 'MA30',
            type: 'line',
            data: calculateMA(30, data),
            smooth: true,
            lineStyle: {
                normal: {opacity: 0.5}
            }
        },
        {
            name: 'Volumn',
            type: 'bar',
            xAxisIndex: 1,
            yAxisIndex: 1,
            data: data.volumns
        }]

## series
series 是提供数据的

### series.type

    {
        name: 'Dow-Jones index',
        type: 'candlestick',
    },

type:

    candlestick https://www.echartsjs.com/examples/en/editor.html?c=doc-example/candlestick-axisPointer
    k   https://echarts.apache.org/examples/en/editor.html?c=candlestick-simple
    line
    custom  https://echarts.apache.org/examples/en/editor.html?c=custom-ohlc

#### 自定义type
https://echarts.apache.org/examples/en/editor.html?c=custom-ohlc

    series: [
        {
            name: 'Dow-Jones index',
            type: 'custom',
            renderItem: renderItem,
        }
    ]

rnderItem:

    function renderItem(params, api) {
        var xValue = api.value(0);
        var openPoint = api.coord([xValue, api.value(1)]);
        var closePoint = api.coord([xValue, api.value(2)]);
        var lowPoint = api.coord([xValue, api.value(3)]);
        var highPoint = api.coord([xValue, api.value(4)]);
        var halfWidth = api.size([1, 0])[0] * 0.35;
        var style = api.style({
            stroke: api.visual('color')
        });

        return {
            type: 'group',
            children: [{
                type: 'line',
                shape: {
                    x1: lowPoint[0], y1: lowPoint[1],
                    x2: highPoint[0], y2: highPoint[1]
                },
                style: style
            }, {
                type: 'line',
                shape: {
                    x1: openPoint[0], y1: openPoint[1],
                    x2: openPoint[0] - halfWidth, y2: openPoint[1]
                },
                style: style
            }, ]
        };
    }

### series.data
直接指定：

    data: data.values

通过dataset:

    dataset: {
        // dimensions: ['trade_date', 'close', 'mean', 'code'],
        source: meanData
    },
    series: [
        {
            name: "价格",
            type: "line",
            encode: {
                x: "trade_date",
                y: "close"
            },
        }
    ]

### 指定series的tooltip

    {
        name: 'Dow-Jones index',
        type: 'candlestick',
        data: data.values,
        tooltip: {
            formatter: function (param) {
                param = param[0];
                return [
                    'Date: ' + param.name + '<hr size=1 style="margin: 3px 0">',
                    'Lowest: ' + param.data[2] + '<br/>',
                ].join('');
            }
        }
    },

### 指定grid

    {
        name: 'Volumn',
        type: 'bar',
        xAxisIndex: 1,
        yAxisIndex: 1,
        data: data.volumns
    }

### itemStyle 
itemStyle 内嵌lineStyle 必须放normal

    itemStyle: {
        normal: {
            width: 1.5,
            color: 'blue',
            borderWidth:1,
            lineStyle: {
                type: 'solid',
                color:'orange',
                width:2
            },
        }
    }

#### symbol

    series: [{
        type: "line",
        symbolSize:10,
        // symbol: 'circle',
        // showSymbol:true,
        itemStyle: {
            color: "#FF0000", //symbol color
        },
        lineStyle: {
            color: "blue", //line color
        }
    }]

#### symbol color callback

    itemStyle: {
        color: (item)=>{
            console.log(item.data.name)  
            return item.data.value[1]>0?'red':'green'
        },           
    }, 

## legend

    // series = [{name:'name1'}, {name:'name2'}]
    legend: {
         bottom: 10,
        left: 'left',
        data: ['name1'] //只显示 name1
    },

## tooltip
trigger: 'item','axis','none'

    tooltip: {
        trigger: 'axis',
        axisPointer: {
            type: 'cross',
            label: {
                backgroundColor: '#6a7985'
            }
        }
    },

### tooltip style
    tooltip:{
        backgroundColor: 'rgba(245, 245, 245, 0.8)',
        borderWidth: 10,
        borderColor: '#ccc',
        padding: 10,
        textStyle: {
            color: '#000'
        },
    }

有些属性支持callback, 比如position:
https://www.echartsjs.com/examples/en/editor.html?c=doc-example/candlestick-axisPointer

    // pos 是当前指针的位置
    position: function (pos, params, el, elRect, size) {
        var obj = {top: 10};
        obj[['left', 'right'][+(pos[0] < size.viewSize[0] / 2)]] = 30;
        return obj;
    },

### tooltip.axisPointer
axisPointer 
1. 可显示cross 指针：
2. 也可以多个grid 共用: 此时 `link: {xAxisIndex: 'all'},` 不放在tooltip 内部

demo: https://www.echartsjs.com/examples/en/editor.html?c=doc-example/candlestick-axisPointer

    axisPointer: {
        link: {xAxisIndex: 'all'},
        label: {
            backgroundColor: 'blue'
        }
    },
    tooltip:{
        axisPointer: {
            type: 'cross',
        }
    }

### 自定义format
    tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b} : {c}'
    },

多根线series 共用一个tooltips

    tooltip: {
        trigger: 'axis',
        formatter: function (seriesList) {
            const series0 = seriesList[0]
            let msg = series0.data[series0.dimensionNames[series0.encode.x]] + '<br>'
            // msg += 'add:' + series0.data.add + '<br>'
            for (const params of seriesList) {
                const key = params.dimensionNames[params.encode.y]
                msg += params.seriesName + ':' + params.data[key] + '<br/>'
            }
            return msg
        },
        axisPointer: {
            animation: false
        }
    },

## brush
todo: brush是用于area 选择的

## grid
grid 控制图形周边的空白，类似css padding

    grid: {
        left: '30%',
        right: '18%',
        bottom: '3%',
        containLabel: true
    },

支持多个grid :

    grid: [
        {
            left: '10%',
            right: '8%',
            height: '50%'
        },
        {
            left: '10%',
            right: '8%',
            bottom: '20%',
            height: '15%'
        }
    ],

# 参考
- Customized Chart Styles
https://www.echartsjs.com/en/tutorial.html#Customized%20Chart%20Styles
- itemStyle
https://echartsjs.com/en/option.html#series-line.itemStyle