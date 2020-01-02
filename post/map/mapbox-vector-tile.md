---
title: Mapbox-vector-tile
date: 2019-08-16
private:
---
# example
https://docs.mapbox.com/vector-tiles/specification/

## parse pbf

    var VectorTile = require('@mapbox/vector-tile').VectorTile;
    var VectorTileFeature = require('@mapbox/vector-tile').VectorTileFeature;
    var Protobuf = require('pbf');
    var fetch = require('node-fetch')



    async function f(){
        let data = await fetch('http://xxxx:8080/geoserver/gwc/service/wmts?REQUEST=GetTile&SERVICE=WMTS&VERSION=1.0.0&LAYER=momenta:subtracks&STYLE=&TILEMATRIX=EPSG:900913:9&TILEMATRIXSET=EPSG:900913&FORMAT=application/vnd.mapbox-vector-tile&TILECOL=422&TILEROW=193').then(r=>r.buffer()).then(r=>{console.log(typeof r);return r})
        var tile = new VectorTileFeature(new Protobuf(data));
        console.log(tile)
        return
        var tile = new VectorTile(new Protobuf(data));
        // Contains a map of all layers
        console.log(tile.layers.subtracks)
        console.log(tile.layers.subtracks._features)
    }


    f()


结果

    $ node a.js
    object
    VectorTileLayer {
      version: 2,
      name: 'subtracks',
      extent: 4096,
      length: 20768,
      _pbf: {
        buf: <Buffer 1a b1 d6 26 0a 09 73 75 62 74 72 61 63 6b 73 12 1a 08 d7 c5 3d 12 08 00 00 01 01 02 02 03 03 18 02 22 08 09 c8 1a ec 27 0a 01 06 12 1a 08 ef ea 16 12 ... 633603 more bytes>,
        pos: 633653,
        type: 0,
        length: 633653
      },
      _keys: [ 'heat', 'status', 'time', 'track_id' ],
      _values: [
        4,
        'IDLE',
        '2019-07-20 09:02:31.391',
        108059,
        9,
        'COLLECTION',
        '2019-07-14 02:17:28.01',
        90390,
        2,
        '2019-07-19 15:18:43.04',
        106628,
        5,
        '2019-07-19 23:33:19.085',

