---
title: echart dataset
date: 2020-01-04
private: 
---
# echart dataset

## 多维

### 默认index映射多维

    option = {
        legend: {},
        tooltip: {},
        dataset: {
            // 提供一份数据。
            source: [
                ['date', '动作', '喜剧', '科幻'], //等价dimension
                ['一季度', 60,30,10],
                ['二季度', 50,30,20],
                ['三季度', 40,30,30],
                ['四季度', 30,30,40]
            ]
        },
        // 声明一个 X 轴，类目轴（category）。默认情况下，类目轴对应到 dataset 第一列。
        xAxis: {type: 'category'},
        // 声明一个 Y 轴，数值轴。
        yAxis: {},
       // 声明多个 bar 系列，默认情况下，每个系列会自动对应到 dataset 的每一列。
        series: [
            {type: 'bar'},
            {type: 'bar'},
            {type: 'bar'}
        ]
    };

### dimensions 健映射
        // 这里指定了维度名的顺序，从而可以利用默认的维度到坐标轴的映射。
        // 如果不指定 dimensions，也可以通过指定 series.encode 完成映射，参见后文。
        // 后3个是y轴
        dimensions: ['date', '动作', '喜剧', '科幻'], 
        source: [
            {date: '一季度', '动作': 43.3, '喜剧': 85.8, '科幻': 93.7},
            {date: '二季度', '动作': 83.1, '喜剧': 73.4, '科幻': 55.1},
            {date: '三季度', '动作': 86.4, '喜剧': 65.2, '科幻': 82.5},
            {date: '四季度', '动作': 72.4, '喜剧': 53.9, '科幻': 39.1}
        ]

## encode 列名映射
    var option = {
        dataset: {
            source: [
                ['score', 'amount', 'city'],
                [50, 10000, '北京'],
                [80, 9000, '上海'],
                [70, 8000, '广东'],
                [60, 7000, '深圳'],
                [50, 6000, '苏州'],
                [40, 5000, '南京'],
                [30, 4000, '杭州']
            ]
        },
        grid: {containLabel: true},
        xAxis: {},
        yAxis: {type: 'category'},
        series: [
            {
                type: 'bar',
                encode: {
                    // amount 列映射到 x 轴
                    x: 'amount',
                    // city 映射到 y 轴
                    y: 'city'
                }
            }
        ]
    };

encode 不仅可映射x,y,还可以映射 tooltip ....

    // 例如在直角坐标系（grid/cartesian）中：
    encode: {
        // 把 “维度1”、“维度5”、“名为 score 的维度” 映射到 X 轴：
        x: [1, 5, 'score'],
        // 把“维度0”映射到 Y 轴。
        y: 0,
        // 使用 “名为 product 的维度” 和 “名为 score 的维度” 的值在 tooltip 中显示
        tooltip: ['product', 'score']
        // 使用 “维度 3” 的维度名作为系列名。（有时候名字比较长，这可以避免在 series.name 重复输入这些名字）
        seriesName: 3,
        // 表示使用 “维度2” 中的值作为 id。这在使用 setOption 动态更新数据时有用处，可以使新老数据用 id 对应起来，从而能够产生合适的数据更新动画。
        itemId: 2,
        // 指定数据项的名称使用 “维度3” 在饼图等图表中有用，可以使这个名字显示在图例（legend）中。
        itemName: 3
    }

    // 对于极坐标系，可以是：
    encode: {
        radius: 3,
        angle: 2,
        ...
    }

    // 对于地理坐标系，可以是：
    encode: {
        lng: 3,
        lat: 2
    }

    // 对于一些没有坐标系的图表，例如饼图、漏斗图等，可以是：
    encode: {
        value: 3
    }

## 参考
echart 4 新特性 dataset https://www.jianshu.com/p/d6aeddf57531
