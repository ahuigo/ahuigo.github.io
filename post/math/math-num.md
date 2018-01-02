# 分类

    实数: x 的整数部分[x], 小数部分{x}
        整数, Integer: ℕ
            正整数, positive:
        有理无理:
            有理数: 两个整数比的数
            无理数: $\sqrt {2}$,  \\(\pi\\)
            a+b+2√(ab) = (√a+√b)^2
            4-√12 = (√3-1)^2
    虚数:1+1i

## function
Power function  幂函数 x^a=y x=y^(1/a)

Exponential_function 指数函数e^x
Logarithm:
翻倍：
(1+x)^10 = 2 ; x=70/10 = 7%
(1+0.05)^n = 2 ; n=70/5 = 14

## 整除
y被x整除: x|y, 即y=ax, 且a不为0


## 公倍数, 公约数
质数: >1 的整数, 2,3,5
a,b 的最小公倍数(包含所有元素): [a,b]
a,b 的最大公约数(包含公共元素): (a,b)

性质0:  a^2*b^2 与b^2*c^2 的最大公约数是: b^2, 最小公倍数是a^2*b^2*c^2
性质1:  $[a,b] * (a,b) = ab$
性质2:  若 $a|bc$ 且 $(a,b)=1$, 则 $a|c$

### 互质, relatively prime
互质（英文：coprime，符号：⊥，又称互素、relatively prime、mutually prime、co-prime）

    gcd(a,b) = 1
    (a,b) = 1

性质之一：
- 整数a和b互质当且仅当存在整数x,y使得xa+yb=1。可以用扩展欧几里得算法(Extended Euclidean algorithm)
- 或者，一般的，有存在整数x,y使得xa+yb=d，其中d是a和b的最大公因数。（贝祖等式）
- a,b互质且a>b, 则根据带余除法公式: a = bx+c, 存在: a,b,c 两两互质, 结合扩展欧几里得算法可以证明这个贝祖等式

其中m,n 为任意整数:
    7m = 5n+1,  因为7,5 互质
    7m = 4n+1, 因为7,4互质
        4*(0,1,2,3,4,5,6)
        余(0,4,1,5,2,6,3)
