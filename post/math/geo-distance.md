---
title: 计算球面两点的距离
date: 2018-09-27
---
# 计算球面两点的距离
球面坐标(也就是经纬度)对应的直角坐标为

- $R*sin(a)$
- $R*cos(a)cos(m)$
- $R*cos(a)sin(m)$

假设球面半径R=1, 两点AB直角坐标分别为:
1. $(\sin{a},\cos{a}\cos{m},\cos{a}\sin{m})$
1. $(\sin{b},\cos{b}\cos{n},\cos{b}\sin{n})$

AB直线距离:

$$
AB^2 =(\sin{a}-\sin{b})^2
    +(\cos{a}\cos{m}-\cos{b}\cos{n})^2
    +(\cos{a}\sin{m}-\cos{b}\sin{n})^2
=(\sin^2{a}+\cos^2{a}\cos^2{m} +\cos^2{a}\sin^2{m})
    + (\sin^2{b}+\cos^2{b}\cos^2{n} +\cos^2{b}\sin^2{n})
    -2[sin(a)sin(b)+cos(a)cos(b)(cos(m)cos(n)+sin(m)sin(n))]
=2 -2\sin{a}\sin{b}-2\cos{a}\cos{b}\cos(m-n)
$$

根据余弦定理：

$c^2=a^2+b^2-2ab*cosø$

$AB^2=R^2+R^2-2R^2cos(ø)$

$ø=arccos(1-AB^2/(2R^2)) = arccos(1-AB^2/2)$

$ø=arccos(\sin{a}\sin{b}+\cos{a}\cos{b}\cos(m-n))$

m-n 是经度之差. AB 弧长
$$
Rø=R*arccos(\sin{a}\sin{b}+\cos{a}\cos{b}\cos(m-n))
$$

## 距离估算
arccos,cos,sin 计算比较耗时。 

1. 可以考虑按照平面直角坐标系估算
参考Geohash距离估算
https://www.cnblogs.com/LBSer/p/3298057.html
2. 小距离：$\arccos(cos(ø))$ 近似 $sin(ø)=sqrt(1-cos^2(ø))$

# 参考
- 地理空间距离计算优化
https://tech.meituan.com/lucene_distance.html
