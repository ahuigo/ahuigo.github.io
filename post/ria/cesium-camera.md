---
title: Cesium Camera
date: 2019-09-12
private:
---
# Cesium 支持的坐标系
https://cesium.com/docs/tutorials/cesium-workshop/#camera-modes
1. 平面坐标系（Cartesian2）；
2. 笛卡尔空间直角坐标系（Cartesian3, ECEF）；
3. Cartographic:（地理坐标系下经纬度的弧度表示）

认识8大坐标标简介：
https://zhuanlan.zhihu.com/p/59743409

## 坐标表示
    var ellipsoid=viewer.scene.globe.ellipsoid;

### 笛卡尔空间直角坐标系（Cartesian3, 也可用position）；

    cartesian3 = Cesium.Cartesian3.fromDegrees(longitude, latitude, height, ellipsoid, result) 
    cartesian3 = Cesium.Cartesian3.fromDegrees(-115.0, 37.0);
    cartesian3 = new Cesium.Cartesian3(x, y, z)
    cartesian3 = camera.position

    //to cartographic
    var cartographic=viewer.scene.globe.ellipsoid.cartesianToCartographic(cartesian3);

### 地理坐标系下经纬度的弧度表示 Cartographic:

    var cartographic=Cesium.Cartographic.fromDegrees(lng,lat,alt);

    var cartesian3=ellipsoid.cartographicToCartesian(cartographic);

## camera 坐标获取
获取直角坐标cartesian3

    camera.position     // new Cesium.Cartesian3(); 直角坐标

获取Cartographic

    //方法1
    viewer.camera.positionCartographic.longitude
    //方法2
    viewer.scene.globe.ellipsoid.cartesianToCartographic(viewer.camera.position).height

### 度数转换

    var lat=Cesium.Math.toDegrees(cartograhphic.latitude);
    var lng=Cesium.Math.toDegrees(cartograhpinc.longitude);
    var alt=cartographic.height;

### camera direction
camera direction:

    var {heading,pitch,roll} = camera;

setView

    viewer.scene.camera.setView({
        destination: new Cesium.Cartesian3.fromDegrees(116, 39, 531),
        orientation: new Cesium.HeadingPitchRoll.fromDegrees(0,-90, 0),
    });

# Move
## flyTo

    var west = -90.0;
    var south = 38.0;
    var east = -87.0;
    var north = 40.0;
    var rectangle = Cesium.Rectangle.fromDegrees(west, south, east, north);

    viewer.camera.flyTo({
        destination : rectangle
    });

    // Show the rectangle.  Not required; just for show.
    viewer.entities.add({
        rectangle : {
            coordinates : rectangle,
            fill : false,
            outline : true,
            outlineColor : Cesium.Color.WHITE
        }
    });

## Rotate

    viewer.camera.lookAt(Cesium.Cartesian3.fromDegrees(15, 0, 100), new Cesium.HeadingPitchRange(0, 0, 100));
    viewer.camera.setView({destination: Cesium.Cartesian3.fromDegrees(15, 0, 100)});

## center
    viewer.camera.setView({destination: Cesium.Cartesian3.fromDegrees(15, 0, 100)});
    //momenta
    window.id.map().centerEase([lng, lat, ele])

