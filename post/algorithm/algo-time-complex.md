# Analysis of Algorithm
## 大O/Omega/Thelta 本质
    A、大O的定义：
    　　如果存在正数c和N，对于所有的n>=N，有f(n)<=c*g(n)，则f(n)=O(g(n))
    B、Big Omega的定义
    　　如果存在正数c和N，对于所有的n>=N，有f(n)>=c*g(n)，则f(n)=Omega(g(n))
    C、Big Theta的定义
    　　如果存在正数c1，c2和N，对于所有的n>=N，有c1*g(n)<=f(n)<=c2*g(n)，则f(n)=Theta(g(n))

e.g.` f(n) = n^3+3*n` 与 n^3 渐近

$$
\displaystyle \lim_{n \rightarrow \infty} \frac{n^3+3\times n}{n^3} = C
$$

## 数学归纳法(代换法：Substitution Method)
求以下算法的big O

    T(n) = 4T(n/2) + n

Solution: 

1. guess O(n^2)
2. Assume: T(k) = C * k^2
3. Then: 
$$ 
    T(n) = 4(C*(\frac{n}{2})^2) +n 
        = Cn^2+n
$$
4. n 无法消去

我们重新假设
1. Assume: $T(k) = C1 * k^2 - C2*k$
2. Then: 
$$ 
    T(n) = 4(C1*(n/2)^2 - C2*n/2) +n 
        = C1n^2 - 2*C2n +n
        = C1n^2 - C2n - (C2 -1)n
        <= C1n^2 - C2n      (if C2>=1)
$$
3. T(1) 满足肯定满足, 证毕

## 递归树法(Recurrence Tree Method)
利用递归树法求: T(n) = T(n/4) + T(n/2) + n^2

         n^2
        /  \
  T(n/4)    T(n/2)

展开

               n^2              1      1
            /       \
        (n/4)^2  (n/2)^2        2      5/16
          /  \     /   \
    (n/16)^2 2*(n/8)^2 (n/4)^2  4       25/256
        /  \  /    \    /  \
(n/64)^2 3(n/32)^2 3(n/16)^2 (n/8)^2  8 (5/16)^3
            ......
    O(1)    ...         O(1)    小于 n

计算1：

    1
    1+4 = 5
    1+2*4 + 16 = 25
    1+3*4 + 3*16 + 64 = 125
    ...
    C(0,n) + C(1,n)*4 + C(2,n)*4^2 ...+ C(n,n)*4^n = (1+4)^n

计算2：

    n^2*[1+5/16+...+(5/16)^2+ ....]
    <= n^2*(1 + 1/2 + 1/4 + ....) = 2n^2
    = O(n^2)

## 主方法(Master Method)
works only for following type of recurrences 

    T(n) = aT(n/b) + f(n) where a >= 1 and b > 1

f(n) 还要满足渐近趋正(asymptotically positive), 总共有 three cases:
1. If f(n) = Θ(n^c) where c < Logb{a} then T(n) = Θ(n^{Logba})  
2. If f(n) = Θ(n^c) where c = Logb{a} then T(n) = Θ(n^c*Log n)
3. If f(n) = Θ(n^c) where c > Logb{a} then T(n) = Θ(f(n))       leaves are the dominant part

Case 2 can be extended for `f(n) = Θ(n^c*(Log n)^k)`
1. If `f(n) = Θ(n^c*(Log n)^k)` for some constant `k >= 0 and c = Logb_a`, then `T(n) = Θ(n^c*(Log n)^(k+1))`

e.g. T(n) = 4T(n/2)+f(n)

    f(n) = n => n^2
    f(n) = n^2 => n^2*Log n
    f(n) = n^3 => n^3

### 证明梗概/思路(Proof sketch/intuition)
https://sites.google.com/site/algorithmssolution/home/c4/master_method

扩展case2 的证明: An Extension to The Master Theorem
http://homepages.math.uic.edu/~leon/cs-mcs401-s08/handouts/extended_master_theorem.pdf

我的手动证明:
![](/img/algo-master-theorem-case2-extended-proof.png)

## Reference
- Analysis of Algorithm | Set 4 
 https://www.geeksforgeeks.org/analysis-algorithm-set-4-master-method-solving-recurrences/