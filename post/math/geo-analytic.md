---
title: Analytic Geometry, 解析几何
date: 2018-09-27
---
# Analytic Geometry, 解析几何
又称为坐标几何（Coordinate geometry）或卡氏几何（Cartesian geometry），早先被叫作笛卡儿几何

# 直线与线段
## 线段
### 线段的定比分点坐标
P是在有向线段 $\vec{P_1 P_2}$ 上的一点, 且 $\lambda = P_1P/PP_2$, 点P就要定比分点

![math/geo-analytic-1.png](/img/math/geo-analytic-1.png)

$x=\frac{x_1 + \lambda x_2}{1+\lambda}$
$y=\frac{y_1 + \lambda y_2}{1+\lambda}$

$x=x_1+(x_2-x_1)\frac{\lambda}{1+\lambda}$

> 主要用于: 已知两点的直线, 反求过x或y轴的P点的 $\lambda$, 进而求P点

## 直线的斜率
1. 斜率: $k=\frac{y2-y1}{x2-x1}$
2. 方程$Ax+By+C=0(B≠0)$ 有 $k=-\frac{A}{B}$

## 点到直线的距离
若在平面坐标几何上的直线定义为ax + by + c = 0，点的座标为（x0, y0），则两者间的距离为：
$d =  \frac{\left|ax_0 + by_0 + c\right|}{\sqrt{a^2+b^2}}$

### 证明
在高中, 利用三角法比较简单(参考的链接):
http://highscope.ch.ntu.edu.tw/wordpress/?p=47407

利用大学的向量更简单:
![math/geo-analytic-2.png](/img/math/geo-analytic-2.png)

## 直线形式
- 点斜式: $y-y_0=k(x-x_0)$
- 两点式: $(y-y_0)/(y_1-y_0)=(x-x_0)/(x_1-x_0)$
- 斜截式: $y=kx+b$
- 截距式: $x/a+y/b=1$

## 直线的关系
对于两直线:
$A_1X + B_1Y + C_1 = 0$ ,
$A_2X + B_2Y + C_2 = 0$

- 相交: $A1B2≠A2B1$
- 平行: $A1B2=A2B1$
- 垂直:
$\frac{A1}{B1}×\frac{A2}{B2}=-1$, $A1A2+B1B2=0$
- 直线的夹角指两条直线所夹的角 $[0,pi/2)$: 利用和差公式
$tanØ=\frac{k2-k1}{1+k2k1}=\frac{A_1B_2-A_2B_1}{A_1A_2+B_1B_2}$

# 一元二次方程, Quadratic Equation
$ax^2+bx+c=0$

## 韦达定理 
根据韦达定理可以找出一元二次方程的根与方程中系数的关系。
${\displaystyle x_{1}+x_{2}={\frac {-b+{\sqrt {b^{2}-4ac\ }}}{2a}}+{\frac {-b-{\sqrt {b^{2}-4ac\ }}}{2a}}={\frac {-2b}{2a}}=-{\frac {b}{a}}}$

${\displaystyle x_1 \cdot x_2={\frac {c}{a}}}$

对称轴:
${\displaystyle \frac{x_1+x_2}{2}=-\frac{b}{2a}}$

极值点:
$\frac{4ac-b^2}{4a}=c-\frac{b^2}{4a}$

# logarithmic, 对数
换底公式:

1. $a^x=M$
2. $\log_b{a^x}=\log_bM$
2. $x\log_b{a}=\log_bM$
2. $x=\frac{\log_b{M}}{\log_ba}=log_aM$