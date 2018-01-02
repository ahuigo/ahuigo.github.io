---
layout: page
title:
category: blog
description:
---
# Preface
广度优先算法(Breadth First Search) 是一种盲目搜索法

https://en.wikipedia.org/wiki/Breadth-first_search


图片出自维基:

![algorithm-bfs-1.gif](/img/algorithm-bfs-1.gif)

# 复杂度

## 空间
因为所有节点都必须被储存，因此BFS的空间复杂度为O(|V| + |E|)，其中|V|是节点的数目，而|E|是图中边的数目
另一种说法称BFS的空间复杂度为 {\displaystyle O(B^{M})} O(B^M)，其中B是最大分支系数，而M是树的最长路径长度。
由于对空间的大量需求，因此BFS并不适合解非常大的问题。

## 时间
最差情形下，BFS必须寻找所有到可能节点的所有路径，因此其时间复杂度为O(|V| + |E|)，其中|V|是节点的数目，而|E|是图中边的数目。
