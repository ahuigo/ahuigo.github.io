---
title: 查找数组中的第K大的值
date: 2019-02-14
---
# 查找数组中的第K大的值

## 通过最大最小堆
时间复杂度 : $O(N \log k)$
空间复杂度 : $O(k)$，用于存储堆元素。

## QuickSelect(快速选择)
This is a question about find k'th number in an array.

    def find_kth(arr, k):
        p = 0
        q = len(arr)
        i = partition_arr(arr, 0) # partion array with arr[0]
        if i+1 == k:
            return arr[k]
        elif i+1<k:
            return find_kth(a[i+1:], k-i-1)
        else:
            return find_kth(a[:i], k)

Time Complex:  
1. lucky: T(n,k)=T(n/2)+O(n) = O(n)
1. worse case: T(n)=T(n-1)+O(n) = O(n^2)

https://www.geeksforgeeks.org/kth-smallestlargest-element-unsorted-array-set-2-expected-linear-time/


## 中位数法
https://www.geeksforgeeks.org/kth-smallestlargest-element-unsorted-array-set-3-worst-case-linear-time/
