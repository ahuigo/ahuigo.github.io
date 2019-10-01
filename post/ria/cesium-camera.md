---
title: Cesium Camera
date: 2019-09-12
private:
---
# Cesium 支持的坐标系
1. 平面坐标系（Cartesian2）；
2. 笛卡尔空间直角坐标系（Cartesian3）；
3. Cartographic:（地理坐标系下经纬度的弧度表示）

## 
    camera.position
    viewer.scene.globe.ellipsoid.cartesianToCartographic(viewer.camera.position).height


# Move

# Rotate

    viewer.camera.lookAt(Cesium.Cartesian3.fromDegrees(15, 0, 100), new Cesium.HeadingPitchRange(0, 0, 100));
    viewer.camera.setView({destination: Cesium.Cartesian3.fromDegrees(15, 0, 100)});