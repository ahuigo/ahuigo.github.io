---
title: Doglas 道格拉斯抽析
date: 2020-01-13
private: true
---
# Doglas 道格拉斯抽稀(Ramer–Douglas–Peucker)
![](/img/math/geo/douglas.png)
> 可用于sampling geometry line

一般tileserver-gl zoom较小是，vertor.pbf 在太小，此时就要抽稀(sampling). 方法主要有：
1. 手工利用douglas 道格拉斯抽稀算法对geometry line取sample points: 可以在网上找到许多现在的实现
2. tippecanoe（转换成mtile的cli）默认Dot-dropping 丢点，每缩小一个zoom层次，就drop 40%的point features（默认）

## tippecanoe 
    tippecanoe 
    -zg 
        -zg ：自动选择一个 maxzoom，该缩放应该足以清楚地区分每个特征中的特征和细节
    -o /data/my.mbtiles 
    -l layer_name
    --coalesce-densest-as-needed 
        如果切片在低或中等缩放级别下过大，请根据需要将尽可能多的要素合并在一起，以允许使用仍可区分的要素创建切片
    --drop-densest-as-needed 
        如果切片在低缩放级别下太大，删除最不明显的要素，以允许使用保留的要素创建切片
    --extend-zooms-if-still-dropping 
        即使高缩放级别的图块也太大，请继续添加缩放级别，直到达到可以表示所有要素的缩放级别
    --force 
        如果 mbtiles 文件已存在，将其删除
    --read-parallel 
    --no-tile-size-limit 
    '--maximum-tile-features=50000000' ./my.geojson

### min/max zoom 
Show `countries` at low zoom levels but `states` at higher zoom levels

    # -z3 仅生成缩放级别 0 到 3
    tippecanoe -z3 -o countries-z3.mbtiles --coalesce-densest-as-needed ne_10m_admin_0_countries.geojson
    # -Z4 仅生成缩放级别 4 及以上
    tippecanoe -zg -Z4 -o states-Z4.mbtiles --coalesce-densest-as-needed --extend-zooms-if-still-dropping ne_10m_admin_1_states_provinces.geojson
    # merge
    tile-join -o states-countries.mbtiles countries-z3.mbtiles states-Z4.mbtiles

### Dropping参数
https://github.com/mapbox/tippecanoe

### Dropping a fixed fraction of features by zoom level
    8、根据缩放级别舍弃部分要素
    -r rate   或者 --drop-rate=rate     在基准级别以下的瓦片中被舍弃的点的比例(默认2.5)。 如果使用-rg，将会估算一个弃置比，保持瓦片中最多包含50,000个要素。同时也可以使用-rg width 指定一个注记宽度来允许瓦片中保持较少的要素，以适应较大的注记或标记，也可以使用-rf        number来设置瓦片中最多包含的要素数量。

    -B zoom   或者 --base-zoom=zoom   基准级别及以上的瓦片将不做点状数据的抽稀 (默认为最大级别）。如果使用了-Bg，将会根据最大要素数50,000估算基准级别。同时也可以使用-Bg width 指定一个注记宽度来允许瓦片中保持较少的要素，以适应较大的注记或标记，也可以使用-Bf number 来设置瓦片中最多包含的要素数量。

    -al  或者 --drop-lines      让线要素跟点要素一样，在低级别做数据抽稀
    -ap 或者 --drop-polygons    让面要素跟点要素一样，在低级别做数据抽稀


### Dropping a fraction of features to keep under tile size limits
9、舍弃一小部分要素来保持瓦片大小不超限

    -as 或 --drop-densest-as-needed ：如果切片太大，尝试通过增加要素之间的最小间距将其减小到 500K 以下。发现的间距适用于整个缩放级别。
    -ad    或者   --drop-fraction-as-needed             从每一个级别动态舍弃一部分要素来保持瓦片大小不超过500kb限制。 (类似于-pd，但是是应用于整个级别，而不是每一个瓦片)

    -an    或者   --drop-smallest-as-needed            从每一个级别动态舍弃最小的要素(物理上的最小：最短的线或最小的面)来保持瓦片大小不超过500kb限制。该选项对点状要素无效。

    -pd    或者   --force-feature-limit                        动态舍弃部分要素来保持瓦片大小不超过500kb限制(该选项与 -ad 类似，但是是针对每个单独的瓦片，而不是整个缩放级别)。该选项可能会导致瓦片边界区域比较难看，一般情况不建议使用。


### Line and polygon simplification
    -S scale  或者--simplification=scale          简化线和面

    -ps  或者 --no-line-simplification               禁止简化线和面

    -pS  或者 --simplify-only-low-zooms          禁止在最大级别简化线和面 (在低级别仍然执行简化)

    -pt  或者   --no-tiny-polygon-reduction       不要将非常小的多边形区域合并为代表其合并区域的小正方形。