---
title: Cesium
date: 2019-09-12
---
# Cesium

## PolylineCollection

    polylines.removeAll();
    PolylineCollection#add
    PolylineCollection#remove
    PolylineCollection#update

## Entity
### Delete Entity

    var polylineEntity = viewer.entities.add({
        //...
    });
    viewer.entities.remove(polylineEntity);

remove all

    viewer.entities.removeAll()

### Entity Camera
https://stackoverflow.com/questions/35066575/cesium-having-the-camera-in-an-entitys-first-person-view

    Cesium.Camera.prototype.rotateView = function(rotation) {
        let { heading, pitch, roll } = rotation;
        heading = this.heading + (heading || 0);
        pitch = this.pitch + (pitch || 0);
        roll = this.roll + (roll || 0);
        const destination = this.position;
        this.setView({
            destination,
            orientation: {
                heading,
                pitch,
                roll
            }
        });
    };