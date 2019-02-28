---
layout: page
title: 深度优先DFS和广度优先BFS
category: blog
description: 
date: 2018-09-26
---
# DFS(Depth First Search) 深度优先搜索
所有的递归函数都可以用基于stack 的循环结构去实现, 这样我们就能直接控制栈的长度。为了具体阐明这个方法，举一个关于[DFS] (Depth First Search) 的例子.

迷宫问题：下图是一个迷宫，1代表墙, 0 代表路. 入口是左上角，所有的路只能走一次，走的方向只能是东西南北，如果确定走出去路线呢？

	{0,1,0,0,0},
	{0,1,0,1,0},
	{0,0,0,0,0},
	{0,1,1,1,0},
	{0,0,0,1,0},

下面我们利用stack 实现路线的深度搜索。

### 基本思路
- 从入口点maze[0][0], 开始走，只能走上下左右这4个方向；
- 有的点可能有多个方向可走, 就把每个方向的可走点visit_point 压入 stack; (stack 的作用是 保存的行进路线的尾点, 相当于函数调用时保存现场)
- 每次循环时，从stack 中pop 出上次行进路线的尾点，继续走。直到到达出口(MAX_ROW-1, MAX_COL-1) 或者无路可走（is_empty 表示没有路线了）
- 分区：
    1. 标识1代表墙，标识0为可以走的路
    - 走过的路, 在maze 中标记为2, 以防止重复走。
    - 待走的路, 放在stack, 标识为2。
    - 走过的路线保存在 predecessor 采用链表结构。

根据思路完成的代码为：

	#include <stdio.h>
	#define MAX_ROW 5
	#define MAX_COL 5
	struct point { int row, col; } stack[512];
	int top = 0;

	void push(struct point p) {
			stack[top++] = p;
	}

	struct point pop(void) {
			return stack[--top];
	}

	int is_empty(void) {
			return top == 0;
	}

	int maze[MAX_ROW][MAX_COL] = {
			0, 1, 0, 0, 0,
			0, 1, 0, 1, 0,
			0, 0, 0, 0, 0,
			0, 1, 1, 1, 0,
			0, 0, 0, 1, 0,
	};

	void print_maze(void) {
			int i, j;
			for (i = 0; i < MAX_ROW; i++) {
					for (j = 0; j < MAX_COL; j++)
							printf("%d ", maze[i][j]);
					putchar('\n');
			}
			printf("*********\n");
	}

	struct point predecessor[MAX_ROW][MAX_COL] = {
		{-1,-1}, {-1,-1}, {-1,-1}, {-1,-1}, {-1,-1},
		{-1,-1}, {-1,-1}, {-1,-1}, {-1,-1}, {-1,-1},
		{-1,-1}, {-1,-1}, {-1,-1}, {-1,-1}, {-1,-1},
		{-1,-1}, {-1,-1}, {-1,-1}, {-1,-1}, {-1,-1},
		{-1,-1}, {-1,-1}, {-1,-1}, {-1,-1}, {-1,-1},
		{-1,-1}, {-1,-1}, {-1,-1}, {-1,-1}, {-1,-1},
	};

	void visit(int row, int col, struct point pre) {
			struct point visit_point = { row, col };
			maze[row][col] = 2;
			predecessor[row][col] = pre;
			push(visit_point);
	}

	int main(void) {
			struct point p = { 0, 0 };

			maze[p.row][p.col] = 2;
			push(p);

			while (!is_empty()) {
					p = pop();
					if (p.row == MAX_ROW - 1  /* goal */
						&& p.col == MAX_COL - 1)
							break;
					if (p.col+1 < MAX_COL     /* right */
						&& maze[p.row][p.col+1] == 0)
							visit(p.row, p.col+1, p);
					if (p.row+1 < MAX_ROW     /* down */
						&& maze[p.row+1][p.col] == 0)
							visit(p.row+1, p.col, p);
					if (p.col-1 >= 0          /* left */
						&& maze[p.row][p.col-1] == 0)
							visit(p.row, p.col-1, p);
					if (p.row-1 >= 0          /* up */
						&& maze[p.row-1][p.col] == 0)
							visit(p.row-1, p.col, p);
					print_maze();
			}
			if (p.row == MAX_ROW - 1 && p.col == MAX_COL - 1) {
					printf("(%d, %d)\n", p.row, p.col);
					while (predecessor[p.row][p.col].row != -1) {
							p = predecessor[p.row][p.col];
							printf("(%d, %d)\n", p.row, p.col);
					}
			} else
					printf("No path!\n");

			return 0;
	}



# BFS(Breadth First Search) 
深度优先搜索[DFS] 有一个缺点是，找出来的路线不一定是最短的(每次搜索时，都是串行遍历多个线路, 有可能是较长的线路导致了搜索的结束)。

