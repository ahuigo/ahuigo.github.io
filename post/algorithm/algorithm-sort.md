---
layout: page
title:	排序算法
category: blog
description:
---
# Preface
常规的几种排序算法, 参考[维基sort](http://zh.wikipedia.org/wiki/%E6%8E%92%E5%BA%8F%E7%AE%97%E6%B3%95)

|名称	|数据对象	|稳定性	|时间复杂度(平均/最坏)	|空间复杂度	|描述|
|冒泡排序|数组,链表	|是	|O(n^2)	|O(1)	|（无序区，有序区）。从无序区通过交换找出最大元素放到有序区前端。|
|插入排序|数组,双链表	|是	|O(n^2)	|O(1)	|（有序区，无序区）。把无序区的第一个元素插入到有序区的合适的位置。对数组：比较得少，换得多。|
|选择排序|数组,链表	|否/是|O(n^2)	|O(1)	|（有序区，无序区）。在无序区里找一个最小的元素跟在有序区的后面。对数组：比较得多，换得少。|
|堆排序	|数组,链表	|否	| O(nlogn)	|O(1)	|（最大堆，有序区）。从堆顶把根卸出来放在有序区之前，再恢复堆。|
|归并排序|数组、链表|是	| O(nlogn)	|O(n) +O(logn) ，如果不是从下到上	|把数据分为两段，从两段中逐个选最小的元素移入新数据段的末尾。可从上到下或从下到上进行。|
|快速排序|数组,链表	|否/是|O(nlogn), O(n^2)	|O(logn) ,O(n)	|找一个中值分成两堆|
|希尔排序	|数组	|否	|O(nlog^2n), O(n^2)	|O(logn) ,O(n)	|每一轮按照事先决定的间隔进行插入排序，间隔会依次缩小，最后一次一定要是1。|
|计数排序|数组、链表|是	|O(n+m)	|O(n+m)	|统计小于等于该元素值的元素的个数i，于是该元素就放在目标数组的索引i位（i≥0）。|
|桶排序	|数组、链表	|是	|O(n)	|O(n)	|将值为i的元素放入i号桶，最后依次把桶里的元素倒出来。|
|基数排序|数组、链表|是	|O(n)	|O(n)	|一种多关键字的排序算法，可用桶排序实现。|
|二叉查找树排序|链表|否	|O(n*logN), 最坏O(n^2)	|O(n)	|初始化二叉树需要平均n*logN, 中序遍历二叉树需要时间n|

- 均按从小到大排列
- k代表数值中的"数位"个数
- n代表数据规模
- m代表数据的最大值减最小值

> 其中基于比较的算法的极限是O(n*logn). 比较排序可以被抽象为一棵完全二叉树(数列组合有n! 种)，每一次比较只能排除一半的可能，至少需要比较x次，2^x > n!,
> x >= log2(n!) 才能区分所有的情况，否则不能区分满射。根据特林公式：n! ~ (2*pi*n)^(1/2) * (n/e)^n, 有O(n!) ~ O(n*log(n/e))

<img src="//zhihu.com/equation?tex=k%5Cgeq+log_%7B2%7D%28%5Csqrt%7B2%5Cpi+n%7D+%5Cleft%28+%5Cfrac%7Bn%7D%7Be%7D++%5Cright%29%5E%7Bn%7D%29+%3Dlog_%7B2%7D%28%5Csqrt%7B2%5Cpi+n%7D%29%2Bnlog%5Cleft%28+%5Cfrac%7Bn%7D%7Be%7D++%5Cright%29%3DO%5Cleft%28+nlogn+%5Cright%29+" alt="k\geq log_{2}(\sqrt{2\pi n} \left( \frac{n}{e}  \right)^{n}) =log_{2}(\sqrt{2\pi n})+nlog\left( \frac{n}{e}  \right)=O\left( nlogn \right) " eeimg="1">

	OS: winxp, Compiler: vc8, CPU：Intel T7200,  Memory: 2G
	不同数组长度下调用6种排序1000次所需时间（秒）

	length          shell           quick           merge           insert          select          bubble
	100             0.0141          0.359           1.875           0.204           0.313           0.421
	1000            0.218           0.578           2.204           1.672           2.265           4
	5000            1.484           3.25            14.14           41.392          63.656          101.703
	10000           3.1             7.8             23.5            253.1           165.6           415.7
	50000           21.8            40.6            121.9           411.88          6353.1          11648.5
	100000          53.1            89              228.1           16465.7         25381.2         44250


结论：
数组长度不大的情况下不宜使用归并排序，其它排序差别不大。
数组长度很大的情况下Shell最快，Quick其次，冒泡最慢。

# Bubble Sort 冒泡排序

	/**
	 * 冒泡排序
	 */
	void bubble_sort(int *arr, int n){
		int i,j,flag;
		for(j=0;j<n-1;j++){
			flag = 0;
			for(i=0; i<n-j-1;i++){
				if(arr[i]>arr[i+1]){
					flag = 1;
					arr[i] = arr[i]^arr[i+1];
					arr[i+1] = arr[i]^arr[i+1];
					arr[i] = arr[i]^arr[i+1];
				}
			}
			if(flag == 0){
				break;
			}
		}
	}


# Insert Sort 插入排序
时间复杂度O(n^2)

	#include <stdio.h>
	#define L 5
	void insert_sort(int *arr, int n);
	int main(){
		int arr[L]={3,10, 2, 8, 7};
		int i=0;
		insert_sort(arr, L);
		do{
			printf("%d ",arr[i]);
		}while(++i<L);
	}

	/**
	 * 插入排序
	 * 这类似于洗牌时的插入排序手法：从右到左（或者从左到右），找一个插入点
	 */
	void insert_sort(int *arr, int n){
		int i,j,v;
		for(j=1;j<n;j++){
			v = arr[j];
			for(i=j-1; i>=0 && arr[i] > v;i--){
				arr[i+1] = arr[i];
			}
			arr[i+1] = v;
		}
	}

# Shell Sort 希尔排序
希尔排序(Shell Sort) 是对插入排序的推广。
其基本思想是， 希尔排序通过将比较的全部元素分为几个区域来提升插入排序的性能。这样可以让一个元素可以一次性地朝最终位置前进一大步。然后算法再取越来越小的步长进行排序，算法的最后一步就是普通的插入排序，但是到了这步，需排序的数据几乎是已排好的了（此时插入排序较快）
从这个角度上说Shell Sort 属于分组排序

复杂度:
Shell Sort 的时间复杂度 依赖于一个步长的增量序列(Increment Sequence), 这涉及到数学上未解决的难题, 通常认为是O(n^(5/4))。下表展示了常见序列下的时间复杂度。此外，希尔排序是不稳定的, 因为分组移动时扰乱了同值元素的次序。

|步长序列|	最坏情况下复杂度|
|`{n/2^i}`|	`\mathcal{O}(n^2)`|
|`2^k - 1`|	`\mathcal{O}(n^{3/2})`|
|`2^i*3^j`|	`\mathcal{O}( n\log^2 n )`|

已知的在大数组中表现优异的步长序列是( 斐波那契数列除去0和1将剩余的数以黄金分割比的两倍的幂进行运算得到的数列)：

	（1, 9, 34, 182, 836, 4025, 19001, 90358, 428481, 2034035, 9651787, 45806244, 217378076, 1031612713, …

斐波那契数列(Fibonacci Sequence)公式 是

	f(n) = f(n-1) + f(n-2); 数列为: 1、1、2、3、5、8、13、21.

当n 越大f(n)/f(n-1) 越接近黄金分割(sqrt(5)-1)/2 = 0.618,  见[Fibonacci]

对应的shell sequence是

	a(n) = floor(fibonacci(n+1)^(sqrt(5)+1)

以下shell 排序所有的序列基于 斐波那契数列 :

	#include <stdio.h>
	#include <math.h>
	int fibonacci[100] = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144};

	int init_fibo(int n){
		int fibo_top = 0;
		//int t = 1 + pow(5, 0.5);//3.2361
		while(n >  (int)floor(pow(fibonacci[fibo_top], 3.2361)) ){
			fibo_top++;
			if(fibo_top>=2){
				fibonacci[fibo_top] = fibonacci[fibo_top-1] + fibonacci[fibo_top-2];
			}
		}
		return --fibo_top;
	}
	void shell_sort(int *arr, int n){
		int top = 0;
		int seq = 1;
		int i, tmp, j;
		top = init_fibo(n);
		while(top >= 0){
			seq = fibonacci[top--];
			//按步长 seq 分组
			for(i=seq; i < n; i++){
				//插入排序
				tmp = arr[i];;
				for(j = i - seq; j >= 0 && arr[j] > tmp; j -= seq){
					arr[j+seq] = arr[j];
				}
				arr[j+seq] = tmp;
			}
		}
	}

	int main(){
		int arr[12] = {9,23,1, 3, 290,0,
			900,1 ,23, -9, 19, 10};
		shell_sort(arr, 12);
		int i = 0;
		while(i<12){
			printf("%d\t", arr[i++]);
		}
	}

希尔排序到1 million 以下的表现比快速排序快。

# Select Sort 选择排序
- 插入排序关键是找插入点: 数据比较多，数据移动较少.
- 而选择排序则是每一次找一个最大(小)值, 数据比较较多, 数据移动少
- 稳定性: 不稳定(有可能交换使同值元素换位) 但是如果愿意新增加一个数据(消耗O(n)), 则可以实现稳定的选择排序。

代码：

	/**
	 * 示例为不稳定的选择排序 空间复杂度是O(1).
	 * 注意: 如果需要稳定的选择排序: 对于数组,可以加一个结果数组，空间复杂度是O(n); 对于链表，不需要增加结果数组，空间复杂度仍然为O(1)
	 */
	void select_sort(int *arr, int n){
		int i=0,j, min;
		while(i < n){
			min = i;
			for(j=i+1;j<n; j++){
				if(arr[j] < arr[min]){
					min = j;
				}
			}
			arr[i] = arr[i] ^ arr[min];
			arr[min] = arr[i] ^ arr[min];
			arr[i] = arr[i] ^ arr[min];
			++i;
		}
	}


# Heap Sort 堆排序
- 空间复杂度: O(1)
- 时间复杂度：通过大（小）堆(O(log n)), 选出堆的最大值(O(logN))，并放到堆末尾的有序区间
- 类似选择排序: 最小堆的根被换到最后，得到一个从大到小的有序区间
- 稳定性：因为同值的元素有的会被顶上去，有的会被顶下去，所以堆排序不是稳定排序

操作：

- 插入堆: 自下往上(新加的数据从下往上挤)，比较+移动, O(log n)
- 删除堆: 自上往下(从尾部挪动一个节点到空隙，然后往下挤)，比较+移动, O(log n)
- 堆初始化: 自n/2 往上遍历，每次遍历时未堆化的根节点需要*往下挤*，O(n*logN). 因为可能会使同值的节点的相对顺序发生变化，这使得堆排序成为不稳定排序
- 堆调整(修改节点值): 从节点开始，往上或者往下做调整，O(logN)

	总的时间 = 堆化的时间O(n*logN)+选择n个数*log(N) = 2*O(n*logN) = O(n*logN)

以下是c 语言版堆排序：

	#include <stdio.h>
	/**
	 * 最大堆调整
	 */
	void max_heapify(int *arr, int i, int n){
		int left,right,t;
		while(2*i+1<n){
			int maxi;
			left = 2*i+1;
			right = left+1;
			maxi = left;
			if(right < n && arr[right] > arr[left]){
				maxi = right;
			}
			if(arr[maxi] > arr[i]){
				t = arr[maxi];
				arr[maxi] = arr[i];
				arr[i] = t;
				i = maxi;
			}else{
				break;
			}
		}
	}
	void init_max_heap(int *arr, int n){
		int i;
		for(i = (n-2)/2; i>=0; i--){
			max_heapify(arr, i, n);
		}
	}

	void heap_sort(int *arr, int n){
		int j = n, t ;
		init_max_heap(arr, n);
		while(--j > 0){
			t = arr[0];
			arr[0] = arr[j];
			arr[j] = t;
			max_heapify(arr, 0, j);
		}
	}
	int main(void)
	{
		int arr[12] = {9,23,1, 3, 290,0,
			900,1 ,23, -9, 19, 10};
		int i = 0;
		heap_sort(arr, 12);
		i = 0;
		printf("\n");
		while(i<12){
			printf("%d\t", arr[i++]);
		}
	}

> 最大堆与最小堆 可以应用于 topK 问题，实现O(n*logK) 的时间复杂度.
当K 特别大时，topK 问题也可以通过快速排序(Quick Sort)中的中值索引i, 实现平均时间复杂度O(1+2...+n) = O(2n) = O(n). 这种算法的缺点是原始数据移动(n)和内存消耗(logN)比较大。

# Merge Sort 归并排序
归并排序不适合小数组
原理：采用分而治之的思想. 递归深度为logN, 总的时间分为归并时间NlogN + merge_sort本身的时间2N, 所以总的时间复杂度为O(NlogN). 总的空间复杂度是O(n)+logN (logN 是递归时栈所消耗的空间)

- 空间复杂度 `O(n)`
- 稳定性：是

代码：

	/**
	 * @brief 归并排序
	 *
	 * @param *list 要排序的数组
	 * @param n 数组中的元素数量
	 */
	void merge_sort(int *list, int list_size)
	{
		if (list_size > 1)
		{
			// 把数组平均分成两个部分
			int *list1 = list;
			int list1_size = list_size / 2;
			int *list2 = list + list_size / 2;
			int list2_size = list_size - list1_size;
			// 分别归并排序
			merge_sort(list1, list1_size);
			merge_sort(list2, list2_size);

			// 归并
			merge_array(list1, list1_size, list2, list2_size);
		}
	}

	/**
	 * @brief 归并两个有序数组
	 * @param list1
	 * @param list1_size
	 * @param list2
	 * @param list2_size
	 */
	void merge_array(int *list1, int list1_size, int *list2, int list2_size)
	{
		int i, j, k;
		i = j = k = 0;
		int *list = malloc((list1_size + list2_size)*sizeof(int));

		while (i < list1_size && j < list2_size) {
			list[k++] = list1[i] < list2[j] ? list1[i++] : list2[j++];
		}
		while (i < list1_size) {
			list[k++] = list1[i++];
		}
		while (j < list2_size) {
			list[k++] = list2[j++];
		}

		for (int ii = 0; ii < (list1_size + list2_size); ++ii) {
			list1[ii] = list[ii];
		}
		free(list);

	}

# Quick Sort 快速排序
Merge Sort 和Quick Sort 都使用了分而治之的思想，递归深度为logN, 时间都是O(NlogN)。

- 空间复杂度 `O(logN)`
- 稳定性： 否

与Merge Sort 不同的是, Merge Sort 通过位置做划分（主要是合并, 合并时需要空间O(n)）,
而Quick Sort 是通过值做划分，主要工作是划分本身, 划分时只需要给一点栈空间(logN)，而且Quick Sort 排序不稳定. 如果需要稳定的 Quick Sort, 则需要空间O(n);
> 从概率上说， 快速排序的平均速度比堆排序要快一些

	void quick_sort(int *arr, int n){
		if(n>1){
			int i,j,val;
			i=0; j = n-1;
			//val 作为中值
			val = arr[0];
			while(i < j){
				//从后向前找比val 小的 并将其移动到左边
				for(;i<j; j--){
					if(arr[j] < val){
						arr[i] = arr[j]; // j 被空出来
						i++;
						break;
					}
				}
				//从前向后找比val 大的 并将其移动到右边
				for(; i<j; i++){
					if(arr[i] > val){
						arr[j] = arr[i]; //i 被空出来
						j--;
						break;
					}
				}
			}
			arr[i] = val;
		}
		if(i>1) quick_sort(arr, i);
		if(n-i>2) quick_sort(arr+i+1, n-i-1);
	}

上面的代码利用到了递归，如果调用栈过深，可以直接给定一个比较大的调用栈

	#include <stdio.h>
	#define MAX_STACK 200
	struct call{
		int *arr;
		int n;
	};
	struct call stack[MAX_STACK];
	int top = 0;
	int is_empty(){
		return top == 0;
	}
	void push(struct call c){
		stack[top++] = c;
	}
	struct call pop(void){
		return stack[--top];
	}

	/**
	 * Quick Sort 非递归
	 */
	void quick_sort(int *arr, int n){
		struct call c = {arr, n};
		push(c);

		while(!is_empty()){
			c = pop();
			arr = c.arr;
			n = c.n;
			int i,j,val;
			if(n>1){
				i=0; j = n-1;
				//val 作为中值
				val = arr[0];
				while(i < j){
					//从后向前找比val 小的 并将其移动到左边
					for(;i<j; j--){
						if(arr[j] < val){
							arr[i] = arr[j]; // j 被空出来
							i++;
							break;
						}
					}
					//从前向后找比val 大的 并将其移动到右边
					for(; i<j; i++){
						if(arr[i] > val){
							arr[j] = arr[i]; //i 被空出来
							j--;
							break;
						}
					}
				}
				arr[i] = val;
			}
			if(i>1){
				c.arr = arr;
				c.n = i;
				push(c);
			}
			if(n-i > 2){
				c.arr = arr+i+1;
				c.n = n-i-1;
				push(c);
			}
		}
	}
	int main(){
		int arr[6] = {9,23,1, 3, 290,0};
		quick_sort(arr, 6);
		int i = 0;
		while(i<6){
			printf("%d\t", arr[i++]);
		}
	}

> Quick Sort 中的中值可以应用于 Kth 搜索，平均时间复杂度是: n + n/2 + .. + 1 = 2n

> 下面介绍三种线性排序算法: Counting/Bucket/Radix 它们突破了比较排序的极限: O(NlogN), 要说明的是，它们是通过牺牲空间 以及满足一定特性来达到线性排序的。

# Counting Sort 计数排序
时间复杂度是 O(2n + 2m) = O(n+m), 空间复杂度: O(n+m). m 指的是数的范围
适用范围: 值域有限，且比较小的情况。比如1~100间的数字.
计数排序可以用在基数排序中的算法来排序数据范围很大的数组。

	/**
	 * 稳定的计数排序
	 */
	void counting_sort(int *ini_arr, int *sorted_arr, int n) {
			//空间：O(m)
			int *count_arr = (int *)malloc(sizeof(int) * 100);
			int i, j, k;
			//O(m)
			for(k=0; k<100; k++){
					count_arr[k] = 0;
			}
			//O(n)
			for(i=0; i<n; i++){
					count_arr[ini_arr[i]]++;
			}
			//O(m)
			for(k=1; k<100; k++){
				count_arr[k] += count_arr[k-1];//让计数本身代表排序的位置(count-1)
			}
			//O(n)
			for(j=n; j>0; j--){
					sorted_arr[--count_arr[ini_arr[j-1]]] = ini_arr[j-1];
			}
			free(count_arr);
	 }

	/**
	 * 不稳定的计数排序, 通常叫鸽巢排序
	 */
	void counting_sort(int *ini_arr, int *sorted_arr, int n) {
			int *count_arr = (int *)malloc(sizeof(int) * 100);
			int i, j, k;
			for(k=0; k<100; k++){
					count_arr[k] = 0;
			}
			for(i=0; i<n; i++){
					count_arr[ini_arr[i]]++;
			}
			j=0;
			for(k=1; k<100; k++){
				for(i=0; i< count_arr[k];i++){
					sorted_arr[j++]	= k;
				}
			}
			free(count_arr);
	 }

交换法

	a=a^b
	b=a^b a^b^b == a
	a=a^b a^b^a == b


# Bucket Sort 桶排序
计数排序(鸽巢排序)只能排序小范围的整数，而桶排序是对计数排序(鸽巢排序)的扩展，可以实现对均匀分布的小数做排序(特别是均匀分布数据)

- 场景: 适合均匀分布的小数(包括整数)，否则桶的长度波动太大，时间复杂度会增加。
- 原理: 1. 将数组放进数量有限的m 个桶子. 2. 然后对每个桶进行再排序(可以是选择，也可以是冒泡, 也可以是快速排序). 3. 最后合并所有的桶子。
- 稳定性: 如果放桶与出桶的顺序是一致的，那么顺序就是稳定的。所以稳定性依赖于对桶内元素的排序
- 复杂度: 当数据是均匀分布的，每个桶平均有元素 n/m 个，对单独的桶使用快速/冒泡等排序, 设k=n/m。

从下面的代码可以看到，时间复杂度为:

	初始化的时间 + 放桶时间 + 出桶时间, 一般m 接近n(k 是一个有限的常数), 所以桶排序的时间复杂度被认为是线性的O(n)
		O(n+m) + O(kn) + O(kn) = O(kn) = O(n)

空间复杂度为：O(n+m) = O(n) (m接近n)


	#include <stdlib.h>
	#include <stdio.h>
	#include <math.h>
	struct bucket{
		float num ;
		struct bucket * r;
	};

	/**
	 * 对单链表做冒泡排序 时间：O(k^2)
	 */
	void link_bubble_sort(struct bucket * head){
		struct bucket * ptr;
		int end = 0;
		int flag;
		float temp;
		if(head->r){
			do{
				ptr = head;
				flag = 0;
				while((int)ptr->r != end){
					if(ptr->num > ptr->r->num){
						flag = 1;
						temp = ptr->num;
						ptr->num = ptr->r->num;
						ptr->r->num = temp;
					}
					ptr = ptr->r;
				}
				end = (int)ptr;
				if(!flag){
					break;
				}
			}while((int)head->r != end);
		}
	}
	/**
	 * 桶排序
	 * 设置m个桶, 平均每个桶有元素k (k=n/m) 个
	 */
	void bucket_sort(float *arr, int n, float min, float max){
		if(n < 2){
			return;
		}
		//buckets 空间：O(n) 初始化时间:O(n)
		struct bucket * buckets = calloc(sizeof(struct bucket) , n);
		int buckets_len = 0;

		int m = n/2;
		//bucket_head 空间:O(m) 初始化时间:O(m)
		struct bucket * (*bucket_head) = calloc(sizeof(struct bucket *), m);
		struct bucket * ptr;
		int i,j;

		//链表有k个元素，查找时间是O(K)
		//放桶的时间： O(n) * O(k) = O(n*k).
		for(i=0; i<n ;i++){
			//j号桶
			j = floor( m * (arr[i]-min) / (max - min));
			if(bucket_head[j] == NULL){
				bucket_head[j] = &buckets[buckets_len];
				ptr = bucket_head[j] ;
			}else{
				ptr = bucket_head[j];
				while(ptr->r != NULL){
					ptr = ptr->r;
				};
				ptr->r = &buckets[buckets_len];
				ptr = ptr->r;
			}
			ptr->num = arr[i];
			buckets_len++;
		}
		//出桶的时间, 依赖于具体的排序算法，如果使用插入/冒泡/选择...排序，每个桶的排序时间为O(k^2),
		//出桶的总时间为: O(m*k^2 + n)= O(n*k +n) = O(kn)
		for(i=0, j=0; j<m; j++){
			ptr = bucket_head[j];
			if(ptr != NULL){
				//bubble_sort
				link_bubble_sort(ptr);
				while(ptr != NULL){
					//result
					arr[i++] = ptr->num;
					ptr = ptr->r;
				}
			}
		}
		free(buckets);
		free(bucket_head);
	}

	void print(float * arr, int n, char * str){
		printf("%s: \n", str);
		int i;
		for(i=0; i<n; i++){
			printf("%f\n", arr[i]);
		}
		printf("\n");
	}
	#define N 100
	#define MAX 1000
	#define ARC4RANDOM_MAX      0x100000000
	int main(){
		float arr[N];
		int n = N;
		int m = 50;
		int i;
		/**
		 * 产生 N 个随机数[0, MAX)
		 */
		for(i=0; i<n; i++){
			arr[i] = ((float)arc4random() / ARC4RANDOM_MAX) * MAX;
		}
		print(arr,n, "Original");
		bucket_sort(arr, n, 0, MAX);
		print(arr,n, "Sorted");
		return 0;
	}


# Radix Sort 基数排序
- 原理: 从最高位或者最低位开始比较，比较位时，一般采用计数排序(也可以是其它的稳定排序)，此时时间复杂度是O(m * n), m 为排序数字的最大位数, 所以时间复杂度被认为是O(n) 空间复杂度:O(n).
- 方法: 比较位时，可以从高位开始比MSD(Most Significant Digit), 也可以从最低位开始比较LSD(Least Significant Digit). MSD 排序比LSD 开销大，因为MSD 需要分堆并对每个堆单独排序，而LSD 不需要维护堆
- 应用: 只能比较整数, 但不限制整数大小.

代码实现：

	void radix_sort(int *arr, int n){
		int i,j, m=0;
		int mask;
		int c[16] = {0};//counter
		int sorted_arr[n];//空间主要消耗在这里

		//get max length of element bits
		for(i=0; i<n; i++){
			while( (arr[i] >> m) > 0){
				m++;
			};
		}

		//counting sort
		for(j=0; j<m; j++){
			mask = 1 << j;
			//O(n)
			for(i=0; i<n; i++){
				c[arr[i] & mask]++;
			}
			for(i=0; i<15; i++){
				c[i+1] += c[i];
			}
			//O(n)
			for(i=n-1; i>=0; i--){
				sorted_arr[--c[arr[i]]] = arr[i];
			}
			for(i=n-1; i>=0; i--){
				arr[i] = sorted_arr[i];
			}
		}
	}

# Reference
- [线性排序]
- [维基sort]
- [c math func]
- [Fibonacci] 李尚志的《线性代数》（数学专业）的 2.8 节有提及。广义 Fibonacci 数列是一个二维的线性空间。

[Fibonacci]: http://www.matrix67.com/blog/archives/6063
[线性排序]: https://www.byvoid.com/blog/sort-radix
[维基sort]: http://zh.wikipedia.org/wiki/%E6%8E%92%E5%BA%8F%E7%AE%97%E6%B3%95
[c math func]: http://en.wikipedia.org/wiki/C_mathematical_functions
