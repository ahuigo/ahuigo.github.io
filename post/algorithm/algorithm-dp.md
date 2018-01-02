---
layout: page
title:	动态规划(Dynamic programing, DP)
category: blog
description:
---
# Preface

动态规则(Dynamic programing, DP) 的大体思路是：将一个特定的问题，切割成若干类似的子问题，最后合并子问题的解并得出总问题的解。

适用场景：

2. 只能用于`最优子结构`的问题，即局部最优解能决定全局最优解（有时需要引入一定近似才能满足要求）.换句话说，问题能分解成子问题
3. 无后效性。子问题的解一旦确认，就不受后续问题干扰。
4. 子问题重叠性。用递归算法自顶向下时，重复的子问题仅计算一次，以减少计算量。为此，递归时得到子问题的解需要被存储，以方便查找。

# 算法

该算法的输入包含了一个有权重的有向图 G，以及G中的一个来源顶点 S。我们以 V 表示 G 中所有顶点的集合。每一个图中的边，都是两个顶点所形成的有序元素对。(u, v) 表示从顶点 u 到 v 有路径相连。我们以 E 表示G中所有边的集合，而边的权重则由权重函数 w: E → [0, ∞] 定义。因此，w(u, v) 就是从顶点 u 到顶点 v 的非负权重（weight）。边的权重可以想像成两个顶点之间的距离。任两点间路径的权重，就是该路径上所有边的权重总和。已知有 V 中有顶点 s 及 t，Dijkstra 算法可以找到 s 到 t的最低权重路径(例如，最短路径)。这个算法也可以在一个图中，找到从一个顶点 s 到任何其他顶点的最短路径。对于不含负权的有向图，Dijkstra算法是目前已知的最快的单源最短路径算法。

算法步骤：

1. 初始时令 S={V0},T={其余顶点}，T中顶点对应的距离值

若存在<v0,vi>，d(V0,Vi)为<v0,vi>弧上的权值

若不存在<v0,vi>，d(V0,Vi)为∞

2. 从T中选取一个其距离值为最小的顶点W且不在S中，加入S

3. 对其余T中顶点的距离值进行修改：若加进W作中间顶点，从V0到Vi的距离值缩短，则修改此距离值

重复上述步骤2、3，直到S中包含所有顶点，即W=Vi为止


![algorithm-dp-1.gif](/img/algorithm-dp-1.gif)

# 应用

## Fabonacci 斐波那契数列
用map 保存子问题的值，减少计算量

	array map [0...n] = { 0 => 0, 1 => 1 }
	fib（n）
		if（map m does not contain key n）
			m[n] := fib(n − 1) + fib（n − 2）
		return m[n]

## Knapsack problem 背包问题
背包问题解法包括：动态规划、搜索法等; 近似解有: 贪心法（其中分数背包问题有最优贪心解）等

## LCS 最长公共子序列
http://en.wikipedia.org/wiki/Longest_common_substring_problem


# Reference

- [dp]
- [Knapsack problem]

[Knapsack problem]: http://zh.wikipedia.org/wiki/%E8%83%8C%E5%8C%85%E9%97%AE%E9%A2%98
[dp]: http://zh.wikipedia.org/zh/%E5%8A%A8%E6%80%81%E8%A7%84%E5%88%92
[LCS]: http://en.wikipedia.org/wiki/Longest_common_subsequence_problem
