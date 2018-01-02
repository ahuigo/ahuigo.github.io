# 三角形triangle
## 三角心
http://math001.com/triangle_lines_onepoint/

1. 角平分线相交于内心，即内切圆圆心
1. 中线相交于重心. 即切成三个等面积的小三角形
![math-triangle-5.png](/img/math-triangle-5.png)
重心离边的距离是顶点到边的距离的$1/3$

2. 高线相交于垂心
![math-triangle-4.png](/img/math-triangle-4.png)
2. 垂直平分线相交于外心, 即外切圆圆心

![math-triangle-2.png](/img/math-triangle-2.png)

## 三角函数

### 三角恒等式

    tanX^2+1=secX^2
    cotX^2+1=cscX^2

证明

    tanX^2+1=y^2/x^2+1 = (x^2+y^2)/x^2 = r^2/x^2 = secX^2
    cotX^2+1=x^2/y^2+1 = (x^2+y^2)/y^2 = r^2/y^2 = cscX^2
    
练习:

    sina+cosa=1/5
    (sina+cosa)^2=1/25
    sin^2*a+2cosa*sina+cos^2*a=1/25
    2cosa*sina=-24/25
    
    sinx+cosx
    =√2(√2/2*sinx+√2/2cosx)
    =√2(sinxcosπ/4+cosxsinπ/4)
    =√2sin(x+π/4) 
    
    sinx-cosx
    =√2(sinxcosπ/4-cosxsinπ/4)
    =√2sin(x-π/4) 
    
#### 三角函数与双曲函数的恒等式
利用三角恒等式的指数定义和双曲函数的指数定义即可求出下列恒等式：

$e^{ix}=\cos x+i\;\sin x,\;e^{-ix}=\cos x-i\;\sin x$

$e^{x}=\cosh x+\sinh x\!,\;e^{-x}=\cosh x-\sinh x$

所以

$\cosh ix=\frac{e^{ix}+e^{-ix}}{2}=\cos x$

$\sinh ix=\frac{e^{ix}-e^{-ix}}{2}=i\sin x$

$\cosh x = {e^{x}+e^{-x} \over 2}$

$\sinh x={e^{x}-e^{-x} \over 2}$

#### 和差公式
它们也叫做“和差定理”或“和差公式”。最快的证明方式是欧拉公式。

    sin(X+Y)=sinX*cosY+cosX*sinY
    cos(X+Y)=cosX*cosY-sinX*sinY
    cos(pi/2+Ø) = -sin(Ø)
    sin(pi/2+Ø) = cos(Ø)
    cos(pi/2-Ø) = sin(Ø)
    sin(pi/2-Ø) = cos(Ø)
    
    1+sin2x=(sinx+cosx)^2

正弦	$\sin(\alpha \pm \beta )=\sin \alpha \cos \beta \pm \cos \alpha \sin \beta$

余弦	$\cos(\alpha \pm \beta )=\cos \alpha \cos \beta \mp \sin \alpha \sin \beta$

正切	$\tan(\alpha \pm \beta )=\frac  {\tan \alpha \pm \tan \beta }{1\mp \tan \alpha \tan \beta }$

余切	 $\cot(\alpha \pm \beta )={\frac  {\cot \alpha \cot \beta \mp 1}{\cot \beta \pm \cot \alpha }}$

正割	 $\sec(\alpha \pm \beta )={\frac  {\sec \alpha \sec \beta }{1\mp \tan \alpha \tan \beta }}$

余割	 $\csc(\alpha \pm \beta )={\frac  {\csc \alpha \csc \beta }{\cot \beta \pm \cot \alpha }}$

证明: http://old.pep.com.cn/gzsxb/jszx/jxyj/201403/t20140321_1189326.htm
<!--
1.应用三角函数线推导差角公式的方法
![math/math-triangle-1.png](/img/math/math-triangle-1.png)
2.应用余弦定理、两点间的距离公式推导差角公式的方法
![math/math-triangle-2.png](/img/math/math-triangle-2.png)
-->

#### 积化和差与和差化积恒等式
$e^{{ix}}=\cos x+i\;\sin x,\;$
$e^{{-ix}}=\cos x-i\;\sin x$

![math/math-triangle-1.png](/img/math/math-triangle-3.png)

