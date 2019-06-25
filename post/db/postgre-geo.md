---
title: Postgre Geo
date: 2019-06-24
---
# Postgre Geo

    $ select st_force2d(geom) from table_name limit 100
    $ \d table_name
    id        | bigint                      |
    timestamp | timestamp without time zone |
    geom      | geometry(LineStringZ,4326)  |
     geom      | geometry(LineStringZ,4326)
