# 分类

- 实数: x 的整数部分[x], 小数部分{x}
    - 整数, Integer: ℕ
        - 正整数, positive:
    - 有理无理:
        - 有理数: 两个整数比的数
        - 无理数: $$\sqrt {2}$$,  $$\pi$$
        - $$a+b+2√(ab) = (√a+√b)^2$$
        - $$4-√12 = (√3-1)^2$$
- 虚数: 1+1i

## function
Power function  幂函数 $$x^a=y$$ $$ x=y^(1/a) $$

Exponential_function 指数函数 $$e^x$$
Logarithm:

翻倍：

$$
    (1+x)^10 = 2 ; x=70/10 = 7%
    (1+0.05)^n = 2 ; n=70/5 = 14
$$

## 整除
y被x整除: $$ x|y $$, 即y=ax, 且a不为0


## 公倍数, 公约数
质数: >1 的整数, 2,3,5
a,b 的最小公倍数(包含所有元素): [a,b]
a,b 的最大公约数(包含公共元素): (a,b)

性质0:  $$ a^2*b^2 $$ 与 $$ b^2*c^2 $$ 的最大公约数是: $$ b^2 $$, 最小公倍数是 $$ a^2*b^2*c^2 $$
性质1:  $$ [a,b] * (a,b) = ab $$
性质2:  若 $$ a|bc $$ 且 $(a,b)=1$, 则 $$a|c$$

### 互质, relatively prime
互质（英文：coprime，符号：⊥，又称互素、relatively prime、mutually prime、co-prime）

    //最大公因数为1的 正整数
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

### 欧几里得算法, Euclidean algorithm
欧几里得算法(又叫辗转相除法): a>b, gcd(a,b) 为最大公因数，满足:

    gcd(a,b) = gcd(b, a mod b)
    (a,b) = (b, a mod b)

比如:

    (5,3) (3, 2) (2, 1) (1, 0) 得最大公因为1
    (8,4) (4, 0) 最大公因4

### 扩展扩展欧几里得算法, Extended Euclidean algorithm
扩展算法： 给予二个整数a、b，必存在整数x、y使得

    ax + by = gcd(a,b)

通解：

    x=x0+lcm(a,b)/a*t; //t是任意整数，lcm 是最小公倍数

归纳法证明：
1. 对于b=0, 存在(x,y)=(1, 0) 使得: ax+by=gcd(a,b) 成立
2. 当a>b>0时，假设
    3. ax1+by1=gcd(a, b)
    3. bx2+(a mod b)y2=gcd(a, a mod b)
3. 根据Euclidean 算法，2中的两式其实是相等的：
    4. ax1+by1 = bx2+(a-[a/b]*b)y2 = ay2+b(x2-[a/b]*y2)
4. 所以如果(x2,y2)存在，而一定存在(x1,y1)=(y2, x2-[a/b]*y2)

### 模逆元(数论倒数)
一整数a对同余n之模逆元是指满足以下公式的整数 b

    a^-1 = b (mod n).
    //也可以写成以下的式子
    ab = 1 (mod n).

整数 a 对模数 n 之模逆元存在的充分必要条件是 a 和 n 互素

证明：
1. exgcd(a,n)为扩展欧几里得算法的函数，则可得到ax+ny=g，g是a,n的最大公因数。
2. 若互质g=1, 则两边mod n, 得ax (mod n)= 1 (mod n), x 即为模逆元b
3. 若g!=1, 
    4. 不存在x使 ax (mod n) = 1 (mod n)，
    5. 否则就出现 ax+ny (mod n) = 1 (mod n) 与g!=1矛盾
