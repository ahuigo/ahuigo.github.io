---
title: layer filter
date: 2023-07-13
private: true
---
# layer filter

## filter prop
https://docs.mapbox.com/mapbox-gl-js/style-spec/layers/#filter
> 利用了==、get

    layer.filter = ['==', ['get', prop], value];
    filter: ['==', ['get', 'is_highlighted'], true],

或者全局：https://docs.mapbox.com/mapbox-gl-js/example/filter-features-within-map-view/

    const map = new mapboxgl.Map()
    map.setFilter('airport', ['has', 'abbrev']);
    map.setFilter('airport', [
        'match',
        ['get', 'abbrev'],
        filtered.map((feature) => {
            return feature.properties.abbrev;
        }),
        true,
        false
    ]);

## case prop
https://docs.mapbox.com/mapbox-gl-js/style-spec/expressions/#case

    ["case",
        condition: boolean, output: OutputType,
        condition: boolean, output: OutputType,
        ...,
        fallback: OutputType
    ]: OutputType

for example:

    layer['paint']['line-color'] = ['case',
        // ["boolean", ["feature-state", "hover"], false], 'red',
        // ['==', ['get', 'is_selected'], true], selectColor,
        ['has', 'color'], ['get', 'color'],
        color || 'red',
    ];

## and 组合
表示score属性的值在1-50之间，对应的filter语法是什么

    filter: ['all', ['>=', ['get', 'score'], 1], ['<=', ['get', 'score'], 50]]