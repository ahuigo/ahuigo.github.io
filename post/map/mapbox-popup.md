---
title: Mapbox popup
date: 2019-11-29
private: true
---
# Mapbox popup
https://docs.mapbox.com/mapbox-gl-js/api/#popup

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
    popupWindow.setHTML

## setMaxWidth
    .setMaxWidth("300px")


## remove
    popupWindow.remove()
