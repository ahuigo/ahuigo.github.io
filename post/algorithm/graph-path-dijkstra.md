---
title: Graph Path Dijkstra算法
date: 2021-12-22
private: true
---
# Dijkstra算法
>Dijkstra算法 归类为贪心算法, 动态规划。
## 算法描述

该算法的输入包含了一个有权重的有向图 G:
1. 我们以 V 表示 G 中所有顶点的集合。每一个图中的边，都是两个顶点所形成的有序元素对。(u, v) 表示从顶点 u 到 v 有路径相连。
2. 我们以 E 表示G中所有边的集合，而边的权重则由权重函数 w: E → [0, ∞] 定义。
   1. 因此，w(u, v) 就是从顶点 u 到顶点 v 的非负权重（weight）。边的权重可以想像成两个顶点之间的距离。任两点间路径的权重，就是该路径上所有边的权重总和。

戴克斯特拉算法设置了一顶点集合S:
1. 在集合S中所有的顶点与源点s之间的最终最短路径权值均已确定。
2. 算法反复选择最短路径估计最小的点u, 并将u加入S中

设起点s,对于任意点u来说，`d[u]`是s到u的已知最短路径长度（不一定最短）。松弛操作是戴克斯特拉算法的基础操作：
1. 如果存在一条从u到v的边，那么从s到v的一条新路径是将边w(u,v)添加到从s到u的路径尾部来拓展一条从s到v的路径。
2. 这条路径的长度是`d[u]+w(u,v)`。
3. 如果这个值比目前已知的`d[v]`的值要小，那么可以用这个值来替代当前`d[v]`中的值。
4. 松弛边的操作一直执行到所有的`d[v]`都代表从s到v的最短路径的长度值[1]。

算法维护两个顶点集合{\displaystyle S}S和{\displaystyle Q}Q[1][9]。集合{\displaystyle S}S保留所有已知实际最短路径值的顶点，而集合{\displaystyle Q}Q则保留其他所有顶点[1][9]。集合{\displaystyle S}S初始状态为空，而后每一步都有一个顶点从{\displaystyle Q}Q移动到{\displaystyle S}S[1][9]。这个被选择的顶点是{\displaystyle Q}Q中拥有最小的{\displaystyle d[u]}{\displaystyle d[u]}值的顶点[1][2]。当一个顶点u从{\displaystyle Q}Q中转移到了{\displaystyle S}S中，算法对u的每条外接边{\displaystyle w(u,v)}{\displaystyle w(u,v)}进行松弛[1]。

对于不含负权的有向图，Dijkstra算法是目前已知的最快的单源最短路径算法。

算法步骤：

1. 初始时令 S={V0},T={其余顶点}，顶点对应的距离值:

若存在`<v0,vi>`，d(V0,Vi)为`<v0,vi>`弧上的权值

若不存在`<v0,vi>`，d(V0,Vi)为∞

2. 从T中选取一个其距离值为最小的顶点W且不在S中，加入S

3. 对其余T中顶点的距离值进行修改：若加进W作中间顶点，从V0到Vi的距离值缩短，则修改此距离值

重复上述步骤2、3，直到S中包含所有顶点，即W=Vi为止


![algorithm-dp-1.gif](/img/algorithm-dp-1.gif)

## 演示
如果采用priorityQueue, 插入删除需要`log(V)`，：组合运行时间为 O(`(V + E)log(V))O((V+E)log(V))`

A出发有`B-C` 由于`B:8<C:1`则A到C最短路径确定是1, 将C加入确定集
![](/img/algo/graph-path-weight.1.png)

C-D-E\
![](/img/algo/graph-path-weight.2.png)

B-D-E(`B:8 插队`)\
![](/img/algo/graph-path-weight.3.png)

D-E\
![](/img/algo/graph-path-weight.4.png)
<iframe id="embed_dom" name="embed_dom" frameborder="0" style="display:block;width:525px; height:245px;" src="https://www.processon.com/embed/5a4d81b1e4b0849f9004d8a9"></iframe>

## 实现
出自[dijkstra] 实现示例

    def dijkstra(aGraph,start):
        pq = PriorityQueue()
        start.setDistance(0)
        pq.buildHeap([(v.getDistance(),v) for v in aGraph])
        while not pq.isEmpty():
            currentVert = pq.delMin()
            for nextVert in currentVert.getConnections():
                newDist = currentVert.getDistance() + currentVert.getWeight(nextVert)
                if newDist < nextVert.getDistance():
                    nextVert.setDistance( newDist )
                    nextVert.setPred(currentVert)   # record
                    pq.decreaseKey(nextVert,newDist)

## 扩展
如果有已知信息可用来估计某一点到目标点的距离，则可改用`A*`搜索算法，以减小最短路径的搜索范围，戴克斯特拉算法本身也可以看作是`A*`搜索算法的一个特例.

戴克斯特拉算法本身采用了与Prim算法类似的贪心策略[9][29][30][31]。快速行进算法与戴克斯特拉算法同样有相似之处

# Reference
[dijkstra]: https://www.ixyread.com/read/python-data-structure-cn/7.%E5%9B%BE%E5%92%8C%E5%9B%BE%E7%9A%84%E7%AE%97%E6%B3%95-7.20.Dijkstra%E7%AE%97%E6%B3%95-README.md
[dijkstra wiki]: https://zh.wikipedia.org/wiki/%E6%88%B4%E5%85%8B%E6%96%AF%E7%89%B9%E6%8B%89%E7%AE%97%E6%B3%95