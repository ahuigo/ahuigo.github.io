---
layout: page
title:	如何避免深度递归
category: blog
description: 
---
# 前言
我们先看看函数与递归的本质：

- 函数调用的本质是: 我们在做一件事过程中，我们发现必须要先完成另外一件事，于是中断当前的工作，并把当前的工作信息保存到栈(stack); 当别的事情完成了再继续当前的工作(从stack 中取出工作信息并继续)。
- 对于递归(self call) 来说，当前的工作与另外一件事 相同的是执行步骤，不同的只是工作内容。

再看看本文要讨论的几个问题：

1. 当递归过深的时候，就会面临爆栈的问题(即stack 不够用), 怎么办呢? 能否不用stack 呢？ 其实在特定的条件下, 可以使用尾递归(tail call) , 它不需要使用stack, 也就是它不需要保存当前的工作，而是直接结束当前的任务, 然后执行下一个相同的任务的。
2. 如果递归不属于尾递归呢？即然函数是基于栈的，那么我们完成可以将递归改成显式的基于stack 的循环结构, 这样我们就能直接控制栈的长度。* 深度优先搜索 * 就是这个思路, 快速排序([Quick Sort](/p/algorithm-sort#Quick Sort)) 也可以采用这个方法。
3. 递归的本质是暂停当前的工作，然后完成另外一件或者一批工作。但是，有的时候我们需要，暂停当前的工作，并完成另外一批工作，而且这一批工作需要同时进行。如果用stack 实现这种需求会非常的困难。怎么办呢？队列quenue 能轻易的实现这样的需求: 它是将这一批工作写入队列, 每次从队列头中取出一份工作，并执行一次，工作结束后，就把暂停当前工作并把工作放到队尾，再从队列头取出下一份工作并执行。简而言之，队列可以实现任务的并行执行。*广度优先搜索* 就是这个思路的典型应用。

# tail call 尾递归
尾递归(tail call), 也叫尾调用, 常规的递归(self call)函数有一个问题是: 无法估量其调用栈(每一次递归都会增一次栈开销). 而尾递归不同, 它可以不在调用栈上面添加一个新的堆栈帧——而是更新它，如同迭代一般。尾递归因而具有两个特征([尾调用]):

1. 调用自身函数(Self-called)；
2. 计算仅占用常量栈空间(Stack Space)。//更明确的讲: 每一次递归调用时, 前一次的计算结果传递给下一函数后，都可以丢掉了(即不用再保存在栈中了)

## 一般形式
尾递归的一般形式:
	int f(n, t){
		t = f_tmp(n, t);
		return f(n-1, t);
	}

用循环代替尾递归:

	for(i=n; i>0; i--){
		t = f_tmp(i, t);
	}

可以看出尾递归 算法必须满足: `f(n, t) = f(n-1, f_tmp(n, t))`. 

1. 第一次调用f(n, t): 经过中间计算f_tmp(n, t)后
2. 第二次调用f(n-1, f_tmp(n,t) ), 与上一次的计算结果关, 没有必要对上次计算做栈保存了.

## 实例

	// 这是一个求和的尾递归的示例. 当然, 这只是示例, 对于这个特定的问题, 更高效的是迭代, 比迭代更高效的是(n+1)*n/2
	function f(n, sum = 0){
		if(n == 0 ){
			return sum;
		}
		sum = sum +n; // f_tmp(n, sum) = sum + n;
		return f(n-1, sum);
	}

	//用循环代替尾递归
	sum = 0;
	for(i=n; i>0; i--){
		sum = sum+n;
	}

## 如何实现尾递归
从代码结构上来说，所有的尾递归函数都是在最尾调用自身。那如何做到尾递归呢？

### 去掉尾处理实现tail-call
有些函数，在调用自身后，还有别的尾运算(tail operation). 那我们可以考虑把tail operation 放到前面！具体怎么实现, 不再赘述。

	func(){
		//some general operation
		self call;
		//some tail operation
	}

### 迭代递归中的尾处理: 广义的尾递归
如果递归函数本身包含迭代语句，并且迭代语句会调用递归本身。那么这种递归函数只能改成广义的尾递归.
广义的尾递归有什么意义: 
1. 避免了函数结果的返回(返回栈)，却无法避免调用栈本身的增长; 
2. 但是因为它只有调用栈开销，可以非常容易的改写成基于栈的迭代式(后面会具体描述)。

	//去掉tail operation 就变成广义的尾递归了
	func(){
		//some operation
		while(exp){
			//some operation
			self call;
			//some tail operation
		}
	}

问题：求26个不同字母排列（26!）
下列递归代码的递归深度只有26，每一层需要*维护并返回*的 $pChars大小分别是:26!, 25!,...1! 

	<?php
	function permutationChar($chars){
		$l = count($chars);
		if($l <=1){
			return $chars;
		}
		$pChars = [];
		for($i = 0; $i < $l ; $i++){
			$char = $chars[$i];
			$tChars = $chars;
			if($i !== $l -1) {
				$tChars[$i] = $tChars[$l-1];
			}
			array_pop($tChars);

			foreach(permutationChar($tChars) as $sub){
				$pChars[] = $char.$sub;
			}
		}
		return $pChars;
	}
	var_dump(permutationChar(str_split("abc")));

可以不要*维护并返回* $pChars 吗？ 这样就成了广义的尾递归。

	function permutationChar($chars, &$arr, $pre = ''){
		$l = strlen($chars);
		if($l <=1){
			$arr[] = $pre.$chars{0};
			return ;
		}
		$pChars = [];
		for($i = 0; $i < $l ; $i++){
			$char = $chars{0};

			permutationChar(substr($tChars, 1), $arr, $pre.$char);
			/*foreach(permutationChar($tChars) as $sub){
				$pChars[] = $char.$sub;
			}*/
			$chars = substr($tChars, 1) . $char;
		}
	}
	$arr=[];
	permutationChar("abc", $arr);
	var_dump($arr);


# 用栈+迭代 代替递归
所有的递归函数都可以用基于栈(stack) 的迭代结构去实现, 这样我们就能直接控制栈的长度。我用两个例子具体阐明这个方法: 深度优先搜索[DFS] (Depth First Search) , 字母列组合。 

## 用栈+迭代 实现字母排列
现在我用迭代式来改写上面的广义递归： 即求26个字母的排列.
以下C 代码的
空间复杂度仅为: O(n=NUM) 
时间复杂度为: 

	Time(n) = C(0,n)(n+1) + C(1,n)(n) + C(2,n)(n-1) + .... + C(n-1, n)*2
		= 1*(n+1) + n*n + n(n-1)*(n-1) + ... + n(n-1)(n-2)(n-3)(...)2*2 ~ n*n! 

所以最终的时间复杂度为O(n*n!)



	#include <stdio.h>
	#include <string.h>
	#define NUM 4
	struct stack{
		int i;
		char strL[NUM+1];
		char strR[NUM+1];
	}calls[NUM];
	int top = 0;

	void push(int i, char *strL, char strR[] ){
		calls[top].i = i;
		strcpy(calls[top].strL, strL);
		strcpy(calls[top].strR, strR);
		top++;
	}
	/**
	 * 用栈+迭代 代替递归
	 */
	int main(){
		int i = 0;
		char str[NUM+1];
		while(i<NUM){
			str[i] = 'a' + i;
			i++;
		}

		// 迭代
		struct stack call;
		push(0, "", str);
		char *strL, *strR;
		int Ln, Rn;
		int time = 0;
		int count = 0;
		while(top > 0){
			time++;
			char newStrL[NUM+1] = "", newStrR[NUM+1] = "";
			call = calls[top-1];
			strL = call.strL;
			strR = call.strR;
			i = call.i;
			calls[top-1].i++;
			Rn = strlen(strR);
			Ln = strlen(strL);
			printf("time: %d, strL:%s, strR:%s i:%d\n", time, strL, strR, i);

			//for(i = 0; i < Rn; i++){
			if(i < Rn){
				//newStrR
				strncpy(newStrR, strR, i);
				strncat(newStrR, strR+i+1, Rn-i-1);

				//newStrL
				strcpy(newStrL, strL);
				newStrL[Ln] = strR[i];

				//output result
				if(*newStrR == '\0'){
					printf("The %d's result：in level=%d, str=%s \n",  ++count, top, newStrL);
					continue;
				//new stack
				}else{
					push(0, newStrL, newStrR); //递归深度NUM层
				}
			}else{
				//printf("hahaah\n");
				top--;
			}
		}
		printf("Time(n=%d, Time(n) = %d)", NUM, time);
	}



## DFS(Depth First Search) 深度优先搜索
所有的递归函数都可以用基于stack 的循环结构去实现, 这样我们就能直接控制栈的长度。为了具体阐明这个方法，我举一个关于[DFS] (Depth First Search) 的例子. 

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
- 走过的路, 在maze 中标记为2, 以防止重复走。
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


# BFS(Breadth First Search) 广度优先搜索
深度优先搜索[DFS] 有一个缺点是，找出来的路线不一定是最短的(每次搜索时，都是串行遍历多个线路, 有可能是较长的线路导致了搜索的结束)。	

而广度优先搜索[BFS], 每次搜索时，则是并行遍历多个线路，哪个线路最先到达出口，搜索就结束。最先到达出口的线路为最优解。	
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

# Reference
- [尾调用]
- [阮一峰尾调用]

[阮一峰尾调用]: http://www.ruanyifeng.com/blog/2015/04/tail-call.html
[尾调用]: http://zh.wikipedia.org/wiki/%E5%B0%BE%E8%B0%83%E7%94%A8
[DFS]: http://songjinshan.com/akabook/zh/stackqueue.html#stackqueue-dfs
[BFS]: http://songjinshan.com/akabook/zh/stackqueue.html#stackqueue-bfs
