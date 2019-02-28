---
title: 图的路径问题
date: 2019-02-17
---
# 图的路径问题
主要包含这么几个问题
1. 最短路径
2. 一笔画问题
    1. 一笔画的充要条件：奇顶点（连接的边数量为奇数的顶点）的数目等于0(任意起点)或者2(奇顶点为起点)
    2. 如果连通无向图 G 有2k 个奇顶点，那么它可以用k 笔画成，并且至少要用 k 笔画成

#　最短路径问题
## 无权图最短路径：
### 单分支DFS：O(E+V) 通用
时间复杂度O(E+V) 顶点和边只遍历1次. 适合贪心

    def getShortPath(graph, start, end):
        start.color = black
        if start == end:
            return [], True

        nodes = [V for V in start.getConnections() if V.color is white]
        for node in nodes:
            path, status = getShortPath(graph, node, end)
            if status:
                return [start]+path
        return [], False

### 多分支DFS(E^V)
上面的DFS算法不是最优的，最优解需要一个节点被遍历多次, 多分支DFS：$单节点的平均边数^{顶点数}=E^V$

    path = []
    def getShortestPath(graph, start, end):
        start.color = black
        # found
        if start == end:
            return [start], 1

        # not found
        nodes = [V for V in start.getConnections() if V.color is 'white']
        if not nodes:
            return [], 0  # not found

        min_path = []
        minL = 0
        for node in nodes: 
            node.color = gray
        for node in nodes:
            path, L = getShortestPath(graph, node, end)
            if minL == 0 or minL > L: 
                minL = L
                min_path = path
        for node in nodes: 
            node.color = white

        if minL == 0
            return [], 0
        else:
            return [start]+path, minL+1

### BFS(E+V)
BFS：时间复杂度O(V+E) 用队列实现, 得到最优解. 省略

## 有权图最短路径
路径带正权重的方案
1. 如果采用广度优先(队列)，大家的权重增长并不能齐头并进$E^V$。
2. 如果采用深度优先（栈），复杂度为$E^V$，。
3. 权重优先的方法：尽量让权重小的优先增长(`队列+插队` 或 `PriorityQueue`)
    1. 如果遇到访问过的点（黑色）权重更小，就让这个黑色插队