#### 二倍角、三倍角和半角公式
这些公式可以使用和差恒等式或多倍角公式来证明, 二倍角与半角是可互证的

a是夹角：$\cos a=\sqrt{\frac{1}{1+{\tan a}^2}}$

![math/math-triangle-4.png](/img/math/math-triangle-4.png)

![math/math-triangle-5.png](/img/math/math-triangle-5.png)


## 余弦定理
[余弦定理]是三角形中三边长度与一个角的余弦值（cos）的数学式:
$c^{2}=a^{2}+b^{2}-2ab\cos(\gamma )$

## 正弦定理
对于任意  $\triangle ABC，  a、b,c$ 分别为 $\angle A、 \angle B、 \angle C的对边， R为ABC的外接圆半径，则有:

$\frac {a}{\sin \angle A}={\frac {b}{\sin \angle B}}={\frac {c}{\sin \angle C}}=2R$

## 边的关系
$|a-b|<c<a+b$ <1>


## 证明角相等
1. 同一弦对应的圆周角 圆心角相等

## 证明三角形相似
1. 两角相等(余弦定理可求边)
2. 1角相等, 角的两边对应成比例(可求第三边)
3. 三边成比例(可求角)

# 平行四边形
## 证明是平行四边形
1. 一组对边平行且相等
1. 两组对边相等
1. 两组对角相等
1. 两组对角相互平分

# 圆内接四边形
圆内接四边形的充要条件:

1. 圆内同一弦对应的圆周角相等: 圆周角等于对应的圆心角的一半
2. 圆的内接四边形的相对两内角互补180: 同一弦的两侧圆周角,对应圆心角相加360

![math-triangle-1.png](/img/math-triangle-1.png)

3. 托勒密定理:
圆内接四边形的两组对边乘积之和等于两条对角线的乘积（充要）。

4. 相交弦定理(充要): P是圆内接四边形ABCD的两对角线交点，角ABP=角DCP, 则三角形ABP相似于三角形DCP，三角形BCP相似于三角形ADP. 则$AP*CP=BP*DP$

## 托勒密定理
托勒密定理是欧几里得几何学中的一个关于四边形的定理。

1. 托勒密定理指出: 凸四边形*两组对边乘积之和*不小于*两条对角线的乘积*，等号当且仅当四边形为圆内接四边形，或退化为直线取得（这时也称为欧拉定理）。

2. 狭义的托勒密定理也可以叙述为：圆内接凸四边形两对对边乘积的和等于两条对角线的乘积。它的逆定理也是成立的

### 证明
https://zh.wikipedia.org/wiki/%E6%89%98%E5%8B%92%E5%AF%86%E5%AE%9A%E7%90%86

1.1	几何证明
1.2	和差化积证明
1.3	复数证明
1.4	逆定理的几何证明
1.5 反演的证明

#### 几何证明
![math-triangle-3.png](/img/math-triangle-3.png)

    设ABCD是圆内接四边形。
    在弦BC上，圆周角∠BAC = ∠BDC，而在AB上，∠ADB = ∠ACB。
    在AC上取一点K，使得∠ABK = ∠CBD； 因为∠ABK + ∠CBK = ∠ABC = ∠CBD + ∠ABD，所以∠CBK = ∠ABD。
    因此△ABK与△DBC相似，同理也有△ABD相似于△KBC。
    因此AK/AB = CD/BD，且CK/BC = DA/BD；
    因此AK·BD = AB·CD，且CK·BD = BC·DA；
    两式相加，得(AK+CK)·BD = AB·CD + BC·DA；
    但AK+CK = AC，因此AC·BD = AB·CD + BC·DA。证毕, 逆向也可以

## 内接四边形面积
若圆O的圆内接四边形的四边长为a, b, c, d，且外切于圆C，

由于四边形内接于圆O，根据[婆罗摩笈多公式]用以计算圆内接四边形的面积的公式：

$S={\sqrt  {(p-a)(p-b)(p-c)(p-d)}}$

其中p为半周长：
    $p={\frac  {a+b+c+d}{2}}$

[婆罗摩笈多公式]: https://zh.wikipedia.org/wiki/%E5%A9%86%E7%BE%85%E6%91%A9%E7%AC%88%E5%A4%9A%E5%85%AC%E5%BC%8F
[余弦定理]:https://zh.wikipedia.org/wiki/余弦定理
