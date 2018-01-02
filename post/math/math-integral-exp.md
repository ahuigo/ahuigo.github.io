# 整式, integral expression

## 整除及带余除法

### 定义
对于:
    $f(x)=a_nx^n+a_{n-1}x^{n-1}+...+a_1x+a_0$
    $g(x)=b_mx^m+b_{m-1}x^{m-1}+...+b_1x+b_0$

若存在多项式
    $h(x)=c_kx^k+c_{k-1}x^{k-1}+...+c_1x+c_0$

使得:
    $f(x)=h(x)g(x)$

则称g(x)整除f(x), 记为 $g(x)|f(x)$, g(x)是因式, f(x)是倍式

### 性质
1. 传递性: 如$h(x)|g(x), 且g(x)|f(x)$ 则 $h(x)|f(x)$
2. 公因式: 如$h(x)|g(x), 且h(x)|f(x)$, 则对于任意u(x)和v(x) 存在 $h(x)|u(x)g(x)+v(x)f(x)$
3. 因式g(x)的次数小于等于f(x)


### 带余除法:
(可利用竖式除法), 对于非0多项式g(x), 对任意f(x)与g(x), 存在q(x), r(x)使得:
    $f(x)=q(x)g(x)+r(x)$, r(x)多项式次数小于g(x).

其中, q(x)是商式, r(x)是余式

### 余数定理:
用一次多项式x-a 去除多项式f(x), 所得余式是一个常数, 这个常数值等于函数值f(a).
因为: $f(x)=q(x)(x-a)+f(a)$

例如: $x+1 除f(x)=x^2-1 +1 = (x-1)(x+1)+1$ 得到的余式为:
$f(-1)=1$

如果x-a是因式: 则f(a)=0

### 一次因式与根的关系
a是f(x)根的充分条件是: $(x-a)|f(x)$

### 多项式因式分解

#### 因式分解法
0. 因式 分解网http://zh.numberempire.com/factoringcalculator.php
1. 提取公因式
2. 透过公式重组，然后再抽出公因数，例子
3. 十字相乘
$ac+ad+bc+bd=a(c+d)+b(c+d)=(a+b)(c+d)$
 即 ${}_{b}^{a}\!X_{d}^{c}$

#### 常用分解
分式分解:
$\frac{2}{7*9}=\frac{1}{7}-\frac{1}{9}$

根式分解:
$\sqrt{4-\sqrt{12}} = 3-2\sqrt{3*1}+1 = \sqrt3-1$

一元三次分解 :
$(x+c)(x^2+ax+b)=$
$x^3+(a+c)x^2+(ac+b)+bc$

请分解一下: $x^3-6x-9$

因式分解 :
$(a±b)^2 = a^2±2ab+b^2$

$(a+b)(a^2-ab+b^2)=a^3+b^3$

$(a-b)(a^2+ab+b^2)=a^3-b^3$

$a^{n}-b^{n}=(a-b)(a^{{n-1}}+a^{{n-2}}b+......+ab^{n-2}+b^{{n-1}})$

$a^{n}+b^{n}=(a+b)(a^{{n-1}}-a^{{n-2}}b+......-ab^{n-2}+b^{{n-1}})$

##### 三次分解
$x^3+x^2+x^1+1=(x+1)(x^2+1)$

### 式子最小值
求最小值:
$x^2+y^2-2x+12y+40 = (x-1)^2+(y+6)^2+3$

求最小值a+b+c:
$a=x^2-2y, b=y^2-2z, c=z^2-2x$

求最小值:
$a^2+b^2+c^2+d^2-ac-ad-bc-bd$
$2a^2+2b^2+2c^2+2d^2-2ac-2ad-2bc-2bd$
$(a-c)^2+(a-d)^2+(b-c)^2+(b-d)^2$

#### 平方和最小值

##### eg.0
1. abc=1, 且a,b,c不全相等

求证: 
$\frac{1}a+\frac{1}b+\frac{1}c>\sqrt{a}+\sqrt{b}+\sqrt{c}$

证明:
1. $\frac{1}a+\frac{1}b+\frac{1}c=ab+bc+ac$
1. $ab+bc+ac=((ab+bc)+(bc+ac)+(ab+ac))/2$
1. $>\sqrt{abbc}+\sqrt{abca}+\sqrt{abcc}$
1. $=\sqrt{a}+\sqrt{b}+\sqrt{c}$

##### eg.1
求证: x,y,z中至少有一个大于0
1. $x=a^2-bc$
1. $y=b^2-ac$
1. $z=c^2-ab$

如果a,b,c不全等, x,y,z中至少有一个大于0, 因为

$x+y+z=a^2+b^2+c^2-bc-ac-ab-bc>0$

##### eg.2
求证: x,y,z中至少有一个大于0
$\frac{a-b}x=\frac{b-c}y=\frac{c-a}z=xyz<0$

因为:
1. $(a-b)+(b-c)+(c-a)=xyz(x+y+z)=0$
1. $x+y+z=0$ 必有一个大于0
