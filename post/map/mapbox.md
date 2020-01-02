---
title: Mapbox 笔记
date: 2019-05-06
private:
---
# Mapbox 笔记
https://docs.mapbox.com/mapbox-gl-js/example/multiple-geometries/
https://codepen.io/ahuigo/pen/ZNEZYo?editors=1000

## init
    map.resize()

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
