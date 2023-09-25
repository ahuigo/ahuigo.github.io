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
1. EPSG：European Petroleum Survey Group, 目前已有的椭球体，投影坐标系等不同组合都对应着不同的ID号(相当于unicode)
    - EPSG:4326表示WGS84坐标系(经纬高坐标)，EPSG:3857表示Web墨卡托投影坐标系(无法显示极地，离赤道越远越大)
    - [其中 EPSG:4326是比较著名的一个，GPS系统就是在用它，别名叫作WGS84，WGS(World Geodetic System)是世界大地测量系统](https://www.zhihu.com/question/52220968)
2. SRID(Spatial Reference ID)：OGC标准中的参数,标识空间数据的坐标系，与EPSG一致；如EPSG:4326 (相当于utf8/utf16/utf32)
    - 例如，SRID 4326表示WGS84坐标系，SRID 3857表示Web墨卡托投影坐标系。在PostGIS中，SRID用于将空间数据从一个坐标系转换为另一个坐标系
3. WKT: Well-Known Text的缩写，是一种用于描述空间数据的文本格式. (相当于存储字符的实际编码)
    - e.g.: POINT (30 10)
4. EWKT and EWKB – Extended Well-Known Text/Binary: 在WKT基础中增加了SRID标识。（相当于txt文件加BOM头）
    1. e.g.: SRID=4326;POINT(30 10)

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

# ST 空间函数
postgis中的空间函数都是以ST 打头的

    ST_Transform函数用于将几何对象从一个坐标系转换为另一个坐标系
    ST_Intersects函数用于测试两个几何对象是否相交，
    ST_Distance函数用于计算两个几何对象之间的距离等等。

## geometry
postgis使用ST_GeomFromText函数将WKT或EWKT格式的文本字符串转换为geometry类型的几何对象(二进制)。

    SELECT ST_GeomFromText('POINT (30 10)', 4326);

## ST_Transform 坐标转换
将几何对象从一个坐标系转换为另一个坐标系。它的语法如下：

    ST_Transform(geometry, srid)

比如：

    # 4326 坐标EWKT:
    SELECT ST_GeomFromEWKT('SRID=4326;POINT (30 10)');

    # 转换成3857 Web墨卡托投影坐标系
    select ST_Transform(ST_GeomFromEWKT('SRID=4326;POINT (30 10)'), 3857);

## ST_MakeEnvelope
函数用于创建一个矩形区域的几何对象

    ST_MakeEnvelope(minx, miny, maxx, maxy, srid)
    srid: 表示坐标系
        4326：WGS84坐标系，用于表示地球表面的经纬度坐标。
        3857：Web墨卡托投影坐标系，用于表示地球表面的平面坐标。
        900913：Google墨卡托投影坐标系，与3857坐标系相同。
        27700：英国国家网格坐标系，用于表示英国境内的坐标。
        2154：法国国家坐标系，用于表示法国境内的坐标。

    ST_MakeEnvelope(-122.271189, 37.804339, -122.275244, 37.808264, 4326),

## within box
REfer : 
https://gis.stackexchange.com/questions/223828/select-all-points-within-a-bounding-box/223955

### ST_Contains
判断goem位于box内

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

### ST_SetSRID
1.Sets the SRID on a geometry to a particular integer value. Useful in constructing bounding boxes for queries.

    geometry ST_SetSRID(geometry geom, integer srid);

2.1.利用交集空间查询

    WHERE (geom && ST_SETSRID(ST_MakeBox2D(ST_POINT(116, 39),ST_POINT(117, 40)), 4326)) 
    //或者
    WHERE ST_INTERSECTS(geom , ST_SETSRID(ST_MakeBox2D(ST_POINT(116, 39),ST_POINT(117, 40)), 4326)) 

### ST_Buffer创建几何对象的缓冲区
缓冲区是指在几何对象周围创建一个固定距离的区域，通常用于空间分析和空间查询。ST_Buffer函数的语法如下：

    # ST_Buffer函数返回一个新的几何对象，其类型与输入几何对象的类型相同。
    ST_Buffer(geometry, radius, [num_segments])
    其中:
        geometry是要创建缓冲区的几何对象，
        radius是缓冲区的半径，
        num_segments是可选参数，用于指定缓冲区的圆弧段数。

这个查询语句将返回一个WGS84坐标系下的点对象缓冲区，其半径为10度。

    SELECT ST_Buffer(ST_GeomFromText('POINT(30 10)', 4326), 10);

### st_intersects,求交集
这个查询语句的含义是：查询与经度为(121,30) 的点的 30000 米缓冲区相交的边界。

    WHERE st_intersects(boundary, st_transform(st_buffer(st_transform(st_geomfromtext('point(121 30)', 4326), 3857),30000),4326))

    st_geomfromtext('point(121 30)', 4326)：//WGS84 坐标系（EPSG 4326）表示。
    st_transform(..., 3857)：将几何对象从 WGS84 坐标系转换为 Web Mercator 投影坐标系（EPSG 3857）。
    st_buffer(..., 30000)：将几何对象的缓冲区设置为 30000 米。
    st_transform(..., 4326)：将几何对象从 Web Mercator 投影坐标系转换回 WGS84 坐标系。
    st_intersects(boundary, ...)：查询与指定几何对象相交的边界。boundary 是一个几何对象，表示边界。

以上语句的 boundary 可以加GIST索引, `explain analyze` 就可以看到会使用`-> Index Scan using counties_boundary_gist on table_name ...: Index Cond:`

    > \d table_name
    "counties_boundary_gist" gist (boundary)


### st_distance 几何距离
    ST_Distance(geom1, geom2)
    ST_Distance(boundary, ST_GeomFromText('POINT(121 30)', 4326))

ST_Distance 函数计算两个几何对象之间的平面距离，即忽略地球的曲率和椭球形状，仅仅计算两个几何对象之间的直线距离。
这个函数的计算速度比 ST_DistanceSphere 快，但是在计算大范围距离时，由于忽略了地球的曲率和椭球形状，可能会导致计算结果不够精确。

### st_distancespheroid/ST_DistanceSphere 几何距离
用于计算两个几何对象之间的距离，考虑地球的椭球形状。这个函数使用指定的椭球体参数来计算距离，可以更准确地计算两个点之间的距离。

    ST_DistanceSpheroid(geometry1, geometry2, spheroid)
    参数：
        1. geometry1 和 geometry2 是要计算距离的两个几何对象，
        2. spheroid 是一个字符串，表示要使用的椭球体参数。常用的椭球体参数包括：
            SPHEROID["WGS 84",6378137,298.257223563]：WGS 84 椭球体参数，用于计算 GPS 坐标系下的距离(米) 
            SPHEROID["GRS 1980",6378137,298.257222101]：GRS 1980 椭球体参数，用于计算国际标准坐标系下的距离(米)
    返回：
        返回两个几何对象之间的距离，单位与椭球体参数有关，通常是米或千米。

查询点到边界的距离(结果是米):

    st_distancespheroid(boundary,st_geomfromtext('point(121 30)', 4326),'spheroid["wgs84",6378137,298.257223563]')

如果不需要特别高的精度，使用默认是WGS 84，不指spheroid 椭球体参数，可以用这个ST_DistanceSphere 代替：

    ST_DistanceSphere(boundary, ST_GeomFromText('POINT(121 30)', 4326))
