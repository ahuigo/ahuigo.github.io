---
title: 查找数组中的中值
date: 2019-02-14
---
# 查找数组中的中值
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


Time Complex:  T(n)=T(n/b)+O(n) = O(n)