---
layout: page
title:	红包飞的概率问题
date: 2015-03-04
updated: 2019-01-01
---
# 红包飞的概率问题
100元的红包，分给10个人，每个人得的数额是随机的。请设计一个公平的算法，保证每个人得到的金额从数学期望上是相等的。

# 生成红包时就拆分好

## 此时生成10个随机数作权重
按每个随机数据的比例拆分

## 此时生成9个随机数,再排列，以间距拆分红包
生成9个随机数rand(0,100), 然后加一个100，并从小到大排序：s1,s2,...,s9,100. 第一个人得到的金额是s1, 第二个人得到的金额是s2-s1,..., 最后一个人得到的金额是100-s9. 加入的100 不是随机数，这样公平吗？

当然公平！让我们证明一下：假如随机数rand(0,1)

### 最大值的期望

- 1个独立随机数中的最大值小于x 的概率是x^1, 相当于对 dx 求积分，上限x, 下限是0
- 2个独立随机数中的最大值小于x 的概率是x^2, 相当于对 (2*x)dx 求积分，上限x, 下限是0
- ...
- n个独立随机数中的最大值小于x 的概率是x^n, 相当于对 (n*x^(n-1))dx 求积分，上限x, 下限是0

那么n个独立随机数的最大值等于x 的概率是：(n*x^(n-1))dx.
概率乘以x 得(n*x^n)dx 积分上限1，下限0，得到的最大值期望就是：n/(n+1).
9 次随机数的期望就是 9/10. 最后一个获取的金额的期望就是(1/10). 就是公平的

### 最小值的期望
如何计算最小值的期望？

2个独立随机数的最小值大于x 的概率是 `(1-x)^2`, 相当于对 `(2-2x)dx` 积分，上限1，下限x

那么最小值为x的概率就是 `(2-2x)*dx`, 对`(2-2x)*xdx` 积分,得到:`x^2-2/3*x^3`,上限1，下限0，得到 1/3
对`n*(1-x)^(n-1)*xdx` 积分,上限1，下限0，得到n/(n+1)

### 第m个值的期望
在`s1,s2,.sm,..,sn` 中 `sm`来说，其等于x的概率为:
$$
f=C_n^1dx * C_{n-1}^{m-1}x^{m-1} * (1-x)^{n-m} \\
=mC_{n}^{m}x^{m-1} * (1-x)^{n-m} * dx \\
$$

sm的期望为:
$$
\int_0^1 mC_{n}^{m}x*x^{m-1} * (1-x)^{n-m} * dx \\
=\int_0^1 mC_{n}^{m}*x^m * (1-x)^{n-m} dx \\
=\int_0^1 mC_n^m [1-(1-x)]^m * (1-x)^{n-m} dx \\
=\int_0^1 mC_n^m [1-C_m^1(1-x)^1+C_m^2(1-x)^2...+(-1)^mC_m^m(1-x)^m] (1-x)^{n-m} dx \\
=mC_n^m \int_0^1 (1-x)^{n-m}-C_m^1(1-x)^{n-m+1}+C_m^2(1-x)^{n-m+2}- ...\\
+(-1)^mC_m^m(1-x)^n dx \\
=-mC_n^m [ \frac{C_m^0}{n-m+1}(1-x)^{n-m+1}
-\frac{C_m^1}{n-m+2}(1-x)^{n-m+2}+...
..+(-1)^mC_m^m\frac{1}{n+1}(1-x)^{n+1} ]|_0^1 \\
=mC_n^m [ \frac{C_m^0}{n-m+1} -\frac{C_m^1}{n-m+2}+...
..+(-1)^mC_m^m\frac{1}{n+1}] \\
=\frac{m}{1+n}\\
$$

我们利用到了公式:
$$
\binom nm \sum_{i=0}^{m} (-1)^i\frac{\binom mi}{(n-m+1)+i}\\
=\frac{n!}{m!(n-m)!} \frac{m!}{(n-m+1)(n-m+2)...n(n+1)}\\
=\frac{1}{1+n}\\
$$

参考:
https://math.stackexchange.com/questions/715706/partial-fraction-expansion-of-frac1xx1x2-cdotsxn/715718#715718  乘积的倒数，就是数列之和
https://math.stackexchange.com/questions/38623/how-to-prove-sum-limits-r-0n-frac-1rr1-binomnr-frac1n1 数列之和也是分部积分的结果
https://math.stackexchange.com/questions/3058307/prove-that-binom-nm-sum-i-0m-1i-frac-binom-min-m1i-frac11 汇总的

# 发送红包时拆分独立
拆分独立是说发送每一个红包时，独立计算。

    /**
    total 为每次抢的剩余金额
    num	剩余人数
    min	最小金额(不限制最小金额时，min = 0)
    **/

    if(num == 1)
        return total;
    d = total/num - min;		//差值d, max = min+2d
    ram = min + 2d*rand(0,1);	/**期望 E(ram) = min+d **/

    total -= ram
    num -= 1
    return ram;

以上算法中，min 是可以指定的，但是max 是不可以指定的, 也就是 max = min + 2d

在max 指定值的情况下，如何寻找一个概率分布（T分布？正态分布？F分布）的方法，使得值的范围是(min, max), 期望为(total/num)呢？
换句话说，值的范围是(0,max-min) 期望为(total/num - min)

