---
title: Mapbox popup
date: 2019-11-29
private: true
---
# Mapbox popup
    const popupWindow = new mapboxgl.Popup({
        closeButton: true,
        closeOnClick: false
    });

## setText

    popupWindow
        .setLngLat([task.lng, task.lat])
        .setText(msg)
        .addTo(this.map);


## setHTML