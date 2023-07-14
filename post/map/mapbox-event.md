---
title: mapbox event
date: 2023-07-14
private: true
---
# mapbox event

## mouseenter, mouseleave
    map.on('mouseenter', id, function (e: any) {
        map.getCanvas().style.cursor = 'pointer';
    })

## popup

    const popup = new mapboxgl.Popup({
        closeButton: false,
        closeOnClick: false
    });

    // Populate the popup and set its coordinates based on the feature.
    var html = "<div id='delete-polygon'>Delete</div>";
    popup.setLngLat(e.lngLat)
      .setHTML(html)
      .addTo(map);

    document.getElementById('delete-polygon')?.addEventListener('click', function () {
      if (map.getLayer(id)) {
        map.removeLayer(id);
        map.removeSource(id);
        map.getCanvas().style.cursor = '';
        popup.remove();
      }
      popup.remove();
    });