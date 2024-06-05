---
title: 跳跃表
date: 2017-09-26
priority:
---
# 跳跃表
我们实现redis 的有序集合用什么结构呢？
1. list: 插入的复杂度是O(n)
2. 链表: 查找的复杂度是O(n)

跳跃表(skiplist) 是一种随机化的数据结构，相当于为链表增加了索引，其效率比拟于二叉查找平衡树（平均查找时间是O(logN)）

基本上，跳跃列表是对`有序的链表`增加上附加的`前进链接`，增加是以随机化的方式进行的，所以在列表中的查找可以快速的跳过部分列表(因此得名)。所有操作都以对数随机化的时间进行。

## 跳跃表与红黑树
1. 算法复杂度差不多，红黑实现更复杂一点
2. skiplist 并发更好一点: 红黑涉及rebalance操作，而skiplist只锁需要盯住的节点更少
2. skiplist 内存好像占用比红黑树大一点（每个节点4指针）
## 跳跃表与B树(btree)

skiplist 是内存结构,它不适合存储到硬盘.
- 因为硬盘上的数据读取和写入通常是块操作，而且硬盘的随机访问速度远低于内存
- 如果需要将有序的数据存储到硬盘上，通常会使用一种专门为硬盘或其他直接访问存储器设计的数据结构，如B树或B+树

# skiplist 特点
一个跳表，应该具有以下特征：

	一个跳表应该有几个层（level）组成；
	跳表的第一层包含所有的元素；
	每一层都是一个有序的链表；
	如果元素x出现在第i层，则所有比i小的层都包含x；
	第i层的元素通过一个down指针指向下一层拥有相同值的元素；
	在每一层中，-1和1两个元素都出现(分别表示INT_MIN和INT_MAX)；
	Top指针指向最高层的第一个元素。

缺点：
1. 不像某些传统平衡树数据结构那样提供绝对的最坏情况性能保证, 但是实际工作良好(普通情况)
2. 能解决查找树的节点值必须不同的问题。

高层链表提供查找插入删除的快速通道。查找时，在L层遍历链表，直到出现大于或等于或为空的节点，就开始找下一层。

	1
	1-----4---6
	1---3-4---6-----9
	1-2-3-4-5-6-7-8-9-10

![](/img/ds-skiplist-level.png)

# Skip List构造步骤：

	1、给定一个有序的**链表**。
	2、选择连表中最大和最小的元素，然后从其他元素中按照一定算法（随机）随即选出一些元素，将这些元素组成有序链表。这个新的链表称为一层，原链表称为其下一层。
	3、为刚选出的每个元素添加一个指针域，这个指针指向下一层中值同自己相等的元素。Top指针指向该层首元素
	4、重复2、3步，直到不再能选择出除最大最小元素以外的元素。


#skiplist vs 平衡树
1. 平衡树调整更复杂
2. 范围查找复杂：平衡树比skiplist操作要复杂, 中序遍历的顺序需要进行改造

# 原理
> http://studentdeng.github.io/blog/2013/08/08/skip-list/
> http://blog.csdn.net/zy825316/article/details/22600003

## 期望

### 元素个数期望
如果每个元素被选中并放到上层的概率是 `p = 1/2`， 那么每个元素被插入到i 层的概率是`p^(i-1) = 1/2^(i-1)`, 
在i 层插入的期望元素的个数是 `n*p^(i-1)`, 
skiplist 总元素个数期望是: `n*(p^0+p^1+p^2+ ... + p^(h-1))`, p小于0.5 时，个数小于2n

### 高度h
假设`p=1/2`
> https://izualzhy.cn/skiplist-intro#4-%E8%AF%81%E6%98%8E

高度的期望证明转化为i 层出现元素的概率接近0的情况：

    1. 第i层至少出现一个元素的概率最多为
    P(至少一个) <=P(U1出现)+P(U2出现)+...+ P(Un) = 1/2^i * n = n/2^i  (可能大于1)

    2. 假设i=c*logN, 代入得
        n/2^(c*log(n)) = n/n^c = 1/n^(c-1)
    
    3. 设i=3log(n):
       P = 1/n^2
    
`i=3log(n)`层 出现元素的概率`1/n^2` 是极其小的，可以认为h 高度不超过`3log(n)`, 杂度度是`O（logN）`

> 可以简单的认为，第一层链表会减半, 所以跳跃表无论查找还是插入删除，都是复杂度为`Log(n)`

