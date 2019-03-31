---
title: OSM 格式
date: 2019-03-29
private:
---
# OSM 格式
OSM XML格式： https://wiki.openstreetmap.org/wiki/OSM_XML
OSM Elements： https://wiki.openstreetmap.org/wiki/Elements

    <node id="1831881213" version="1" changeset="12370172" lat="54.0900666" lon="12.2539381" user="lafkor" uid="75625" visible="true" timestamp="2012-07-20T09:43:19Z">
        <tag k="name" v="Neu Broderstorf"/>
        <tag k="traffic_sign" v="city_limit"/>
    </node>

OSM 是描述地图信息的文件格式。分为：

## 元素Element
1. Node: 点
    1. lon,lat
    2. user: 最近一次更新此点的用户
    2. uid: 最近一次更新此点的用户uid
    2. changset: 最近一次更新的changset
   1. height=*标示物体所海拔；
   2. 通过layer=* 和 level=*，可以标示物体所在的地图层面与所在建筑物内的层数；
   3. 通过place=* and name=*来表示对象的名称。
2. Ways: way也是通过多个点（node）连接成线（面）来构成的。
    1. Open polyline: 非闭合线：收尾不闭合的线段。通常可用于表示现实中的道路、河流、铁路等。
    2. Closed polyline:  闭合线：收尾相连的线。例如可以表示现实中的环线地铁。
    3. Area: 闭合区域。通常使用landuse=* 来标示区域等。
3. Relation: node,ways 或其他relations 组成, 相互的关系通过role来定义。
4. Tag 标签: 附属信息，比如地名、highway=footway, maxspeed=30km/h
> https://wiki.openstreetmap.org/wiki/Zh-hans:Map_Features#.E8.87.AA.E7.84.B6

## OsmChange
OsmChangeset is used to Describe differences between two dumps of OSM data
OSM Change： https://wiki.openstreetmap.org/wiki/OsmChange

    <osmChange version="0.6" generator="acme osm editor">
        <modify>
            <node id="1234" changeset="42" version="2" lat="12.1234567" lon="-8.7654321">
                <tag k="amenity" v="school"/>
            </node>
        </modify>
    </osmChange>