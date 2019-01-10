---
title: 求数列中和最大的连续子序列的和
date: 2019-01-09
---
# 求数列中和最大的连续子序列的和
> Find max sum of consecutive sequence for an array.

## 问题
给定一个随机的数字序列，要求找出其中和最大的连续子集的和，比如`{6,-2,-3,5,9,-8,6}`，和最大的连续子集应该是 `sum(6,-2,-3,5,9)=15`

## 方案
我们定义以个数列是：

    a0,a1,a2,....,ai,....an

再定义：

    F(i) 代表前i个元素中，以ai结尾的连续序列最大和(必须包含ai, 否者为0)

我们就把问题转化为 查找F(i)的最大值:

    max(F(0),F(1),....,F(n))

于是:

    如果F(i-1)=0 
        F(i) = ai  //if ai>0  (以ai 结尾的子序列的最大和)
        F(i) = 0   //if ai<=0 (丢弃含有ai的子序列)
    如果F(i-1)>0 
        F(i) = ai+F(i)    //if ai+F(i)>0  (以ai 结尾的子序列的最大和)
        F(i) = 0          //if ai+F(i)<=0 (丢弃含有ai的子序列)

## 编码实现
1. F(i) 用sum(partial_sub) 来求解, 它是以ai 为结尾的最大连续子序列的和
2. Max(F) 用sum(max_sub) 求解，max_sub 就是我们要找的最大连续子序列

具体代码(python):

    arr = [6,-2,-3,5,9,-8,6]

    # 局部连续和序列
    partial_sub = []
    sum_partial_sub = 0

    # 最大连续和序列
    max_sub = []
    sum_max_sub = 0
    for v in arr:
        partial_sub.append(v)
        sum_partial_sub += v

        if sum_partial_sub <= 0:
            partial_sub = []
            sum_partial_sub = 0

        if sum_max_sub < sum_partial_sub :
            sum_max_sub = sum_partial_sub
            max_sub = partial_sub[:] # copy 而不是引用

        print(partial_sub, sum(partial_sub))

    print("\nsum(%s)=%d" % (max_sub, sum_max_sub))

结果：

    [6] 6
    [6, -2] 4
    [6, -2, -3] 1
    [6, -2, -3, 5] 6
    [6, -2, -3, 5, 9] 15
    [6, -2, -3, 5, 9, -8] 7
    [6, -2, -3, 5, 9, -8, 6] 13

    sum([6, -2, -3, 5, 9])=15

更简洁易读点:

    arr = [6,-2,-3,5,9,-8,6]

    # 局部连续和序列
    partial_sub = []

    # 最大连续和序列
    max_sub = []
    for v in arr:
        partial_sub.append(v)
        if sum(partial_sub) <= 0:
            partial_sub = []
        if sum(max_sub) < sum(partial_sub) :
            max_sub = partial_sub[:] # copy 而不是引用

    print(max_sub, sum(max_sub))