---
title: antv interact brush
date: 2020-01-14
private: true
---
# antv brush
https://codepen.io/ahuigo/pen/jOEKmxp?editors=1010
https://bizcharts.net/products/bizCharts/demo/detail?id=g2-brush-interval&selectedKey=%E6%A6%82%E8%A7%88


    import Brush from "@antv/g2-brush";

     componentDidMount() {
              new Brush({
                  canvas: chart.get('canvas'),
                  chart,
                  type: 'X',
                  onBrushstart(p) {
                    console.log(p)
                      chart.hideTooltip();
                  },
                onBrushend1(p){
                  console.log('end',p)
                },
                  onBrushmove(p) {
                    console.log('move',p)
                      chart.hideTooltip();
                  }
              });
              chart.on('plotdblclick', () => {
                  chart.get('options').filters = {};
                  chart.repaint();
              });
        }


# 交互

