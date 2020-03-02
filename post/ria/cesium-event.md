---
title: Cesium Event
date: 2020-02-28
private: true
---
# Cesium Event

## eventType
事件类型表
https://cesium.com/docs/cesiumjs-ref-doc/ScreenSpaceEventType.html

    Cesium.ScreenSpaceEventType.LEFT_CLICK 
    Cesium.ScreenSpaceEventType.RIGHT_CLICK
    Cesium.ScreenSpaceEventType.LEFT_DOUBLE_CLICK 

## 事件handler
单击handler

    viewer.screenSpaceEventHandler.setInputAction(function(e) {
        console.log(e.position) ;//position: Cartesian2{x,y}
    }, Cesium.ScreenSpaceEventType.LEFT_DOWN);

示例
https://sandcastle.cesium.com/?src=Hello%20World.html&label=Showcases&gist=38dcfe80a26c8995d9f4290da10f441d

### 多个handler
https://groups.google.com/forum/#!topic/cesium-dev/81F3lZ2TpKs

    var handler1 = new Cesium.ScreenSpaceEventHandler(viewer.canvas);
    var handler2 = new Cesium.ScreenSpaceEventHandler(viewer.canvas);

    handler1.setInputAction(

        function (click) {
            console.log("second"+click);
        },
        Cesium.ScreenSpaceEventType.LEFT_CLICK
    );


    handler2.setInputAction(

        function (click) {
            console.log("first"+click);
        },
        Cesium.ScreenSpaceEventType.LEFT_CLICK
    );

# 事件案例
## 获取点击位置
    export interface MapPosition {
        lng: number;
        lat: number;
        alt?: number;
    }
    export interface DomPosition {
        x: number;
        y: number;
    }
    export function onContextMenu(handler: (mapPos: MapPosition, clickPos: DomPosition) => any) {
        // var viewer = new Cesium.Viewer('cesiumContainer');
        const viewer = window.id.cesium.viewer;
        const Cesium = window.Cesium;
        const wrapListener = (e: MouseEvent) => {
            const mapDomPos = viewer.canvas.getBoundingClientRect()
            const clickPos = { x: e.clientX - mapDomPos.x, y: e.clientY - mapDomPos.y }
            var mousePosition = new Cesium.Cartesian2(clickPos.x, clickPos.y);

            var ellipsoid = viewer.scene.globe.ellipsoid;
            var cartesian = viewer.camera.pickEllipsoid(mousePosition, ellipsoid);
            if (cartesian) {
                var cartographic = ellipsoid.cartesianToCartographic(cartesian);
                var lng = Cesium.Math.toDegrees(cartographic.longitude).toFixed(8);
                var lat = Cesium.Math.toDegrees(cartographic.latitude).toFixed(8);
                handler({ lng, lat }, clickPos)
            } else {
                console.log('Globe was not picked');
            }
        }
        viewer.canvas.addEventListener('contextmenu', wrapListener, false);
        return () => {
            viewer.canvas.removeEventListener('contextmenu', wrapListener);
        };
    }