# Example
Here is an example, https://www.cs.auckland.ac.nz/~jmor159/PLDS210/niemann/s_skl.htm
[example](https://www.cs.auckland.ac.nz/~jmor159/PLDS210/niemann/s_skl.txt)
	
	#include <stdio.h>
	#include <stdlib.h>
	
	/* define data-type and compare operators here */
	typedef int T;                  /* type of item to be stored */
	#define compLT(a,b) (a < b)
	#define compEQ(a,b) (a == b)
	
	/* levels range from (0 .. MAXLEVEL) */
	#define MAXLEVEL 15
	
	typedef struct Node_ {
		T data;                     /* user's data */
		struct Node_ *forward[1];   /* skip list forward pointer */
	} Node;

	typedef struct {
		Node *hdr;                  /* list Header */
		int listLevel;              /* current level of list */
	} SkipList;

	SkipList list;                  /* skip list information */

	#define NIL list.hdr

	Node *insertNode(T data) {
		int i, newLevel;
		Node *update[MAXLEVEL+1];
		Node *x;

	   /***********************************************
		*  allocate node for data and insert in list  *
		***********************************************/

		/* find where data belongs */
		x = list.hdr;
		for (i = list.listLevel; i >= 0; i--) {
			while (x->forward[i] != NIL 
			  && compLT(x->forward[i]->data, data))
				x = x->forward[i];
			update[i] = x;
		}
		x = x->forward[0];
		if (x != NIL && compEQ(x->data, data)) return(x);

		/* determine level */
		for (newLevel = 0; rand() < RAND_MAX/2 && newLevel < MAXLEVEL; newLevel++);

		if (newLevel > list.listLevel) {
			for (i = list.listLevel + 1; i <= newLevel; i++)
				update[i] = NIL;
			list.listLevel = newLevel;
		}

		/* make new node */
		if ((x = malloc(sizeof(Node) + 
		  newLevel*sizeof(Node *))) == 0) {
			printf ("insufficient memory (insertNode)\n");
			exit(1);
		}
		x->data = data;

		/* update forward links */
		for (i = 0; i <= newLevel; i++) {
			x->forward[i] = update[i]->forward[i];
			update[i]->forward[i] = x;
		}
		return(x);
	}

	void deleteNode(T data) {
		int i;
		Node *update[MAXLEVEL+1], *x;

	   /*******************************************
		*  delete node containing data from list  *
		*******************************************/

		/* find where data belongs */
		x = list.hdr;
		for (i = list.listLevel; i >= 0; i--) {
			while (x->forward[i] != NIL 
			  && compLT(x->forward[i]->data, data))
				x = x->forward[i];
			update[i] = x;
		}
		x = x->forward[0];
		if (x == NIL || !compEQ(x->data, data)) return;

		/* adjust forward pointers */
		for (i = 0; i <= list.listLevel; i++) {
			if (update[i]->forward[i] != x) break;
			update[i]->forward[i] = x->forward[i];
		}

		free (x);

		/* adjust header level */
		while ((list.listLevel > 0)
		&& (list.hdr->forward[list.listLevel] == NIL))
			list.listLevel--;
	}

	Node *findNode(T data) {
		int i;
		Node *x = list.hdr;

	   /*******************************
		*  find node containing data  *
		*******************************/

		for (i = list.listLevel; i >= 0; i--) {
			while (x->forward[i] != NIL 
			  && compLT(x->forward[i]->data, data))
				x = x->forward[i];
		}
		x = x->forward[0];
		if (x != NIL && compEQ(x->data, data)) return (x);
		return(0);
	}

	void initList() {
		int i;

	   /**************************
		*  initialize skip list  *
		**************************/

		if ((list.hdr = malloc(sizeof(Node) + MAXLEVEL*sizeof(Node *))) == 0) {
			printf ("insufficient memory (initList)\n");
			exit(1);
		}
		for (i = 0; i <= MAXLEVEL; i++)
			list.hdr->forward[i] = NIL;
		list.listLevel = 0;
	}

	int main(int argc, char **argv) {
		int i, *a, maxnum, random;

		/* command-line:
		 *
		 *   skl maxnum [random]
		 *
		 *   skl 2000
		 *       process 2000 sequential records
		 *   skl 4000 r
		 *       process 4000 random records
		 *
		 */

		maxnum = atoi(argv[1]);
		random = argc > 2;

		initList();

		if ((a = malloc(maxnum * sizeof(*a))) == 0) {
			fprintf (stderr, "insufficient memory (a)\n");
			exit(1);
		}

		if (random) {
			/* fill "a" with unique random numbers */
			for (i = 0; i < maxnum; i++) a[i] = rand();
			printf ("ran, %d items\n", maxnum);
		} else {
			for (i = 0; i < maxnum; i++) a[i] = i;
			printf ("seq, %d items\n", maxnum);
		}

		for (i = 0; i < maxnum; i++) {
			insertNode(a[i]);
		}

		for (i = maxnum-1; i >= 0; i--) {
			findNode(a[i]);
		}

		for (i = maxnum-1; i >= 0; i--) {
			deleteNode(a[i]);
		}
		return 0;
	}
