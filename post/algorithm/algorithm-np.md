---
title: NPC, NP完全
date: 2018-09-26
---
# NPC, NP完全
P 问题：(polynomial time class)
1. 多项式时间（Polynomial time, 指时间复杂度不大于n的多项式倍数, 即不超于`O(n^k)`, `k`为常数. 比如`O(1),O(n),O(n^3)`都属于多项式时间）
2. P问题, 指在多项式时间内可以找出解的决定性问题(decision problem)，

NP: 非决定性多项式集合（non-deterministic polynomial，NP）
1. NP问题, 则包含可在多项式时间内**验证其解**是否正确，但**不保证**能在多项式时间内**能找出解**的决定性问题(不确定是否有多项多解，就是non-deterministic polynomial)。或者说能猜出解的问题。
    1. 比如：背包中能否找出装价值不小于100元的方案？如果有方案，可以在O(n)内验证。所以它是NP问题.
1. 如果一个NP能找出多项式解，那这个NP就是P问题。那么是否所有的NP问题是P?(NP=P?)
    2. 存在一些很难的NP问题（几乎不可能找到多项式解）, 我们叫它NP-complete问题. NPC问题的存在，让我们倾向于相信，NP不会等价于P。

NP完全或NP完备（NP-Complete，缩写为NP-C或NPC）
1. NPC是`NP`与`NP困难,NP-hard`问题的交集，是NP中最难的决定性问题。
2. NPC应该是最不可能被化简为P（多项式时间可决定）的决定性问题的集合。
    2. 归约: A归约为B，就是可以用B的方法解决A。比如一元二次方程求解可转化成一元一次方程
    3. 其他属于NP的问题都可在多项式时间内归约(reduce to)成它A, 那解决了A，那么其它的NP问题都解决了。
    1. 如果一个已知NPC问题可以转化（归约）成A问题，那么A问题也是NPC


## 例子: 子集合加总问题
1. 给予一个有限数量的整数集合，找出任何一个此集合的非空子集且此子集内整数和为零. 
2. 目前能找到的解是遍历每一个集合: C(1, n)+C(2,n)+...+C(n,n)=2^n

### Pascal's triangle, 杨逃三角
杨辉三角形第 n 层（顶层称第 0 层，第 1 行，正好对应于二项式 (a+b)^{n} 展开的系数C(k, n) = C(k-1, n-1) + C(k, n-1)

## Reference
- [NPC]
- 十年程序员难倒了一个算法上面，真的老了 
https://v2ex.com/t/895464?

[NPC]: https://zh.wikipedia.org/wiki/NP%E5%AE%8C%E5%85%A8