### 权重优先(Dijkstra算法)
如果采用priorityQueue, 插入删除需要`log(V)`，：组合运行时间为 O(`(V + E)log(V))O((V+E)log(V))`

B-C
![](/img/algo/graph-path-weight.1.png)

C-D-E\
![](/img/algo/graph-path-weight.2.png)

B-D-E(`B:8 插队`)\
![](/img/algo/graph-path-weight.3.png)

D-E\
![](/img/algo/graph-path-weight.4.png)
<iframe id="embed_dom" name="embed_dom" frameborder="0" style="display:block;width:525px; height:245px;" src="https://www.processon.com/embed/5a4d81b1e4b0849f9004d8a9"></iframe>

#### 实现
出自[dijkstra] 实现示例

    def dijkstra(aGraph,start):
        pq = PriorityQueue()
        start.setDistance(0)
        pq.buildHeap([(v.getDistance(),v) for v in aGraph])
        while not pq.isEmpty():
            currentVert = pq.delMin()
            for nextVert in currentVert.getConnections():
                newDist = currentVert.getDistance() \
                        + currentVert.getWeight(nextVert)
                if newDist < nextVert.getDistance():
                    nextVert.setDistance( newDist )
                    nextVert.setPred(currentVert)
                    pq.decreaseKey(nextVert,newDist)

### 多分支DFS 方案
伪代码：复杂度是$E^V$

    path = []
    def getShortestPath(graph, start, end):
        start.color = black
        # found
        if start == end:
            return [start], start.weight

        # not found
        nodes = [V for V in start.getConnections() if V.color=='white']
        if not nodes:
            return [], 0  # not found

        min_path = []
        minL = 0
        for node in nodes:
            path, L = getShortestPath(graph, node, end)
            if minL == 0 or minL > L: 
                minL = L
                min_path = path
            node.color = white

        if minL == 0
            return [], 0
        else:
            return [start]+path, minL+start.weight

# 一笔画问题(单分支DFS)
从一个起点一笔画成: 如果路线走入死胡同（not done）就需要backtrack。来自骑士之旅的例子

    from pythonds.graphs import Graph, Vertex
    def knightTour(n,path,u,limit):
        u.setColor('gray')
        path.append(u)
        if n < limit:
            nbrList = list(u.getConnections())
            i = 0
            done = False
            for node in nbrList if node is white:
                done = knightTour(n+1, path, node, limit)
                if done:
                    break
                else: # prepare to backtrack
                    path.pop()
                    u.setColor('white')
        else:
            done = True
        return done

N 个节点，平均每个节点访问的边数K，复杂度就是$k^N$，效率太低: https://facert.gitbooks.io/python-data-structure-cn/7.%E5%9B%BE%E5%92%8C%E5%9B%BE%E7%9A%84%E7%AE%97%E6%B3%95/7.14.%E9%AA%91%E5%A3%AB%E4%B9%8B%E6%97%85%E5%88%86%E6%9E%90/

我们可以先访问边缘的节点，减少进入死胡同。这种知识加速算法被称为启发式。人类每天都使用启发式来帮助做出决策，启发式搜索通常用于人工智能领域。这个特定的启发式称为 Warnsdorff 算法，由 H. C. Warnsdorff 命名，他在 1823 年发表了他的算法.

    # orderbyAvail 代替getConnections
    def orderByAvail(n):
        resList = []
        for v in n.getConnections():
            if v.getColor() == 'white':
                c = 0
                for w in v.getConnections():
                    if w.getColor() == 'white':
                        c = c + 1
                resList.append((c,v))
        resList.sort(key=lambda x: x[0])
        return [y[1] for y in resList]

# 拓扑排序（DFS E+V）
![](/img/algo/graph-topological-order.png)
对一个有向无环图(Directed Acyclic Graph简称DAG)G进行拓扑排序(Topological Order) 
就是[DFS访问的顺序`dfsvisit`][topological]

    from pythonds.graphs import Graph
    class DFSGraph(Graph):
        def __init__(self):
            super().__init__()
            self.time = 0

        def dfs(self):
            for aVertex in self:
                aVertex.setColor('white')
                aVertex.setPred(-1)
            for aVertex in self:
                if aVertex.getColor() == 'white':
                    self.dfsvisit(aVertex) # 防止落单

        def dfsvisit(self,startVertex):
            startVertex.setColor('gray')
            self.time += 1
            startVertex.setDiscovery(self.time)
            for nextVertex in startVertex.getConnections():
                if nextVertex.getColor() == 'white':
                    nextVertex.setPred(startVertex)
                    self.dfsvisit(nextVertex)
            startVertex.setColor('black')
            self.time += 1
            startVertex.setFinish(self.time)

# 强连通分量算法SCC
找到图中高度互连的顶点的集群C 的一种图算法被称为强连通分量算法（SCC）
![](/img/algo/graph-scc.0.png)


SCC 算法步骤:
1.调用 dfs 为图 G 计算每个顶点的完成时间。
![](/img/algo/graph-scc.1.png)

2.计算 $G^T$
3.为图 $G^T$ 调用 dfs，但在 DFS 的主循环中，以完成时间的递减顺序探查每个顶点。
![](/img/algo/graph-scc.2.png)

4.在步骤 3 中计算的森林中的每个树是强连通分量。输出森林中每个树中每个顶点的顶点标识组件。

# Refer
[topological]: https://facert.gitbooks.io/python-data-structure-cn/7.%E5%9B%BE%E5%92%8C%E5%9B%BE%E7%9A%84%E7%AE%97%E6%B3%95/7.15.%E9%80%9A%E7%94%A8%E6%B7%B1%E5%BA%A6%E4%BC%98%E5%85%88%E6%90%9C%E7%B4%A2/
[dijkstra]: https://facert.gitbooks.io/python-data-structure-cn/7.%E5%9B%BE%E5%92%8C%E5%9B%BE%E7%9A%84%E7%AE%97%E6%B3%95/7.20.Dijkstra%E7%AE%97%E6%B3%95/