BFS 图片出自维基:
![algorithm-bfs-1.gif](/img/algorithm-bfs-1.gif)

而广度优先搜索[BFS]
1. 每次搜索时，则是并行遍历多个线路，哪个线路最先到达出口，搜索就结束。
2. 最先到达出口的线路为最优解。
3. 只适合权重为1的图，否则：
   1. 要遍历完所有的节点
   2. 每个节点要存放：目前已经搜索到的最短路径
   2. 每个节点要：标记White/Black

队列很好的实现的搜索的并行化(每一次 dequeue 都会给每条路路线一次前进 enqueue 的机会)。 队伍queue 本身也保存了所有走过的点，通过p.predecessor 保存了完整的线路的点的索引链表。

	#include <stdio.h>
	#define MAX_ROW 5
	#define MAX_COL 5

	struct point { int row, col, predecessor; } queue[512];
	int head = 0, tail = 0;

	void enqueue(struct point p) {
			queue[tail++] = p;
	}

	struct point dequeue(void) {
			return queue[head++];
	}

	int is_empty(void) {
			return head == tail;
	}

	int maze[MAX_ROW][MAX_COL] = {
			0, 1, 0, 0, 0,
			0, 1, 0, 1, 0,
			0, 0, 0, 0, 0,
			0, 1, 1, 1, 0,
			0, 0, 0, 1, 0,
	};

	void print_maze(void) {
			int i, j;
			for (i = 0; i < MAX_ROW; i++) {
					for (j = 0; j < MAX_COL; j++)
							printf("%d ", maze[i][j]);
					putchar('\n');
			}
			printf("*********\n");
	}

	void visit(int row, int col) {
			struct point visit_point = { row, col, head-1 };
			maze[row][col] = 2;
			enqueue(visit_point);
	}

	int main(void) {
			struct point p = { 0, 0, -1 };
			maze[p.row][p.col] = 2;
			enqueue(p);

			while (!is_empty()) {
					p = dequeue();
					if (p.row == MAX_ROW - 1  /* goal */
						&& p.col == MAX_COL - 1)
							break;
					if (p.col+1 < MAX_COL     /* right */
						&& maze[p.row][p.col+1] == 0)
							visit(p.row, p.col+1);
					if (p.row+1 < MAX_ROW     /* down */
						&& maze[p.row+1][p.col] == 0)
							visit(p.row+1, p.col);
					if (p.col-1 >= 0          /* left */
						&& maze[p.row][p.col-1] == 0)
							visit(p.row, p.col-1);
					if (p.row-1 >= 0          /* up */
						&& maze[p.row-1][p.col] == 0)
							visit(p.row-1, p.col);
					print_maze();
			}
			if (p.row == MAX_ROW - 1 && p.col == MAX_COL - 1) {
					printf("(%d, %d)\n", p.row, p.col);
					while (p.predecessor != -1) {
							p = queue[p.predecessor];
							printf("(%d, %d)\n", p.row, p.col);
					}
			} else
					printf("No path!\n");

			return 0;
	}

## 复杂度

### 空间
因为所有节点都必须被储存，因此BFS的空间复杂度为O(|V| + |E|)，其中|V|是节点的数目，而|E|是图中边的数目
另一种说法称BFS的空间复杂度为 {\displaystyle O(B^{M})} O(B^M)，其中B是最大分支系数，而M是树的最长路径长度。

### 时间
最差情形下，BFS必须寻找所有到可能节点的所有路径，因此其时间复杂度为O(|V| + |E|)，其中|V|是节点的数目，而|E|是图中边的数目。

## BFS Example2
https://facert.gitbooks.io/python-data-structure-cn/7.%E5%9B%BE%E5%92%8C%E5%9B%BE%E7%9A%84%E7%AE%97%E6%B3%95/7.9.%E5%AE%9E%E7%8E%B0%E5%B9%BF%E5%BA%A6%E4%BC%98%E5%85%88%E6%90%9C%E7%B4%A2/

    def bfs(g,start):
      start.setDistance(0)
      start.setPred(None)
      vertQueue = Queue()
      vertQueue.enqueue(start)
      while (vertQueue.size() > 0):
        currentVert = vertQueue.dequeue()
        for nbr in currentVert.getConnections():
          if (nbr.getColor() == 'white'):
            nbr.setColor('gray')
            nbr.setDistance(currentVert.getDistance() + 1)
            nbr.setPred(currentVert)
            vertQueue.enqueue(nbr)
        currentVert.setColor('black')

# 参考
- [DFS]
- [BFS]

[DFS]: http://songjinshan.com/akabook/zh/stackqueue.html#stackqueue-dfs
[BFS]: http://songjinshan.com/akabook/zh/stackqueue.html#stackqueue-bfs