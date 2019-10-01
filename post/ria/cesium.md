---
title: Cesium
date: 2019-09-12
---
# Cesium
# imagery 图层
Supported Imagery Formats:

    WMS
    TMS
    WMTS (with time dynamic imagery)
    ArcGIS
    Bing Maps
    Google Earth
    Mapbox
    Open Street Map

## crud imagery
    viewer.imageryLayers.remove(viewer.imageryLayers.get(0));

    // Add Sentinel-2 imagery
    viewer.imageryLayers.addImageryProvider(new Cesium.IonImageryProvider({ assetId : 3954 }));

## config imagery
https://cesiumjs.org/Cesium/Build/Apps/Sandcastle/index.html?src=Imagery%20Adjustment.html

# Adding Terrain
Cesium supports streaming and visualizing global high-resolution terrain and water effects for oceans, lakes, and rivers. like imagery

    // Load Cesium World Terrain
    viewer.terrainProvider = Cesium.createWorldTerrain({
        requestWaterMask : true, // required for water effects
        requestVertexNormals : true // required for terrain lighting
    });
    // Enable depth testing so things behind the terrain disappear.
    viewer.scene.globe.depthTestAgainstTerrain = true;

# Entity
## Format
Cesium supports popular vector formats `GeoJson and KML`, as well as an open format we developed specifically for describing a scene in Cesium called CZML.

### Delete Entity

    var polylineEntity = viewer.entities.add({
        //...
    });
    viewer.entities.remove(polylineEntity);

remove all

    viewer.entities.removeAll()

## PolylineCollection

    polylines.removeAll();
    PolylineCollection#add
    PolylineCollection#remove
    PolylineCollection#update