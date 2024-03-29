---
title: 动态规划(Dynamic programing, DP)
date: 2018-09-26
---
# 动态规划(Dynamic programing, DP)
动态规则(Dynamic programing, DP) 的大体思路是(数学归纳法)：将一个特定的问题，切割成若干类似的子问题，最后合并子问题的解并得出总问题的解。

适用场景：

2. 只能用于`最优子结构`的问题，即局部最优解能决定全局最优解（有时需要引入一定近似才能满足要求）.换句话说，问题能分解成子问题
3. 无后效性。子问题的解一旦确认，就不受后续问题干扰。
4. 子问题重叠性。用递归算法自顶向下时，重复的子问题仅计算一次，以减少计算量。为此，递归时得到子问题的解需要被存储，以方便查找。

# 应用
此类问题通常可以化解为：$a^n = f(a^(n-1), a^(n-2), ...)$

## 最短路径
refer: post/algorithm/graph-path-dijkstra.md

## Fabonacci 斐波那契数列
用map 保存子问题的值，减少计算量

	array map [0...n] = { 0 => 0, 1 => 1 }
	fib（n）
		if（map m does not contain key n）
			m[n] := fib(n − 1) + fib（n − 2）
		return m[n]

## Knapsack problem 背包问题
背包属于[NPC](/algorithm/algorith-np), 暂时不存在多项式时间算法。

背包问题解法包括：动态规划、搜索法等; 

近似解有:
1. 贪心法（其中分数背包问题有最优贪心解）等
2. [遗传算法](http://www.cnblogs.com/heaad/archive/2010/12/23/1914725.html): 
 
## LCS 最长公共子序列
http://en.wikipedia.org/wiki/Longest_common_substring_problem

## LIS 最长上升子序列

    3 5 0 1 2 0 8

的LIS 为

    0 1 2 8

设`F_{k}`定义为：以数列中第k项结尾的最长递增子序列的长度.

    F_k = max(F_i+1 | A_k>A_i)
    LIS = max{F_i}

复杂度:

    n + (n-1) + ... + 3 + 2 + 1 = O(n^2)

注意，最长上升子序列可能有多个

    3 5 9 1 2 0 3 中的：
        3,5,9 (以9结尾) 与 1,2,3 (以3结尾)

# References

- [dp]
- [Knapsack problem]

[Knapsack problem]: http://zh.wikipedia.org/wiki/%E8%83%8C%E5%8C%85%E9%97%AE%E9%A2%98
[dp]: http://zh.wikipedia.org/zh/%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92
[LCS]: http://en.wikipedia.org/wiki/Longest_common_subsequence_problem
