# Preface
参考 http://www.ruanyifeng.com/blog/2013/06/rsa_algorithm_part_one.html

## math base
> Ref: 扩展欧几里得算法与中国剩余定理 
    http://blog.miskcoo.com/2014/09/chinese-remainder-theorem

### p1,p2互质的情况
先来考虑只有两个方程, 并且模数p1,p2互质的情况。

(1)假设现在有一个关于 x 的同余方程组(1)：

$x \equiv a_1 \pmod {p_1}$\
$x \equiv a_2 \pmod {p_2}$

(2)两个方程等价于, (2):

$x = a_1 + k_1{p_1}$\
$x = a_2 + k_2{p_2}$

(3)两个方程联立起来，再消去 x, (3):

    a1 + k1p1 = a2 + k2p2

(4)利用扩展欧几里得算法来求出一组整数解(k′1,k′2),根据(3)所有的整数解（p1,p2 互质的）：

    k1=p2t+k′1
    k2=p1t+k′2

代入 (2) 中就可以得到这个同余方程组所有的解：

    x=a1+k1p1
     =a1+p1p2t+k′1p1
     =x0+p1p2t

价于下面这个同余方程：

    x≡x0(mod p1p2)

    如果x0 在 [0,p1p2) 有p1p2个
    对应a1:[0,p1) a2:[0,p2) 也有p1p2个(a1,a2)
    (a1,a2)与x0是一一对应的关系

(5)对于一个同余方程组

    x≡a1(mod p1)
     ≡a2(mod p2)
     ⋮
     ≡an(mod pn)

在这里模数两两互质, 按照刚刚的过程合并得到一个同余方程

    x≡x0(mod p1p2⋯pn)

在这里模数两两互质。

### 模数不是两两互质的话该怎么办?
从只含有两个方程的同余方程组开始

    x≡a1(mod m1)
    x≡a2(mod m2)

和先前一样，展开消去 x 后得到

    a1+k1m1=a2+k2m2

根据裴蜀定理，我们可以知道如果 gcd(m1,m2)∣(a2−a1) 那么这个方程就有整数解，否则它就不存在整数解。

假设我们已经根据扩展欧几里得算法求出了一组特殊解 (k′1,k′2)，那么所有的解是什么呢？
设 g=gcd(m1,m2)，又由于 a2−a1 是 g 的倍数，那么就可以把 (4) 这个方程改写为(5)

    k1m1/g−k2m2/g=(a2−a1)/g

这样的话 m1g 和 m2g 就互质了，那么这个方程所有的整数解就是

    k1=m2/gt+k′1
    k2=m1/gt+k′2

回代入可以得到

    x=a1+k1m1
     =x0+m1m2/gt
     =x0+lcm(m1,m2)t

这个解实际上等价于下面这个同余方程：

    x≡x0(mod lcm(m1,m2))

对于一个同余方程组

    x≡a1(mod m1)
     ≡a2(mod m2)
     ⋮
     ≡an(mod mn)

它等价于

    x≡x0(mod lcm(m1,m2,⋯,mn))

