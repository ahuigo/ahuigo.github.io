# sequence of numbers

## 等差数列(arithmetic progression (AP) or arithmetic sequence)
$S_n=n(a_n+a_1)/2=n*a1+n(n-1)d/2$

### 性质
1. 如果m+n=s+t, 则: $a_m+a_n=a_s+a_t$ 成立
1. $S_n, S_{2n}-S_{n}, S_{3n}-S_{2n}...$ 也是等差数列($n^2d$)
1. $S_1, S_2-S_1, S_3-S_2...$ 也是等差数列(d).

1. $S_n = a_1+...+a_n$
1. $S_{2n}-S_n=a_{n+1}+...+a_{2n} = S_n+n^2d$
1. $S_{3n}-S_{2n}=a_{2n+1}+...+a_{3n} = S_n+2n^2d$

## 等比数列
对于$a_1, a_1q^1, a_1q^2, a_1q^3, a_1q^4, ....$ 性质:

0. a1*(1-q^n)/(1-q)
1. $S_1,S_2-S_1,S_3-S_2$是等比: q
1. $S_n,S_{2n}-S_{n},S_{3n} -S_{2n}$ 是等比: $q^n$
2. 如m+n=s+t, 有$a_m a_n=a_s a_t$

分组之和也是等比(n=1 时退化成原数列)

1. $S_n = a_1+...+a_n$
1. $S_{2n}-S_n=a_{n+1}+...+a_{2n} = S_n*q^n$
1. $S_{3n}-S_{2n}=a_{2n+1}+...+a_{3n} = S_n*q^{2n}$

## 等比差数列
1. $S=1+2q^1+3q^2+...+nq^{n-1}$
1. $qS= 1q^1+2q^2+...+(n-1)q^{n-1}+nq^n$
1. $(1-q)S=1+q^1+q^2+...+q^{n-1}-nq^n$
1. $(1-q)S=\frac{1-q^n}{1-q}-nq^n$
1. $S=\frac{1-q^n-nq^n+nq^{n+1}}{(1-q)^2}$

## 数列分解例子(见整式-因式分解)
$\frac{1}{1\times 2}+\frac{2}{1\times 2\times 3}+\frac{3}{1\times 2\times 3\times 4}+...+\frac{9}{1\times 2\times...\times 9}$

注意:
1. $\frac{3}{1\times 2\times 3\times 4}=\frac 1{1\times 2\times 3}-\frac{1}{1\times 2\times 3\times 4}$
1. ${\displaystyle \frac{n}{(n+1)!}=\frac {1}{n!}-\frac{1}{(n+1)!}}$
1. $\frac{3}{3\times 4}=\frac {1}{3}-\frac{1}{3\times 4}$
1. ${\displaystyle \frac{1}{n+1}=\frac {1}{n}-\frac{1}{n(n+1)}}$

