---
title: echart line
date: 2019-12-23
private: 
---
# echart line
```js
option = {
    title: {
        text: '折线图堆叠'
    },
    tooltip: {
        trigger: 'axis'
    },
    legend: {
        data:['邮件营销','联盟广告','视频广告','直接访问','搜索引擎']
    },
    grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
    },
    toolbox: {
        feature: {
            saveAsImage: {}
        }
    },
    xAxis: {
        type: 'category',
        boundaryGap: false,
        data: ['周一','周二','周三','周四','周五','周六','周日']
    },
    yAxis: {
        type: 'value'
    },
    series: [
        {
            name:'邮件营销',
            type:'line',
            stack: '总量',
            data:[120, 132, 101, 134, 90, 230, 210]
        },
        {
            name:'联盟广告',
            type:'line',
            stack: '总量',
            data:[220, 182, 191, 234, 290, 330, 310]
        },
    ]
};
```

## grid
grid 控制图形周边的空白，类似css padding

    grid: {
        left: '30%',
        right: '18%',
        bottom: '3%',
        containLabel: true
    },

# dynamic + time
```js
function getData(mm=1) {
    var start_day = new Date(1997, 9, 3);
    var data = [];
    for (var i = 0; i < 10; i++) {
        const now = new Date(+start_day + (86400*1000*i));
        var value =  Math.random() * 20 - 10;
        const item =  {
            name: now.toString(),
            value: [
                [now.getFullYear(), now.getMonth() + 1, now.getDate()].join('/'),
                Math.round(value/mm)
            ]
        }
        data.push(item)
    }
    return data
}

option = {
    title: {
        text: '动态数据 + 时间坐标轴'
    },
    tooltip: {
        trigger: 'axis',
        formatter: function (params) {
            params = params[0];
            var date = new Date(params.name);
            return date.getDate() + '/' + (date.getMonth() + 1) + '/' + date.getFullYear() + ' : ' + params.value[1];
        },
        axisPointer: {
            animation: false
        }
    },
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
    series: [{
        name: '模拟数据',
        type: 'line',
        showSymbol: true,
        hoverAnimation: false,
        data: getData()
    },
    {
        name: '模拟数据',
        type: 'line',
        showSymbol: true,
        hoverAnimation: false,
        data: getData()
    }
    ],
};

setInterval(()=>{
    
     //update data
    myChart.setOption({
        series: [{
            data: getData(1)
        },{
            data: getData(10)
        }]
    });
},5000);
```

# line 
## symbol
    series: [{
        type: "line",
        symbolSize:10,
        showSymbol:true,
        itemStyle: {
            normal: {
                color: "#2ec7c9", //symbol color
                lineStyle: {
                    color: "blue", //line color
                }
            }
        },
        lineStyle: {
            color: "blue", //line color
        }
    }]