---
layout: page
title:
category: blog
description:
---
# Preface
redis > 3.2

- geoadd: O(log(N))
- geopos: O(log(N))
- GEODIST: O(log(N))
- GEORADIUS: O(log(N)+M)， 其中 N 为指定范围之内的元素数量， 而 M 则是被返回的元素数量。
- GEOHASH: 返回多个元素的HASH 值

# geoadd
- 添加元素复杂度：`O(log(N))`
- 存储形式：有序集合， 从而像 `GEORADIUS 和 GEORADIUSBYMEMBER` 这样的命令可以在之后通过位置查询取得这些元素。
- 返回值：新添加元素数量， 不包括原来已经存在的或更新的元素

将经、纬、名字 添加到key 里面，

    GEOADD key longitude latitude member [longitude latitude member ...]

精确的坐标限制由 `EPSG:900913 / EPSG:3785 / OSGEO:41001` 等坐标系统定义， 具体如下：

    有效的经度介于 -180 度至 180 度之间。
    有效的纬度介于 -85.05112878 度至 85.05112878 度之间。

Example

    redis> GEOADD Sicily 13.361389 38.115556 "Palermo" 15.087269 37.502669 "Catania"
    (integer) 2

    redis> GEODIST Sicily Palermo Catania
    "166274.15156960039"

    redis> GEORADIUS Sicily 15 37 100 km
    1) "Catania"

    redis> GEORADIUS Sicily 15 37 200 km
    1) "Palermo"
    2) "Catania"

# geopos

    redis> GEOADD Sicily 13.361389 38.115556 "Palermo" 15.087269 37.502669 "Catania"
    (integer) 2

    redis> GEOPOS Sicily Palermo Catania NonExisting
    1) 1) "13.361389338970184"
       2) "38.115556395496299"
    2) 1) "15.087267458438873"
       2) "37.50266842333162"
    3) (nil)

# GEODIST

    GEODIST key member1 member2 [unit]

指定单位的参数 `unit` 必须是以下单位的其中一个：

    m 表示单位为米(default)。
    km 表示单位为千米。
    mi 表示单位为英里。
    ft 表示单位为英尺。

# GEORADIUS

    GEORADIUS key longitude latitude radius m|km|ft|mi [WITHCOORD] [WITHDIST] [WITHHASH] [ASC|DESC] [COUNT count]

在给定以下可选项时， 命令会返回额外的信息：

    WITHDIST ： 返回位置元素与中心之间的距离
    WITHCOORD ：将位置元素的经度和维度也一并返回。
    WITHHASH ： 以 52 位有符号整数的形式， 返回位置元素经过原始 geohash 编码的有序集合分值。 这个选项主要用于底层应用或者调试

命令默认返回未排序的位置元素。 通过以下两个参数， 用户可以指定被返回位置元素的排序方式：

    ASC ：根据中心的位置， 按照从近到远的方式返回位置元素。
    DESC：根据中心的位置， 按照从远到近的方式返回位置元素。

`COUNT n`  只能减少返回元素数量，不会减少计算量

在返回嵌套数组时， 子数组的第一个元素总是位置元素的名字。 至于额外的信息， 则会作为子数组的后续元素， 按照以下顺序被返回：

    1. 距离
    2. geohash 整数。
    3. 经度和纬度。

Example

    redis> GEOADD Sicily 13.361389 38.115556 "Palermo" 15.087269 37.502669 "Catania"
    (integer) 2

    redis> GEORADIUS Sicily 15 37 200 km WITHDIST
    1) 1) "Palermo"
       2) "190.4424"
    2) 1) "Catania"
       2) "56.4413"

    redis> GEORADIUS Sicily 15 37 200 km WITHCOORD
    1) 1) "Palermo"
       2) 1) "13.361389338970184"
          2) "38.115556395496299"
    2) 1) "Catania"
       2) 1) "15.087267458438873"
          2) "37.50266842333162"

    redis> GEORADIUS Sicily 15 37 200 km WITHDIST WITHCOORD
    1) 1) "Palermo"
       2) "190.4424"
       3) 1) "13.361389338970184"
          2) "38.115556395496299"
    2) 1) "Catania"
       2) "56.4413"
       3) 1) "15.087267458438873"
          2) "37.50266842333162"

## GEORADIUSBYMEMBER
这个命令和 GEORADIUS 命令一样，

    GEORADIUSBYMEMBER key member radius m|km|ft|mi [WITHCOORD] [WITHDIST] [WITHHASH] [ASC|DESC] [COUNT count]

# GEOHASH
返回一个或多个位置元素的 Geohash 表示。

    GEOHASH key member [member ...]
