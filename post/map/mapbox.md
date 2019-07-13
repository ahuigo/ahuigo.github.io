---
title: Mapbox 笔记
date: 2019-05-06
private:
---
# Mapbox 笔记

https://docs.mapbox.com/mapbox-gl-js/example/multiple-geometries/
https://codepen.io/ahuigo/pen/ZNEZYo?editors=1000


## event

    map.on('click', 'skeleton', function(e) {
        // via point
        var features = map.queryRenderedFeatures(e.point);

        // via reactangle
        var bbox = [
            [e.point.x - 1, e.point.y - 1],
            [e.point.x + 1, e.point.y + 1]
        ];
        var features = map.queryRenderedFeatures(bbox, { layers: ['skeleton'] });

## filter

    [
        "all",
        [">=", "number", 1],
        ["<", "number", 10]
    ]

## curd: soureces and layers


### get

    map.getStyle().sources dict
        this.map.getSource('composite')
    map.getStyle().layers list:[{id:'device'}]
        this.map.getLayer('state label')

### remove

    map.removeSource('route')
    map.removeLayer('route')

### toggel hidden
https://docs.mapbox.com/mapbox-gl-js/example/toggle-layers/

    var visibility = map.getLayoutProperty(layerId, 'visibility');
    if (visibility === 'visible') {
        map.setLayoutProperty(layerId, 'visibility', 'none');
    } else {
        map.setLayoutProperty(layerId, 'visibility', 'visible');
    }

### add

    layer = map.getStyle().layers[0]
    map.addLayer(layer)
    source = map.getStyle().sources['device']

    map.add('points', {
        type:'geojson',
        data:{
            type: 'FeatureCollection',
            features:[]
        }

    })

### update
    device_source.setData({
        type: 'FeatureCollection',
        features:[]
    });

## layer
type: circle 可放缩

    https://docs.mapbox.com/mapbox-gl-js/example/data-driven-circle-colors/

circle with cluster:

    https://docs.mapbox.com/mapbox-gl-js/example/cluster/


type: fill 可放缩

    https://docs.mapbox.com/mapbox-gl-js/example/fill-pattern/

type: 'custom'

    https://docs.mapbox.com/mapbox-gl-js/example/custom-style-layer/

"type": "symbol" 不放缩

    https://docs.mapbox.com/mapbox-gl-js/example/geojson-markers/