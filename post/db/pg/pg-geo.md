---
title: Postgre postgis
date: 2019-06-24
private:
---
# Postgis
> 参考 https://www.jianshu.com/p/8f6f76b82f13

Postgis 是基于R-Tree 的索引

## install postgis
Refer to : https://postgis.net/install/
先安装

    $ brew install postgis

然后进入postgre:

    -- Enable PostGIS (includes raster)
    CREATE EXTENSION postgis;
    -- Enable Topology
    CREATE EXTENSION postgis_topology;

## 空间数据类型
空间字段可以分为geometry和geography两种，大部分情况使用满足opengis标准的geometry(point,line,polygon...)。

# 空间数据标准
1. EPSG：European Petroleum Survey Group, 目前已有的椭球体，投影坐标系等不同组合都对应着不同的ID号
[其中 EPSG:4326是比较著名的一个，GPS系统就是在用它，别名叫作WGS84，WGS(World Geodetic System)是世界大地测量系统](https://www.zhihu.com/question/52220968)
2. SRID：OGC标准中的参数SRID，也是指的空间参考系统的ID，与EPSG一致；如EPSG:4326
3. WKT: 只是空间参考系统的文字描述, 无论是参考椭球、基准面、投影方式、坐标单位等，都有相应 的EPSG值表示
4. EWKT and EWKB – Extended Well-Known Text/Binary: wkt+srid(up to 2D (x, y), 3D (x, y, z), 4D (x, y, z, m))
    1. for example: SRID=4326;POINT(-44.3 60.1)

WKT 表示样表：https://www.cnblogs.com/tiandi/archive/2012/07/18/2598093.html

    POINT(6 10)
    LINESTRING(3 4,10 50,20 25)
    POLYGON((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2))
    MULTIPOINT(3.5 5.6, 4.8 10.5)
    MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))
    MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3 2,2 2)),((6 3,9 2,9 4,6 3)))
    GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))
    POINT ZM (1 1 5 60)
    POINT M (1 1 80)
    POINT EMPTY
    MULTIPOLYGON EMPTY

## EPSG 标准
> https://github.com/penouc/blog/issues/1

### EPSG:4326 (WGS84)
世界大地测量系统1984 （World Geodetic System of 1984) 是 GPS 用来描述地球上位置的地理学坐标系统（`三维`）。
1. WGS84 通常使用 GeoJSON 作为坐标系统的单位，GeoJSON 中使用数字作为经度和纬度的单位。
2. 我们没有办法在二位平面上展示 WGS84 坐标系统，所以大部分的软件在展现这种坐标的时候都会使用一个叫做 equirectangular （EPSG:54001）的投影（即直接使用经纬度单位）
Equirectangular projection(ERP)是一种简单的投影方式，将经线映射为恒定间距的垂直线，将纬线映射为恒定间距的水平线。这种投影方式映射关系简单，但既不是等面积的也不是保角的，引入了相当大的失真。

### EPSG: 3857 (Pseudo-Mercator)
Pseudo-Mercator 投影系统将 WGS84 坐标系统投影在平面上(这个投影系统北纬和南纬的85.06度以上的地区不会展示)。
1. 这些投影（EPSG:3857）内部都是使用的 WGS84 坐标系统 -- 即使用的 WGS84 椭球体构建，但是将它们（EPSG:3857）的坐标是投射在一个球面上。
2. 通过这个投影规则可以投射出的正方形的地图，但是如果想将两个不同的参考椭球体投影在同一个投影坐标系上是不对的，这就表示在软件上必须展示是动态可变的。
（这也是为什么 mapBox 在存储数据的时候使用的是 EPSG: 4326 但是展示的时候使用 EPSG:3857）。

# geom 操作

## create geom
定义geom 字段, 比如gorm

    Geom *gormgis.GeoLineZ `sql:"type:geometry(LineStringZ,4326)" json:"geom,omitempty"`

或者在表中创建字段

    CREATE TABLE ROADS ( 
        ID int4, 
        ROAD_NAME varchar(25), 
        roads_geom geometry(LINESTRING,4326) 
    );

## insert geom

    INSERT INTO roads (roads_geom, road_name) VALUES (ST_GeomFromText('LINESTRING(192783 228138,192612 229814)', 4326),'Paul St');

### insert WKT 格式

    INSERT INTO roads ( roads_geom, road_name )VALUES (GeomFromEWKT('SRID=4326;LINESTRING(192783 228138,192612 229814)'), '北京' )
    INSERT INTO roads ( roads_geom, road_name )VALUES (GeomFromEWKT('SRID=4326;POINTM(116.39 39.9 10)'), '北京' )

### insert point

    ST_POINT(116, 39)

### geom from lng/lat
make geom from lng/lat

    geom = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326);

## select geom
### 显示图形:st_force2d

    $ select st_force2d(geom) from table_name limit 100
    0102000020E61000000200000000000000788807410000000050D90B41000000002083074100000000B00D0C41

### 读取格式

### select AsText/AsGeoJson

    select ST_AsText(roads_geom),ST_AsGeoJson(roads_geom) from roads;
                    st_astext                |                             st_asgeojson
    -----------------------------------------+-----------------------------------------------------------------------
    LINESTRING(192783 228138,192612 229814) | {"type":"LineString","coordinates":[[192783,228138],[192612,229814]]}

### select Ewkt

    > SELECT ST_AsEwkt(the_geom)
     SRID=4326;LINESTRING(192783 228138,192612 229814)
    
### select x/y/z
点的经纬

    ST_X(the_geom), ST_Y(the_geom) FROM cities;

## where 
### within box
REfer : 
https://gis.stackexchange.com/questions/223828/select-all-points-within-a-bounding-box/223955

#### ST_Contains

    SELECT *
    FROM planet_osm_roads
    WHERE planet_osm_roads.geom && ST_Transform(
        ST_MakeEnvelope(-122.271189, 37.804339, -122.275244, 37.808264, 4326),
        3857
    );

or change it to this:

    SELECT *
    FROM planet_osm_roads
    WHERE ST_Contains(
        ST_Transform(
            ST_MakeEnvelope(-122.271189, 37.804339, -122.275244, 37.808264, 4326),3857)
        ,planet_osm_roads.geom);

#### ST_SetSRID
1.Sets the SRID on a geometry to a particular integer value. Useful in constructing bounding boxes for queries.

    geometry ST_SetSRID(geometry geom, integer srid);

2.1.利用交集空间查询

    WHERE (geom && ST_SETSRID(ST_MakeBox2D(ST_POINT(116, 39),ST_POINT(117, 40)), 4326)) 
    //或者
    WHERE ST_INTERSECTS(geom , ST_SETSRID(ST_MakeBox2D(ST_POINT(116, 39),ST_POINT(117, 40)), 4326)) 
