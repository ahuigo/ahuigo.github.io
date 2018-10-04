---
title: highcharts
date: 2018-10-04
---
# highcharts
[hicharts](/p/js/js-chart-highcharts)

## responsive highcharts
好的设计方法是, 事先设定好renderTo 的位置:

    new Highcharts.Chart({
        chart:{ zoomType:'x', renderTo:id_selector}
    }

## timezone

    Highcharts.setOptions({
        global: {
            timezoneOffset: -8 * 60
        }
    });

## plotOptions

### 显示数据标签

    plotOptions: {
           line: {
               dataLabels: {
                   enabled: true
               },
               enableMouseTracking: false
           }
     },

### 尺度 threshold
如果尺度不需要从0 开始

    plotOptions: {
       area: {
           threshold: null

### fillcolor

    plotOptions: {
        area: {
            fillColor: {
                linearGradient: { x1: 0, y1: 0, x2: 0, y2: 1 },
                stops: [
                    [0, Highcharts.getOptions().colors[0]],
                    [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                ]
            },
            marker: { radius: 2 },
            lineWidth: 1
        }
    },

## zoom

    chart: {
          zoomType: 'x'
      },


## map
如何使用highmaps制作中国地图
https://www.google.com/search?q=%E5%A6%82%E4%BD%95%E4%BD%BF%E7%94%A8highmaps%E5%88%B6%E4%BD%9C%E4%B8%AD%E5%9B%BD%E5%9C%B0%E5%9B%BE
http://runjs.cn/code/ovymune9


## dateformat

   Highcharts.dateFormat("%Y/%m/%d", this.value);

## taggerLines:1
 The number of lines to spread the labels over to make room or tighter labels. .

## addSeries
You need to looka at the "Methods and Properties" part of the API. See http://api.highcharts.com/highcharts#Chart (There is an jsFiddle on the documentation page as well).

  var options = {
      chart: {
          renderTo: 'container',
          defaultSeriesType: 'spline'
      },
      series: []
  };
  var chart = new Highcharts.Chart(options);
  var chart = $('#container').highcharts()

  chart.addSeries({
      name: array.teamName,
      data: array.teamPowher
  });

If you are going to add several series you should set the redraw flag to false and then call redraw manually after as that will be much faster.

  var chart = new Highcharts.Chart(options);
  chart.addSeries({
      name: array.teamName,
      data: array.teamPower
  }, false);
  chart.addSeries({
      name: array.teamName,
      data: array.teamPower
  }, false);
  chart.redraw();

### update

  chart.series[0].setData([129.2, 144.0...

## spline with tooltip
http://jsfiddle.net/gh/get/jquery/1.9.1/highslide-software/highcharts.com/tree/master/samples/highcharts/demo/spline-irregular-time/

xAxis:

  xAxis: {
      categories: array_values(dates)
  },

## tooltip:
> http://jsfiddle.net/6tc6T/3/

    tooltip: {
      headerFormat: '<b>{series.name}</b><br>',
      pointFormat: '{point.x:%e. %b}: {point.y:.2f} m {point.z}'
    },

multi points:

    tooltip: {
        crosshairs: true,
        shared: true,
        formatter:function(){
            var s = [];
            $.each(this.points, function(i, point) {
                s.push('<span style="color:#D31B22;font-weight:bold;">'+ point.series.name +' </span>: '+
                    point.y +'');
            });
            return s.join(' <br/> ');
        }
    },

single point:

        this.point.y, this.point.other
        this.series.name

## xAxis

### xAxis.type = 'datetime'

    xAxis: {
        type: 'datetime',
        dateTimeLabelFormats: { // don't display the dummy year
            month: '%e. %b',
            year: '%b'
        },
        title: {
            text: 'Date'
        }
        //categories: xDatas
    },

### xAxis tick

    xAxis: {
        tickPixelInterval: 5

## tooltip

          tooltip: {
              headerFormat: '<b>{series.name}</b><br>',
              pointFormat: '{point.x:%e. %b}: {point.y:.2f} m {point.z}'
          },

## series

### with series.marker

    series:
        name: name
        marker: {
            symbol: 'circle'
        },
        data:

### with series date

      $(function () {
          $('#container').highcharts({
              chart: { type: 'spline' },
              xAxis: { type: 'datetime', },

              series: [{
                  name: 'Winter 2012-2013',
                  // Define the data points. All series have a dummy year
                  // of 1970/71 in order to be compared on the same x axis.
                  data: [
                      {x:Date.UTC(1970, 9, 21), y:12,z:'好'},//[Date.UTC(1970, 9, 21), 12],
                      {x:Date.UTC(1970, 10, 21),y:10,z:'坏'}
                  ]
              }]
          });
      });

### column
column 柱状图

    new Highcharts.Chart({
        chart:{ type:'column', zoomType:'x', renderTo:'x'},
        title: { text:'title' },
        xAxis: {type:'category' },
        yAxis: {
            title: { text:'y' }
        },
        series:[{name:'xxx', data:[['BEIJING', 23.7], ['a2', 27.7]]}]
    })