---
title: BFPRT 算法
date: 2018-09-26
---
# Topk 算法之BFPRT算法
基于最大/小堆的TopK 算法复杂度为 $O(n\log n)$

其实还有O(n)的算法 —— BFPRT 基于减治法，采用类似二分法的快排分区减低复杂度。

## 利用分区减治法求topK
1. 选取主元比如arr[0]，
2. 并利用快排分区基于主元，将arr 分成左右，主元的新位置为i
3. 递归求解
    1. 如果`i=k-1` 则左边刚好是topk
    2. 如果`i>k-1` 则继续在左边寻找topk
    3. 如果`i<k-1` 则继续在右边寻找top(k-1-i)

最坏时间复杂度在: `n+（n-1）+...+k=O(n^2)`
最好时间复杂度在: `n`
平均时间复杂度在: `n+n/2+n/4=2n=O(n)`

## BFPRT 算法(Median of medians)
为了避免主元分割不均衡，造成上述算法出现最坏的时间复杂度。
BFPRT 算法做了改良。尽可能选择靠近中点的主元。俗称 Median of medians 算法
1. 选取靠近中点的主元`pivot`：
    1. n个元素划分为5个每组，每组5个元素
    2. 每组插入排序后取中位数： $25*n/5=5n$ 
    3. 调用BFPRT 求所有中位数的中位数, 作为主元pivot: $T(n/5)$
2. 以主元pivot为界，分左右区`partition()`. 小于主元的确定有1/10+2/10=3/10, 大于主元的确定有3/10, 不确定的有4/10: $n$
3. 根据主元位置i与K比较。递归调用BFPRT
    1. 如果`i=k-1` 则左边刚好是topk
    2. 如果`i>k-1` 则继续在左边寻找topk, 最坏情况是: $T(7n/10)$
    3. 如果`i<k-1` 则继续在右边寻找top(k-1-i), 最坏情况是: $T(7n/10)$

### 时间复杂度
$$ T(n)<=c*n+T(n/5)+T(7n/10) $$
$$ T(n)<=c*n+T(.2n)+T(.7n) $$


利用归纳树法证明:
$ T(n) < cn*(1+.9+.9^2+.9^3+...) = cn*1/(1-0.9) = 10cn$

                   cn               1cn
               /        \
            .2cn       .7cn        .9cn
            /  \      /    \
    T(.2^2n) 2T(.2*.7n) T(.7^2n)  (.2+.7)^2cn
             ....                (.2+0.7)^3cn

利用假设法证明:
当n<N时, 存在一个t, 使得T(n) 的上界是：$T(n)<=tn$

$T(n/5)<=5t/n$
$$ T(n) <= c*n+t*.2n+ t*.7n $$
$$ T(n) <= tn + (c-0.1t)*n $$

我们取t>=10c, 得到: $T(n)<=tn$, 
当n 取任意一个N 时，都可以得到上界$T(n)<=10cn$, 得证！

为什么选择5? 因为如果选择3,7,9,11 复杂度反而更高。


## BFPRT 算法实现
```python
def bfprt(arr, n, k):
    pivotIndex = getPivotIndex(arr, n)
    pivotIndex = partition(arr, n, pivotIndex)
    if pivotIndex+1 == k:
        return k-1
    elif pivotIndex+1<=k:
        return pivotIndex+bfprt(arr[pivotIndex+1:], n-pivotIndex-1, k-pivotIndex-1)
    elif pivotIndex+1>=k:
        return pivotIndex+bfprt(arr[:pivotIndex], pivotIndex, k)

def partition(arr, n, pivotIndex):
    pivot = arr[pivotIndex]
    arr[pivotIndex] = arr[0]
    i=0; j=n-1
    while i<j:
        while i<j and arr[j]<=pivot:
            j-=1
        arr[i] = arr[j]; # after j is null
        while i<j and arr[i]>=pivot:
            i+=1
        arr[j] = arr[i]; # i is null
    arr[i] = pivot
    return i
            
    
def getPivotIndex(arr, n):
    if n<10:
        return 0
    for j in range(7, n, 5):
        t = arr[j]
        p = j
        for i in range(j-5,0, -5):
            if arr[i] < t:
                arr[i+5] = arr[i]
                p = i
            else:
                break
        arr[p] = t
    return n//5//2*5 -3
    
import numpy
# numpy.random.randint(0,20,11)
arr = numpy.array([14,  0, 4, 13,  5, 17,  19,  1, 16, 10, 11])
print('topKIndex', bfprt(arr, 11, 3))
print(arr[:3])
```