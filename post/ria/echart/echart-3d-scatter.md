---
title: echart 3d scatter
date: 2019-12-19
private: 
---
# echart 3d scatter

    var data = [["Income","Life Expectancy","Population","Country","Year"],[815,34.05,351014,"Australia",1800],[1314,39,645526,"Canada",1800],[985,32,402711280,"China",1850],[1543,36.26,1181650,"Cuba",1850],[1512,37.35415172,1607810,"Finland",1850],[2146,43.28,36277905,"France",1850],[2182,38.37,33663143,"Germany",1850]];
    var symbolSize = 2.5;
    option = {
        grid3D: {},
        xAxis3D: {
            type: 'category'
        },
        yAxis3D: {},
        zAxis3D: {},
        dataset: {
            dimensions: [
                'Income',
                'Life Expectancy',
                'Population',
                'Country',
                {name: 'Year', type: 'ordinal'}
            ],
            source: data
        },
        series: [
            {
                type: 'scatter3D',
                symbolSize: symbolSize,
                encode: {
                    x: 'Country',
                    y: 'Life Expectancy',
                    z: 'Income',
                    tooltip: [0, 1, 2, 3, 4]
                }
            }
        ]
    };

    myChart.setOption(option);

完整的：

    const option = {
        tooltip: {},
        grid3D: {
            viewControl: {
                // 使用正交投影。
                projection: 'orthographic'
            }
        },
        xAxis3D: {
            // 因为 x 轴和 y 轴都是类目数据，所以需要设置 type: 'category' 保证正确显示数据。
            // type: 'category'
        },
        yAxis3D: { },
        zAxis3D: {},
        dataset: {
            dimensions: [
                'change',
                'period',
                'total',
                // { name: 'Year', type: 'ordinal' as 'number' | 'float' | 'int' | 'ordinal' | 'time' }
                // { name: 'Year', type: 'ordinal' as echarts.DimentionType }
            ],
            source: data,//.filter((v: any) => v[1] >= 40)
        },
        visualMap: {
            calculable: true, //可以筛选
            max: 400000,
            min: 300000,
            dimension: 'total', // 维度的名字默认就是表头的属性名, 或者列的顺序如第二列
            inRange: {
                color: ['#FF0000', 'blue', 'green']
            }
        },
        series: [
            {
                type: 'scatter3D',
                symbolSize: 5,
                encode: {
                    x: 'change',
                    y: 'period',
                    z: 'total',
                    tooltip: [0, 1, 2, 3, 4, 5]
                }
            }
        ]
    };
