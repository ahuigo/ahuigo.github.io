---
layout: page
title:	行列有序矩阵的topK
category: blog
description: 
---
# 问题
[问题](http://segmentfault.com/q/1010000000715010)
是这样的，有两个长度都为n的有序递增数组A、 B, 它们的任意两个元素相加构成一个矩阵M(n, n), 求这个矩阵的前K 个最小数。

# 数据集定义

> 非常感谢 @brayden 的启发, 我将M(n*n)矩阵分为三个区域：

- **已经遍历 && 已经选择(结果集R)**
- **已经遍历 && 未选择(待选集S, 使用最小堆结构)**，
- **未遍历(待遍历集U)**

R的所有的元素不大于S, S所有的元素不大于R:

- R <= S <= U

# 操作

1. 初始化，将(a0b0)放到S集（最小堆）,S 集为空
2. 从S 集删除最小元素(即堆顶)，最小元素(ai,bi)放到R 结果集。(如果R足够K, 就结束)
3. 从待遍历集U中: 将(ai,bi+1)放到S集中；如果bi=0, 还得把(ai+1, 0) 放到S集中.
4. 回到步骤2 继续

![](/img/topK-of-matrix-column-row-sorted.png)

# 复杂度
S集元素个数最多为min(K, n). 所以时间复杂度为`O(K*log(min(K, n)))`.

S集需要的空间为`O(min(K,n))`, R集需要的空间`O(K)`, U集不需要空间。

# 代码示例

	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	
	struct heap{
		int ai,bi;
		int v;
	};
	int S_n= 0;
	
	void print_heap(struct heap *S){
		int i=0,j=0;
		int pad = (int)log2((float)S_n);
		int k = 1;
		printf("\n---- print S start --------\n");
		while(i<S_n){
			for(j=0; j<pad;j++){
				printf("%8c", ' ');
			}
			for(j = i+k; i<j && i<S_n; i++){
				printf("%-2d(%d,%d)\t\t", S[i].v, S[i].ai, S[i].bi);
			}
			printf("\n");
			k *=2;
			pad--;
		}
		printf("\n---- print S end --------\n");
	}
	void heap_swap(struct heap *a, struct heap *b){
		struct heap t;
		t=*a;
		*a=*b;
		*b=t;
	}
	
	/**
	 * 向下调整堆: O(logN)
	 */
	void min_heap_down(struct heap *S, int i){
		int left,right;
		while(2*i+1<S_n){
			int mini;
			left = 2*i+1;
			right = left+1;
			mini = left;
			if(right < S_n && S[right].v < S[left].v){
				mini = right;
			}
			if(S[mini].v < S[i].v){
				heap_swap(S+mini, S+i);
				i = mini;
			}else{
				break;
			}
		}
	}
	/**
	 * min_heap_insert: O(logN)
	 */
	void min_heap_insert(struct heap *S, int ai, int bi, int v){
		int i,j,temp;
		struct heap node = {ai, bi, v};
		S[S_n] = node;
		i = S_n;
		while(i > 0){
			j = (i-1)/2;
			if(S[j].v > S[i].v){
				heap_swap(S+i, S+j);
			}else{
				break;
			}
			i = j;
		}	
		S_n++;
	}
	
	/**
	 * min_heap_del: O(logN)
	 */
	void min_heap_del(struct heap *S, int i){
		heap_swap(&S[i], &S[--S_n]);
		min_heap_down(S, i);
	}
	
	/**
	 * topK of matrix[a , b]
	 * 时间复杂度为: O(K * log(min(K,n)))
	 */
	int topK(int *a, int *b, int n, int K, int *R){
		int k=0;
		struct heap *S;
		S = malloc( sizeof(struct heap) * (K<n ? K :n));
	
		//用(a0, b0) 初始化S集
		min_heap_insert(S, 0, 0, a[0]+b[0]);
	
		while(S_n >0){
			struct heap node = S[0];
			min_heap_del(S, 0);
			R[k] = node.v;
			printf("Result: %d k=%d \n", node.v, k);
	
			if(++k < K){
				if(node.bi + 1 < n){
					min_heap_insert(S, node.ai, node.bi+1, a[node.ai] + b[node.bi+1]);
				}
				if(node.bi == 0 && node.ai+1 < n){
					//这个点就是图中左下的粗体小S (node.ai+1, 0), 这个点之所以要加入S集，是为了保证S集小于U集。如果这个点留在U集，就不能保证S <= R了。
					min_heap_insert(S, node.ai+1, 0, a[node.ai+1] + b[0]);
				}
			}else{
				break;
			}
			//print_heap(S);
		};
		free(S);
		return k;
	}
	
	#define N 3
	int main(void) {
		int a[N] = {2,4,5};
		int b[N] = {1,2,6};
		int n=N;
		int K = 6;
		int *R = malloc( sizeof(int) * K);
		int k = topK(a, b, n, K, R);
		return 0;
	}
	
# 继续优化
经 @brayden 的提醒, 图中S列的纵列，只需要一个元素(时间复杂度不变)。
这需要增加一个数组(初始值-1, 大小为min(K, n))：arr[ai] = bi, 如果bi >= 0, 代表 (ai,bi) 这个点及左边的点在R集，否则该行还没有元素加入到R集。	

加入S的标准就变成了(这样纵列和横列就最多有一个元素加入到S集了)：

- 选中元素的右边的点B，如果B上面的点属于R集，则B 点应该加入到S集.
- 选中元素的下边的点A，如果A左边的点属于R集，则A 点应该加入到S集.

代码可以优化为：

	int topK(int *a, int *b, int n, int K, int *R){
		int k=0;
		struct heap *S;
		S = malloc( sizeof(struct heap) * (K<n ? K :n));
	
		//用(a0, b0) 初始化S集
		min_heap_insert(S, 0, 0, a[0]+b[0]);

		//heap_x[ai] = bi . ai 行属于R集的点中，最右边的点在(ai, bi)
		int * heap_x = malloc( sizeof(int) * (K<n ? K :n));
		int i,j;
		for(i=0, j=K<n?K:n,; i<j;i++){
			heap_x[i] = -1;
		}

		struct heap node;
		while(S_n >0){
			node = S[0];
			min_heap_del(S, 0);
			R[k] = node.v;
			printf("Result: %d k=%d \n", node.v, k);
	
			heap_x[node.ai] = node.bi;
			if(++k < K){
				if(node.bi + 1 < n && (node.ai ==0 || node.bi+1 <= heap_x[node.ai-1])){
					min_heap_insert(S, node.ai, node.bi+1, a[node.ai] + b[node.bi+1]);
				}
				if(node.ai+1 < n && (node.bi == 0 || node.bi-1 == heap_x[node.ai+1])){
					min_heap_insert(S, node.ai+1, node.bi, a[node.ai+1] + b[node.bi]);
				}
			}else{
				break;
			}
			//print_heap(S);
		};
		free(S);
		free(heap_x);
		return k;
	}

# 推广
- 如果是M(n,n,n) 三维矩阵呢？那么复杂度为`O(K*log(min(K,n))^2)`, 如果 `K<n` 那么时间复杂度为`O(K*log(K)^2)`
- 如果是M(m,n,o) 矩阵呢？那么复杂度为`O(K*log(min(K,m) * min(K,n) * min(K, o)/ max(K,m,n,o)))`
